//
//  CreateProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct CreateProfileRequest: BackendEncodableRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp
    let logName = APIRequestName.createProfile
    let logParams: EventParameters?

    let userId: AdaptyUserId
    let appAccountToken: UUID?
    let parameters: AdaptyProfileParameters?
    let environmentMeta: Environment.Meta

    init(
        userId: AdaptyUserId,
        appAccountToken: UUID?,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta
    ) {
        endpoint = HTTPEndpoint(
            method: .post,
            path: "/sdk/analytics/profiles/\(userId.profileId)/"
        )

        headers = HTTPHeaders()
            .setUserProfileId(userId)

        self.userId = userId
        self.appAccountToken = appAccountToken
        self.parameters = parameters
        self.environmentMeta = environmentMeta

        logParams = [
            "customer_user_id": userId.customerId,
            "app_account_token": appAccountToken?.uuidString
        ]
    }

    enum CodingKeys: String, CodingKey {
        case customerUserId = "customer_user_id"
        case appAccountToken = "store_account_token"
        case environmentMeta = "installation_meta"
        case storeCountry = "store_country"
        case ipV4Address = "ip_v4_address"
        case appTrackingTransparencyStatus = "att_status"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_analytics_profile", forKey: .type)
        try dataObject.encode(userId.profileId, forKey: .id)

        if let parameters {
            try dataObject.encode(parameters, forKey: .attributes)
        }
        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)

        try attributesObject.encodeIfPresent(userId.customerId, forKey: .customerUserId)
        try attributesObject.encodeIfPresent(appAccountToken?.uuidString.lowercased(), forKey: .appAccountToken)
        try attributesObject.encode(environmentMeta, forKey: .environmentMeta)
        if parameters?.storeCountry == nil {
            try attributesObject.encodeIfPresent(environmentMeta.storefront?.countryCode, forKey: .storeCountry)
        }
        if parameters?.ipV4Address == nil {
            try attributesObject.encodeIfPresent(environmentMeta.ipV4Address, forKey: .ipV4Address)
        }

        if parameters?.appTrackingTransparencyStatus == nil {
            try attributesObject.encodeIfPresent(environmentMeta.appTrackingTransparencyStatus, forKey: .appTrackingTransparencyStatus)
        }
    }
}

extension Backend.MainExecutor {
    func createProfile(
        userId: AdaptyUserId,
        appAccountToken: UUID?,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta
    ) async throws(HTTPError) -> VH<AdaptyProfile> {
        let request = CreateProfileRequest(
            userId: userId,
            appAccountToken: appAccountToken,
            parameters: parameters,
            environmentMeta: environmentMeta
        )
        let response = try await perform(request, withDecoder: VH<AdaptyProfile>.decoder)
        return response.body
    }
}
