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
    private let installTime: Date
    private let appLaunchCount: Int

    private var registerInstallTask: Task<Void, any Error>?

    private init?(_ sdk: Adapty) {
        let storage = UserAcquisitionStorage()
        guard
            let installTime = Environment.Application.installationTime,
            let appLaunchCount = Environment.Application.appLaunchCount,
            storage.version > 0
        else { return nil }

        self.storage = storage
        self.executor = sdk.backend.createUAExecutor()
        self.installTime = installTime
        self.appLaunchCount = appLaunchCount
        self.registerInstallTask = nil

        if storage.hasRegistrationInstallResponse {
            let response = storage.registrationInstallResponse
            let details = response.asAdaptyInstallationDetails(
                installTime: installTime,
                appLaunchCount: appLaunchCount
            )
            Adapty.callDelegate { $0.onInstallationDetailsSuccess(details) }

        } else {
            _ = startRegisterInstallTaskIfNeeded()
        }
    }

    func startRegisterInstallTaskIfNeeded(maxRetries: Int = 10) -> Bool {
        guard
            !storage.hasRegistrationInstallResponse,
            registerInstallTask == nil,
            let sdk = Adapty.optionalSDK
        else { return false }

        let installTime = installTime
        let appLaunchCount = appLaunchCount

        registerInstallTask = Task { @AdaptyActor in
            let installInfo = await Environment.InstallInfo(
                installTime: installTime,
                appLaunchCount: appLaunchCount,
                includedAnalyticIds: true
            )

            do {
                let response = try await executor.registerInstall(
                    profileId: sdk.profileStorage.profileId,
                    installInfo: installInfo,
                    maxRetries: maxRetries
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
                Adapty.callDelegate { $0.onInstallationDetailsFail(error: error.asAdaptyError ?? AdaptyError.fetchInstallationDetailsFailed(unknownError: error)) }
            }
        }
        return true
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
