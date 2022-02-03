//
//  WebService.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2021/07/25.
//

import Foundation
import Alamofire
import ObjectMapper
import RxSwift

enum NetworkResult<T:Mappable> {
    case success(T)
    case error(NetworkError)
}

enum NetworkError: Int, Error {
    case unknown = -1
    case badRequest = 400
    case authenticationFailed = 401
    case notFoundException = 404
    case contentLengthError = 413
    case quotaExceeded = 429
    case systemError = 500
    case endpointError = 503
    case timeout = 504
    case objectError = 999
}

protocol NetworkUtil: URLRequestConvertible {
    var baseURL: String { get }
    var method : HTTPMethod { get }
    var path : String { get }
    var parameters : Parameters { get }
}

extension NetworkUtil {
    var baseURL:String { return "https://www.googleapis.com" }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var urlRequest = URLRequest(url: url)
        urlRequest.method = method
        let param = parameters
        
        return try URLEncoding().encode(urlRequest, with: param)
    }
}

class NetworkService {
    func perform<T>(_ apiRoute: NetworkUtil) -> Single<NetworkResult<T>> {
        print("net work!!!!!! call API")
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 10
        manager.session.configuration.timeoutIntervalForResource = 10

        return Single.create { single in
            let dataRequest = AF.request(apiRoute)
            dataRequest
                .validate(contentType: ["application/json", "application/x-www-form-urlencoded", "text/json", "text/plain", "text/html"])
                .responseData(completionHandler: { response in
                    print("response : \(response)")
                    switch response.result {
                    case .success(let data):
                        if let jsonData = String(data: data, encoding: .utf8),
                           let obj = T(JSONString: jsonData) {
                            single(.success(.success(obj)))
                            //completion(.success(obj))
                        }else{
                            single(.success(.error(.objectError)))
                            //completion(.error(.objectError))
                        }
                    case .failure(let error):
                        print(error)
                        if let err = NetworkError(rawValue: response.response?.statusCode ?? 0) {
                            single(.success(.error(err)))
                            //completion(.error(err))
                        }else{
                            single(.success(.error(.unknown)))
                            //completion(.error(.unknown))
                        }
                    }
                })
            
            return Disposables.create()
        }
    }
    
    /*
    func perform<T: Mappable>(_ apiRoute: NetworkUtil, completion: @escaping (NetworkResult<T>) -> Void) {
        print("net work!!!!!! call API")
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 10
        manager.session.configuration.timeoutIntervalForResource = 10

        let dataRequest = AF.request(apiRoute)
        dataRequest
            .validate(contentType: ["application/json", "application/x-www-form-urlencoded", "text/json", "text/plain", "text/html"])
            .responseData(completionHandler: { response in
                print("response : \(response)")
                switch response.result {
                case .success(let data):
                    if let jsonData = String(data: data, encoding: .utf8),
                       let obj = T(JSONString: jsonData) {
                        completion(.success(obj))
                    }else{
                        completion(.error(.objectError))
                    }
                case .failure(let error):
                    print(error)
                    if let err = NetworkError(rawValue: response.response?.statusCode ?? 0) {
                        completion(.error(err))
                    }else{
                        completion(.error(.unknown))
                    }
                    break
                }
            })
    }
     */
}
