package com.sumupreactnativebridge;

import androidx.annotation.NonNull;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;

import com.sumup.merchant.reader.api.SumUpAPI;
import com.sumup.merchant.reader.api.SumUpLogin;
import com.sumup.merchant.reader.api.SumUpState;
import com.sumup.merchant.reader.api.SumUpPayment;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.UUID;

@ReactModule(name = SumupReactNativeBridgeModule.NAME)
public class SumupReactNativeBridgeModule extends ReactContextBaseJavaModule {
    public static final String NAME = "SumupReactNativeBridge";

    private static final int REQUEST_CODE_LOGIN = 1;
    private static final int REQUEST_CODE_PAYMENT = 2;
    private static final int REQUEST_CODE_PAYMENT_SETTINGS = 3;
    private static final int TRANSACTION_SUCCESSFUL = 1;
  
    private Promise sumUpPromise;

    public SumupReactNativeBridgeModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(mActivityEventListener);
        SumUpState.init(reactContext);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void login(String affiliateKey, String token, Promise promise) {
      if (SumUpAPI.isLoggedIn()) {
        WritableMap map = Arguments.createMap();
        map.putBoolean("success", true);
        promise.resolve(map);
      } else {
        sumUpPromise = promise;
        SumUpLogin sumupLogin = SumUpLogin.builder(affiliateKey).accessToken(token).build();
        SumUpAPI.openLoginActivity(getCurrentActivity(), sumupLogin, REQUEST_CODE_LOGIN);
      }
    }
  
    @ReactMethod
    public void logout(Promise promise) {
      sumUpPromise = promise;
      SumUpAPI.logout();
      sumUpPromise.resolve(true);
    }
  
    @ReactMethod
    public void isLoggedIn(Promise promise) {
      promise.resolve(SumUpAPI.isLoggedIn());
    }
  
    @ReactMethod
    public void preferences(Promise promise) {
      sumUpPromise = promise;
      SumUpAPI.openPaymentSettingsActivity(getCurrentActivity(), REQUEST_CODE_PAYMENT_SETTINGS);
    }
  
    @ReactMethod
    public void payment(ReadableMap request, Promise promise) {
      sumUpPromise = promise;
      try {
        String foreignTransactionId = "";
        if (request.getString("foreignID") != null) {
          foreignTransactionId = request.getString("foreignID");
        }
        SumUpPayment.Currency currencyCode = SumUpPayment.Currency.valueOf(request.getString("currencyCode"));
        SumUpPayment payment;
        if (request.getBoolean("skipScreenOptions") == true) {
          payment = SumUpPayment.builder()
              .total(BigDecimal.valueOf(request.getDouble("totalAmount")).setScale(2, RoundingMode.HALF_EVEN))
              .currency(currencyCode).title(request.getString("title")).foreignTransactionId(foreignTransactionId)
              .skipSuccessScreen().build();
        } else {
          payment = SumUpPayment.builder()
              .total(BigDecimal.valueOf(request.getDouble("totalAmount")).setScale(2, RoundingMode.HALF_EVEN))
              .currency(currencyCode).title(request.getString("title")).foreignTransactionId(foreignTransactionId)
              .build();
        }
  
        SumUpAPI.checkout(getCurrentActivity(), payment, REQUEST_CODE_PAYMENT);
      } catch (Exception ex) {
        sumUpPromise.reject(ex);
        sumUpPromise = null;
      }
    }
  
    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
      @Override
      public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
          case REQUEST_CODE_LOGIN:
            if (data != null) {
              Bundle extra = data.getExtras();
              if (extra.getInt(SumUpAPI.Response.RESULT_CODE) == REQUEST_CODE_LOGIN) {
                WritableMap map = Arguments.createMap();
                map.putBoolean("success", true);
                sumUpPromise.resolve(map);
              } else {
                sumUpPromise.reject(extra.getString(SumUpAPI.Response.RESULT_CODE),
                    extra.getString(SumUpAPI.Response.MESSAGE));
              }
            }
            break;
          case REQUEST_CODE_PAYMENT:
            if (data != null) {
              Bundle extra = data.getExtras();
              if (sumUpPromise != null) {
                if (extra.getInt(SumUpAPI.Response.RESULT_CODE) == TRANSACTION_SUCCESSFUL) {
                  WritableMap map = Arguments.createMap();
                  map.putBoolean("success", true);
                  map.putString("transactionCode", extra.getString(SumUpAPI.Response.TX_CODE));
                  sumUpPromise.resolve(map);
                } else
                  sumUpPromise.reject(extra.getString(SumUpAPI.Response.RESULT_CODE),
                      extra.getString(SumUpAPI.Response.MESSAGE));
              }
            }
            break;
          case REQUEST_CODE_PAYMENT_SETTINGS:
            WritableMap map = Arguments.createMap();
            map.putBoolean("success", true);
            sumUpPromise.resolve(map);
            break;
          default:
            break;
        }
      }
    };
}
