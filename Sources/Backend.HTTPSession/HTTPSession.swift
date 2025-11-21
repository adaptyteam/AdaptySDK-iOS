//
//  HTTPSession.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.09.2022.
//

import Foundation

final class HTTPSession: Sendable {
    let configuration: HTTPConfiguration

    private let _responseValidator: HTTPDataResponse.Validator
    private let _session: URLSession
    private let _state: HTTPSessionState
    private let _delegate: URLSession.Delegate
    private let _requestSign: Sign?

    typealias Sign = @Sendable (URLRequest, HTTPEndpoint) throws -> URLRequest

    init(
        configuration: HTTPCodableConfiguration,
        requestSign: Sign? = nil,
        responseValidator: @escaping HTTPDataResponse.Validator = HTTPDataResponse.defaultValidator
    ) {
        self.configuration = configuration
        _requestSign = requestSign
        _responseValidator = responseValidator
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
        withBaseUrl baseUrl: URL,
        withDecoder decoder: @escaping HTTPDecoder<Body>
    ) async throws(HTTPError) -> HTTPResponse<Body> {
        let state = _state
        let stamp = request.stamp
        let endpoint = request.endpoint
        var urlRequest: URLRequest

        do {
            urlRequest = try request.convertToURLRequest(baseUrl: baseUrl, configuration: configuration)
            if let _requestSign {
                urlRequest = try _requestSign(urlRequest, request.endpoint)
            }
        } catch {
            let httpError = HTTPError.perform(endpoint, error: error)
            Log.encodingError(httpError, endpoint: endpoint, stamp: stamp)
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
            throw httpError
        }

        if let error = _responseValidator(dataResponse) {
            let httpError = HTTPError.backend(dataResponse, error: error)
            Log.responseError(httpError, request: urlRequest, stamp: stamp, response: dataResponse)
            throw httpError
        }

        let startDecodeTime = DispatchTime.now()

        var bodyResponse: HTTPResponse<Body>
        do {
            bodyResponse = try await decoder(dataResponse, configuration as? HTTPCodableConfiguration, request)
        } catch {
            let httpError = HTTPError.decoding(dataResponse, error: error)
            Log.responseError(httpError, request: urlRequest, stamp: stamp, response: dataResponse)
            throw httpError
        }
        let endDecodeTime = DispatchTime.now()
        bodyResponse = bodyResponse.replaceDecodingTime(start: startDecodeTime, end: endDecodeTime)
        Log.response(dataResponse.replaceMetrics(bodyResponse.metrics), request: urlRequest, stamp: stamp)
        return bodyResponse
    }
}
