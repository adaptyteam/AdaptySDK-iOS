//
//  FetchProfileRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchProfileRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<Profile?>
    let endpoint: HTTPEndpoint
    let headers: Headers

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<Profile?, Error>

            if headers.hasSameBackendResponseHash(response.headers) {
                result = .success(nil)
            } else {
                result = jsonDecoder.decode(Backend.Response.Body<Profile>.self, response.body).map { $0.value }
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
    func performFetchProfileRequest(profileId: String,
                                    responseHash: String?,
                                    _ completion: @escaping ResultCompletion<VH<Profile?>>) {
        let request = FetchProfileRequest(profileId: profileId,
                                          responseHash: responseHash)

        perform(request) { (result: FetchProfileRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
