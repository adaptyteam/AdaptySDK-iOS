//
//  Environment+SendBox.swift
//  AaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

private let log = Log.default

extension Environment.System {
    
    static var storeCountry: String? { SKStorefrontManager.countryCode }

    static let isSandbox: Bool = {
        guard !Environment.Device.isSimulator else { return true }

        guard let path = Bundle.main.appStoreReceiptURL?.path else { return false }

        if path.contains("MASReceipt/receipt") {
            return path.contains("Xcode/DerivedData")
        } else {
            return path.contains("sandboxReceipt")
        }
    }()

    static let storeKit2Enabled: Bool =
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            true
        } else {
            false
        }
}
