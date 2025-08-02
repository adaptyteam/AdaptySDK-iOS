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
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let userId: AdaptyUserId
    let parameters: AdaptyProfileParameters?
    let environmentMeta: Environment.Meta?

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeResponse(
            response,
            withConfiguration: configuration,
            requestHeaders: headers
        )
    }

    init(
        userId: AdaptyUserId,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta?,
        responseHash: String?
    ) {
        endpoint = HTTPEndpoint(
            method: .patch,
            path: "/sdk/analytics/profiles/\(userId.profileId)/"
        )

        headers = HTTPHeaders()
            .setUserProfileId(userId)
            .setBackendResponseHash(responseHash)

        self.userId = userId
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
        try dataObject.encode(userId.profileId, forKey: .id)

        if let parameters {
            try dataObject.encode(parameters, forKey: .attributes)
        }
        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)

        if let environmentMeta {
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
}

extension Backend.MainExecutor {
    func syncProfile(
        userId: AdaptyUserId,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta?,
        responseHash: String?
    ) async throws(HTTPError) -> VH<AdaptyProfile?> {
        if parameters == nil, environmentMeta == nil {
            try await fetchProfile(
                userId: userId,
                responseHash: responseHash
            )
        } else {
            try await updateProfile(
                userId: userId,
                parameters: parameters,
                environmentMeta: environmentMeta,
                responseHash: responseHash
            )
        }
    }

    private func updateProfile(
        userId: AdaptyUserId,
        parameters: AdaptyProfileParameters?,
        environmentMeta: Environment.Meta?,
        responseHash: String?
    ) async throws(HTTPError) -> VH<AdaptyProfile?> {
        let request = UpdateProfileRequest(
            userId: userId,
            parameters: parameters,
            environmentMeta: environmentMeta,
            responseHash: responseHash
        )

        let response = try await perform(
            request,
            requestName: .updateProfile
        )

        return VH(response.body, hash: response.headers.getBackendResponseHash())
    }
}
