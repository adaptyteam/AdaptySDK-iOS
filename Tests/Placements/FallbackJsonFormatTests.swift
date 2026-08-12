//
//  FallbackJsonFormatTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 29.05.2026.
//

#if canImport(Testing)

import AdaptyCodable
import Foundation
import Testing

private enum TestResources {
    static var fallbackURL: URL? {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("fallback.json")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    static var hasFallbackJSON: Bool {
        fallbackURL != nil
    }
}

/// Locks in the backend serialisation contract observed in fallback.json:
/// every placementId key under `/data` is stored as raw UTF-8 bytes, not as
/// a `\uXXXX` escape sequence. Production code (FallbackPlacements) builds
/// pointers via simple `"/data/\(id)"` interpolation, which relies on this
/// invariant — if the backend ever switches to ASCII-escape serialisation,
/// pointer lookup for non-ASCII placementIds will silently start returning
/// nil. This test catches that change at build time.
struct FallbackJsonFormatTests {
    @Test(.enabled(if: TestResources.hasFallbackJSON))
    func dataKeysDoNotUseUnicodeEscapes() throws {
        let data = try Data(contentsOf: #require(TestResources.fallbackURL))

        let info = try data.jsonInspect(pointer: "/data")
        guard case let .object(rawKeys) = info else {
            Issue.record("/data is expected to be an object, got \(info)")
            return
        }

        // After the raw-form contract fix in sdjson_inspect, the returned
        // strings are byte-for-byte copies of the key as it appears in the
        // source JSON, including any backslash escapes. Finding the literal
        // two-character sequence "\u" inside any key means the backend
        // produced \uXXXX escapes — a contract change.
        let escapeMarker = "\u{5c}u" // "\u" without a Swift escape literal

        let offending = rawKeys.filter { $0.contains(escapeMarker) }
        if !offending.isEmpty {
            Issue.record(
                """
                Found \(offending.count) /data key(s) serialised with \\u escapes — \
                backend contract changed; FallbackPlacements pointer lookup will break \
                for non-ASCII placementIds. Examples: \(Array(offending.prefix(5)))
                """
            )
        }
        #expect(offending.isEmpty)
    }

    @Test(.enabled(if: TestResources.hasFallbackJSON))
    func dataContainsNonAsciiKeys() throws {
        // Sanity-check companion to `dataKeysDoNotUseUnicodeEscapes`: if the
        // file ever lost its non-ASCII placementIds entirely, the escape-free
        // assertion would pass trivially. This test guarantees we keep
        // exercising real non-ASCII inputs against the contract.
        let data = try Data(contentsOf: #require(TestResources.fallbackURL))

        let info = try data.jsonInspect(pointer: "/data")
        guard case let .object(rawKeys) = info else {
            Issue.record("/data is expected to be an object, got \(info)")
            return
        }

        let nonAscii = rawKeys.filter { key in
            key.unicodeScalars.contains(where: { $0.value >= 0x80 })
        }
        if nonAscii.isEmpty {
            Issue.record("Expected at least one non-ASCII placementId in /data to keep the escape-free contract test meaningful, but found none.")
        }
        #expect(!nonAscii.isEmpty)
    }
}

#endif
