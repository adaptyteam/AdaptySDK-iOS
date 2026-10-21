@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite("Alert Dialog String Id", .tags(.codable))
@MainActor
struct AlertDialogStringIdTests {
    @Test("Parameters resolve string ids, falling back to text")
    func resolvesStringIds() throws {
        let state = try AdaptyUIState(configuration: Self.configuration(), actionHandler: nil)
        let params = VS.ShowAlertDialogParameters.fromDictionary([
            "titleStringId": "alert_title",
            "title": "Fallback title",
            "messageStringId": "missing",
            "message": "Fallback message",
            "actions": [
                ["titleStringId": "alert_ok"],
                ["title": "Cancel", "style": "cancel"],
                ["titleStringId": "missing"],
            ],
        ])

        #expect(params.title.flatMap(state.text) == "Localized title")
        #expect(params.message.flatMap(state.text) == "Fallback message")
        #expect(params.buttons.map { $0.title.flatMap(state.text) } == ["OK", "Cancel", nil])
    }

    @Test("Missing title and string id stay absent")
    func absentWithoutTitleAndStringId() {
        let params = VS.ShowAlertDialogParameters.fromDictionary([:])
        #expect(params.title == nil)
        #expect(params.message == nil)
        #expect(params.buttons.isEmpty)
    }

    static func configuration() throws -> AdaptyUIConfiguration {
        let schema = try AdaptyUISchema(
            from: """
            {
              "format": "5.2.0",
              "screens": { "main": { "content": { "type": "text", "string_id": "alert_title" } } },
              "localizations": [{
                "id": "en",
                "strings": [
                  { "id": "alert_title", "value": "Localized title" },
                  { "id": "alert_ok", "value": "OK" }
                ]
              }]
            }
            """,
            configuration: .init(device: .phone)
        )
        return try schema.extractUIConfiguration(
            id: "alert-string-id-test", withLocaleId: "en",
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
