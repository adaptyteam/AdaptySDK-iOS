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
    case sessionStart = "session_start"
    case sessionEnd = "session_end"
}

class KinesisManager {

    let streamName: String
    let sessionID = UUID().uuidString

    init(accessKey: String, secretAccessKey: String, region: AWSRegionType, streamName: String) {

        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretAccessKey)
        let configuration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        let kinesisRecorder = AWSKinesisRecorder.default()
        kinesisRecorder.diskAgeLimit = TimeInterval(30 * 24 * 60 * 60); // 30 days
        kinesisRecorder.diskByteLimit = UInt(10 * 1024 * 1024); // 10MB
        kinesisRecorder.notificationByteThreshold = UInt(5 * 1024 * 1024); // 5MB

        self.streamName = streamName
    }

    func trackEvent(_ eventType: EventType, profileID: String, profileInstallationMetaID: String) {

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
        })
    }
    
}
