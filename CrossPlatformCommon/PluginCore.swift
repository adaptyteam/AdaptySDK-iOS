//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 31.10.2024.
//

import Adapty
import AdaptyUI
import Foundation

final class AdaptyCrossPlatformDelegate: NSObject, AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {}
}

struct AdaptyInfoPlist {
    enum Key: String {
        case apiKey = "AdaptyPublicSdkKey"
        case observerMode = "AdaptyObserverMode"

        case idfaCollectionDisabled = "AdaptyIDFACollectionDisabled"
        case ipAddressCollectionDisabled = "AdaptyIPCollectionDisabled"

        case overrideBaseURL = "AdaptyOverrideBaseURL"
        case overrideFallbackBaseURL = "AdaptyOverrideFallbackBaseURL"

        case serverCluster = "AdaptyServerCluster"
    }

    private let dictionary: [String: Any]
    let apiKey: String

    var serverCluster: Adapty.ConfigurationBuilder.ServerCluster {
        guard let value = dictionary[Key.serverCluster.rawValue] as? String else { return .default }

        switch value {
        case "eu": return .eu
        default: return .default
        }
    }

    var observerMode: Bool { dictionary[Key.observerMode.rawValue] as? Bool ?? false }
    var idfaCollectionDisabled: Bool { dictionary[Key.idfaCollectionDisabled.rawValue] as? Bool ?? false }
    var ipAddressCollectionDisabled: Bool { dictionary[Key.ipAddressCollectionDisabled.rawValue] as? Bool ?? false }

    var overrideBaseURL: URL? {
        guard let urlString = dictionary[Key.overrideBaseURL.rawValue] as? String else { return nil }
        return URL(string: urlString)
    }

    var overrideFallbackBaseURL: URL? {
        guard let urlString = dictionary[Key.overrideFallbackBaseURL.rawValue] as? String else { return nil }
        return URL(string: urlString)
    }

    private init(dictionary: [String: Any], apiKey: String) {
        self.dictionary = dictionary
        self.apiKey = apiKey
    }

    static func load() -> Self? {
        guard let infoDictionary = loadDictionary() else { return nil }
        guard let apiKey = infoDictionary[Key.apiKey.rawValue] as? String else { return nil }

        return .init(dictionary: infoDictionary, apiKey: apiKey)
    }

    private static func loadDictionary() -> [String: Any]? {
        guard let plistPath = Bundle.main.path(forResource: "Adapty-Info", ofType: "plist"),
              let plistData = try? Data(contentsOf: URL(fileURLWithPath: plistPath)),
              let plist = try? PropertyListSerialization.propertyList(from: plistData,
                                                                      options: .mutableContainers,
                                                                      format: nil) as? [String: Any]?
        else {
            return Bundle.main.infoDictionary
        }

        return plist
    }
}

extension AdaptyCrossPlatform {
    private static let delegate = AdaptyCrossPlatformDelegate()

    static func autoActivate(
        sdkName: String,
        version: String

    ) {
        guard let infoPlist = AdaptyInfoPlist.load() else {
//            Adapty.writeLog(level: .error, message: "You must provide 'AdaptyPublicSdkKey' in your application Adapty-Info.plist file to initialize Adapty")
            return
        }

        Adapty.delegate = delegate

        var builder = Adapty
            .ConfigurationBuilder(withAPIKey: infoPlist.apiKey)
            .with(crosplatformSDKName: sdkName, version: version)
            .with(serverCluster: infoPlist.serverCluster)
            .with(observerMode: infoPlist.observerMode)
            .with(idfaCollectionDisabled: infoPlist.idfaCollectionDisabled)
            .with(ipAddressCollectionDisabled: infoPlist.ipAddressCollectionDisabled)

        if let overrideBaseURL = infoPlist.overrideBaseURL {
            builder = builder.with(backendBaseUrl: overrideBaseURL)
        }

        if let overrideFallbackBaseURL = infoPlist.overrideFallbackBaseURL {
            builder = builder.with(backendFallbackBaseUrl: overrideFallbackBaseURL)
        }

        Adapty.activate(with: builder)
    }
}
