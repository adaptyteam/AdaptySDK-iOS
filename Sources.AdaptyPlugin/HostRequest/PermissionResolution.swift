//
//  PermissionResolution.swift
//  AdaptyPlugin
//

import Foundation

/// Non-UIKit carrier for a host permission response, resolved through `HostRequestRegistry`.
/// The UIKit-side `PluginSystemRequestsHandler` maps it to `AdaptyUIPermissionResult`.
struct PermissionResolution {
    enum Status: String, Decodable {
        case granted
        case denied
        case unavailable
    }

    let status: Status
    let detail: String?
}
