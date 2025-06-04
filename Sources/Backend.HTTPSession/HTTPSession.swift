//
//  HTTPSession.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.09.2022.
//

import Foundation

final class HTTPSession: Sendable {
    let configuration: HTTPConfiguration
    let requestAdditional: HTTPRequestAdditional?

    private let _responseValidator: HTTPDataResponse.Validator
    private let _errorHandler: HTTPErrorHandlerActor?
    private let _session: URLSession
    private let _state: HTTPSessionState
    private let _delegate: URLSession.Delegate
    private let _requestSign: Sign?

    typealias Sign = @Sendable (URLRequest, HTTPEndpoint) throws -> URLRequest

    init(
        configuration: HTTPCodableConfiguration,
        requestAdditional: HTTPRequestAdditional? = nil,
        requestSign: Sign? = nil,
        responseValidator: @escaping HTTPDataResponse.Validator = HTTPDataResponse.defaultValidator,
        errorHandler: HTTPErrorHandler? = nil
    ) {
        self.configuration = configuration
        self.requestAdditional = requestAdditional
        _requestSign = requestSign
        _responseValidator = responseValidator
        _errorHandler = errorHandler.map { HTTPErrorHandlerActor(handler: $0) }
        let state = HTTPSessionState()
        _state = state
        let delegate = URLSession.Delegate(sessionState: state, configuration: configuration)

        _session = URLSession(
            configuration: configuration.sessionConfiguration,
            delegate: delegate,
            delegateQueue: nil
        )
        _delegate = delegate
    }

    func perform<Body>(
        _ request: some HTTPRequest,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws -> HTTPResponse<Body> {
        let state = _state
        let stamp = request.stamp
        let errorHandler = _errorHandler
        let endpoint = request.endpoint
        var urlRequest: URLRequest

        do {
            urlRequest = try request.convertToURLRequest(configuration: configuration, additional: requestAdditional)
            if let _requestSign {
                urlRequest = try _requestSign(urlRequest, request.endpoint)
            }
        } catch {
            let httpError = HTTPError.perform(endpoint, error: error)
            Log.encodingError(httpError, endpoint: endpoint, stamp: stamp)
            errorHandler?.call(httpError)
            throw httpError
        }

        Log.request(urlRequest, endpoint: endpoint, session: _session.configuration, stamp: stamp)

        let dataResponse: HTTPDataResponse
        do {
            let (data, response, metrics) = try await _session.data(with: urlRequest, sessionState: state)
            dataResponse = HTTPDataResponse(endpoint: endpoint, response: response, metrics: metrics.map(HTTPMetrics.init), data: data)
        } catch {
            let wrap = error as? URLErrorWithMetrics
            let httpError = HTTPError.network(endpoint, metrics: wrap?.metrics.map(HTTPMetrics.init), error: wrap?.error ?? error)
            Log.responseError(httpError, request: urlRequest, stamp: stamp, response: nil)
            errorHandler?.call(httpError)
            throw httpError
        }

        if let error = _responseValidator(dataResponse) {
            let httpError = HTTPError.backend(dataResponse, error: error)
            Log.responseError(httpError, request: urlRequest, stamp: stamp, response: dataResponse)
            errorHandler?.call(httpError)
            throw httpError
        }

        let startDecodeTime = DispatchTime.now()

        var bodyResponse: HTTPResponse<Body>
        do {
            bodyResponse = try await decoder(dataResponse)

        } catch {
            let httpError = HTTPError.decoding(dataResponse, error: error)
            Log.responseError(httpError, request: urlRequest, stamp: stamp, response: dataResponse)
            errorHandler?.call(httpError)
            throw httpError
        }
        let endDecodeTime = DispatchTime.now()
        bodyResponse = bodyResponse.replaceDecodingTime(start: startDecodeTime, end: endDecodeTime)
        Log.response(dataResponse.replaceMetrics(bodyResponse.metrics), request: urlRequest, stamp: stamp)
        return bodyResponse
    }
}
