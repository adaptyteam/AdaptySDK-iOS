//
//  Backend.BaseUrls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2023
//

import Foundation

extension Backend {
    static let publicEnvironmentBaseUrl = URL(string: "https://api.adapty.io/api/v1")!
    static let publicEnvironmentFallbackBaseUrl = URL(string: "https://fallback.adapty.io/api/v1")!
}
