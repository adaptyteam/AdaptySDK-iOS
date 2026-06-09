//
//  AdaptyFlow.ViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.06.2026.
//

import Foundation
import AdaptyUIBuilder

extension AdaptyFlow {
    struct ViewConfiguration {
        let layouts: [Layout]
        let grids: [Grid]
    }

    struct Grid: Sendable {

        let platforms: [String]?
        let devices: [AdaptyUISchema.DeviceKind]?
        let customId: String?
        let hBreakpoints: [Int]
        let vBreakpoints: [Int]
        let cells: [Int]
    }

    struct Layout: Sendable, Identifiable {
        let id: String
    }
}

extension AdaptyFlow.ViewConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case layouts
        case grids
    }
}

extension AdaptyFlow.Grid: Codable {
    enum CodingKeys: String, CodingKey {
        case platforms
        case devices
        case customId = "custom_id"
        case hBreakpoints = "h_breakpoints"
        case vBreakpoints = "v_breakpoints"
        case cells
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let v = try? container.decode(String.self, forKey: .platforms), v == "all" {
            platforms = nil
        } else {
            platforms = try container.decodeIfPresent([String].self, forKey: .platforms) ?? []
        }
        if let v = try? container.decode(String.self, forKey: .devices), v == "all" {
            devices = nil
        } else {
            devices = try container.decodeIfPresent([AdaptyUISchema.DeviceKind].self, forKey: .devices) ?? []
        }
        customId = try container.decodeIfPresent(String.self, forKey: .customId)
        hBreakpoints = try container.decodeIfPresent([Int].self, forKey: .hBreakpoints) ?? []
        vBreakpoints = try container.decodeIfPresent([Int].self, forKey: .vBreakpoints) ?? []
        cells = try container.decode([Int].self, forKey: .cells)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let platforms {
            if platforms.isNotEmpty {
                try container.encode(platforms, forKey: .platforms)
            }
        } else {
            try container.encode("all", forKey: .platforms)
        }

        if let devices {
            if devices.isNotEmpty {
                try container.encode(devices, forKey: .devices)
            }
        } else {
            try container.encode("all", forKey: .devices)
        }

        try container.encodeIfPresent(customId, forKey: .customId)

        if hBreakpoints.isNotEmpty {
            try container.encode(hBreakpoints, forKey: .hBreakpoints)
        }

        if vBreakpoints.isNotEmpty {
            try container.encode(vBreakpoints, forKey: .vBreakpoints)
        }

        try container.encode(cells, forKey: .cells)
    }
}

extension AdaptyFlow.Layout: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "flow_layout_id"
    }
}

