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

    let info: Environment.InstallInfo

    init(profileId: String, info: Environment.InstallInfo) {
        headers = HTTPHeaders().setBackendProfileId(profileId)
        self.info = info
    }

    func encode(to encoder: any Encoder) throws {
        try info.encode(to: encoder)
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

    func reqisterInstall(
        profileId: String,
        info: Environment.InstallInfo,
        maxRetries: Int = 5
    ) async throws {
        let request = RegisterInstallRequest(
            profileId: profileId,
            info: info
        )
        var lastError: Error?
        for attempt in 0 ..< maxRetries {
            do {
                let _: HTTPEmptyResponse = try await perform(request, requestName: .reqisterInstall, logParams: attempt > 0 ? ["retry_attempt": attempt, "max_retry": maxRetries] : nil)
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
}
