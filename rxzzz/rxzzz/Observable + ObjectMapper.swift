//
//  Observable + ObjectMapper.swift
//  rxzzz
//
//  Created by 姜守栋 on 2018/1/24.
//  Copyright © 2018年 Nick.Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import ObjectMapper

enum RxSwiftMoyaError: String, Swift.Error {
    case ParseJSONError
    case OtherError
}

extension Observable {
    
    func mapObject<T: Mappable>(type: T.Type, key: String? = nil) -> Observable<T> {
        return self.map { response in
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            if let error = self.parseError(response: dict) {
                throw error
            }
            if let k = key {
                guard let dictionary = dict[k] as? [String: Any] else {
                    throw RxSwiftMoyaError.ParseJSONError
                }
                return Mapper<T>().map(JSON: dictionary)!
            }
            return Mapper<T>().map(JSON: dict)!
        }
    }
    
    func mapArray<T: Mappable>(type: T.Type, key: String? = nil) -> Observable<[T]> {
        return self.map { response in
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            if let error = self.parseError(response: dict) {
                throw error
            }
            if key != nil {
                guard let dictionary = dict[key!] as? [[String: Any]] else {
                    throw RxSwiftMoyaError.ParseJSONError
                }
                return Mapper<T>().mapArray(JSONArray: dictionary)
            } else {
                guard let array = response as? [Any] else {
                    throw RxSwiftMoyaError.ParseJSONError
                }
                guard let dicts = array as? [[String: Any]] else {
                    throw RxSwiftMoyaError.ParseJSONError
                }
                return Mapper<T>().mapArray(JSONArray: dicts)
            }
        }
    }
    
    func parseServerError() -> Observable {
        return self.map { (response) in
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            if let error = self.parseError(response: dict) {
                throw error
            }
            return self as! Element
        }
        
    }
    
    fileprivate func parseError(response: [String: Any]?) -> NSError? {
        var error: NSError?
        if let value = response {
            if let code = value["code"] as? Int, code != 200 {
                var msg = ""
                if let message = value["error"] as? String {
                    msg = message
                }
                error = NSError(domain: "Network", code: code, userInfo: [NSLocalizedDescriptionKey: msg])
            }
        }
        return error
    }
    
}
