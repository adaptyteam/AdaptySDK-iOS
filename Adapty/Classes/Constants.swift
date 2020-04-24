//
//  Constants.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

struct Constants {
    struct APIKeys {
        // ApiKey will be replaced during SDK active method
        static var secretKey = ""
    }
    
    struct URLs {
        static let api = "api.adapty.io/api"
        static let kinesis = "kinesis.us-east-1.amazonaws.com"
    }
    
    struct Headers {
        static let authorization = "Authorization"
        static let profileId = "ADAPTY-SDK-PROFILE-ID"
        static let platform = "ADAPTY-SDK-PLATFORM"
        static let version = "ADAPTY-SDK-VERSION"
        static let build = "ADAPTY-SDK-VERSION-BUILD"
    }

    struct Kinesis {
        static let streamName = "adapty-data-pipeline-prod"
        static let region = "us-east-1"
        static let hmacShaTypeString = "AWS4-HMAC-SHA256"
        static let serviceType = "kinesis"
        static let aws4Request = "aws4_request"
        static let amzTarget = "Kinesis_20131202.PutRecords"
        static let contentType = "application/x-amz-json-1.1"
    }
    
    struct UserDefaults {
        static let profileId = "AdaptySDK_Profile_Id"
        static let installation = "AdaptySDK_Installation"
        static let cachedEvents = "AdaptySDK_Cached_Events"
        static let cachedTransactionsIds = "AdaptySDK_Cached_Transactions_Ids"
        static let purchaserInfo = "AdaptySDK_Purchaser_Info"
        static let cachedPurchaseContainers = "AdaptySDK_Cached_Purchase_Containers"
        static let cachedProducts = "AdaptySDK_Cached_Products"
    }
    
    struct Versions {
        static let SDKBuild = 1
    }
    
    struct BundleKeys {
        static let appDelegateProxyEnabled = "AdaptyAppDelegateProxyEnabled"
    }
    
    struct TypeNames {
        static let profile = "adapty_analytics_profile"
        static let installation = "adapty_analytics_profile_installation_meta"
        static let appleReceipt = "adapty_inapps_apple_receipt_validation_result"
        static let appleSubscriptionOffer = "adapty_inapps_apple_subscription_offer_signing_result"
        static let profileAttribution = "adapty_analytics_profile_attribution"
    }
    
    struct NotificationPayload {
        static let source = "source"
        static let promoDeliveryId = "promo_delivery_id"
    }
}
