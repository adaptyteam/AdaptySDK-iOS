//
//  RequestManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
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
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async {
                    self.handleResponseFor(router, data: data, response: response, error: error, completion: completion)
                }
            }
            
            dataTask.resume()
            
            return dataTask
        } catch {
            completion(.failure(error), nil)
        }
        
        return nil
    }
    
    private class func handleResponseFor<T: JSONCodable>(_ router: Router, data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<T, Error>, HTTPURLResponse?) -> ()) {
        if let error = error {
            completion(.failure(error), nil)
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            completion(.failure(NetworkResponse.emptyResponse), nil)
            return
        }
        
        logJSON(data)
        
        if let error = self.handleNetworkResponse(response) {
            completion(.failure(error), response)
            return
        }
        
        guard let data = data else {
            completion(.failure(NetworkResponse.emptyData), response)
            return
        }
        
        var responseObject: T?
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(.failure(NetworkResponse.unableToDecode), nil)
                return
            }
            
            #warning("Think of better way to handle keyPaths")
            if let keyPath = router.keyPath {
                let statusModel = try ResponseStatusModel(json: json)
                if statusModel?.status == .failure {
                    completion(.failure(NetworkResponse.statusError), nil)
                    return
                }
                
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
        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
            print("Response : \(jsonString)")
        }
    }
    
}
