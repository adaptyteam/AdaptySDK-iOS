//
//  SK2StorefrontManager.swift
//
//
//  Created by Aleksey Goncharov on 30.1.24..
//

import Foundation
import StoreKit

//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//class SK2StorefrontManager: StorefrontManager {
//    func fetchStoreCountry(_ callback: @escaping (String?) -> Void) {
//        Task {
//            let countryCode = await Storefront.current?.countryCode
//            callback(countryCode)
//        }
//    }
//
//    func subscribeForUpdates(_ callback: @escaping (String) -> Void) {
//        Task(priority: .utility) {
//            for await value in Storefront.updates {
//                let countryCode = value.countryCode
//
//                Log.verbose("SK2StorefrontManager: Storefront.updates new value: \(countryCode)")
//
//                callback(countryCode)
//            }
//        }
//    }
//}
