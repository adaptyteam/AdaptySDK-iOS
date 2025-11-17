//
//  ValidateReceiptRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct ValidateReceiptRequest: BackendEncodableRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/in-apps/apple/receipt/validate/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp
    let requestName = BackendRequestName.validateReceipt

    let userId: AdaptyUserId
    let receipt: Data

    init(userId: AdaptyUserId, receipt: Data) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)

        self.userId = userId
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
        try attributesObject.encode(userId.profileId, forKey: .profileId)
        try attributesObject.encode(receipt, forKey: .receipt)
    }
}

extension Backend.MainExecutor {
    func validateReceipt(
        userId: AdaptyUserId,
        receipt: Data
    ) async throws(HTTPError) -> VH<AdaptyProfile> {
        let request = ValidateReceiptRequest(
            userId: userId,
            receipt: receipt
        )
        let response = try await perform(request, withDecoder: VH<AdaptyProfile>.decoder)
        return response.body
    }
}
