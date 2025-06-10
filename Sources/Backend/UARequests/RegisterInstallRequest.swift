//
//  RegisterInstallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

private struct RegisterInstallRequest: HTTPEncodableRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/attribution/install"
    )

    let headers: HTTPHeaders
    let stamp = Log.stamp

    let installInfo: Environment.InstallInfo

    init(profileId: String, installInfo: Environment.InstallInfo) {
        headers = HTTPHeaders().setBackendProfileId(profileId)
        self.installInfo = installInfo
    }

    func encode(to encoder: any Encoder) throws {
        try installInfo.encode(to: encoder)
    }
}

extension Backend.UAExecutor {
    private func exponentialBackoffDelay(
        _ attempt: Int,
        base: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0
    ) -> TimeInterval {
        let max = min(base * pow(2.0, Double(attempt)), maxDelay)
        return Double.random(in: 0 ... max)
    }

    func registerInstall(
        profileId: String,
        installInfo: Environment.InstallInfo,
        maxRetries: Int = 5
    ) async throws {
        let request = RegisterInstallRequest(
            profileId: profileId,
            installInfo: installInfo
        )
        var lastError: Error?
        for attempt in 0 ..< maxRetries {
            do {
                let _: HTTPEmptyResponse = try await perform(request, requestName: .reqisterInstall, logParams: attempt > 0 ? ["retry_attempt": attempt, "max_retries": maxRetries] : nil)
                return
            } catch {
                lastError = error
                guard let httpError = error as? HTTPError,
                      Backend.canRetryRequest(httpError)
                else { throw error }
                try await Task.sleep(nanoseconds: UInt64(exponentialBackoffDelay(attempt) * 1_000_000_000))
                continue
            }
        }

        if let lastError {
            throw lastError
        }
    }

    func registerInstall(
        profileId: String,
        includedAnalyticIds: Bool,
        maxRetries: Int = 5
    ) async throws {
        guard let installInfo = await Environment.InstallInfo(includedAnalyticIds: includedAnalyticIds) else {
            return
        }

        try await registerInstall(profileId: profileId, installInfo: installInfo)
    }
}

package extension Adapty {
    nonisolated static func debugSendRegisterInstallRequest(installTime: Date = Date()) async throws {
        let sdk = try await activatedSDK
        try await sdk.httpUASession.registerInstall(
            profileId: sdk.profileStorage.profileId,
            installInfo: await Environment.InstallInfo(installTime: installTime, includedAnalyticIds: true),
            maxRetries: 0
        )
    }
}
