//
//  AdaptyProfileManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import StoreKit

extension AdaptyProfileManager {
    enum SendedEnvironment {
        case dont
        case withIdfa
        case withoutIdfa
    }
}

extension AdaptyProfileManager.SendedEnvironment {
    func needSend(analyticsDisabled: Bool) -> Bool {
        switch self {
        case .dont:
            true
        case .withIdfa:
            false
        case .withoutIdfa:
            analyticsDisabled ? false : true
        }
    }

    func getValueIfNeedSend(analyticsDisabled: Bool) -> Environment.Meta? {
        if needSend(analyticsDisabled: analyticsDisabled) {
            Environment.Meta(includedAnalyticIds: !analyticsDisabled)
        } else {
            nil
        }
    }
}
