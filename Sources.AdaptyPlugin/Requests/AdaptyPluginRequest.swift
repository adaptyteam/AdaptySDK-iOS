//
//  AdaptyPluginRequest.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

public protocol AdaptyPluginRequest: Decodable, Sendable {
    static var method: String { get }
    func execute() async throws -> AdaptyJsonData
}
