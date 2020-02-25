//
//  ProfileModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

public class ProfileModel: JSONCodable, Codable {
    
    var profileId: String
    var customerUserId: String?

    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let profileId = attributes?["id"] as? String
        else {
            throw SerializationError.missing("id")
        }
        
        self.profileId = profileId
        self.customerUserId = attributes?["customer_user_id"] as? String
    }
    
}
