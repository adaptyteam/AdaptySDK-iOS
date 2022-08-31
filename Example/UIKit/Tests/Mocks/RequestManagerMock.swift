//
//  RequestManagerMock.swift
//  Adapty_Tests
//
//  Created by Rustam on 08.12.2021.
//  Copyright © 2021 Adapty. All rights reserved.
//

@testable import Adapty
import Foundation

struct Stub {
    let statusCode: Int
    let jsonFileName: String?
    let error: Error?
    let urlMatcher: String
}

class MockURLProtocol: URLProtocol {
    // MARK: URLProtocol Stubs

    static var stubs: [Stub] = []

    static func addStab(_ stub: Stub) {
        stubs.append(stub)
    }

    static func stub(for request: URLRequest) -> Stub? {
        return stubs.filter({ request.url?.absoluteString.contains($0.urlMatcher) ?? false }).first
    }

    static func removeAllStubs(function: String = #function) {
        testName = function
        stubs.removeAll()
    }

    private static var testName: String = ""

    // MARK: URLProtocol

    override static func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let stub = MockURLProtocol.stub(for: request) else {
            let testName = MockURLProtocol.testName
            fatalError("No stubs for request: \(request.httpMethod!) \(request) in test: \(testName)")
        }

        let response = HTTPURLResponse(url: request.url!,
                                       statusCode: stub.statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let jsonFileName = stub.jsonFileName {
            guard let data = try? DataProvider().jsonDataNamed(jsonFileName) else {
                fatalError("No data")
            }

            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } else if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocol(self, didLoad: Data())
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
    }
}

extension URLSession {
    static var mock: URLSession {
        URLProtocol.registerClass(MockURLProtocol.self)

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}
