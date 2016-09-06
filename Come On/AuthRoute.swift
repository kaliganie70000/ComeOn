//
//  LoginRoute.swift
//  Come On
//
//  Created by Julien Colin on 06/10/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import Alamofire

enum AuthRoute: URLRequestConvertible {
  
  case Create([String: AnyObject])
  case Read()
  case Delete()
  
  var method: Alamofire.Method {
    switch self {
    case .Create:
      return .POST
    case .Read:
      return .GET
    case .Delete:
      return .DELETE
    }
  }
  
  var path: String {
      return "/auth"
  }
  
  // MARK: URLRequestConvertible
  
  var URLRequest: NSMutableURLRequest {
    
    switch self {
    case .Create(let parameters):
      let mutableURLRequest = ComeOnAPI.sharedInstance.getMutableUrlRequest(path, logged: true)
      mutableURLRequest.HTTPMethod = method.rawValue
      return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
    default:
      let mutableURLRequest = ComeOnAPI.sharedInstance.getMutableUrlRequest(path)
      mutableURLRequest.HTTPMethod = method.rawValue
      return mutableURLRequest
    }
  }
  
}