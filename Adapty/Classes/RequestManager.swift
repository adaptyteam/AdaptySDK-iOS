//
//  RequestManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

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

typealias RequestCompletion <T: JSONCodable> = (Result<T, Error>, HTTPURLResponse?) -> Void

class RequestManager {
    
    static let shared = RequestManager()
    private var tasksQueue: [URLSessionDataTask] = [] {
        didSet {
            startNewRequestIfPossible()
        }
    }
    private var currentTask: URLSessionDataTask?
    private var concurrentQueue = DispatchQueue(label: "com.Adapty.AdaptyConcurrentQueue", attributes: .concurrent)
    
    @discardableResult
    class func request<T: JSONCodable>(router: Router, completion: @escaping RequestCompletion<T>) -> URLSessionDataTask? {
        do {
            let urlRequest = try router.asURLRequest()
            return shared.performRequest(urlRequest, router: router, completion: completion)
        } catch {
            LoggerManager.logError(error)
            completion(.failure(error), nil)
        }
        
        return nil
    }

    @discardableResult
    class func request<T: JSONCodable>(urlRequest: URLRequest, completion: @escaping RequestCompletion<T>) -> URLSessionDataTask? {
        return shared.performRequest(urlRequest, router: nil, completion: completion)
    }

    @discardableResult
    private func performRequest<T: JSONCodable>(_ urlRequest: URLRequest, router: Router?, completion: @escaping RequestCompletion<T>) -> URLSessionDataTask? {
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.global(qos: .background).async {
                self.handleResponse(data: data, response: response, error: error, router: router) { (result: Result<T, Error>, response) in
                    switch result {
                    case .failure(let error):
                        LoggerManager.logError(error)
                    default:
                        break
                    }
                    
                    completion(result, response)
                }
            }
        }

        concurrentQueue.async(flags: .barrier) { self.tasksQueue.append(dataTask) }

        return dataTask
    }
    
    private func startNewRequestIfPossible() {
        guard currentTask == nil else {
            return
        }
        
        currentTask = tasksQueue.first
        currentTask?.resume()
    }
    
    private func handleResponse<T: JSONCodable>(data: Data?, response: URLResponse?, error: Error?, router: Router?, completion: @escaping RequestCompletion<T>) {
        logResponse(data, response)
        
        if let error = error {
            handleResult(result: .failure(error), response: nil, completion: completion)
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            handleResult(result: .failure(NetworkResponse.emptyResponse), response: nil, completion: completion)
            return
        }
        
        guard let data = data else {
            handleResult(result: .failure(NetworkResponse.emptyData), response: response, completion: completion)
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            handleResult(result: .failure(NetworkResponse.unableToDecode), response: nil, completion: completion)
            return
        }
        
        if let error = self.handleNetworkResponse(response) {
            do {
                let errors = try ResponseErrorsArray(json: json)
                if let error = errors?.errors.first {
                    handleResult(result: .failure(NSError(domain: "", code: error.status, userInfo: [NSLocalizedDescriptionKey: error.description])), response: nil, completion: completion)
                    return
                }
                
                handleResult(result: .failure(error), response: response, completion: completion)
                return
            } catch {
                handleResult(result: .failure(error), response: response, completion: completion)
                return
            }
        }
        
        var responseObject: T?
        
        do {
            if let keyPath = router?.keyPath {
                guard let json = json[keyPath] as? [String: Any] else {
                    handleResult(result: .failure(NetworkResponse.unableToDecode), response: nil, completion: completion)
                    return
                }
                
                responseObject = try T(json: json)
            } else {
                responseObject = try T(json: json)
            }
        } catch {
            handleResult(result: .failure(error), response: nil, completion: completion)
            return
        }
        
        if let responseObject = responseObject {
            handleResult(result: .success(responseObject), response: response, completion: completion)
        } else {
            handleResult(result: .failure(NetworkResponse.unableToDecode), response: response, completion: completion)
        }
    }
    
    private func handleResult<T: JSONCodable>(result: Result<T, Error>, response: HTTPURLResponse?, completion: @escaping RequestCompletion<T>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let result):
                completion(.success(result), response)
            case .failure(let error):
                completion(.failure(error), response)
            }
        }
        
        concurrentQueue.async(flags: .barrier) {
            self.currentTask = nil
            self.tasksQueue.removeFirst()
        }
    }
    
    private func handleNetworkResponse(_ response: HTTPURLResponse) -> Error? {
        switch response.statusCode {
        case 200...299: return nil
        case 401...499: return NetworkResponse.authenticationError
        case 500...599: return NetworkResponse.badRequest
        case 600: return NetworkResponse.outdated
        default: return NetworkResponse.failed
        }
    }
    
    private func logResponse(_ data: Data?, _ response: URLResponse?) {
        var message = "Received response: \(response?.url?.absoluteString ?? "")\n"
        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
            message.append("\(jsonString)\n")
        }
        if let response = response as? HTTPURLResponse {
            message.append("Headers: \(response.allHeaderFields)")
        }
        LoggerManager.logMessage(message)
    }
    
}
