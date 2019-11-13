//
//  ProfileModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

public class ProfileModel: JSONCodable, Codable {
    
    var profileId: String
    var customerUserId: String

    required init?(json: Parameters) throws {
        guard let profileId = json["profile_id"] as? String,
            let customerUserId = json["customer_user_id"] as? String else {
                throw SerializationError.missing("profileId, customerUserId")
        }
        
        self.profileId = profileId
        self.customerUserId = customerUserId
    }
    
}
