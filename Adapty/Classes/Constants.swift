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
        static let streamName = "AWS_STREAM_NAME"
        static let accessKey = "AWS_ACCESS_KEY"
        static let secretKey = "AWS_SECRET_KEY"
        static let region = AWSRegionType.Unknown
    }
    
    struct UserDefaults {
        static let profile = "AdaptySDK_Profile"
        static let installation = "AdaptySDK_Installation"
    }
    
    struct Versions {
        static let SDKBuild = 1
    }
}
