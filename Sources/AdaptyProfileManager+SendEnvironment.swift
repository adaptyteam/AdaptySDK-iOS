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
            Environment.Device.canTakeIdfa && !analyticsDisabled
        }
    }

    func getValueIfNeedSend(analyticsDisabled: Bool) -> Environment.Meta? {
        guard needSend(analyticsDisabled: analyticsDisabled) else { return nil }

        let meta = Environment.Meta(includedAnalyticIds: !analyticsDisabled)

        if meta.idfa == nil, self == .withoutIdfa {
            return nil
        }

        return meta
    }
}
