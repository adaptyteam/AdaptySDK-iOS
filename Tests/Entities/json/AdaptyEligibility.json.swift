//
//  AdaptyEligibility.json.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 22.11.2022
//

@testable import Adapty

extension AdaptyEligibility {
    enum ValidJSON {
        static let all = [eligible, ineligible, notApplicable]
        static let eligible: JSONValue = "eligible"
        static let ineligible: JSONValue = "ineligible"
        static let notApplicable: JSONValue = "not_applicable"
    }
}
