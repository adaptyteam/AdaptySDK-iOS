//
//  KinesisManager.swift
//  Adapty
//
//  Created by sugaroff on 11/5/19.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation
import AWSCore
import AWSKinesis

enum EventType: String {
    case live = "live"
}

class KinesisManager {

    let streamName: String
    let sessionID = UUID().uuidString

    init(identityPoolId: String, region: AWSRegionType, identityId: String, cognitoToken: String, streamName: String) {
        let provider = CognitoProvider(regionType: region, identityPoolId: identityPoolId, useEnhancedFlow: true, identityProviderManager: nil, token: cognitoToken, identityId: identityId)
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: region, identityProvider: provider)
        let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        let kinesisRecorder = AWSKinesisRecorder.default()
        kinesisRecorder.diskAgeLimit = TimeInterval(30 * 24 * 60 * 60); // 30 days
        kinesisRecorder.diskByteLimit = UInt(10 * 1024 * 1024); // 10MB
        kinesisRecorder.notificationByteThreshold = UInt(5 * 1024 * 1024); // 5MB

        self.streamName = streamName
    }

    func trackEvent(_ eventType: EventType, profileID: String, profileInstallationMetaID: String, completion: ((Error?) -> Void)? = nil) {

        let kinesisRecorder = AWSKinesisRecorder.default()

        var eventParams = [String: String]()

        eventParams["event_name"] = eventType.rawValue
        eventParams["event_id"] = UUID().uuidString
        eventParams["profile_id"] = profileID
        eventParams["profile_installation_meta_id"] = profileInstallationMetaID
        eventParams["session_id"] = sessionID
        eventParams["created_at"] = Date().description

        let eventData = try! JSONEncoder().encode(eventParams)

        kinesisRecorder.saveRecord(eventData, streamName: streamName, partitionKey: profileInstallationMetaID)?.continueOnSuccessWith(block: { task -> Any? in
            return kinesisRecorder.submitAllRecords()
        }).continueWith(block: { task -> Any? in
            completion?(task.error)
            return nil
        })
    }
    
}

class CognitoProvider: AWSCognitoCredentialsProviderHelper {
    
    var token: String?
    
    init(regionType: AWSRegionType, identityPoolId: String, useEnhancedFlow: Bool, identityProviderManager: AWSIdentityProviderManager?, token: String, identityId: String) {
        super.init(regionType: regionType, identityPoolId: identityPoolId, useEnhancedFlow: useEnhancedFlow, identityProviderManager: identityProviderManager)
        
        self.token = token
        self.identityId = identityId
    }
    
    override func logins() -> AWSTask<NSDictionary> {
        if let token = token {
            return AWSTask(result: [AWSIdentityProviderAmazonCognitoIdentity: token])
        }
        
        return AWSTask(error:NSError(domain: "Cognito Login", code: -1 , userInfo: ["Cognito" : "No current Congito access token"]))
    }
    
}
