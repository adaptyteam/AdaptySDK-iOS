//
//  FetchAllProductVendorIdsRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchAllProductVendorIdsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<[String]?>
    let endpoint: HTTPEndpoint
    let headers: Headers

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<[String]?, Error>

            if headers.hasSameBackendResponseHash(response.headers) {
                result = .success(nil)
            } else {
                result = jsonDecoder.decode(Backend.Response.ValueOfData<[String]>.self, response.body).map { $0.value }
            }
            return result.map { response.replaceBody(Backend.Response.Body($0)) }
                .mapError { .decoding(response, error: $0) }
        }
    }

    init(apiKeyPrefix: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/products-ids/app_store/"
        )

        headers = Headers()
            .setBackendResponseHash(responseHash)
    }
}
