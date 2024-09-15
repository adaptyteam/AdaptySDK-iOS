//
//  PaywallResponseTests.swift
//
//
//  Created by Aleksei Valiano on 09.02.2024
//
//
import XCTest
@testable import Adapty

final class PaywallResponseTests: XCTestCase {
    enum Json: String, CaseIterable {
        case paywallResponse = "PaywallResponse.json"

        var url: URL {
            let thisSourceFile = URL(fileURLWithPath: #file)
            let thisDirectory = thisSourceFile.deletingLastPathComponent()
            return thisDirectory.appendingPathComponent("\(self.rawValue)")
        }
    }

    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        decoder.setProfileId("profileId")
        return decoder
    }

    func test(fileURL url: URL) throws {
        let json = try Data(contentsOf: url)

        let meta = try jsonDecoder.decode(Backend.Response.ValueOfMeta<AdaptyPaywallChosen.Meta>.self, from: json)
        let data = try jsonDecoder.decode(Backend.Response.ValueOfData<AdaptyPaywallChosen>.self, from: json)

        guard case let .data(viewConfiguration) = data.value.value.viewConfiguration else { return }

        let locolized = try viewConfiguration.extractLocale()
        let fakeLocolized = try viewConfiguration.extractLocale(AdaptyLocale(id: "fake"))

        let x = viewConfiguration
        
        let _ = locolized
        let _ = fakeLocolized
    }

    func testPaywalls() throws {
        for item in Json.allCases {
            try test(fileURL: item.url)
        }
    }
}
