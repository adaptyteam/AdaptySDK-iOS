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

typealias RequestCompletion <T: JSONCodable> = (Result<T, AdaptyError>, HTTPURLResponse?) -> Void

class RequestManager {
    
    static let shared = RequestManager()
    private var tasksQueue: [URLSessionDataTask] = [] {
        didSet {
            startNewRequestIfPossible()
        }
    }
    private var currentTask: URLSessionDataTask?
    private var concurrentQueue = DispatchQueue(label: "com.Adapty.AdaptyConcurrentQueue", attributes: .concurrent)
    
    // MARK:- Public methods
    
    @discardableResult
    class func request<T: JSONCodable>(router: Router, completion: @escaping RequestCompletion<T>) -> URLSessionDataTask? {
        do {
            let urlRequest = try router.asURLRequest()
            return shared.performRequest(urlRequest, router: router, completion: completion)
        } catch let error as AdaptyError {
            LoggerManager.logError(error)
            completion(.failure(error), nil)
        } catch {
            LoggerManager.logError(error)
            completion(.failure(AdaptyError(with: error)), nil)
        }
        
        return nil
    }

    @discardableResult
    class func request<T: JSONCodable>(urlRequest: URLRequest, completion: @escaping RequestCompletion<T>) -> URLSessionDataTask? {
        return shared.performRequest(urlRequest, router: nil, completion: completion)
    }
    
    // MARK:- Private methods

    @discardableResult
    private func performRequest<T: JSONCodable>(_ urlRequest: URLRequest, router: Router?, completion: @escaping RequestCompletion<T>) -> URLSessionDataTask? {
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.global(qos: .background).async {
                self.handleResponse(data: data, response: response, error: error, router: router) { (result: Result<T, AdaptyError>, response) in
                    switch result {
                    case .failure(let error):
                        if error.adaptyErrorCode == .missingParam, T.self is PromoModel.Type {
                            // Ignore empty response from getPromo request
                        } else {
                            LoggerManager.logError(error)
                        }
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
            handleResult(result: .failure(AdaptyError(with: error)), response: nil, router: router, completion: completion)
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            handleResult(result: .failure(AdaptyError.emptyResponse), response: nil, router: router, completion: completion)
            return
        }
        
        guard let data = data else {
            handleResult(result: .failure(AdaptyError.emptyData), response: response, router: router, completion: completion)
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Parameters else {
            handleResult(result: .failure(AdaptyError.unableToDecode), response: nil, router: router, completion: completion)
            return
        }
        
        if let error = self.handleNetworkStatusCode(response.statusCode) {
            do {
                let responseErrors = try ResponseErrorsArray(json: json)
                if let responseError = responseErrors?.errors.first {
                    handleResult(result: .failure(AdaptyError(code: responseError.status, adaptyCode: error.adaptyErrorCode, message: responseError.description)), response: nil, router: router, completion: completion)
                    return
                }
                
                handleResult(result: .failure(error), response: response, router: router, completion: completion)
                return
            } catch let error as AdaptyError {
                handleResult(result: .failure(error), response: response, router: router, completion: completion)
                return
            } catch {
                handleResult(result: .failure(AdaptyError(with: error)), response: response, router: router, completion: completion)
                return
            }
        }
        
        // trying to get cached response instead of empty server response
        let jsonObject = RequestHashManager.shared.tryToGetCachedJSONObject(for: data, response: response, router: router) ?? json
        
        var responseObject: T?
        
        do {
            if let keyPath = router?.keyPath {
                guard let jsonObject = jsonObject[keyPath] as? Parameters else {
                    handleResult(result: .failure(AdaptyError.unableToDecode), response: nil, router: router, completion: completion)
                    return
                }
                
                responseObject = try T(json: jsonObject)
            } else {
                responseObject = try T(json: jsonObject)
            }
        } catch let error as AdaptyError {
            handleResult(result: .failure(error), response: nil, router: router, completion: completion)
            return
        } catch {
            handleResult(result: .failure(AdaptyError(with: error)), response: nil, router: router, completion: completion)
            return
        }
        
        if let responseObject = responseObject {
            handleResult(result: .success(responseObject), response: response, router: router, completion: completion)
        } else {
            handleResult(result: .failure(AdaptyError.unableToDecode), response: response, router: router, completion: completion)
        }
    }
    
    private func handleResult<T: JSONCodable>(result: Result<T, AdaptyError>, response: HTTPURLResponse?, router: Router?, completion: @escaping RequestCompletion<T>) {
        if case .createProfile = router, case .failure = result, let request = tasksQueue.first?.originalRequest {
            // re-create createProfile request and put it into the end of the queue
            performRequest(request, router: router, completion: completion)
            
            concurrentQueue.async(flags: .barrier) {
                if self.tasksQueue.count == 2 {
                    // don't need to start cycling request, so don't nullify `currentTask` before `taskQueue` changes
                    self.tasksQueue.removeFirst()
                    self.currentTask = nil
                } else {
                    // regular logic
                    self.currentTask = nil
                    self.tasksQueue.removeFirst()
                }
            }
            
            return
        }
        
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
    
    private func handleNetworkStatusCode(_ statusCode: Int) -> AdaptyError? {
        switch statusCode {
        case 200...299: return nil
        case 401, 403: return AdaptyError.authenticationError
        case 429, 500...599: return AdaptyError.serverError
        case 400...499: return AdaptyError.badRequest
        default: return AdaptyError.failed
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
