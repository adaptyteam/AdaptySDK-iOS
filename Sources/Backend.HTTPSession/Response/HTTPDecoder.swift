//
//  HTTPDecoder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.08.2024
//

import Foundation

typealias HTTPDecoder<Body> = @Sendable (HTTPDataResponse, HTTPCodableConfiguration?, HTTPRequest) async throws -> HTTPResponse<Body>
