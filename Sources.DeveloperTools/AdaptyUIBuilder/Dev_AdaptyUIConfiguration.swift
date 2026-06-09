//
//  Dev_AdaptyUIConfiguration.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

import AdaptyUIBuilder
import Foundation

public struct Dev_AdaptyUIConfiguration {
    typealias Wrapped = AdaptyUIConfiguration
    let wrapped: Wrapped
    let previewProducts: [Dev_PreviewProduct]
    public let json: String
}

public extension Dev_AdaptyUIConfiguration {
    static func create(
        main: String,
        templates: String? = nil,
        navigators: [String: String]? = nil,
        contents: [AdaptyUISchema.ExampleContent],
        script: String? = nil,
        startScreenName: String?,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration,
        environment: Dev_PreviewEnvironment = .empty
    ) throws -> Self {
        let json = try AdaptyUISchema.createJson(
            main: main,
            templates: templates,
            navigators: navigators,
            contents: contents,
            script: script,
            startScreenName: startScreenName
        )

        return try create(
            json: json,
            decodingConfiguration: decodingConfiguration,
            environment: environment
        )
    }

    static func create(
        json: String,
        decodingConfiguration: AdaptyUISchema.DecodingConfiguration,
        environment: Dev_PreviewEnvironment = .empty
    ) throws -> Self {
        let uuid = UUID().uuidString.lowercased()
        let schema = try AdaptyUISchema(from: json, configuration: decodingConfiguration)
        let configuration = try schema.extractUIConfiguration(
            id: uuid,
            envoriment: .init(
                sdkVersion: environment.sdkVersion,
                osName: environment.osName,
                osVersion: environment.osVersion,
                deviceModel: environment.deviceModel,
                appBundleId: environment.appBundleId,
                appVersion: environment.appVersion,
                appBuild: environment.appBuild,
                appCurrentLocale: environment.appCurrentLocale,
                userLocales: environment.userLocales,
                userUses24HourClock: environment.userUses24HourClock,
                flow: .init(
                    placementId: environment.placementId,
                    variationId: environment.variationId,
                    abTestName: environment.abTestName,
                    name: environment.placementName,
                    products: environment.products.asProductConstants()
                )
            )
        )
        return .init(
            wrapped: configuration,
            previewProducts: environment.products,
            json: json
        )
    }
}

