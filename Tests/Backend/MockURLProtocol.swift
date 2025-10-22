//
//  MockURLProtocol.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 14.10.2025.
//

@testable import Adapty
import Foundation

final class MockURLProtocol: URLProtocol {
    enum Constants {
        static let handledKey = "MockURLProtocol.Handled"
        static let allowedSchemes: [String?] = ["http", "https"]
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url,
              Constants.allowedSchemes.contains(url.scheme),
              URLProtocol.property(forKey: Constants.handledKey, in: request) == nil
        else { return false }
        return true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        return self.canInit(with: request)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        
        // Пример оригинального JSON
        let original = [
            "user": "Alice",
            "role": "user",
            "features": ["read", "comment"]
        ] as [String: Any]
        
        // Меняем поле
        var modified = original
        modified["role"] = "admin"
        // Можно добавить или удалить поля
        modified["injectedBy"] = "URLProtocol"
        
        do {
            let body = try JSONSerialization.data(withJSONObject: modified, options: [])
            let headers = ["Content-Type": "application/json; charset=utf-8"]
            let httpResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            )!

            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        task?.cancel()
    }
}
