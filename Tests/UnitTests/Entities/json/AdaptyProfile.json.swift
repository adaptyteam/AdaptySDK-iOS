//
//  AdaptyProfile.json.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK

extension AdaptyProfile {
    enum ValidJSON {
        static let all = [empty, withCustomAttributes, example]

        static let empty: JSONValue =
            ["app_id": "14c3d623-2f3a-455a-aa86-ef83dff6913b",
             "profile_id": "bd7ef643-b3e9-43a0-99b9-9f5a118b916b",
             "customer_user_id": .null,
             "total_revenue_usd": 0.0,
             "paid_access_levels": .null,
             "subscriptions": .null,
             "non_subscriptions": .null,
             "promotional_offer_eligibility": false,
             "introductory_offer_eligibility": true]

        static let withCustomAttributes: JSONValue =
            ["app_id": "14c3d623-2f3a-455a-aa86-ef83dff6913b",
             "profile_id": "b8937cc3-27be-417b-931f-a710c5e69c6f",
             "customer_user_id": .null,
             "total_revenue_usd": 0.0,
             "paid_access_levels": .null,
             "subscriptions": .null,
             "non_subscriptions": .null,
             "custom_attributes": ["custom_bool": 1.0,
                                   "custom_float": 1984.84,
                                   "custom_int": 123.0,
                                   "custom_string": "str_value",
                                   "custom_uint": 234.0],
             "promotional_offer_eligibility": false,
             "introductory_offer_eligibility": true]

        static let example: JSONValue =
            ["app_id": "14c3d623-2f3a-455a-aa86-ef83dff6913b",
             "profile_id": "79182a1e-575e-40a4-8afe-7614adf5ee9d",
             "customer_user_id": .null,
             "total_revenue_usd": 227.73524709468688,
             "paid_access_levels": [
                 "premium": ["id": "premium",
                             "is_active": true,
                             "is_lifetime": true,
                             "expires_at": .null,
                             "starts_at": .null,
                             "will_renew": false,
                             "vendor_product_id": "unlimited.9999",
                             "store": "app_store",
                             "activated_at": "2022-09-30T15:14:32.000000+0000",
                             "renewed_at": "2022-09-30T15:48:00.000000+0000",
                             "unsubscribed_at": .null,
                             "billing_issue_detected_at": .null,
                             "is_in_grace_period": false,
                             "active_introductory_offer_type": .null,
                             "active_promotional_offer_type": .null,
                             "active_promotional_offer_id": .null,
                             "cancellation_reason": .null,
                             "is_refund": false]],
             "subscriptions": [
                 "weekly.premium.599": ["is_active": false,
                                        "is_lifetime": false,
                                        "expires_at": "2022-09-30T15:51:00.000000+0000",
                                        "starts_at": .null,
                                        "will_renew": false,
                                        "vendor_product_id": "weekly.premium.599",
                                        "vendor_transaction_id": "2000000167503456",
                                        "vendor_original_transaction_id": "2000000167490043",
                                        "store": "app_store",
                                        "activated_at": "2022-09-30T15:14:32.000000+0000",
                                        "renewed_at": "2022-09-30T15:48:00.000000+0000",
                                        "unsubscribed_at": "2022-09-30T15:51:00.000000+0000",
                                        "billing_issue_detected_at": "2022-09-30T15:51:00.000000+0000",
                                        "is_in_grace_period": false,
                                        "active_introductory_offer_type": .null,
                                        "active_promotional_offer_type": .null,
                                        "active_promotional_offer_id": .null,
                                        "cancellation_reason": "voluntarily_cancelled",
                                        "is_sandbox": true,
                                        "is_refund": false],
                 "unlimited.9999": ["is_active": true,
                                    "is_lifetime": true,
                                    "expires_at": .null,
                                    "starts_at": .null,
                                    "will_renew": false,
                                    "vendor_product_id": "unlimited.9999",
                                    "vendor_transaction_id": "2000000189496548",
                                    "vendor_original_transaction_id": "2000000189496548",
                                    "store": "app_store",
                                    "activated_at": "2022-10-30T16:17:17.000000+0000",
                                    "renewed_at": .null,
                                    "unsubscribed_at": .null,
                                    "billing_issue_detected_at": .null,
                                    "is_in_grace_period": false,
                                    "active_introductory_offer_type": .null,
                                    "active_promotional_offer_type": .null,
                                    "active_promotional_offer_id": .null,
                                    "cancellation_reason": .null,
                                    "is_sandbox": true,
                                    "is_refund": false]],
             "non_subscriptions": [
                 "consumable_apples_99": [["purchase_id": "5ecfeb86-538d-4090-8182-572b70b5c4ca",
                                           "purchased_at": "2022-10-30T16:20:38.000000+0000",
                                           "vendor_product_id": "consumable_apples_99",
                                           "vendor_transaction_id": "2000000189496768",
                                           "vendor_original_transaction_id": "2000000189496768",
                                           "store": "app_store",
                                           "is_one_time": false,
                                           "is_sandbox": true,
                                           "is_refund": false]]],
             "custom_attributes": [:],
             "promotional_offer_eligibility": false,
             "introductory_offer_eligibility": true]
    }
}
