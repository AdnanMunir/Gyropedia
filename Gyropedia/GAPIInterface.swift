//
//  OLAPIInterface.swift
//  Oneload
//
//  Created by Adnan Munir on 7/19/17.
//  Copyright © 2017 OneLoad. All rights reserved.
//

import Alamofire
import SwiftyJSON

class OLAPIInterface: NSObject {
    
//    var requestManager = AFHTTPRequestOperationManager()
    var sessionManager = Alamofire.SessionManager()
    static var manager : SessionManager = {
        
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        
        headers["Content-Type"] = "application/json"
        headers["Channel_Id"] = "MOBILE"
        headers["subChannel"] = "IOS"
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            "https://10.10.6.23:8443/oneload/rest/": .pinCertificates(
//                certificates: ServerTrustPolicy.certificates(),
//                validateCertificateChain: false,
//                validateHost: false
//            ),
            "devserver":.disableEvaluation,
            "adeelserver":.disableEvaluation
        ]
        
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.httpAdditionalHeaders = headers
        
        let manager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
    
    static let sharedInstance = OLAPIInterface()
    
    override init() {
        super.init()
        //setUpAPIConfigurations()
    }
    
    fileprivate func setUpAPIConfigurations() {
        
    }
    
    func postRequestWith(path:String,parameters:[String:Any],completionBlock: @escaping (APICompletionHandler)) {
        
//        var headers = Alamofire.SessionManager.defaultHTTPHeaders
//
//        headers["Content-Type"] = "application/json"
//        headers["Channel_Id"] = "MOBILE"
//        headers["subChannel"] = "IOS"
        
        OLAPIInterface.manager.request(CONSTANTS.BASE_URL + path, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
           let res = OLResponse()
            switch response.result {
            case .success(let value):
                let swiftyJsonVar = JSON(response.result.value!)// crash if response = nil in case server does not reponds
                
                res.statusCode = swiftyJsonVar["statusCode"].stringValue
                res.statusDescription = swiftyJsonVar["statusDescription"].stringValue

                completionBlock(res, ["":""], [],swiftyJsonVar)
                break
            case .failure(let error):
                res.statusDescription = "There is some error.Please try again later."
                completionBlock(res, ["":""], [],nil)
                break
            }
        }
    }
    
}
