//
//  KinesisCredentials.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct KinesisCredentials: Decodable, Equatable {
    let accessKeyId: String
    let secretSigningKey: String
    let sessionToken: String
    let expiration: Date

    enum CodingKeys: String, CodingKey {
        case accessKeyId = "iam_access_key_id"
        case secretSigningKey = "iam_secret_key"
        case sessionToken = "iam_session_token"
        case expiration = "iam_expiration"
    }
}
