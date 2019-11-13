//
//  InstallationModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 01/11/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

public class InstallationModel: JSONCodable, Codable {
    
    var profileInstallationMetaId: String
    
    required init?(json: Parameters) throws {
        guard let profileInstallationMetaId = json["profile_installation_meta_id"] as? String else {
            throw SerializationError.missing("profileInstallationMetaId")
        }
        
        self.profileInstallationMetaId = profileInstallationMetaId
    }
    
}
