//
//  InstallationModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 01/11/2019.
//  Copyright © 2019 Adapty. All rights reserved.
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
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let profileInstallationMetaId = attributes?["id"] as? String,
            let profileId = attributes?["profile_id"] as? String,
            let iamAccessKeyId = attributes?["iam_access_key_id"] as? String,
            let iamSecretKey = attributes?["iam_secret_key"] as? String,
            let iamSessionToken = attributes?["iam_session_token"] as? String,
            let iamExpiration = attributes?["iam_expiration"] as? String
        else {
            throw SerializationError.missing("id, profileId, iam_access_key_id, iam_secret_key, iam_session_token, iam_expiration")
        }
        
        self.profileId = profileId
        self.profileInstallationMetaId = profileInstallationMetaId
        self.iamAccessKeyId = iamAccessKeyId
        self.iamSecretKey = iamSecretKey
        self.iamSessionToken = iamSessionToken
        self.iamExpiration = iamExpiration
    }
    
}
