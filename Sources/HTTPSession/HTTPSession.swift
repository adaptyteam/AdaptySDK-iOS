//
//  HTTPSession.swift
//  Adapty
//
//  Created by Aleksei Valiano on 15.09.2022.
//

import Foundation

final class HTTPSession {
    let configuration: HTTPCodableConfiguration
    let responseQueue: DispatchQueue
    let requestAdditionals: HTTPRequestAdditionals?
    private let _responseValidator: HTTPDataResponse.Validator
    private let _errorHandler: ErrorHandler?
    private let _session: URLSession
    private let requestSign: Sign

    var forceLogCurl: Bool

    typealias ErrorHandler = (HTTPError) -> Void
    typealias Decoder<Body> = (HTTPDataResponse) -> HTTPResponse<Body>.Result
    typealias Sign = (URLRequest, HTTPEndpoint) -> Result<URLRequest, HTTPError>

    init(
        configuration: HTTPCodableConfiguration,
        responseQueue: DispatchQueue = .main,
        requestAdditionals: HTTPRequestAdditionals? = nil,
        requestSign: Sign? = nil,
        responseValidator: @escaping HTTPDataResponse.Validator = HTTPDataResponse.defaultValidator,
        errorHandler: ErrorHandler? = nil,
        forceLogCurl: Bool = false
    ) {
        self.configuration = configuration
        self.requestAdditionals = requestAdditionals
        self.responseQueue = responseQueue
        self.forceLogCurl = forceLogCurl
        self.requestSign = requestSign ?? { r, _ in .success(r) }
        _responseValidator = responseValidator
        _errorHandler = errorHandler
        _session = URLSession(configuration: configuration.sessionConfiguration)
    }

    func invalidateAndCancel() {
        _session.invalidateAndCancel()
    }

    @discardableResult
    final func perform<Request: HTTPRequest, Body>(
        _ request: Request,
        queue: DispatchQueue? = nil,
        decoder: @escaping Decoder<Body>,
        logStamp: String = Log.stamp,
        _ completionHandler: @escaping (HTTPResponse<Body>.Result) -> Void
    ) -> HTTPCancelable {
        let errorHandler = _errorHandler
        let queue = queue ?? responseQueue
        let endpoint = request.endpoint
        let urlRequest: URLRequest

        switch request.tryConvertToURLRequest(configuration: configuration, additionals: requestAdditionals)
            .flatMap({ requestSign($0, request.endpoint) }) {
        case let .success(request):
            urlRequest = request
        case let .failure(error):
            Logger.encoding(endpoint: endpoint, error: error)
            queue.async {
                errorHandler?(error)
                completionHandler(.failure(error))
            }
            return HTTPSession.emptyCancelable
        }

        let responseValidator = _responseValidator
//        let forceLogCurl = request.forceLogCurl || forceLogCurl
        let sessionConfiguration = _session.configuration
        Logger.request(urlRequest, endpoint: endpoint, session: sessionConfiguration, stamp: logStamp)
        let task = _session.dataTask(with: urlRequest) { data, response, error in
            let result: HTTPResponse<Body>.Result
            if let error = error {
                result = .failure(.network(endpoint, error: error))
            } else if let response = response as? HTTPURLResponse {
                let dataResponse = HTTPDataResponse(endpoint: endpoint, response: response, data: data)
                if let apiError = responseValidator(dataResponse) {
                    result = .failure(apiError)
                } else {
                    result = HTTPDataResponse.Result.success(dataResponse).flatMap(decoder)
                }
            } else {
                result = .failure(.network(endpoint, error: DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given response is nil or not is HTTPURLResponse."))))
            }

            Logger.response(response, data: data, endpoint: endpoint, error: result.error, request: urlRequest, stamp: logStamp)
            queue.async {
                if let errorHandler = errorHandler, let error = result.error { errorHandler(error) }
                completionHandler(result)
            }
        }
        task.resume()
        return task
    }

    @discardableResult
    final func perform<Request: HTTPRequest>(
        _ request: Request,
        queue: DispatchQueue? = nil,
        logStamp: String = Log.stamp,
        _ completionHandler: @escaping (HTTPStringResponse.Result) -> Void
    ) -> HTTPCancelable {
        perform(request, queue: queue, decoder: { response in
            let body: String?
            if let data = response.body {
                body = String(data: data, encoding: .utf8)
            } else {
                body = nil
            }
            return .success(response.replaceBody(body))
        }, logStamp: logStamp, completionHandler)
    }

    @discardableResult
    final func perform<Request: HTTPRequest>(
        _ request: Request,
        queue: DispatchQueue? = nil,
        logStamp: String = Log.stamp,
        _ completionHandler: @escaping (HTTPDataResponse.Result) -> Void
    ) -> HTTPCancelable {
        perform(request, queue: queue, decoder: { .success($0) }, logStamp: logStamp, completionHandler)
    }

    @discardableResult
    final func perform<Request: HTTPRequest>(
        _ request: Request,
        queue: DispatchQueue? = nil,
        logStamp: String = Log.stamp,
        _ completionHandler: @escaping (HTTPEmptyResponse.Result) -> Void
    ) -> HTTPCancelable {
        perform(request, queue: queue, decoder: { .success($0.asEmptyResponse) }, logStamp: logStamp, completionHandler)
    }
}
