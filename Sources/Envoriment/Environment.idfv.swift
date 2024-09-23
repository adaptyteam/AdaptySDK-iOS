//
//  Environment.idfv.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

#if canImport(UIKit)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

private let log = Log.default

extension Environment.Device {
    @MainActor
    static let idfv: String? = {
        #if os(macOS) || targetEnvironment(macCatalyst)
            let matchingDict = IOServiceMatching("IOPlatformExpertDevice")
            let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, matchingDict)
            defer { IOObjectRelease(platformExpert) }

            guard platformExpert != 0 else { return nil }
            return IORegistryEntryCreateCFProperty(
                platformExpert,
                kIOPlatformUUIDKey as CFString,
                kCFAllocatorDefault,
                0
            ).takeRetainedValue() as? String
        #else
            return UIDevice.current.identifierForVendor?.uuidString
        #endif
    }()
}
