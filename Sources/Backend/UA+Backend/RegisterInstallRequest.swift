//
//  RegisterInstallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

private struct RegisterInstallRequest: BackendEncodableRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/attribution/install"
    )

    let headers: HTTPHeaders
    let stamp = Log.stamp
    let requestName = BackendRequestName.reqisterInstall
    var logParams: EventParameters?

    let installInfo: Environment.InstallInfo

    init(
        userId: AdaptyUserId,
        installInfo: Environment.InstallInfo,
        logParams: EventParameters? = nil
    ) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)

        self.installInfo = installInfo

        self.logParams = logParams
    }

    func encode(to encoder: any Encoder) throws {
        try installInfo.encode(to: encoder)
    }
}

private typealias ResponseBody = Backend.Response.OptionalData<RegistrationInstallResponse>

extension Backend.UAExecutor {
    private func exponentialBackoffDelay(
        _ attempt: Int,
        base: AdaptyDuration = .seconds(1),
        min minDelay: AdaptyDuration = .milliseconds(500),
        max maxDelay: AdaptyDuration = .seconds(30)
    ) -> AdaptyDuration {
        let upperBound =
            if attempt <= 0 {
                base
            } else if attempt < Int.bitWidth - 1 {
                min(base * (1 << attempt), maxDelay)
            } else {
                maxDelay
            }
        return max(minDelay, upperBound * Double.random(in: 0 ... 1))
    }

    func registerInstall(
        userId: AdaptyUserId,
        installInfo: Environment.InstallInfo,
        maxRetries: Int = 5
    ) async throws(HTTPError) -> RegistrationInstallResponse? {
        var request = RegisterInstallRequest(
            userId: userId,
            installInfo: installInfo
        )
        var attempt = 0

        while !Task.isCancelled {
            do {
                request.logParams = attempt > 0 ? ["retry_attempt": attempt, "max_retries": maxRetries] : nil
                let response: HTTPResponse<ResponseBody> = try await perform(request)
                return response.body.value
            } catch {
                guard attempt < maxRetries,
                      !error.isCancelled,
                      canRetryRequest(error)
                else { throw error }
                attempt += 1
                try? await Task.sleep(duration: exponentialBackoffDelay(attempt))
            }
        }
        throw HTTPError.cancelled(request.endpoint)
    }
}
