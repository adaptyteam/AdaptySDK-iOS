//
//  RequestManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import UIKit

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

#warning("Improve error handling")
enum NetworkResponse: String, Error {
    case success
    case emptyResponse = "Response is empty."
    case emptyData = "Request data is empty."
    case authenticationError = "You need to be authenticated first."
    case alreadyAuthenticatedError = "User is already authenticated. Logout first."
    case badRequest = "Bad request."
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
    case missingRequiredParams = "Missing required params."
    case statusError = "Received 'failure' status."
}

class RequestManager {
    
    @discardableResult
    class func request<T: JSONCodable>(router: Router, completion: @escaping (Result<T, Error>, HTTPURLResponse?) -> ()) -> URLSessionDataTask? {
        do {
            let urlRequest = try router.asURLRequest()
            return request(urlRequest: urlRequest, router: router, completion: completion)
        } catch {
            completion(.failure(error), nil)
        }
        
        return nil
    }

    @discardableResult
    class func request<T: JSONCodable>(urlRequest: URLRequest, completion: @escaping (Result<T, Error>, HTTPURLResponse?) -> ()) -> URLSessionDataTask? {
        return request(urlRequest: urlRequest, router: nil, completion: completion)
    }

    @discardableResult
    private class func request<T: JSONCodable>(urlRequest: URLRequest, router: Router?, completion: @escaping (Result<T, Error>, HTTPURLResponse?) -> ()) -> URLSessionDataTask? {
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                self.handleResponse(data: data, response: response, error: error, router: router, completion: completion)
            }
        }

        dataTask.resume()

        return dataTask
    }
    
    private class func handleResponse<T: JSONCodable>(data: Data?, response: URLResponse?, error: Error?, router: Router?, completion: @escaping (Result<T, Error>, HTTPURLResponse?) -> ()) {
        if let error = error {
            completion(.failure(error), nil)
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            completion(.failure(NetworkResponse.emptyResponse), nil)
            return
        }
        
        logJSON(data)
        
        guard let data = data else {
            completion(.failure(NetworkResponse.emptyData), response)
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            completion(.failure(NetworkResponse.unableToDecode), nil)
            return
        }
        
        if let error = self.handleNetworkResponse(response) {
            do {
                let errors = try ResponseErrorsArray(json: json)
                if let error = errors?.errors.first {
                    completion(.failure(NSError(domain: "", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.description])), nil)
                    return
                }
                
                completion(.failure(error), response)
                return
            } catch {
                completion(.failure(error), response)
                return
            }
        }
        
        var responseObject: T?
        
        do {
            if let keyPath = router?.keyPath {
                guard let json = json[keyPath] as? [String: Any] else {
                    completion(.failure(NetworkResponse.unableToDecode), nil)
                    return
                }
                
                responseObject = try T(json: json)
            } else {
                responseObject = try T(json: json)
            }
        } catch {
            completion(.failure(error), nil)
            return
        }
        
        if let responseObject = responseObject {
            completion(.success(responseObject), response)
        } else {
            completion(.failure(NetworkResponse.unableToDecode), response)
        }
    }
    
    private class func handleNetworkResponse(_ response: HTTPURLResponse) -> Error? {
        switch response.statusCode {
        case 200...299: return nil
        case 401...499: return NetworkResponse.authenticationError
        case 500...599: return NetworkResponse.badRequest
        case 600: return NetworkResponse.outdated
        default: return NetworkResponse.failed
        }
    }
    
    private class func logJSON(_ data: Data?) {
//        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
//            print("Response : \(jsonString)")
//        }
    }
    
}
