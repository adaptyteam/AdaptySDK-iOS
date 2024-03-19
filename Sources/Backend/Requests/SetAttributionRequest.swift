//
//  SetAttributionRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct SetAttributionRequest: HTTPDataRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyProfile?>
    let endpoint: HTTPEndpoint
    let headers: Headers
    let networkUserId: String?
    let source: AdaptyAttributionSource
    let attribution: [AnyHashable: Any]

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<AdaptyProfile?, Error> =
                if headers.hasSameBackendResponseHash(response.headers) {
                    .success(nil)
                } else {
                    jsonDecoder.decode(Backend.Response.Body<AdaptyProfile>.self, response.body).map { $0.value }
                }
            return result.map { response.replaceBody(Backend.Response.Body($0)) }
                .mapError { .decoding(response, error: $0) }
        }
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
                "source": .value(source.description),
                "network_user_id": .valueOrNil(networkUserId),
            ]
        ) { (result: SetAttributionRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
