//
//  FetchProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchProfileRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyProfile?>
    let endpoint: HTTPEndpoint
    let headers: Headers

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
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
