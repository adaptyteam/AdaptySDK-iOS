//
//  FetchProductStatesRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchProductStatesRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = [BackendProductState]?
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/products/"
    )
    let headers: Headers
    let queryItems: QueryItems

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        createDecoder(jsonDecoder)
    }

    init(profileId: String, responseHash: String?) {
        headers = Headers()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)
        queryItems = QueryItems().setBackendProfileId(profileId)
    }
}

extension HTTPRequestWithDecodableResponse where ResponseBody == [BackendProductState]? {
    func createDecoder(
        _ jsonDecoder: JSONDecoder
    ) -> (HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result {
        { decodeResponse($0, jsonDecoder) }
    }

    func decodeResponse(
        _ response: HTTPDataResponse,
        _ jsonDecoder: JSONDecoder
    ) -> HTTPResponse<ResponseBody>.Result {
        typealias ResponseData = Backend.Response.ValueOfData<[BackendProductState]>

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
    func performFetchProductStatesRequest(
        profileId: String,
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<[BackendProductState]?>>
    ) {
        let request = FetchProductStatesRequest(profileId: profileId, responseHash: responseHash)
        perform(request, logName: "get_products") { (result: FetchProductStatesRequest.Result) in
            completion(result
                .map { VH($0.body, hash: $0.headers.getBackendResponseHash()) }
                .mapError { $0.asAdaptyError }
            )
        }
    }
}
