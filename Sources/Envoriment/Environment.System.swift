//
//  Environment.System.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#endif

private let log = Log.default

extension Environment {
    enum System {
        static var timezone: String { TimeZone.current.identifier }

        static var locale: AdaptyLocale { AdaptyLocale(id: Locale.preferredLanguages.first ?? Locale.current.identifier) }

        @AdaptyActor
        private static var _version: String?

        @AdaptyActor
        static var version: String {
            get async {
                if let result = _version { return result }

                #if os(macOS) || targetEnvironment(macCatalyst)
                    let result = await MainActor.run { ProcessInfo().operatingSystemVersionString }
                #else
                    let result = await UIDevice.current.systemVersion
                #endif

                _version = result
                return result
            }
        }

        @AdaptyActor
        private static var _name: String?

        @AdaptyActor
        static var name: String {
            get async {
                if let result = _name { return result }

                #if os(macOS) || targetEnvironment(macCatalyst)
                    let result = "macOS"
                #else
                    let result = await UIDevice.current.systemName
                #endif

                _name = result
                return result
            }
        }
    }
}
