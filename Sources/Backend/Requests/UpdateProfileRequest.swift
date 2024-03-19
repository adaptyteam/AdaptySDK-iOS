//
//  UpdateProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

extension Backend.Request {
    enum SendEnvironment {
        case dont
        case withAnalytics
        case withoutAnalytics
    }
}

private struct UpdateProfileRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyProfile?>
    let endpoint: HTTPEndpoint
    let headers: Headers
    let profileId: String
    let parameters: AdaptyProfileParameters?
    let environmentMeta: Environment.Meta?

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

    init(
        profileId: String,
        parameters: AdaptyProfileParameters? = nil,
        sendEnvironmentMeta: Backend.Request.SendEnvironment,
        responseHash: String?
    ) {
        let environmentMeta: Environment.Meta? =
            switch sendEnvironmentMeta {
            case .dont:
                nil
            case .withAnalytics:
                Environment.Meta(includedAnalyticIds: !(parameters?.analyticsDisabled ?? false))
            case .withoutAnalytics:
                Environment.Meta(includedAnalyticIds: !(parameters?.analyticsDisabled ?? true))
            }

        self.init(
            profileId: profileId,
            parameters: parameters,
            environmentMeta: environmentMeta,
            responseHash: responseHash
        )
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

        guard let analyticsDisabled = parameters?.analyticsDisabled else {
            self.environmentMeta = environmentMeta
            return
        }
        if var environmentMeta {
            environmentMeta.includedAnalyticIds = !analyticsDisabled
            self.environmentMeta = environmentMeta
        } else {
            self.environmentMeta = !analyticsDisabled ? Environment.Meta(includedAnalyticIds: true) : nil
        }
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
        sendEnvironmentMeta: Backend.Request.SendEnvironment,
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile?>>
    ) {
        let request = UpdateProfileRequest(
            profileId: profileId,
            parameters: parameters,
            sendEnvironmentMeta: sendEnvironmentMeta,
            responseHash: responseHash
        )
        perform(request, logName: "update_profile") { (result: UpdateProfileRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
