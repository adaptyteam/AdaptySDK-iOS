//
//  Constants.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

struct Constants {
    struct APIKeys {
        // ApiKey will be replaced during SDK active method
        static var secretKey = ""
    }
    
    struct Headers {
        static let authorization = "Authorization"
        static let profileId = "ADAPTY-SDK-PROFILE-ID"
    }

    struct Kinesis {
        static let streamName = "adapty-sdk-test"
        static let region = "us-east-1"
        static let hmacShaTypeString = "AWS4-HMAC-SHA256"
        static let serviceType = "kinesis"
        static let aws4Request = "aws4_request"
        static let amzTarget = "Kinesis_20131202.PutRecords"
        static let contentType = "application/x-amz-json-1.1"
    }
    
    struct UserDefaults {
        static let profile = "AdaptySDK_Profile"
        static let installation = "AdaptySDK_Installation"
        static let cachedEvents = "AdaptySDK_Cached_Events"
        static let cachedTransactionsIds = "AdaptySDK_Cached_Transactions_Ids"
    }
    
    struct Versions {
        static let SDKBuild = 1
    }
    
    struct BundleKeys {
        static let appDelegateProxyEnabled = "AdaptyAppDelegateProxyEnabled"
    }
}
