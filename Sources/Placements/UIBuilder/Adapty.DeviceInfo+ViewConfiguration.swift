//
//  Adapty.DeviceInfo+ViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.06.2026.
//

import Foundation

extension AdaptyFlow.ViewConfiguration {
    func getLayout(for info: Adapty.DeviceInfo, with customId: String?) throws(AdaptyError) -> AdaptyFlow.Layout? {
        let grid: AdaptyFlow.Grid
        if let customId {
            guard let value = getGrid(for: customId) else { return nil }
            grid = value
        } else {
            grid = try getGrid(for: info.kind)
        }

        let index = try grid.getIndex(horizontal: info.horizontal, vertical: info.vertical)
        guard layouts.indices.contains(index) else { throw .isNoViewConfigurationInFlow() }
        return layouts[index]
    }

    private func getGrid(for customId: String) -> AdaptyFlow.Grid? {
        grids.first { $0.customId == customId }
    }

    private static let currentPlatform = "ios"

    private func getGrid(for device: Adapty.DeviceKind) throws(AdaptyError) -> AdaptyFlow.Grid {
        let result = grids.first { grid in
            if let platform = grid.platforms {
                guard platform.contains(where: { $0 == Self.currentPlatform }) else {
                    return false
                }
            }
            if let devices = grid.devices {
                guard devices.contains(where: { $0 == device }) else {
                    return false
                }
            }
            return true
        }

        guard let result else { throw .isNoViewConfigurationInFlow() }
        return result
    }
}

private extension AdaptyFlow.Grid {
    func getIndex(horizontal: Int, vertical: Int) throws(AdaptyError) -> Int {
        let col = hBreakpoints.prefix { horizontal >= $0 }.count
        let row = vBreakpoints.prefix { vertical >= $0 }.count
        let index = row * (hBreakpoints.count + 1) + col
        guard cells.indices.contains(index) else { throw .isNoViewConfigurationInFlow() }
        return cells[index]
    }
}

