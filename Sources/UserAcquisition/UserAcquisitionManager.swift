//
//  UserAcquisitionManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.06.2025.
//

import Foundation

@AdaptyActor
final class UserAcquisitionManager: Sendable {
    private let storage: UserAcquisitionStorage
    private let executor: Backend.UAExecutor
    private var registerInstallTask: Task<Void, any Error>?

    private init?(_ sdk: Adapty) {
        let storage = UserAcquisitionStorage()
        guard storage.version > 0 else { return nil }

        let executor = sdk.backend.createUAExecutor()
        self.storage = storage
        self.executor = executor
        self.registerInstallTask = nil

        startRegisterInstallTaskIfNeeded()
    }

    func startRegisterInstallTaskIfNeeded() {
        guard
            !storage.hasRegistrationInstallResponse,
            registerInstallTask == nil,
            let sdk = Adapty.optionalSDK
        else { return }
        guard registerInstallTask == nil else { return }

        registerInstallTask = Task { @AdaptyActor in
            guard let installInfo = await Environment.InstallInfo(includedAnalyticIds: true) else {
                return
            }
            do {
                let response = try await executor.registerInstall(
                    profileId: sdk.profileStorage.profileId,
                    installInfo: installInfo,
                    maxRetries: 100
                )
                storage.setRegistrationInstallResponse(response)

                let details = response.asAdaptyInstallationDetails(
                    installTime: installInfo.installTime,
                    appLaunchCount: installInfo.appLaunchCount
                )

                Adapty.callDelegate { $0.onInstallationDetailsSuccess(details) }

            } catch {
                if let httpError = error as? HTTPError, httpError.isCancelled {
                    return
                }
                Adapty.callDelegate { $0.onInstallationDetailsFail(error: error) }
            }
        }
    }

    func getCurrentInstallationStatus() async -> AdaptyInstallationStatus {
        guard
            let installTime = Environment.Application.installationTime,
            let appLaunchCount = Environment.Application.appLaunchCount
        else { return .notAvailable }

        guard storage.hasRegistrationInstallResponse
        else { return .notDetermined }

        let response = storage.registrationInstallResponse

        return .determined(response.asAdaptyInstallationDetails(
            installTime: installTime,
            appLaunchCount: appLaunchCount
        ))
    }

    // TODO: delete
    func debugSendRegisterInstallRequest(sdk: Adapty, installTime: Date) async throws {
        _ = try await executor.registerInstall(
            profileId: sdk.profileStorage.profileId,
            installInfo: await Environment.InstallInfo(
                installTime: installTime,
                appLaunchCount: Environment.Application.appLaunchCount ?? 1,
                includedAnalyticIds: true
            ),
            maxRetries: 1
        )
    }
}

@AdaptyActor
extension UserAcquisitionManager {
    static var shared: UserAcquisitionManager?
    static func activate(_ sdk: Adapty) { shared = .init(sdk) }
}

private extension RegistrationInstallResponse? {
    func asAdaptyInstallationDetails(installTime: Date, appLaunchCount: Int) -> AdaptyInstallationDetails {
        let response = self
        return .init(
            id: response?.id,
            installTime: installTime,
            appLaunchCount: appLaunchCount,
            payload: response?.payload
        )
    }
}
