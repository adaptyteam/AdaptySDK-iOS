//
//  CreateProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct CreateProfileRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<AdaptyProfile>

    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let profileId: String
    let parameters: AdaptyProfileParameters?
    let customerUserId: String?
    let appAccountToken: UUID?
    let environmentMeta: Environment.Meta

    init(
        profileId: String,
        customerUserId: String?,
        appAccountToken: UUID?,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta
    ) {
        endpoint = HTTPEndpoint(
            method: .post,
            path: "/sdk/analytics/profiles/\(profileId)/"
        )

        headers = HTTPHeaders().setBackendProfileId(profileId)
        self.profileId = profileId
        self.parameters = parameters
        self.customerUserId = customerUserId
        self.appAccountToken = appAccountToken
        self.environmentMeta = environmentMeta
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
        try dataObject.encode(profileId, forKey: .id)

        if let parameters {
            try dataObject.encode(parameters, forKey: .attributes)
        }
        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)

        try attributesObject.encodeIfPresent(customerUserId, forKey: .customerUserId)
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
        profileId: String,
        customerUserId: String?,
        appAccountToken: UUID?,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta
    ) async throws(HTTPError) -> VH<AdaptyProfile> {
        let request = CreateProfileRequest(
            profileId: profileId,
            customerUserId: customerUserId,
            appAccountToken: appAccountToken,
            parameters: parameters,
            environmentMeta: environmentMeta
        )

        let response = try await perform(
            request,
            requestName: .createProfile,
            logParams: [
                "customer_user_id": customerUserId,
                "app_account_token": appAccountToken?.uuidString
            ]
        )

        return VH(response.body.value, hash: response.headers.getBackendResponseHash())
    }
}
