//
//  Backend.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 19.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import Foundation

extension Backend {
    static func createForTests() -> Backend {
        Backend(secretKey: Adapty.Configuration.secretKey, baseURL: Backend.publicEnvironmentBaseUrl)
    }
}
