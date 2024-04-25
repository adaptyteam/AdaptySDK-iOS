//
//  SetASATokenRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.03.2024.
//

import Foundation

private struct SetASATokenRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyProfile?
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/attribution/asa/"
    )
    let headers: Headers
    let token: String

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        createDecoder(jsonDecoder)
    }

    init(profileId: String, token: String, responseHash: String?) {
        headers = Headers()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)

        self.token = token
    }

    enum CodingKeys: String, CodingKey {
        case token
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_attribution_asa", forKey: .type)
        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        try attributesObject.encode(token, forKey: .token)
    }
}

extension HTTPSession {
    func performASATokenRequest(
        profileId: String,
        token: String,
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile?>>
    ) {
        let request = SetASATokenRequest(
            profileId: profileId,
            token: token,
            responseHash: responseHash
        )
        perform(
            request,
            logName: "set_asa_token",
            logParams: ["token": .value(token)]
        ) { (result: SetASATokenRequest.Result) in
            completion(result
                .map { VH($0.body, hash: $0.headers.getBackendResponseHash()) }
                .mapError { $0.asAdaptyError }
            )
        }
    }
}
