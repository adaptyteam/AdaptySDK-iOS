//
//  Environment+AppTrackingTransparency.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency

    extension Environment.Device {
        @available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, *)
        static var appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus {
            ATTrackingManager.trackingAuthorizationStatus
        }
    }
#endif
