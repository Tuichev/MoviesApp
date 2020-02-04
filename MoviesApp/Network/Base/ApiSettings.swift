//
//  ApiSettings.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation

class ApiSettings {
    
    static let shared = ApiSettings()
    
    private init() {}
    
    let kServerBaseURL = ""
    
    private var currentDefaults: UserDefaults = .standard
    
    var token: String? {
        
        set {
            currentDefaults.set(newValue, forKey: Keys.token)
        }
        
        get {
            guard let value = currentDefaults.object(forKey: Keys.token) as? String else {
                return nil
            }
            
            return !value.isEmpty ? value : nil
        }
    }
}
