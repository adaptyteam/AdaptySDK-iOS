//
//  RegisterInstallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

private struct RegisterInstallRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.OptionalData<RegistrationInstallResponse>

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
        if max > 500 {
            return Double.random(in: 500 ... max)
        } else {
            return 500
        }
    }

    func registerInstall(
        profileId: String,
        installInfo: Environment.InstallInfo,
        maxRetries: Int = 5
    ) async throws -> RegistrationInstallResponse? {
        let request = RegisterInstallRequest(
            profileId: profileId,
            installInfo: installInfo
        )
        var attempt = 0
        repeat {
            do {
                let response = try await perform(request, requestName: .reqisterInstall, logParams: attempt > 0 ? ["retry_attempt": attempt, "max_retries": maxRetries] : nil)
                return response.body.value
            } catch {
                guard attempt < maxRetries,
                      UABackend.canRetryRequest(error)
                else { throw error }
                attempt += 1
                try await Task.sleep(nanoseconds: UInt64(exponentialBackoffDelay(attempt) * 1_000_000_000))
            }
        } while true
    }
}
