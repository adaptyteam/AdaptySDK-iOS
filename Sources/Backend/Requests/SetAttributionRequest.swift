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
    let headers: Headers
    let networkUserId: String?
    let source: AdaptyAttributionSource
    let attribution: [AnyHashable: Any]

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        createDecoder(jsonDecoder)
    }

    init(profileId: String, networkUserId: String?, source: AdaptyAttributionSource, attribution: [AnyHashable: Any], responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .post,
            path: "/sdk/analytics/profiles/\(profileId)/attribution/"
        )
        headers = Headers()
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

extension HTTPSession {
    func performSetAttributionRequest(
        profileId: String,
        networkUserId: String?,
        source: AdaptyAttributionSource,
        attribution: [AnyHashable: Any],
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile?>>
    ) {
        let request = SetAttributionRequest(
            profileId: profileId,
            networkUserId: networkUserId,
            source: source,
            attribution: attribution,
            responseHash: responseHash
        )
        perform(
            request,
            logName: "set_attribution",
            logParams: [
                "source": source.description,
                "network_user_id": networkUserId,
            ]
        ) { (result: SetAttributionRequest.Result) in
            completion(result
                .map { VH($0.body, hash: $0.headers.getBackendResponseHash()) }
                .mapError { $0.asAdaptyError }
            )
        }
    }
}
