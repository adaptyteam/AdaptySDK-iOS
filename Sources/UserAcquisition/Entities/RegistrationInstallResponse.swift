//
//  RegistrationInstallResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.06.2025.
//

import Foundation

struct RegistrationInstallResponse: Sendable, Hashable, Identifiable {
    let id: String
    let payload: AdaptyInstallationDetails.Payload?
}

extension RegistrationInstallResponse: CustomStringConvertible {
    public var description: String {
        "(id: \(id), payload: \(payload?.jsonString ?? "nil")"
    }
}

extension RegistrationInstallResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "install_id"
        case payload
    }
}
