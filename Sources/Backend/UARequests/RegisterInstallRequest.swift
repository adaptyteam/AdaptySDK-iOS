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
    func reqisterInstall(
        profileId: String,
        info: Environment.InstallInfo
    ) async throws {
        let request = RegisterInstallRequest(
            profileId: profileId,
            info: info
        )

        let _: HTTPEmptyResponse = try await perform(request, requestName: .reqisterInstall)
    }
}
