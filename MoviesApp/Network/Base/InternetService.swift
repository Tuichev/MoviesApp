//
//  InternetService.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation
import Alamofire

class InternetService {
    
    let net = NetworkReachabilityManager()
    
    static let shared = InternetService()
    var internetHandler:((_ flag: Bool) -> Void)?
    
    private init() {}
    
    func start() {
        self.startNetworkReachabilityObserver()
    }
    
    private func startNetworkReachabilityObserver() {
        
        net?.startListening()
        
        net?.listener = {status in
            
            if self.net?.isReachable ?? false {
                
                if ((self.net?.isReachableOnEthernetOrWiFi) != nil) {
                    self.internetHandler?(true)
                } else if(self.net?.isReachableOnWWAN)! {
                    self.internetHandler?(true)
                }
            } else {
                self.internetHandler?(false)
            }
        }
    }
    
    func checkInternetConnect() -> Bool {
        
        guard let connect = self.net?.isReachable else {
            return false
        }
        
        return connect
    }
    
}
