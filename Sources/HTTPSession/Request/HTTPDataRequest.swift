//
//  HTTPDataRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.08.2024
//

import Foundation

protocol HTTPDataRequest: HTTPRequest {
    var contentType: String? { get }
    func getData(configuration: HTTPConfiguration) throws -> Data?
}

extension HTTPDataRequest {
    var contentType: String? { nil }
}
