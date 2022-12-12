//
//  AdaptyEligibility.json.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK

extension AdaptyEligibility {
    enum ValidJSON {
        static let all = [eligible, ineligible, unknown, blablabla]
        static let eligible: JSONValue = "eligible"
        static let ineligible: JSONValue = "ineligible"
        static let unknown: JSONValue = "unknown"
        static let blablabla: JSONValue = "bla-bla-bla"
    }
}
