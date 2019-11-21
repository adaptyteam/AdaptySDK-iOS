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
    var cognitoId: String
    var cognitoToken: String
    
    required init?(json: Parameters) throws {
        guard let profileId = json["profile_id"] as? String,
            let profileInstallationMetaId = json["profile_installation_meta_id"] as? String,
            let cognitoId = json["cognito_id"] as? String,
            let cognitoToken = json["cognito_token"] as? String else {
            throw SerializationError.missing("profileId, profileInstallationMetaId, cognitoId, cognitoToken")
        }
        
        self.profileId = profileId
        self.profileInstallationMetaId = profileInstallationMetaId
        self.cognitoId = cognitoId
        self.cognitoToken = cognitoToken
    }
    
}
