//
//  MeasuredPlacementTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import SwiftUI
import Testing
#if canImport(UIKit)
import UIKit

/// A geometry effect rounds the frame of its content to whole pixels, edge by
/// edge. Where the content starts on half a pixel, it can come out a pixel
/// narrower than it measured, and a text placed in that frame truncates. A row of
/// three links 201 pt wide, centred in 354 pt, starts at 76.5 pt: half a pixel
/// at @3x. The check means something only on a @3x device.
@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Box Layout"),
    .feature("Measured Placement"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
@MainActor
struct MeasuredPlacementTests {
    /// What the text measured and the frame it was placed in.
    final class Log {
        var ideal: [String: CGFloat] = [:]
        var placed: [String: CGFloat] = [:]
    }

    struct Probe: Layout {
        let word: String
        let log: Log

        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
            subviews[0].sizeThatFits(proposal)
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
            log.ideal[word] = subviews[0].sizeThatFits(.unspecified).width
            log.placed[word] = bounds.width
            subviews[0].place(at: bounds.origin, proposal: proposal)
        }
    }

    enum Effect: CaseIterable {
        case rotation, scale

        func apply(_ view: some View) -> some View {
            switch self {
            case .rotation: AnyView(view.rotationEffect(.zero))
            case .scale: AnyView(view.scaleEffect(x: 1, y: 1))
            }
        }
    }

    static func render(_ view: some View) {
        let root = view.frame(width: 354, height: 100)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 354, height: 100))
        window.rootViewController = UIHostingController(rootView: root)
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        window.isHidden = true
    }

    @Test("Text under a geometry effect keeps its measured width on half a pixel", arguments: Effect.allCases)
    func textKeepsMeasuredWidth(effect: Effect) {
        let log = Log()
        let words = ["Restore", "Terms", "Privacy"]

        Self.render(
            HStack(spacing: 8) {
                ForEach(words, id: \.self) { word in
                    effect.apply(
                        Probe(word: word, log: log) {
                            Text(word).font(.system(size: 14))
                        }
                        .measuredPlacement()
                    )
                    .padding(.horizontal, 8)
                }
            }
            .frame(maxWidth: .infinity)
        )

        for word in words {
            let ideal = try! #require(log.ideal[word])
            let placed = try! #require(log.placed[word])
            #expect(placed >= ideal, "\(word): placed \(placed) < measured \(ideal)")
        }
    }

    /// Only an element that sets or animates a rotation or a scale gets the effect,
    /// and with it the layer and the rounding. The answer comes from the
    /// configuration alone, so it never changes while an animation runs.
    @Test("Rotation and scale effects only where the configuration sets or animates them")
    func transformsFollowConfiguration() throws {
        let screen = try Self.screen(content: """
        {
          "type": "v_stack",
          "content": [
            { "type": "text", "string_id": "plain", "opacity": 0.5 },
            { "type": "text", "string_id": "rotated", "rotation": { "angle": 10 } },
            { "type": "text", "string_id": "scaled", "scale": { "scale": [2, 2] } },
            {
              "type": "text", "string_id": "spins",
              "on_appear": [{ "type": "rotation", "angle": { "start": 0, "end": 90 }, "duration": 100 }]
            },
            {
              "type": "text", "string_id": "fades",
              "on_appear": [{ "type": "opacity", "opacity": { "start": 0, "end": 1 }, "duration": 100 }]
            }
          ]
        }
        """)

        func transforms(_ stringId: String) throws -> (rotates: Bool, scales: Bool) {
            let element = try #require(screen.poolElements.first {
                guard case let .text(text, _) = $0 else { return false }
                return "\(text.value)".contains(stringId)
            })
            return try AdaptyUIAnimatablePropertiesModifier<EmptyModifier>.transforms(#require(element.properties))
        }

        #expect(try transforms("plain") == (false, false))
        #expect(try transforms("rotated") == (true, false))
        #expect(try transforms("scaled") == (false, true))
        #expect(try transforms("spins") == (true, false))
        #expect(try transforms("fades") == (false, false))
    }

    static func screen(content: String) throws -> VC.Screen {
        let schema = try AdaptyUISchema(
            from: """
            {
              "format": "5.1.0",
              "screens": {
                "main": {
                  "content": \(content)
                }
              }
            }
            """,
            configuration: .init(device: .phone)
        )

        let configuration = try schema.extractUIConfiguration(
            id: "measured-placement-test",
            withLocaleId: "en",
            envoriment: .init(
                sdkVersion: "test",
                osName: "test",
                osVersion: "test",
                deviceModel: "test",
                appBundleId: nil,
                appVersion: nil,
                appBuild: nil,
                appCurrentLocale: nil,
                userLocales: [],
                userUses24HourClock: true,
                flow: .init(
                    placementId: "test",
                    variationId: "test",
                    variationName: nil,
                    abTestName: "test",
                    name: "test",
                    products: []
                )
            )
        )

        return try #require(configuration.screens["main"])
    }
}

#endif
