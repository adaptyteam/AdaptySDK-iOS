//
//  FetchAllProductVendorIdsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchAllProductVendorIdsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<[String]>
    let endpoint: HTTPEndpoint

    init(apiKeyPrefix: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/products-ids/app_store/"
        )
    }
}
