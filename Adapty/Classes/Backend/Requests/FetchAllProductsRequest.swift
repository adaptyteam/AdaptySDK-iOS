//
//  FetchAllProductsRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchAllProductsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<[BackendProduct]?>
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/purchase-products/"
    )
    let headers: Headers
    let queryItems: QueryItems

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<[BackendProduct]?, Error>

            if headers.hasSameBackendResponseHash(response.headers) {
                result = .success(nil)
            } else {
                result = jsonDecoder.decode(Backend.Response.ValueOfData<[BackendProduct]>.self, response.body).map { $0.value }
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
    func performFetchAllProductsRequest(profileId: String,
                                        responseHash: String?,
                                        syncedBundleReceipt: Bool,
                                        _ completion: @escaping AdaptyResultCompletion<VH<[BackendProduct]?>>) {
        let request = FetchAllProductsRequest(profileId: profileId,
                                              responseHash: responseHash)

        perform(request) { (result: FetchAllProductsRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value?.map(syncedBundleReceipt: syncedBundleReceipt), hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
