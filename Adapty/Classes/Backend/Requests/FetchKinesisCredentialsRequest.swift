//
//  FetchKinesisCredentialsRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchKinesisCredentialsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<KinesisCredentials>

    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/kinesis/credentials/"
    )
    let headers: Headers

    init(profileId: String) {
        headers = Headers().setBackendProfileId(profileId)
    }
}
