//
//  EventRoute.swift
//  Come On
//
//  Created by Antoine roy on 22/01/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import Foundation
import Alamofire

enum EventRoute: URLRequestConvertible {

    case Create([String: AnyObject])
    case CreateInvitationForUser(eventId: Int, userId: Int)
    case CreateMap(eventId: Int, myUserId: Int, lat: CGFloat, long: CGFloat, message: String?)

    case Read()
    case ReadEvents(page: Int)
    case ReadEvent(id: Int)
    case ReadMap(eventId: Int)

    case AcceptInvitation(id: Int)
    case RejectInvitation(id: Int)
    case ListParticipant(id: Int)
    
    case GetMediasEvent(id: Int)
    //case SetMediaEvent(id: Int, param: NSMutableData, contentType: String)
    case SetMediaEvent(id: Int)
    case SendMessage(id: Int, message: String?)
    case GetMessages(id: Int)
    
    case UpdateEvent(id: Int, params: [String: AnyObject])

    var method: Alamofire.Method {
        switch self {
        case .Create, .CreateInvitationForUser, .CreateMap, .AcceptInvitation, .SetMediaEvent, SendMessage:
            return .POST
        case .Read, .ReadEvents, .ReadMap, .ListParticipant, .GetMediasEvent, .ReadEvent, .GetMessages:
            return .GET
        case .RejectInvitation:
            return .DELETE
        case .UpdateEvent:
            return .PUT
        }
    }

    var path: String {
        switch self {
        case .Create:
            return "/event"
        case .CreateInvitationForUser(let eventId, let userId):
            return "/event/\(eventId)/invitation/\(userId)"
        case .CreateMap(let eventId, let myUserId, _, _, _):
            return "/event/\(eventId)/map/\(myUserId)"

        case .ReadEvents(_):
            return "/event/"
        case .ReadEvent(let id):
            return "/event/\(id)/"
            
        case .ReadMap(let eventId):
            return "/event/\(eventId)/map/"
            
        case .AcceptInvitation(let id):
            return "/event/\(id)/participant/"
        case .RejectInvitation(let id):
            return "/event/\(id)/participant/"
        case .ListParticipant(let id):
            return "/event/\(id)/participant/"
        
        case .GetMediasEvent(let id):
            return "/event/\(id)/media/"
        case .SetMediaEvent(let id):
            return "/event/\(id)/media/"
            
        case .UpdateEvent(let id, _):
            return "/event/\(id)/"
            
        case .SendMessage(let id, _):
            return "/event/\(id)/messages/"
        case .GetMessages(let id):
            return "/event/\(id)/messages/"
        default:
            return ""
        }
    }


    // MARK: URLRequestConvertible

    var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = ComeOnAPI.sharedInstance.getMutableUrlRequest(path)
        mutableURLRequest.HTTPMethod = method.rawValue

        switch self {
        case .Create(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .CreateMap(_, _, let lat, let long, let message):
            var params: [String: AnyObject] = ["latitude": lat,
                                               "longitude": long]
            if let m = message { params["message"] = m }
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
        case .ReadEvents(let page):
            //let params: [String: AnyObject] = ["page": page]
            print("param events!")
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        case .UpdateEvent(_, let params):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
        case .SendMessage(_, let message):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["message": message!]).0
        default:
            return mutableURLRequest
        }
    }

}
