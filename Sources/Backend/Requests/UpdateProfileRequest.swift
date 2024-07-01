//
//  UpdateProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct UpdateProfileRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyProfile?
    let endpoint: HTTPEndpoint
    let headers: Headers
    let profileId: String
    let parameters: AdaptyProfileParameters?
    let environmentMeta: Environment.Meta?

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        createDecoder(jsonDecoder)
    }

    init(
        profileId: String,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta?,
        responseHash: String?
    ) {
        endpoint = HTTPEndpoint(
            method: .patch,
            path: "/sdk/analytics/profiles/\(profileId)/"
        )

        headers = Headers()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)

        self.profileId = profileId
        self.parameters = parameters
        self.environmentMeta = environmentMeta
    }

    enum CodingKeys: String, CodingKey {
        case environmentMeta = "installation_meta"
        case storeCountry = "store_country"
        case ipV4Address = "ip_v4_address"
        case appTrackingTransparencyStatus = "att_status"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_analytics_profile", forKey: .type)
        try dataObject.encode(profileId, forKey: .id)

        if let parameters {
            try dataObject.encode(parameters, forKey: .attributes)
        }
        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)

        if let environmentMeta {
            try attributesObject.encode(environmentMeta, forKey: .environmentMeta)
            try attributesObject.encodeIfPresent(environmentMeta.storeCountry, forKey: .storeCountry)
            try attributesObject.encodeIfPresent(environmentMeta.ipV4Address, forKey: .ipV4Address)
            if parameters?.appTrackingTransparencyStatus == nil {
                try attributesObject.encodeIfPresent(environmentMeta.appTrackingTransparencyStatus, forKey: .appTrackingTransparencyStatus)
            }
        }
    }
}

extension HTTPSession {
    func performUpdateProfileRequest(
        profileId: String,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta?,
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile?>>
    ) {
        let request = UpdateProfileRequest(
            profileId: profileId,
            parameters: parameters,
            environmentMeta: environmentMeta,
            responseHash: responseHash
        )
        perform(request, logName: "update_profile") { (result: UpdateProfileRequest.Result) in
            completion(result
                .map { VH($0.body, hash: $0.headers.getBackendResponseHash()) }
                .mapError { $0.asAdaptyError }
            )
        }
    }
}
