//
//  FetchProductStatesRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchProductStatesRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<[BackendProductState]?>
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/purchase-products/"
    )
    let headers: Headers
    let queryItems: QueryItems

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<[BackendProductState]?, Error> =
                if headers.hasSameBackendResponseHash(response.headers) {
                    .success(nil)
                } else {
                    jsonDecoder.decode(Backend.Response.ValueOfData<[BackendProductState]>.self, response.body).map { $0.value }
                }
            return result.map { response.replaceBody(Backend.Response.Body($0)) }
                .mapError { .decoding(response, error: $0) }
        }
    }

    init(profileId: String, responseHash: String?) {
        headers = Headers()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)
        queryItems = QueryItems().setBackendProfileId(profileId)
    }
}

extension HTTPSession {
    func performFetchProductStatesRequest(
        profileId: String,
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<[BackendProductState]?>>
    ) {
        let request = FetchProductStatesRequest(profileId: profileId, responseHash: responseHash)
        perform(request, logName: "get_products") { (result: FetchProductStatesRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                let products = response.body.value
                let hash = response.headers.getBackendResponseHash()
                completion(.success(VH(products, hash: hash)))
            }
        }
    }
}
