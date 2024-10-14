//
//  ProfileManager+SendEvironment.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import StoreKit

extension ProfileManager {
    enum SendedEnvironment: Sendable, Hashable { // TODO: need refactoring
        case dont
        case withIdfa
        case withoutIdfa
    }
}

extension Environment.Meta {
    var sendedEnvironment: ProfileManager.SendedEnvironment {
        idfa == nil ? .withoutIdfa : .withIdfa
    }
}

extension ProfileManager.SendedEnvironment {
    func needSend(analyticsDisabled: Bool) async -> Bool {
        switch self {
        case .dont: 
            return true
        case .withIdfa: 
            return false
        case .withoutIdfa:
            guard !analyticsDisabled else { return false }
            return await Environment.Device.idfaRetriavalStatus == .allowed
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
