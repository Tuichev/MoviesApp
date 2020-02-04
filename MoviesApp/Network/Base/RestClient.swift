//
//  RestClient.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import SwiftyJSON

class RestClient: NSObject {
    
    internal var http = HttpService()
    internal let baseUrl = ApiSettings.shared.kServerBaseURL
    
    let dataIsNil = CustomError.init(localizedDescription: StringValue.Base.kOopsTryAgainLater, code: 0)
    
    internal func requestsResponse(_ response: Any?, _ error: Error?, resp: @escaping IdResponseBlock) {
        
        if let err = error {
            return resp(nil, err)
        }
        
        guard let data = response as? Data else {
            return resp(nil, dataIsNil)
        }
        
        let json = JSON(data)
        
        self.parseData(object: json.rawValue,
                       modelCls: LoginEntity.self,
                       response: resp)
    }
    
    func cancellRequests() {
        http.cancellAllRequests()
    }
    
    fileprivate func parseData<P: BaseMappable>(object: Any, modelCls: P.Type, response: (IdResponseBlock)) {
        
        if object is NSArray {
            let result = Mapper<P>().mapArray(JSONObject: object)
            return response(result, nil)
        }
        
        if object is NSDictionary {
            let model: P = Mapper<P>().map(JSONObject: object)!
            return response(model, nil)
        }
    }
}
