//
//  Dev_PreviewEnvironment.swift
//  AdaptyDeveloperTools
//
//  Created by Alexey Goncharov on 05.05.2026.
//

import Adapty
import AdaptyUIBuilder
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct Dev_PreviewEnvironment: Sendable {
    public var sdkVersion: String
    public var osName: String
    public var osVersion: String
    public var deviceModel: String
    public var appBundleId: String?
    public var appVersion: String?
    public var appBuild: String?
    public var appCurrentLocale: String?
    public var userLocales: [String]
    public var userUses24HourClock: Bool

    public var placementId: String
    public var variationId: String
    public var abTestName: String
    public var placementName: String

    public var products: [Dev_PreviewProduct]

    public init(
        sdkVersion: String,
        osName: String,
        osVersion: String,
        deviceModel: String,
        appBundleId: String?,
        appVersion: String?,
        appBuild: String?,
        appCurrentLocale: String?,
        userLocales: [String],
        userUses24HourClock: Bool,
        placementId: String,
        variationId: String,
        abTestName: String,
        placementName: String,
        products: [Dev_PreviewProduct] = []
    ) {
        self.sdkVersion = sdkVersion
        self.osName = osName
        self.osVersion = osVersion
        self.deviceModel = deviceModel
        self.appBundleId = appBundleId
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.appCurrentLocale = appCurrentLocale
        self.userLocales = userLocales
        self.userUses24HourClock = userUses24HourClock
        self.placementId = placementId
        self.variationId = variationId
        self.abTestName = abTestName
        self.placementName = placementName
        self.products = products
    }

    public static let empty = Dev_PreviewEnvironment(
        sdkVersion: "",
        osName: "",
        osVersion: "",
        deviceModel: "",
        appBundleId: nil,
        appVersion: nil,
        appBuild: nil,
        appCurrentLocale: nil,
        userLocales: [],
        userUses24HourClock: true,
        placementId: "",
        variationId: "",
        abTestName: "",
        placementName: "",
        products: []
    )

    @MainActor
    public static func systemDefault(
        placementId: String = "preview_placement",
        variationId: String = "preview_variation",
        abTestName: String = "preview_abtest",
        placementName: String = "preview",
        products: [Dev_PreviewProduct] = []
    ) -> Dev_PreviewEnvironment {
        Dev_PreviewEnvironment(
            sdkVersion: Adapty.SDKVersion,
            osName: detectedOSName,
            osVersion: detectedOSVersion,
            deviceModel: detectedDeviceModel,
            appBundleId: Bundle.main.bundleIdentifier,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            appBuild: Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
            appCurrentLocale: Bundle.main.preferredLocalizations.first,
            userLocales: Locale.preferredLanguages,
            userUses24HourClock: detectUses24HourClock(),
            placementId: placementId,
            variationId: variationId,
            abTestName: abTestName,
            placementName: placementName,
            products: products
        )
    }

}

public struct Dev_PreviewProduct: Sendable {
    public var flowProductId: String
    public var adaptyProductId: String
    public var adaptyAccessLevelId: String
    public var adaptyProductType: String
    public var paywallVariationId: String
    public var paywallName: String

    public var localizedDescription: String?
    public var localizedTitle: String?
    public var isFamilyShareable: Bool
    public var regionCode: String?
    public var price: Price?
    public var subscription: Subscription?

    public init(
        flowProductId: String,
        adaptyProductId: String,
        adaptyAccessLevelId: String = "premium",
        adaptyProductType: String = "subscription",
        paywallVariationId: String = "preview_variation",
        paywallName: String = "preview",
        localizedDescription: String? = nil,
        localizedTitle: String? = nil,
        isFamilyShareable: Bool = false,
        regionCode: String? = nil,
        price: Price? = nil,
        subscription: Subscription? = nil
    ) {
        self.flowProductId = flowProductId
        self.adaptyProductId = adaptyProductId
        self.adaptyAccessLevelId = adaptyAccessLevelId
        self.adaptyProductType = adaptyProductType
        self.paywallVariationId = paywallVariationId
        self.paywallName = paywallName
        self.localizedDescription = localizedDescription
        self.localizedTitle = localizedTitle
        self.isFamilyShareable = isFamilyShareable
        self.regionCode = regionCode
        self.price = price
        self.subscription = subscription
    }

    public struct Price: Sendable {
        public var amount: Double
        public var currencyCode: String?
        public var currencySymbol: String?
        public var localizedString: String?

        public init(
            amount: Double,
            currencyCode: String? = nil,
            currencySymbol: String? = nil,
            localizedString: String? = nil
        ) {
            self.amount = amount
            self.currencyCode = currencyCode
            self.currencySymbol = currencySymbol
            self.localizedString = localizedString
        }
    }

    public struct Subscription: Sendable {
        public var groupIdentifier: String
        public var period: Period
        public var localizedPeriod: String?
        public var offer: Offer?

        public init(
            groupIdentifier: String,
            period: Period,
            localizedPeriod: String? = nil,
            offer: Offer? = nil
        ) {
            self.groupIdentifier = groupIdentifier
            self.period = period
            self.localizedPeriod = localizedPeriod
            self.offer = offer
        }

        public struct Period: Sendable {
            public var unit: String
            public var numberOfUnits: Int

            public init(unit: String, numberOfUnits: Int) {
                self.unit = unit
                self.numberOfUnits = numberOfUnits
            }
        }

        public struct Offer: Sendable {
            public var id: String?
            public var type: String
            public var price: Price?
            public var paymentMode: String
            public var period: Period
            public var numberOfPeriods: Int
            public var localizedPeriod: String?
            public var localizedNumberOfPeriods: String?

            public init(
                id: String? = nil,
                type: String,
                price: Price? = nil,
                paymentMode: String,
                period: Period,
                numberOfPeriods: Int,
                localizedPeriod: String? = nil,
                localizedNumberOfPeriods: String? = nil
            ) {
                self.id = id
                self.type = type
                self.price = price
                self.paymentMode = paymentMode
                self.period = period
                self.numberOfPeriods = numberOfPeriods
                self.localizedPeriod = localizedPeriod
                self.localizedNumberOfPeriods = localizedNumberOfPeriods
            }
        }
    }

}

private extension Dev_PreviewEnvironment {
    static var detectedOSName: String {
        #if os(iOS)
        "iOS"
        #elseif os(macOS)
        "macOS"
        #elseif os(visionOS)
        "visionOS"
        #else
        "unknown"
        #endif
    }

    static var detectedOSVersion: String {
        #if canImport(UIKit)
        UIDevice.current.systemVersion
        #else
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
        #endif
    }

    @MainActor
    static var detectedDeviceModel: String {
        #if canImport(UIKit)
        UIDevice.current.model
        #else
        "Mac"
        #endif
    }

    static func detectUses24HourClock() -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let template = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current) ?? ""
        return !template.contains("a")
    }
}
