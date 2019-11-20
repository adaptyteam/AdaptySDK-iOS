//
//  Constants.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation
import AWSCore

struct Constants {
    struct APIKeys {
        // ApiKey will be replaced during SDK active method
        static var secretKey = ""
    }

    struct Kinesis {
        static let streamName = "adapty-sdk-test"
        static let identityPoolId = "us-east-1:f479318d-b226-417d-982a-18f9d87c7f8a"
        static let region = AWSRegionType.USEast1
    }
    
    struct UserDefaults {
        static let profile = "AdaptySDK_Profile"
        static let installation = "AdaptySDK_Installation"
    }
    
    struct Versions {
        static let SDKBuild = 1
    }
}
