//
//  Environment.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

import Foundation

struct Environment: Sendable {
    let application: (
        installationIdentifier: String,
        version: String?,
        build: String?,
        minimumOSVersion: String?
    )
    let system: (
        name: String,
        version: String
    )
    let sessionIdentifier: String
}

@AdaptyActor
extension Environment {
    static var _instance: Environment?

    static var instance: Environment {
        get async {
            if let instance = _instance {
                return instance
            }
            let instance = await Environment()
            _instance = instance
            return instance
        }
    }

    private init() async {
        await self.init(
            application: (
                installationIdentifier: Environment.Application.installationIdentifier,
                version: Environment.Application.version,
                build: Environment.Application.build,
                minimumOSVersion: Environment.Application.minimumOSVersion
            ),
            system: (
                name: Environment.System.name,
                version: Environment.System.version
            ),
            sessionIdentifier: Environment.Application.sessionIdentifier
        )
    }
}
