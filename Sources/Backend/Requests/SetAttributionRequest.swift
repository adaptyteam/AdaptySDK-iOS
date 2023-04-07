//
//  SetAttributionRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct SetAttributionRequest: HTTPDataRequest {
    typealias Result = HTTPEmptyResponse.Result

    let endpoint: HTTPEndpoint
    let headers: Headers
    let networkUserId: String?
    let source: AdaptyAttributionSource
    let attribution: [AnyHashable: Any]

    init(profileId: String, networkUserId: String?, source: AdaptyAttributionSource, attribution: [AnyHashable: Any]) {
        endpoint = HTTPEndpoint(
            method: .post,
            path: "/sdk/analytics/profiles/\(profileId)/attribution/"
        )
        headers = Headers().setBackendProfileId(profileId)
        self.networkUserId = networkUserId
        self.source = source
        self.attribution = attribution
    }

    enum CodingKeys: String, CodingKey {
        case networkUserId = "network_user_id"
        case source
        case attribution
    }

    func getData(configuration: HTTPConfiguration) throws -> Data? {
        var object: [AnyHashable: Any] = [
            CodingKeys.source.stringValue: source.rawValue,
            CodingKeys.attribution.stringValue: attribution,
        ]

        if let networkUserId = networkUserId {
            object[CodingKeys.networkUserId.stringValue] = networkUserId
        }

        return try JSONSerialization.data(withJSONObject: [Backend.CodingKeys.data.stringValue: [
            Backend.CodingKeys.type.stringValue: "adapty_analytics_profile_attribution",
            Backend.CodingKeys.attributes.stringValue: object] as [String: Any]])
    }
}

extension HTTPSession {
    func performSetAttributionRequest(profileId: String,
                                      networkUserId: String?,
                                      source: AdaptyAttributionSource,
                                      attribution: [AnyHashable: Any],
                                      _ completion: AdaptyErrorCompletion?) {
        let request = SetAttributionRequest(profileId: profileId,
                                            networkUserId: networkUserId,
                                            source: source,
                                            attribution: attribution)
        perform(request,
                logName: "set_attribution",
                logParams: [
                    "source": .value(source.description),
                    "network_user_id": .valueOrNil(networkUserId)
                ]) { (result: SetAttributionRequest.Result) in
            switch result {
            case let .failure(error):
                completion?(error.asAdaptyError)
            case .success:
                completion?(nil)
            }
        }
    }
}
