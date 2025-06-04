//
//  HTTPRequestAdditional.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.08.2024
//

import Foundation

protocol HTTPRequestAdditional: Sendable {
    var headers: HTTPHeaders? { get }
    var queryItems: HTTPRequest.QueryItems? { get }
}
