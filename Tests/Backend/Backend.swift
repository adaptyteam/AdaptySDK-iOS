//
//  Backend.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 19.11.2022
//

@testable import Adapty
import Foundation

extension Backend {
    static func createForTests() -> Backend {
        Backend(secretKey: Adapty.Configuration.secretKey, baseURL: Backend.publicEnvironmentBaseUrl)
    }
}
