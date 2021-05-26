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

fileprivate class SessionDataTask: Equatable {
    
    var task: URLSessionDataTask?
    var router: Router?
    private var retriesCount = 0
    private var maxRetriesCount: Int
    private var retriesDelay: TimeInterval
    
    init(task: URLSessionDataTask? = nil, router: Router?, maxRetriesCount: Int = 3, retriesDelay: TimeInterval = 2) {
        self.task = task
        self.router = router
        self.maxRetriesCount = maxRetriesCount
        self.retriesDelay = retriesDelay
    }
    
    func retry(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        retriesCount += 1
        if retriesCount > maxRetriesCount {
            completion(nil, nil, AdaptyError.badRequest)
            return
        }
        
        guard let request = task?.originalRequest else {
            completion(nil, nil, AdaptyError.badRequest)
            return
        }
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.global(qos: .background).async {
                completion(data, response, error)
            }
        }
        
        DispatchQueue.main.async {
            Timer.scheduledTimer(timeInterval: self.retriesDelay, target: self, selector: #selector(self.resumeTaks), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func resumeTaks() {
        task?.resume()
    }
    
    static func == (lhs: SessionDataTask, rhs: SessionDataTask) -> Bool {
        return lhs.task == rhs.task && lhs.retriesCount == rhs.retriesCount && lhs.maxRetriesCount == rhs.maxRetriesCount && lhs.retriesDelay == rhs.retriesDelay
    }
    
}

class RequestManager {
    
    static let shared = RequestManager()
    
    private var runningTasksLimit: Int {
        return 1
    }
    private var waitingTasksQueue: [SessionDataTask] = [] {
        didSet {
            startNewRequestIfPossible()
        }
    }
    private var runningTasksQueue: [SessionDataTask] = []
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
        let task = SessionDataTask(router: router)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.global(qos: .background).async {
                self.handleResponse(task: task, data: data, response: response, error: error) { (result: Result<T, AdaptyError>, response) in
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
        task.task = dataTask

        concurrentQueue.async(flags: .barrier) { self.waitingTasksQueue.append(task) }

        return dataTask
    }
    
    private func startNewRequestIfPossible() {
        guard let task = waitingTasksQueue.first, runningTasksQueue.count < runningTasksLimit else {
            return
        }
        
        runningTasksQueue.append(task)
        waitingTasksQueue.removeFirst()
        task.task?.resume()
    }
    
    private func handleResponse<T: JSONCodable>(task: SessionDataTask, data: Data?, response: URLResponse?, error: Error?, completion: @escaping RequestCompletion<T>) {
        logResponse(data, response)
        
        if let error = error as NSError? {
            if error.isNetworkConnectionError {
                task.retry(completion: { data, response, error in
                    self.handleResponse(task: task, data: data, response: response, error: error, completion: completion)
                })
            } else {
                handleResult(task: task, result: .failure(AdaptyError(with: error)), response: nil, completion: completion)
            }
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            handleResult(task: task, result: .failure(AdaptyError.emptyResponse), response: nil, completion: completion)
            return
        }
        
        guard let data = data else {
            handleResult(task: task, result: .failure(AdaptyError.emptyData), response: response, completion: completion)
            return
        }
        
        if handleNetworkStatusCode(response.statusCode)?.adaptyErrorCode == .serverError {
            task.retry(completion: { data, response, error in
                self.handleResponse(task: task, data: data, response: response, error: error, completion: completion)
            })
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Parameters else {
            handleResult(task: task, result: .failure(AdaptyError.unableToDecode), response: nil, completion: completion)
            return
        }
        
        if let error = self.handleNetworkStatusCode(response.statusCode) {
            do {
                let responseErrors = try ResponseErrorsArray(json: json)
                if let responseError = responseErrors?.errors.first {
                    handleResult(task: task, result: .failure(AdaptyError(code: responseError.status, adaptyCode: error.adaptyErrorCode, message: responseError.description)), response: nil, completion: completion)
                    return
                }
                
                handleResult(task: task, result: .failure(error), response: response, completion: completion)
                return
            } catch let error as AdaptyError {
                handleResult(task: task, result: .failure(error), response: response, completion: completion)
                return
            } catch {
                handleResult(task: task, result: .failure(AdaptyError(with: error)), response: response, completion: completion)
                return
            }
        }
        
        // trying to get cached response instead of empty server response
        let jsonObject = RequestHashManager.shared.tryToGetCachedJSONObject(for: data, response: response, router: task.router) ?? json
        
        var responseObject: T?
        
        do {
            if let keyPath = task.router?.keyPath {
                guard let jsonObject = jsonObject[keyPath] as? Parameters else {
                    handleResult(task: task, result: .failure(AdaptyError.unableToDecode), response: nil, completion: completion)
                    return
                }
                
                responseObject = try T(json: jsonObject)
            } else {
                responseObject = try T(json: jsonObject)
            }
        } catch let error as AdaptyError {
            handleResult(task: task, result: .failure(error), response: nil, completion: completion)
            return
        } catch {
            handleResult(task: task, result: .failure(AdaptyError(with: error)), response: nil, completion: completion)
            return
        }
        
        if let responseObject = responseObject {
            handleResult(task: task, result: .success(responseObject), response: response, completion: completion)
        } else {
            handleResult(task: task, result: .failure(AdaptyError.unableToDecode), response: response, completion: completion)
        }
    }
    
    private func handleResult<T: JSONCodable>(task: SessionDataTask, result: Result<T, AdaptyError>, response: HTTPURLResponse?, completion: @escaping RequestCompletion<T>) {
        
        func removeCurrentTask() {
            runningTasksQueue.removeAll { (dataTask) -> Bool in
                return dataTask == task
            }
        }
        
        func startNextTask() {
            removeCurrentTask()
            startNewRequestIfPossible()
        }
        
        if case .createProfile = task.router,
           case .failure = result,
           let request = task.task?.originalRequest {
            // re-create createProfile request and put it into the end of the queue
            performRequest(request, router: task.router, completion: completion)
            
            concurrentQueue.async(flags: .barrier) {
                if self.waitingTasksQueue.count == 1 {
                    // don't need to start cycling request, so don't start next create profile request
                    removeCurrentTask()
                } else {
                    // regular logic
                    startNextTask()
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
            startNextTask()
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
