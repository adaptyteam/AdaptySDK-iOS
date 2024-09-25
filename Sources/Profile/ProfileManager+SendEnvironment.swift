//
//  ProfileManager+SendEvironment.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import StoreKit

extension ProfileManager {
    enum SendedEnvironment: Sendable, Hashable { // TODO:  need refactoring
        case dont
        case withIdfa
        case withoutIdfa
    }
}

extension ProfileManager.SendedEnvironment {
    func needSend(analyticsDisabled: Bool) async -> Bool {
        switch self {
        case .dont:
            true
        case .withIdfa:
            false
        case .withoutIdfa:
            await Environment.Device.canTakeIdfa && !analyticsDisabled
        }
    }

    @AdaptyActor
    func getValueIfNeedSend(analyticsDisabled: Bool) async -> Environment.Meta? {
        guard await needSend(analyticsDisabled: analyticsDisabled) else { return nil }

        let meta = await Environment.Meta(includedAnalyticIds: !analyticsDisabled)

        if meta.idfa == nil, self == .withoutIdfa {
            return nil
        }

        return meta
    }
}
