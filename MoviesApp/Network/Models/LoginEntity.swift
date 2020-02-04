//
//  LoginEntity.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation
import ObjectMapper

class LoginEntity: Mappable {
    
    var email: String?
    var password: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        email         <- map ["email"]
        password      <- map ["password"]
    }
}
