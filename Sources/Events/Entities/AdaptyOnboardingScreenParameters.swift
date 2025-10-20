//
//  AdaptyOnboardingScreenParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

public struct AdaptyOnboardingScreenParameters: Sendable {
    public let name: String?
    public let screenName: String?
    public let screenOrder: UInt
    
    public init(name: String? = nil, screenName: String? = nil, screenOrder: UInt = 0) throws(AdaptyError) {
        guard screenOrder > 0 else {
            let error = AdaptyError.wrongParamOnboardingScreenOrder()
            Log.default.error(error.debugDescription)
            throw error
        }
        
        self.name = name.trimmed.nonEmptyOrNil
        self.screenName = screenName.trimmed.nonEmptyOrNil
        self.screenOrder = screenOrder
    }
}

extension AdaptyOnboardingScreenParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "onboarding_name"
        case screenName = "onboarding_screen_name"
        case screenOrder = "onboarding_screen_order"
    }
}
