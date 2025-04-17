//
//  ValidateReceiptRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct ValidateReceiptRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<AdaptyProfile>

    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/in-apps/apple/receipt/validate/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let profileId: String
    let receipt: Data

    init(profileId: String, receipt: Data) {
        headers = HTTPHeaders().setBackendProfileId(profileId)
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

extension Backend.MainExecutor {
    func validateReceipt(
        profileId: String,
        receipt: Data
    ) async throws -> VH<AdaptyProfile> {
        let request = ValidateReceiptRequest(profileId: profileId, receipt: receipt)

        let response = try await perform(
            request,
            requestName: .validateReceipt
        )

        return VH(response.body.value, hash: response.headers.getBackendResponseHash())
    }
}
