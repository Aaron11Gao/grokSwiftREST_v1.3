//
//  GistRouter.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2016-10-29.
//  Copyright © 2016 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire
enum GistRouter: URLRequestConvertible {
  static let baseURLString = "https://api.github.com/"
  
  case getPublic()
  case getMyStarred()
  case getMine()
  case isStarred(String)
  case star(String)
  case unstar(String)
  case getAtPath(String)
  
  func asURLRequest() throws -> URLRequest {
    var method: HTTPMethod {
      switch self {
      case .getPublic, .getAtPath, .getMyStarred, .getMine, .isStarred:
        return .get
      case .star:
        return .put
      case .unstar:
        return .delete
      }
    }
    
    let url: URL = {
      let relativePath: String
      switch self {
      case .getAtPath(let path):
        // already have the full URL, so just return it
        return URL(string: path)!
      case .getPublic():
        relativePath = "gists/public"
      case .getMyStarred():
        relativePath = "gists/starred"
      case .getMine():
        relativePath = "gists"
      case .isStarred(let id):
        relativePath = "gists/\(id)/star"
      case .star(let id):
        relativePath = "gists/\(id)/star"
      case .unstar(let id):
        relativePath = "gists/\(id)/star"
      }
      
      var url = URL(string: GistRouter.baseURLString)!
      url.appendPathComponent(relativePath)
      return url
    }()
    
    let params: ([String: Any]?) = {
      switch self {
      case .getPublic, .getAtPath, .getMyStarred, .getMine, .isStarred, .star, .unstar:
        return nil
      }
    }()
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue
    
    // Set OAuth token if we have one
    if let token = GitHubAPIManager.sharedInstance.OAuthToken {
      urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }
    
    let encoding = JSONEncoding.default
    return try encoding.encode(urlRequest, with: params)
  }
}
