//
//  CreateProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct CreateProfileRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyProfile>

    let endpoint: HTTPEndpoint
    let headers: Headers
    let profileId: String
    let parameters: AdaptyProfileParameters?
    let customerUserId: String?
    let environmentMeta: Environment.Meta

    init(
        profileId: String,
        customerUserId: String?,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta
    ) {
        endpoint = HTTPEndpoint(
            method: .post,
            path: "/sdk/analytics/profiles/\(profileId)/"
        )

        headers = Headers().setBackendProfileId(profileId)
        self.profileId = profileId
        self.parameters = parameters
        self.customerUserId = customerUserId
        var environmentMeta = environmentMeta
        if let analyticsDisabled = parameters?.analyticsDisabled {
            environmentMeta.includedAnalyticIds = !analyticsDisabled
        }
        self.environmentMeta = environmentMeta
    }

    enum CodingKeys: String, CodingKey {
        case customerUserId = "customer_user_id"
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
        try attributesObject.encodeIfPresent(customerUserId, forKey: .customerUserId)
        try attributesObject.encode(environmentMeta, forKey: .environmentMeta)
        try attributesObject.encodeIfPresent(environmentMeta.storeCountry, forKey: .storeCountry)
        try attributesObject.encodeIfPresent(environmentMeta.ipV4Address, forKey: .ipV4Address)

        if parameters?.appTrackingTransparencyStatus == nil {
            try attributesObject.encodeIfPresent(environmentMeta.appTrackingTransparencyStatus, forKey: .appTrackingTransparencyStatus)
        }
    }
}

private extension CreateProfileRequest {
    init(
        profileId: String,
        customerUserId: String?,
        analyticsDisabled: Bool
    ) {
        self.init(
            profileId: profileId,
            customerUserId: customerUserId,
            parameters: AdaptyProfileParameters.Builder()
                .with(analyticsDisabled: analyticsDisabled)
                .build(),
            environmentMeta: Environment.Meta(includedAnalyticIds: !analyticsDisabled)
        )
    }
}

extension HTTPSession {
    func performCreateProfileRequest(
        profileId: String,
        customerUserId: String?,
        analyticsDisabled: Bool,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>
    ) {
        let request = CreateProfileRequest(
            profileId: profileId,
            customerUserId: customerUserId,
            analyticsDisabled: analyticsDisabled
        )
        perform(
            request,
            logName: "create_profile",
            logParams: ["has_customer_user_id": .value(customerUserId != nil)]
        ) { (result: CreateProfileRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
