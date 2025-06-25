//
//  Adapty+UserAcquisition.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.06.2025.
//

import Foundation

public extension Adapty {
    nonisolated static func getCurrentInstallationStatus() async throws -> AdaptyInstallationStatus {
        try await withActivatedSDK(
            methodName: .getCurrentInstallationStatus
        ) { _ in
            guard let manager = UserAcquisitionManager.shared
            else { return .notAvailable }
            return await manager.getCurrentInstallationStatus()
        }
    }

    internal func startRegisterInstallTaskIfNeeded()  {
        _ = UserAcquisitionManager.shared?.startRegisterInstallTaskIfNeeded()
    }
}
