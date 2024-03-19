//
//  ValidateReceiptRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct ValidateReceiptRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyProfile>

    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/in-apps/apple/receipt/validate/"
    )
    let headers: Headers
    let profileId: String
    let receipt: Data

    init(profileId: String, receipt: Data) {
        headers = Headers().setBackendProfileId(profileId)
        self.profileId = profileId
        self.receipt = receipt
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "profile_id"
        case receipt = "receipt_encoded"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_inapps_apple_receipt_validation_result", forKey: .type)

        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        try attributesObject.encode(profileId, forKey: .profileId)
        try attributesObject.encode(receipt, forKey: .receipt)
    }
}

extension HTTPSession {
    func performValidateReceiptRequest(
        profileId: String,
        receipt: Data,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>
    ) {
        let request = ValidateReceiptRequest(profileId: profileId, receipt: receipt)

        perform(request, logName: "validate_receipt") { (result: ValidateReceiptRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, hash: response.headers.getBackendResponseHash())))
            }
        }
    }
}
