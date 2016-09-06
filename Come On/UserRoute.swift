//
//  UserRoute.swift
//  Come On
//
//  Created by Antoine roy on 24/11/2015.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import Foundation
import Alamofire

enum UserRoute: URLRequestConvertible {
    
    case Create([String: AnyObject])
    case CreateInvitation(userId: Int, invitedUserId: Int)
    case CreateInvitationAccept(meId: Int, userId: Int)
    case CreateGroup(meId: Int, name: String)
    case CreateUserInGroup(meId: Int, groupId: Int, userId: Int)
    
    case Read(userId: Int)
    case ReadFull(userId: Int)
    case ReadContacts(userId: Int, page: Int)
    case ReadCommonFriends(meId: Int, friendId: Int)
    case ReadGroups(userId: Int)
    case ReadSearch(search: String)
    case ReadInvitations(userId: Int)
    case ReadInvitationsForMe(userId: Int)
    
    case Update(meId: Int, params: [String: AnyObject])
    case UpdateGroup(userId: Int, groupId: Int, newName: String)
    
    case DeleteGroup(userId: Int, groupId: Int)
    case DeleteUserInGroup(meId: Int, groupId: Int, userId: Int)
    case DeleteContact(meId: Int, userId: Int)
    case DeleteInvitation(meId: Int, userId: Int)
    
    var method: Alamofire.Method {
        switch self {
        case .Create:
            return .POST
        case .CreateInvitation:
            return .POST
        case .CreateInvitationAccept:
            return .POST
        case .CreateGroup:
            return .POST
        case .CreateUserInGroup:
            return .POST
            
        case .Read:
            return .GET
        case .ReadFull:
            return .GET
        case .ReadContacts:
            return .GET
        case .ReadCommonFriends:
            return .GET
        case .ReadGroups:
            return .GET
        case .ReadSearch:
            return .GET
        case .ReadInvitations, .ReadInvitationsForMe:
            return .GET
            
        case .Update, .UpdateGroup:
            return .PUT
            
        case .DeleteGroup, .DeleteUserInGroup, .DeleteContact, .DeleteInvitation:
            return .DELETE
        }
    }
    
    var path: String {
        switch self {
        case .Create:
            return "/user"
        case .CreateInvitation(let userId, let invitedUserId):
            return "/user/\(userId)/invitation/\(invitedUserId)"
        case .CreateInvitationAccept(let meId, let userId):
            return "/user/\(meId)/contact/\(userId)"
        case .CreateGroup(let meId, _):
            return "/user/\(meId)/group/"
        case .CreateUserInGroup(let meId, let groupId, let userId):
            return "/user/\(meId)/group/\(groupId)/user/\(userId)"
            
        case .Read(let userId):
            return "/user/\(userId)/"
        case .ReadFull(let userId):
            return "/user/\(userId)/full"
        case .ReadContacts(let userId, _):
            return "/user/\(userId)/contact"
        case .ReadCommonFriends(let meId, let friendId):
            return "/user/\(meId)/contact/common/\(friendId)"
        case .ReadGroups(let userId):
            return "/user/\(userId)/group"
        case .ReadSearch:
            return "/user/search"
        case .ReadInvitations(let meId):
            return "/user/\(meId)/invitation/"
        case .ReadInvitationsForMe(let userId):
            return "/user/\(userId)/invitation/for_me"
            
        case .Update(let meId, _):
            return "/user/\(meId)"
        case .UpdateGroup(let userId, let groupId, _):
            return "/user/\(userId)/group/\(groupId)"
            
        case .DeleteGroup(let userId, let groupId):
            return "/user/\(userId)/group/\(groupId)"
        case .DeleteUserInGroup(let meId, let groupId, let userId):
            return "/user/\(meId)/group/\(groupId)/user/\(userId)"
        case .DeleteContact(let meId, let userId):
            return "/user/\(meId)/contact/\(userId)"
        case .DeleteInvitation(let meId, let userId):
            return "/user/\(meId)/invitation/\(userId)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = ComeOnAPI.sharedInstance.getMutableUrlRequest(path)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .Create(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .CreateGroup(_, let name):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["name": name]).0
        case .Update(_, let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateGroup(_, _, let newName):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["name": newName]).0
        case .ReadSearch(let search):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["pseudo": search]).0
        case .ReadContacts(_, let page):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["page": page]).0
        default:
            return mutableURLRequest
        }
    }
    
}