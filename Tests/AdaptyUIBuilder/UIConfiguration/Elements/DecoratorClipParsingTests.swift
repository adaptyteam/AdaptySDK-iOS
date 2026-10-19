@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite("Decorator Clip Parsing", .tags(.codable))
struct DecoratorClipParsingTests {
    @Test("Missing clip defaults to content", arguments: [
        Json(##"{}"##),
        Json(##"{"type":"circle"}"##),
        Json(##"{"type":"rect","rect_corner_radius":[10,20,30,40]}"##),
    ])
    func defaultClip(json: Json) throws {
        #expect(try json.decode(Schema.Decorator.self).clip == .content)
        let configuration = try DecoratorClipFixtures.configuration(content: Json(deserilized: [
            "type": "text", "string_id": "title", "decorator": json.deserilized,
        ]))
        let screen = try #require(configuration.screens["main"])
        let decorator = try #require(screen.poolElements[screen.content].properties?.decorator)
        #expect(decorator.clip == .content)
    }

    @Test("Both modes preserve the rest of the decorator", arguments: ["content", "none"])
    func explicitClip(mode: String) throws {
        let value = try Json(deserilized: [
            "clip": mode,
            "type": "rect",
            "rect_corner_radius": [10, 20, 30, 40],
            "background": "#00FF00",
            "border": "#0000FF",
            "thickness": 3,
            "shadow": ["color": "#000000", "blur_radius": 4],
            "inner_shadow": ["color": "#FF0000", "blur_radius": 2],
            "blur_radius": 5,
        ]).decode(Schema.Decorator.self)
        #expect(value.clip.rawValue == mode)
        guard case let .rectangle(radius) = value.shapeType else {
            Issue.record("Expected a rounded rectangle")
            return
        }
        #expect(radius.topLeading == 10)
        #expect(radius.topTrailing == 20)
        #expect(radius.bottomTrailing == 30)
        #expect(radius.bottomLeading == 40)
        #expect(value.background != nil)
        #expect(value.border?.thickness == 3)
        #expect(value.shadow?.blurRadius == 4)
        #expect(value.innerShadow?.blurRadius == 2)
        #expect(value.blurRadius == 5)
    }

    @Test("Invalid clip fails direct decoding and full schema parsing", arguments: [
        Json(##"true"##), Json(##"false"##), Json(##"0"##), Json(##"1"##),
        Json(##"{}"##), Json(##"[]"##),
        Json(##""all""##), Json(##""unknown""##), Json(##""true""##),
        Json(##""false""##), Json(##""Content""##), Json(##""""##),
    ])
    func invalidClip(value: Json) throws {
        let decorator = try Json(deserilized: ["clip": value.deserilized])
        #expect(throws: DecodingError.self) {
            try decorator.decode(Schema.Decorator.self)
        }
        let content = try Json(deserilized: [
            "type": "text", "string_id": "title", "decorator": decorator.deserilized,
        ])
        #expect(throws: (any Error).self) {
            try DecoratorClipFixtures.configuration(content: content)
        }
    }

    @Test("Common properties retain clip for simple and composite elements", arguments: [
        Json(##"{"type":"text","string_id":"title"}"##),
        Json(##"{"type":"box","content":{"type":"text","string_id":"title"}}"##),
        Json(##"{"type":"deck","items":[{"type":"deck_item","content":{"type":"text","string_id":"title"}}]}"##),
    ], ["content", "none"])
    func commonProperties(element: Json, mode: String) throws {
        var content = try #require(element.deserilized as? [String: Any])
        content["decorator"] = ["clip": mode]
        let configuration = try DecoratorClipFixtures.configuration(content: Json(deserilized: content))
        let screen = try #require(configuration.screens["main"])
        let decorator = try #require(screen.poolElements[screen.content].properties?.decorator)
        #expect(decorator.clip.rawValue == mode)
    }

    @Test("Missing decorator stays absent")
    func missingDecorator() throws {
        let configuration = try DecoratorClipFixtures.configuration()
        let screen = try #require(configuration.screens["main"])
        #expect(screen.poolElements[screen.content].properties?.decorator == nil)
    }
}

enum DecoratorClipFixtures {
    static func configuration(
        content: Json = Json(##"{"type":"text","string_id":"title"}"##),
        assets: Json = Json(##"[]"##)
    ) throws -> VC {
        let json = try Json(deserilized: [
            "format": "5.2.0",
            "assets": assets.deserilized,
            "screens": ["main": ["content": content.deserilized]],
        ])
        let schema = try AdaptyUISchema(from: json.data, configuration: .init(device: .phone))
        return try schema.extractUIConfiguration(
            id: "decorator-clip-test", withLocaleId: "en",
            envoriment: .init(
                sdkVersion: "test", osName: "test", osVersion: "test", deviceModel: "test",
                appBundleId: nil, appVersion: nil, appBuild: nil, appCurrentLocale: nil,
                userLocales: [], userUses24HourClock: true,
                flow: .init(placementId: "test", variationId: "test", variationName: nil,
                            abTestName: "test", name: "test", products: [])
            )
        )
    }
}
