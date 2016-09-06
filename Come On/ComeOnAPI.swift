//
//  ComeOnAPI.swift
//  Come On
//
//  Created by Julien Colin on 05/10/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import Alamofire

protocol NetworkErrorDelegate {
    func handleError(code: Int?) -> Void
}

class ComeOnNetworkError: NetworkErrorDelegate {
    func handleError(code: Int?) {
        if let code = code {
            switch code {
            case 401:
                print("Deconnected")
            default:
                print("Code \(code)")
            }
        }
    }
}

class ComeOnAPI {
    static let sharedInstance = ComeOnAPI()
    
    let baseUrl: String!
    var delegate: NetworkErrorDelegate?
    
    var datas = APIDatas()
    
    var auth: Auth?
    
    init() {
        baseUrl = "http://api.comeon.io/1.0"
    }
    
    func disconnectAndReset() {
        auth = nil
        datas = APIDatas()
    }
    
    func saveCreditentials(auth: Auth) {
        self.auth = auth
    }
    
    func getMutableUrlRequest(path: String, logged: Bool = true) -> NSMutableURLRequest {
        let URL = NSURL(string: self.baseUrl)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        
        if let auth = auth, apiKey = auth.apiKey where logged {
            mutableURLRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        }
        return mutableURLRequest
    }
    
    func performRequest(request: URLRequestConvertible,
        viewControllerToPresent: UIViewController? = nil,
        manualErrorHandling: Bool = false,
        before: (() -> Void)! = nil,
        success: ((json: AnyObject!, httpCode: Int) -> Void)! = nil,
        failure: ((json: AnyObject!, httpCode: Int?) -> Void)! = nil,
        after: (() -> Void)! = nil) {
            before?()
            Alamofire.request(request).responseJSON { response in
                self.logRequest(request, response: response)
                if response.result.isFailure || !(200..<300).contains(response.response!.statusCode) {
                    if !manualErrorHandling {
                        self.delegate?.handleError(response.response?.statusCode)
                    }
                    failure?(json: response.result.value, httpCode: response.response?.statusCode)
                } else {
                    success?(json: response.result.value, httpCode: response.response!.statusCode)
                }
                after?()
            }
    }
    
    func performFormDataRequest(request: URLRequestConvertible,
        dataImage: NSData,
        viewControllerToPresent: UIViewController? = nil,
        manualErrorHandling: Bool = false,
        before: (() -> Void)! = nil,
        success: ((json: AnyObject!, httpCode: Int) -> Void)! = nil,
        failure: ((json: AnyObject!, httpCode: Int?) -> Void)! = nil,
        after: (() -> Void)! = nil) {
        
        before?()
        
        print("perform formData avec url : \(request.URLRequest)")
        
        Alamofire.upload(
            .POST,
            request.URLRequest,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: dataImage, name: "image")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        print("------- SUCCESS!!")
                        debugPrint(response)
                    }
                case .Failure(let encodingError):
                    print("------- ERROR!!")
                    print(encodingError)
                }
                after?()
            }
            
        )
        
    }
    
    func logRequest(request: URLRequestConvertible, response: Response<AnyObject, NSError>) {
        print("============================")
        print("REQUEST")
        print("[\(request.URLRequest.HTTPMethod)] \(request.URLRequest.URL!)")
        if request.URLRequest.HTTPBody != nil {
            print("[Body] \(NSString(data: request.URLRequest.HTTPBody!, encoding: NSUTF8StringEncoding)!)")
        }
        if let allHTTPHeaderFields = request.URLRequest.allHTTPHeaderFields {
            print("[Headers] \(allHTTPHeaderFields)")
        }
        print("RESPONSE")
        debugPrint(response)
        print("============================")
    }
}

class APIDatas {
    
    var groups: [ContactsGroup] = []
    var contacts = Contact()
    
    var contactGroupList: [ContactsGroup]? { // Liste des groupes contacts partagée entre les différentes pages
        didSet {
            if let contactGroupList = contactGroupList {
                contactGroupListBool = [Bool](count: contactGroupList.count, repeatedValue: false)
                contactGroupListBool![contactGroupListBool!.count - 1] = true
            } else {
                contactGroupListBool = nil
            }
        }
    }
    var contactGroupListBool: [Bool]?
}
