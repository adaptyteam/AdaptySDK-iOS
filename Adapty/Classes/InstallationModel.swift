//
//  InstallationModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 01/11/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

public class InstallationModel: JSONCodable, Codable {
    
    var profileId: String
    var profileInstallationMetaId: String
    var iamAccessKeyId: String
    var iamSecretKey: String
    var iamSessionToken: String
    var iamExpiration: String
    
    required init?(json: Parameters) throws {
        guard
            let profileId = json["profile_id"] as? String,
            let profileInstallationMetaId = json["profile_installation_meta_id"] as? String,
            let iamAccessKeyId = json["iam_access_key_id"] as? String,
            let iamSecretKey = json["iam_secret_key"] as? String,
            let iamSessionToken = json["iam_session_token"] as? String,
            let iamExpiration = json["iam_expiration"] as? String
        else {
            throw SerializationError.missing("profileId, profileInstallationMetaId, iam_access_key_id, iam_secret_key, iam_session_token, iam_expiration")
        }
        
        self.profileId = profileId
        self.profileInstallationMetaId = profileInstallationMetaId
        self.iamAccessKeyId = iamAccessKeyId
        self.iamSecretKey = iamSecretKey
        self.iamSessionToken = iamSessionToken
        self.iamExpiration = iamExpiration
    }
    
}
