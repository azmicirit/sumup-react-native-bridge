import Foundation
import SumUpSDK

@objc(SumupReactNativeBridge)
class SumupReactNativeBridge: NSObject {
    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc func setupAPIKey(_ apikey: String,
                           resolve: RCTPromiseResolveBlock,
                           reject: RCTPromiseRejectBlock
    ) -> Void {
        let setAPIKey = SumUpSDK.setup(withAPIKey: apikey)
        resolve(true)
    }
    
    @objc func logout(_ resolve: @escaping RCTPromiseResolveBlock,
                      reject:@escaping RCTPromiseRejectBlock
    ) -> Void {
        SumUpSDK.logout{(success: Bool, error: Error?) in
            resolve(success)
        }
    }
    
    @objc func login(_ token: String,
                     resolve: @escaping RCTPromiseResolveBlock,
                     reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        if (SumUpSDK.isLoggedIn) {
            return resolve(["success": true])
        } else if (token.count > 0) {
            SumUpSDK.login(withToken: token) { (success: Bool, error: Error?) in
                if (success) {
                    return resolve(["success": true])
                } else {
                    if let safeError = error as NSError? {
                        return resolve(["success": false,
                                        "code": safeError.code,
                                        "message": safeError.localizedDescription,
                                        "invalidToken": (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.invalidAccessToken.rawValue || safeError.code == SumUpSDKError.accountGeneral.rawValue)])
                    } else {
                        return resolve(["success": false,
                                        "code": 500,
                                        "message": "Fatal Error"])
                    }
                }
            }
        } else {
            DispatchQueue.main.sync {
                guard let rootView = UIApplication.shared.keyWindow?.rootViewController else {
                    return resolve(["success": false, "code": 404, "message": "RootView cannot be null"])
                }
                
                SumUpSDK.presentLogin(from: rootView, animated: true) { (success: Bool, error: Error?) in
                    if (success) {
                        resolve(["success": true])
                    } else {
                        let nsError = error as NSError?
                        resolve(["success": false, "code": nsError?.code ?? nil, "message": nsError?.localizedDescription ?? nil])
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
                return resolve(["success": false, "code": 404, "message": "RootView cannot be null"])
            }
            
            rootView.dismiss(animated: false)
            
            SumUpSDK.presentCheckoutPreferences(from: rootView, animated: true) { (success: Bool, error: Error?) in
                if let safeError = error as NSError? {
                    return resolve(["success": false,
                                    "code": safeError.code,
                                    "message": safeError.localizedDescription,
                                    "invalidToken": (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.invalidAccessToken.rawValue || safeError.code == SumUpSDKError.accountGeneral.rawValue),
                                    "notLoggedIn": (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.accountNotLoggedIn.rawValue)])
                } else {
                    resolve(["success": true])
                }
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
        
        let checkOutRequest = CheckoutRequest(total: total, title: title, currencyCode: currency, paymentOptions: [.cardReader, .mobilePayment])
        if (skip == true) {
            checkOutRequest.skipScreenOptions = .success
        }
        if (!foreignTrID.isEmpty) {
            checkOutRequest.foreignTransactionID = foreignTrID
        }
        DispatchQueue.main.sync {
            guard let rootView = UIApplication.shared.keyWindow?.rootViewController else {
                return resolve(["success": false, "code": 404, "message": "RootView cannot be null"])
            }
            
            rootView.dismiss(animated: false)
            
            SumUpSDK.checkout(with: checkOutRequest, from: rootView) { (result: CheckoutResult?, error: Error?) in
                if let safeError = error as NSError? {
                    return resolve(["success": false,
                                    "code": safeError.code,
                                    "message": safeError.localizedDescription,
                                    "invalidToken": (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.invalidAccessToken.rawValue || safeError.code == SumUpSDKError.accountGeneral.rawValue),
                                    "notLoggedIn": (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.accountNotLoggedIn.rawValue)])
                }
                
                guard let safeResult = result else {
                    return resolve(["success": false, "code": 404, "message": "No Result"])
                }
                
                return resolve(["success": safeResult.success, "transactionCode": safeResult.transactionCode])
            }
        }
    }
}
