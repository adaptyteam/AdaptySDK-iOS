//
//  InstallationModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 01/11/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

public class InstallationModel: JSONCodable, Codable {
    
    var profileInstallationMetaId: String
    var iamAccessKeyId: String
    var iamSecretKey: String
    var iamSessionToken: String
    
    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let profileInstallationMetaId = attributes?["id"] as? String
        else {
            throw SerializationError.missing("InstallationModel - id")
        }
        
        self.profileInstallationMetaId = profileInstallationMetaId
        self.iamAccessKeyId = attributes?["iam_access_key_id"] as? String ?? ""
        self.iamSecretKey = attributes?["iam_secret_key"] as? String ?? ""
        self.iamSessionToken = attributes?["iam_session_token"] as? String ?? ""
        
        logMissingRequiredParams()
    }
    
    private func logMissingRequiredParams() {
        var missingParams = ""
        if self.iamAccessKeyId.isEmpty { missingParams.append("iam_access_key_id") }
        if self.iamSecretKey.isEmpty { missingParams.append("iam_secret_key") }
        if self.iamSessionToken.isEmpty { missingParams.append("iam_session_token") }
        if !missingParams.isEmpty { LoggerManager.logError("Missing some of the required params of InstallationModel: \(missingParams)") }
    }
    
}
