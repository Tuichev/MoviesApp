//
//  LoginAPI.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation
import Alamofire

class LoginAPI: RestClient {
    
    func login(_ email: String,_ password: String, resp: @escaping IdResponseBlock) {
        
        let url = baseUrl + Requests.login
        
        let params: [String: Any] = ["email": email,
                                     "password": password]
        
        http.queryWithoutTokenBy(url, method: .post, parameters: params, queue: .defaultQos, resp: { (response, error) in
            
            self.requestsResponse(response, error, resp: resp)
        })
    }
    
}
