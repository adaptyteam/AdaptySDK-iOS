//
//  FetchProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchProfileRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyProfile?
    let endpoint: HTTPEndpoint
    let headers: Headers

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        createDecoder(jsonDecoder)
    }

    init(profileId: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/analytics/profiles/\(profileId)/"
        )

        headers = Headers()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)
    }
}

extension HTTPRequestWithDecodableResponse where ResponseBody == AdaptyProfile? {
    func createDecoder(
        _ jsonDecoder: JSONDecoder
    ) -> (HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result {
        { decodeResponse($0, jsonDecoder) }
    }

    func decodeResponse(
        _ response: HTTPDataResponse,
        _ jsonDecoder: JSONDecoder
    ) -> HTTPResponse<ResponseBody>.Result {
        typealias ResponseData = Backend.Response.ValueOfData<AdaptyProfile>

        let result: Swift.Result<ResponseBody, Error> =
            if headers.hasSameBackendResponseHash(response.headers) {
                .success(nil)
            } else {
                jsonDecoder.decode(ResponseData.self, response.body).map { $0.value }
            }

        return result
            .map { response.replaceBody($0) }
            .mapError { .decoding(response, error: $0) }
    }
}

extension HTTPSession {
    func performFetchProfileRequest(
        profileId: String,
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile?>>
    ) {
        let request = FetchProfileRequest(
            profileId: profileId,
            responseHash: responseHash
        )
        perform(request, logName: "get_profile") { (result: FetchProfileRequest.Result) in
            completion(result
                .map { VH($0.body, hash: $0.headers.getBackendResponseHash()) }
                .mapError { $0.asAdaptyError }
            )
        }
    }
}
