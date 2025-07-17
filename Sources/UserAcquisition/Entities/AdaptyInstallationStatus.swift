//
//  AdaptyInstallationStatus.swift
//  Adapty
//
//  Created by Aleksei Valiano on 18.06.2025.
//

import Foundation

public enum AdaptyInstallationStatus: Sendable, Hashable {
    case notAvailable
    case notDetermined
    case determined(AdaptyInstallationDetails)
}
