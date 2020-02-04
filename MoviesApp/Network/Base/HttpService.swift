//
//  HttpService.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias IdResponseBlock = (_ swiftObj: Any?, _ error: Error?) -> Void
typealias BoolResponseBlock = (_ completion: Bool) -> Void

enum QueueQos {
    case background
    case defaultQos
}

protocol CustomErrorProtocol: Error {
    var localizedDescription: String { get }
    var code: Int { get }
}

struct CustomError: CustomErrorProtocol {
    
    var localizedDescription: String
    var code: Int
    
    init(localizedDescription: String, code: Int) {
        self.localizedDescription = localizedDescription
        self.code = code
    }
}

class HttpService {
    
    func checkInternetConnect() -> Bool {
        return InternetService.shared.checkInternetConnect()
    }
    
    func internetConnectErr() -> CustomError {
        return CustomError(localizedDescription: StringValue.Base.kNoInternetConnection.localized, code: 404)
    }
    
    func serverError() -> CustomError {
        return CustomError(localizedDescription: "Could not access the server", code: 404)
    }
    
    func serverSomthWrongError() -> CustomError {
        return CustomError(localizedDescription: StringValue.Base.kOopsTryAgainLater.localized, code: 404)
    }
    
    func requestError(_ description: String?, _ error: Int?) -> CustomError {
        return CustomError(localizedDescription: description ?? StringValue.Base.kOopsTryAgainLater.localized, code: error ?? 404)
    }
}

extension HttpService {
    
    func cancellAllRequests() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    func queryBy(_ url: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 queue: QueueQos,
                 headers: HTTPHeaders? = nil,
                 resp: @escaping IdResponseBlock) {
        
        guard let token = ApiSettings.shared.token else {
            return resp(nil, serverError())
        }
        
        var headersForQuery: HTTPHeaders = headers ?? [Keys.token: token]
        headersForQuery[Keys.token] = token
        
        return query(url,
                     method: method,
                     parameters: parameters,
                     encoding: encoding,
                     headers: headersForQuery,
                     queue: queue,
                     resp: resp)
    }
    
    func queryWithoutTokenBy(_ url: URLConvertible,
                             method: HTTPMethod = .get,
                             parameters: Parameters? = nil,
                             encoding: ParameterEncoding = URLEncoding.default,
                             headers: HTTPHeaders? = nil,
                             queue: QueueQos,
                             resp: @escaping IdResponseBlock) {
        
        query(url,
              method: method,
              parameters: parameters,
              encoding: encoding,
              headers: headers,
              queue: queue,
              resp: resp)
        
    }
    
    internal func query(_ url: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        queue: QueueQos,
                        resp: @escaping IdResponseBlock) {
        
        var queueQos = DispatchQueue(label: "com.lampa-queueBackground", qos: .background, attributes: [.concurrent])
        
        switch queue {
        case QueueQos.defaultQos:
            queueQos = DispatchQueue(label: "com.lampa-queueDefault", qos: .default, attributes: [.concurrent])
        default:
            break
        }
        
        if !checkInternetConnect() {
            return resp(nil, internetConnectErr())
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let request = Alamofire.request(url,
                                        method: method,
                                        parameters: parameters,
                                        encoding: encoding,
                                        headers: headers
            ).responseJSON (queue: queueQos) { (response) in
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                switch response.result {
                case .success:
                    
                    if let respValue = response.result.value {
                        guard let jsonResp = try? JSONSerialization.data(withJSONObject: respValue, options: []), let jResp = (try? JSONSerialization.jsonObject(with: jsonResp)) else { return }
                        
                        if let dict = jResp as? [String: AnyObject] {
                            
                            let status = dict["status"] as? String
                            
                            if let error = dict["error"] as? String {
                                let customError = CustomError(localizedDescription: error, code: 412)
                                return resp(nil, customError)
                            }
                            
                            if status == "error" {
                                return resp(nil, self.serverSomthWrongError())
                            }
                            
                            if let accessToken = dict["token"] as? String {
                                ApiSettings.shared.token = accessToken
                            }
                            
                            print("Request================")
                            print (jResp)
                            
                        } else if let arrayDict = jResp as? [[String: Any]] {
                            
                            print(arrayDict)
                        } else {
                            return
                        }
                        
                        if let err =  self.parseErrors(jsonResp) {
                            return resp(nil, err)
                        }
                        
                        resp(jsonResp, nil)
                    }
                    
                    break
                case .failure:
                    if (response.error as NSError?)?.code == NSURLErrorCancelled {
                        resp(nil, self.serverError()) //request canceled
                    } else {
                        resp(nil, self.serverError())
                    }
                }
        }
        
        print("Request================")
        print (request)
    }
    
    func parseErrors(_ jResp: Data) -> CustomError? {
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jResp) as? [String: Any] {
                
                if let errorShow = json["non_field_errors"] as? [String] {
                    
                    if let msg = errorShow.first {
                        
                        return CustomError(localizedDescription: msg, code: 404)
                    }
                }
            }
        }
        catch {
            print("Error deserializing JSON: \(error)")
        }
        
        return nil
    }
    
    func parseErrorMultipart(_ jResp: Data) -> CustomError? {
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jResp) as? [String: Any] {
                
                if let errorShow = json["error"] as? [String] {
                    
                    if let msg = errorShow.first {
                        
                        return CustomError(localizedDescription: msg, code: 404)
                    }
                }
            }
        }
        catch {
            print("Error deserializing JSON: \(error)")
        }
        
        return nil
    }
    
    internal func queryMultipart(_ url: URLConvertible,
                                 method: HTTPMethod = .post,
                                 parameters: Parameters? = nil,
                                 filePath: URL? = nil,
                                 image: [UIImage]? = nil,
                                 keyForFile: String = "",
                                 encryptedData: String? = nil,
                                 encryptedPhoto: String? = nil,
                                 headers: HTTPHeaders? = nil,
                                 equalKeyForArrayParameter: String? = nil,
                                 encoding: ParameterEncoding = URLEncoding.default,
                                 resp: @escaping IdResponseBlock) {
        
        if !checkInternetConnect() {
            return resp(nil, internetConnectErr())
        }
        
        guard let token = ApiSettings.shared.token else {
            return resp(nil, serverError())
        }
        
        var headersForQuery: HTTPHeaders = headers ?? [Keys.token: token]
        //headersForQuery[Keys.token] = token
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if let params = parameters {
                for (key, value) in params {
                    
                    if let data = String(describing: value).data(using: String.Encoding.utf8, allowLossyConversion: false) {
                        
                        var newKey = key
                        
                        if let keyToRaplace = equalKeyForArrayParameter, key.contains(keyToRaplace) {
                            newKey = "\(keyToRaplace)[]"
                        }
                        
                        multipartFormData.append(data, withName: newKey)
                    }
                }
            }
            
            if let data = image {
                
                for item in data {
                    
                    if let imageData1 = item.jpegData(compressionQuality: 0.5) {
                        multipartFormData.append(imageData1, withName:keyForFile, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                    }
                }
            }
            
            if let urlPath = filePath {
                multipartFormData.append(urlPath, withName: keyForFile)
            }
            
            if let enc = encryptedData {
                if let data = String(describing: enc).data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    multipartFormData.append(data, withName: keyForFile, fileName: "\(Date().timeIntervalSince1970).m4a", mimeType: "audio/mp4")
                }
            }
            
            
            if let enc = encryptedPhoto {
                if let data = String(describing: enc).data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    multipartFormData.append(data, withName: keyForFile, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
            }
            
        }, to: url, method: method, headers: headersForQuery) { (encodingResult) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.responseString {
                    response in
                    
                    
                    if let respValue = response.result.value {
                        
                        guard let test = String(describing: respValue).data(using: String.Encoding.utf8, allowLossyConversion: false) else { return }
                        
                        guard let jResp = try? JSONSerialization.jsonObject(with: test) else { return }
                        
                        if let dict = jResp as? [String: AnyObject] {
                            
                            let status = dict["status"] as? String
                            
                            if status == "error" {
                                return resp(nil, self.serverSomthWrongError())
                            }
                        } else if let arrayDict = jResp as? [[String: Any]] {
                            
                            print(arrayDict)
                        } else {
                            return
                        }
                        
                        print("jResp ================")
                        print(jResp)
                        
//                        if let err =  self.parseErrorMultipart(jsonResp) {
//                            return resp(nil, err)
//                        }
                        
                        if let dataForSerialization = respValue.data(using: .utf8) {
                            resp(dataForSerialization, nil)
                        }
                    } else {
                        resp(nil, self.serverError())
                    }
                }
                
            case .failure:
                resp(nil, self.serverError())
              
            }
        }
    }
    
}
