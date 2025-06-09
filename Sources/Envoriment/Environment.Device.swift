//
//  Environment.Device.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

extension Environment {
    enum Device {
        #if targetEnvironment(simulator)
            static let isSimulator = true
        #else
            static let isSimulator = false
        #endif

        static let model: String = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

                var modelIdentifier: String?
                if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
                    modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
                }
                IOObjectRelease(service)

                if modelIdentifier?.isEmpty ?? false {
                    modelIdentifier = nil
                }

                return modelIdentifier ?? "unknown device"

            #else
                var systemInfo = utsname()
                uname(&systemInfo)
                let machineMirror = Mirror(reflecting: systemInfo.machine)
                return machineMirror.children.reduce("") { identifier, element in
                    guard let value = element.value as? Int8, value != 0 else { return identifier }
                    return identifier + String(UnicodeScalar(UInt8(value)))
                }
            #endif
        }()

        typealias ScreenInfo = (width: Int, height: Int, scale: Double)

        @AdaptyActor
        private static var _mainScreenInfo: ScreenInfo?

        @AdaptyActor
        static var mainScreenInfo: ScreenInfo? {
            get async {
                if let result = _mainScreenInfo { return result }

                let result: ScreenInfo? = await MainActor.run {
                    #if canImport(UIKit)
                        let mainScreen = UIScreen.main
                        let nativeBounds = mainScreen.nativeBounds
                        return (
                            width: Int(nativeBounds.width),
                            height: Int(nativeBounds.height),
                            scale: Double(mainScreen.scale)
                        )
                    #elseif canImport(AppKit)
                        guard let mainScreen = NSScreen.main else { return nil }
                        let frameInPoints = mainScreen.frame
                        let scale = mainScreen.backingScaleFactor
                        return (
                            width: Int(frameInPoints.width * scale),
                            height: Int(frameInPoints.height * scale),
                            scale: Double(scale)
                        )

                    #else
                        return nil
                    #endif
                }

                if let result {
                    _mainScreenInfo = result
                }
                return result
            }
        }
    }
}
