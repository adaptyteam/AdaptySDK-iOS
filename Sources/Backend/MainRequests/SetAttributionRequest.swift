//
//  SetAttributionRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct SetAttributionRequest: HTTPDataRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyProfile?
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let networkUserId: String?
    let source: AdaptyAttributionSource
    let attribution: [String: any Sendable]

    func decodeDataResponse(
        response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeResponse(
            response,
            withConfiguration: configuration,
            requestHeaders: headers
        )
    }

    init(profileId: String, networkUserId: String?, source: AdaptyAttributionSource, attribution: [String: any Sendable], responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .post,
            path: "/sdk/analytics/profiles/\(profileId)/attribution/"
        )
        headers = HTTPHeaders()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)

        self.networkUserId = networkUserId
        self.source = source
        self.attribution = attribution
    }

    enum CodingKeys: String, CodingKey {
        case networkUserId = "network_user_id"
        case source
        case attribution
    }

    func getData(configuration _: HTTPConfiguration) throws -> Data? {
        var object: [AnyHashable: Any] = [
            CodingKeys.source.stringValue: source.rawValue,
            CodingKeys.attribution.stringValue: attribution,
        ]

        if let networkUserId {
            object[CodingKeys.networkUserId.stringValue] = networkUserId
        }

        return try JSONSerialization.data(withJSONObject: [Backend.CodingKeys.data.stringValue: [
            Backend.CodingKeys.type.stringValue: "adapty_analytics_profile_attribution",
            Backend.CodingKeys.attributes.stringValue: object,
        ] as [String: Any]])
    }
}

extension Backend.MainExecutor {
    func sendAttribution(
        profileId: String,
        networkUserId: String?,
        source: AdaptyAttributionSource,
        attribution: [String: any Sendable],
        responseHash: String?
    ) async throws -> VH<AdaptyProfile?> {
        let request = SetAttributionRequest(
            profileId: profileId,
            networkUserId: networkUserId,
            source: source,
            attribution: attribution,
            responseHash: responseHash
        )
        let response = try await perform(
            request,
            requestName: .sendAttribution,
            logParams: [
                "source": source.description,
                "network_user_id": networkUserId,
            ]
        )

        return VH(response.body, hash: response.headers.getBackendResponseHash())
    }
}
