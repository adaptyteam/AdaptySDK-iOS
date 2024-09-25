//
//  Environment.Application.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.09.2024
//

import Foundation

extension Environment {
    enum Application {
        static let sessionIdentifier = UUID().uuidString.lowercased()

        static let version: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let build: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}
