//
//  PluginLocalizationResolverTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
@testable import AdaptyUIBuilder
import Foundation
import Testing

@MainActor
struct PluginLocalizationResolverTests {
    @Test("the event carries the resolver id and both locale lists, without a view")
    func encodesEvent() throws {
        let event = FlowViewEvent.DidAskLocalization(
            eventId: "hr_1",
            resolverId: "my_resolver",
            preferredLocales: ["de-DE", "fr"],
            locales: ["en", "fr"],
            defaultLocale: "en"
        )

        #expect(try Json.encode(event) == Json(##"""
        {
          "id": "flow_view_did_ask_localization",
          "event_id": "hr_1",
          "resolver_id": "my_resolver",
          "preferred_locales": ["de-DE", "fr"],
          "locales": ["en", "fr"],
          "default_locale": "en"
        }
        """##))
    }

    @Test("the answer reads the result, and a null or missing result as nil")
    func decodesAnswer() throws {
        let chosen = try Json(##"""
        { "method": "flow_view_did_answer_localization", "event_id": "hr_1", "result": "fr" }
        """##).decode(Request.FlowViewDidAnswerLocalization.self)
        #expect(chosen.eventId == "hr_1")
        #expect(chosen.result == "fr")

        let null = try Json(##"""
        { "method": "flow_view_did_answer_localization", "event_id": "hr_1", "result": null }
        """##).decode(Request.FlowViewDidAnswerLocalization.self)
        #expect(null.result == nil)

        let missing = try Json(##"""
        { "method": "flow_view_did_answer_localization", "event_id": "hr_1" }
        """##).decode(Request.FlowViewDidAnswerLocalization.self)
        #expect(missing.result == nil)
    }

    @Test("the host's answer chooses the localization over the fallback resolver")
    func hostAnswerWins() async throws {
        let host = AnsweringHost(answer: .result("fr"))
        let strategy = strategy(host: host)

        // the fallback alone would choose the default "en" for "de"
        #expect(try await strategy.resolve(for: ["de"], from: Self.schema()) == "fr")

        let event = try #require(host.events.first)
        #expect(event.resolverId == "my_resolver")
        #expect(event.preferredLocales == ["de"])
        #expect(event.locales.sorted() == ["en", "fr"])
        #expect(event.defaultLocale == "en")
    }

    @Test("a null answer lets the fallback resolver choose")
    func nullAnswerFallsBack() async throws {
        let host = AnsweringHost(answer: .result(nil))
        #expect(try await strategy(host: host).resolve(for: ["de", "fr"], from: Self.schema()) == "fr")
        #expect(host.events.count == 1)
    }

    @Test("an unanswered request times out and the fallback resolver chooses; a late answer is ignored")
    func timeoutFallsBack() async throws {
        let host = AnsweringHost(answer: .none)
        let strategy = strategy(host: host, timeout: 0.05)

        #expect(try await strategy.resolve(for: ["de", "fr"], from: Self.schema()) == "fr")

        let event = try #require(host.events.first)
        _ = try await hostAnswer(eventId: event.eventId, result: "en").execute()
    }

    @Test("an id the flow does not have is ignored and the fallback resolver chooses")
    func unknownLocaleFallsBack() async throws {
        let host = AnsweringHost(answer: .result("xx"))

        #expect(try await strategy(host: host).resolve(for: ["fr"], from: Self.schema()) == "fr")
    }
}

private extension PluginLocalizationResolverTests {
    func strategy(host: AnsweringHost, timeout: TimeInterval = 5) -> AdaptyUILocalizationStrategy {
        .custom(
            resolver: AdaptyUIPluginLocalizationResolver(id: "my_resolver", timeout: timeout, eventHandler: host),
            fallbackResolver: .auto
        )
    }

    static func schema() throws -> AdaptyUISchema {
        try AdaptyUISchema(
            from: """
            {
              "format": "5.2.0",
              "default_localization": "en",
              "screens": { "main": { "content": { "type": "text", "string_id": "title" } } },
              "localizations": [
                { "id": "en", "strings": [{ "id": "title", "value": "Title" }] },
                { "id": "fr", "strings": [{ "id": "title", "value": "Titre" }] }
              ]
            }
            """,
            configuration: .init(device: .phone)
        )
    }
}

private func hostAnswer(eventId: String, result: String?) throws -> Request.FlowViewDidAnswerLocalization {
    var json: [String: Any] = ["method": "flow_view_did_answer_localization", "event_id": eventId]
    if let result { json["result"] = result }
    return try Json(deserilized: json).decode(Request.FlowViewDidAnswerLocalization.self)
}

/// A host that records localization requests and answers them through
/// `flow_view_did_answer_localization`, the way the cross-platform side does.
private final class AnsweringHost: EventHandler, @unchecked Sendable {
    enum Answer {
        case result(String?)
        case none
    }

    let answer: Answer
    private let lock = NSLock()
    private var recorded: [FlowViewEvent.DidAskLocalization] = []

    init(answer: Answer) {
        self.answer = answer
    }

    var events: [FlowViewEvent.DidAskLocalization] {
        lock.withLock { recorded }
    }

    func handle(event: AdaptyPluginEvent) {
        guard let event = event as? FlowViewEvent.DidAskLocalization else { return }
        lock.withLock { recorded.append(event) }

        guard case let .result(result) = answer else { return }
        let eventId = event.eventId
        Task {
            _ = try await hostAnswer(eventId: eventId, result: result).execute()
        }
    }
}
