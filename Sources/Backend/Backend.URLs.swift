//
//  Backend.URLs.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2023
//

import Foundation

extension Backend {
    struct URLs {
        static let defaultPublicEnvironment = URLs(
            baseUrl: URL(string: "https://api.adapty.io/api/v1")!,
            fallbackUrl: URL(string: "https://fallback.adapty.io/api/v1")!,
            configsUrl: URL(string: "https://configs-cdn.adapty.io/api/v1")!,
            proxy: nil
        )

        static let euPublicEnvironment = URLs(
            baseUrl: URL(string: "https://api-eu.adapty.io/api/v1")!,
            fallbackUrl: URL(string: "https://fallback.adapty.io/api/v1")!,
            configsUrl: URL(string: "https://configs-cdn.adapty.io/api/v1")!,
            proxy: nil
        )

        static let cnPublicEnvironment = URLs(
            baseUrl: URL(string: "https://api-cn.adapty.io/api/v1")!,
            fallbackUrl: URL(string: "https://fallback.adapty.io/api/v1")!,
            configsUrl: URL(string: "https://configs-cdn.adapty.io/api/v1")!,
            proxy: nil
        )

        let baseUrl: URL
        let fallbackUrl: URL
        let configsUrl: URL
        let proxy: (host: String, port: Int)?
    }
}
