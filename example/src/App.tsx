import React, { useState, useEffect } from 'react';
import {
  View,
  SafeAreaView,
  NativeModules,
  Alert,
  Text,
  TouchableHighlight,
  Platform,
} from 'react-native';
import SumupSDK from '../../src/index';

const App = () => {
  const [token, setToken] = useState('');

  const apiKey = '<SumUp Affiliate Key>';
  const accessToken = '<SumUp Access Token>';
  const refreshToken = '<SumUp Refresh Token>';

  useEffect(() => {
    (async () => {
      if (Platform.OS === 'ios') {
        const result = await SumupSDK.setupAPIKey(apiKey);
        console.log('SETUP API KEY', result);
      }
    })();
  }, []);

  const uuidv4 = () => {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
      /[xy]/g,
      function (c) {
        const r = (Math.random() * 16) | 0,
          v = c == 'x' ? r : (r & 0x3) | 0x8;
        return v.toString(16);
      }
    );
  };

  const isLoggedInBtnClicked = async () => {
    const result = await SumupSDK.isLoggedIn();
    Alert.alert('Is Logged In?', result.toString());
  };

  const logoutBtnClicked = async () => {
    await SumupSDK.logout();
    setToken('');
  };

  const loginBtnClicked = async () => {
    let result = null;
    if (Platform.OS === 'ios') {
      result = await SumupSDK.login(accessToken);
    } else {
      result = await SumupSDK.login(apiKey, accessToken);
    }
    console.log(Platform.OS, result?.success, result);
  };

  const preferences = async () => {
    const result = await SumupSDK.preferences();
    console.log(result);
  };

  const checkout = async () => {
    const payment = await SumupSDK.payment({
      title: 'Test Payment',
      totalAmount: 1.75,
      currencyCode: 'GBP',
      skipScreenOptions: false,
      foreignID: uuidv4(),
    });
    console.log(payment.success);
  };

  return (
    <SafeAreaView>
      <View
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#fff',
        }}
      >
        <Text>{token ? token : '-'}</Text>
        <TouchableHighlight onPress={isLoggedInBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Is Logged In?</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={loginBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Login</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={logoutBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Logout</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={() => setToken(accessToken)}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Get Access Token</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={() => setToken(refreshToken)}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Refresh Token</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={preferences}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Preferences</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={checkout}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Checkout</Text>
          </View>
        </TouchableHighlight>
      </View>
    </SafeAreaView>
  );
};

export default App;
