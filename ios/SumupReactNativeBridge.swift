import Foundation
import SumUpSDK

@objc(SumupReactNativeBridge)
class SumupReactNativeBridge: NSObject {
  func generateJSONResponse(parms: [String:Any]) -> String {
    if let jsonData = try? JSONSerialization.data(withJSONObject: parms, options: []) {
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
        return jsonString
      } else {
        return "error"
      }
    } else {
      return "error"
    }
  }
  
  @objc static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  @objc func setupAPIKey(_ apikey: String,
                         resolve: RCTPromiseResolveBlock,
                         reject: RCTPromiseRejectBlock
  ) -> Void {
    let setAPIKey = SumUpSDK.setup(withAPIKey: apikey)
    if (setAPIKey) {
      resolve(self.generateJSONResponse(parms: ["success": true]) )
    } else {
      let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Could not setup API KEY"])
      reject("ERROR_API_KEY", "Could not setup this API KEY", error)
    }
  }
  
  @objc func logout(_ resolve: @escaping RCTPromiseResolveBlock,
                    reject:@escaping RCTPromiseRejectBlock
  ) -> Void {
    SumUpSDK.logout{(success: Bool, error: Error?) in
      if (success) {
        resolve(true)
      } else {
        let newerror = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: String(describing: error)])
        reject("ERROR_LOGOUT", String(describing: error), newerror)
      }
    }
  }
  
  @objc func login(_ token: String,
                   resolve: @escaping RCTPromiseResolveBlock,
                   reject: @escaping RCTPromiseRejectBlock
  ) -> Void {
    if (SumUpSDK.isLoggedIn) {
      resolve(self.generateJSONResponse(parms: ["success": true, "token": token]))
    } else if (token.count > 0) {
      SumUpSDK.login(withToken: token) { (success: Bool, error: Error?) in
        if (success) {
          resolve(self.generateJSONResponse(parms: ["success": true, "token": token]))
        } else {
          let newerror = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: String(describing: error)])
          reject("ERROR_LOGIN", String(describing: error), newerror)
        }
      }
    } else {
      DispatchQueue.main.sync {
        guard let rootView = UIApplication.shared.keyWindow?.rootViewController else {
          return reject("ERROR_LOGIN", "Could not found RootViewController", nil)
        }
        
        SumUpSDK.presentLogin(from: rootView, animated: true) { (success: Bool, error: Error?) in
          guard error == nil else {
            let newerror = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey:String(describing: error)])
            return  reject("ERROR_LOGIN", String(describing: error), newerror)
          }
          if (success) {
            resolve(self.generateJSONResponse(parms: ["success": true]))
          } else {
            let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey:String(describing: error)])
            reject("ERROR_LOGIN", String(describing: error), error)
          }
        }
      }
    }
  }
  
  @objc func isLoggedIn(_ resolve: @escaping RCTPromiseResolveBlock,
                        reject: @escaping RCTPromiseRejectBlock
  ) ->Void {
    resolve(SumUpSDK.isLoggedIn);
  }
  
  @objc func preferences(_ resolve: @escaping RCTPromiseResolveBlock,
                         reject: @escaping RCTPromiseRejectBlock
  ) ->Void {
    DispatchQueue.main.sync {
      guard let rootView = UIApplication.shared.keyWindow?.rootViewController else {
        return reject("ERROR_PREFERENCES", "Could not found RootViewController", nil)
      }
      
      SumUpSDK.presentCheckoutPreferences(from: rootView, animated: true) { (success: Bool, error: Error?) in
        if let safeError = error as NSError? {
          if (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.accountNotLoggedIn.rawValue) {
            reject("ERROR_PREFERENCES", "not logged in: \(safeError.localizedDescription)", nil)
          } else if (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.checkoutInProgress.rawValue) {
            reject("ERROR_PREFERENCES", "checkout is in progress: \(safeError.localizedDescription)", nil)
          } else {
            reject("ERROR_PREFERENCES", "general error: \(safeError.localizedDescription)", nil)
          }
          return
        }
        
        resolve(self.generateJSONResponse(parms: ["success": true]))
      }
    }
  }
  
  @objc func payment(_ request: [String: Any],
                     resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock
  ) -> Void {
    let title: String = request["title"] as? String != nil ? request["title"] as! String : ""
    let total: NSDecimalNumber = NSDecimalNumber(decimal: NSNumber(value: request["totalAmount"] != nil ? request["totalAmount"] as! Double : 0).decimalValue)
    let foreignTrID: String = request["foreignID"] as? String != nil ? request["foreignID"] as! String : ""
    let skip: Bool = request["skipScreenOptions"] as? Bool != nil ? request["skipScreenOptions"] as! Bool : false
    guard let currency: String = request["currencyCode"] as? String != nil ? request["currencyCode"] as! String : SumUpSDK.currentMerchant?.currencyCode else { return }
    print("hello", total, currency, skip, foreignTrID)
    let checkOutRequest = CheckoutRequest(total: total, title: title, currencyCode: currency, paymentOptions: [.cardReader, .mobilePayment])
    if (skip == true) {
      checkOutRequest.skipScreenOptions = .success
    }
    if (!foreignTrID.isEmpty) {
      checkOutRequest.foreignTransactionID = foreignTrID
    }
    DispatchQueue.main.sync {
      guard let rootView = UIApplication.shared.keyWindow?.rootViewController else {
        return reject("ERROR_CHECKOUT", "Could not found RootViewController", nil)
      }
      SumUpSDK.checkout(with: checkOutRequest, from: rootView) { (result: CheckoutResult?, error: Error?) in
        if let safeError = error as NSError? {
          if (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.accountNotLoggedIn.rawValue) {
            reject("ERROR_PAYMENT", "not logged in: \(safeError.localizedDescription)", nil)
          } else {
            reject("ERROR_PAYMENT", "error during checkout: \(safeError.localizedDescription)", nil)
          }
          return
        }
        
        
        guard let safeResult = result else {
          reject("E_COUNT", "no error and no result should not happen: ", NSError(domain: "", code: 200, userInfo: nil))
          return
        }
        
        print("transactionCode==\(String(describing: safeResult.transactionCode))")
        var resultObject = [String:Any]()
        if safeResult.success {
          print("success")
          resultObject["success"] = true
          guard let transCode = safeResult.transactionCode else {
            return
          }
          resultObject["transactionCode"] = transCode
          if let info = safeResult.additionalInfo,
             let foreignTransId = info["foreign_transaction_id"] as? String,
             let amount = info["amount"] as? NSDecimalNumber {
            resultObject["foreignTransactionID"] = foreignTransId
            resultObject["amount"] = amount
          }
          resolve(self.generateJSONResponse(parms: resultObject))
        } else {
          reject("ERROR_CHECKOUT", "Transaction arborted", NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Error by PaymentCheckout"]))
        }
      }
    }
  }
}
