//
//  BoxFrameLayoutTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import SwiftUI
import Testing
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Renders `AdaptyUIBoxFrameLayout` next to the native flexible frame it replaces
/// and checks that both put the box and its child in the same place. Only the
/// proposal the child is placed with differs, on purpose.
@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Box Layout"),
    .feature("Box Frame"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
@MainActor
struct BoxFrameLayoutTests {
    typealias Bounds = (min: CGFloat?, max: CGFloat?)

    /// Where the box and its child ended up.
    final class Frames {
        var box: CGRect?
        var child: CGRect?
    }

    /// Proposes its child exactly `proposal`, `nil` and infinity included, places
    /// it at the origin with the same proposal and records where it went. It takes
    /// whatever it is offered itself, so an infinite child does not make its own
    /// origin invalid.
    struct Root: Layout {
        let proposal: ProposedViewSize
        let frames: Frames

        func sizeThatFits(proposal: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGSize {
            proposal.replacingUnspecifiedDimensions()
        }

        func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
            guard let box = subviews.first else { return }
            frames.box = CGRect(origin: bounds.origin, size: box.sizeThatFits(proposal))
            box.place(at: bounds.origin, proposal: proposal)
        }
    }

    /// Passes everything through to the child and records where it was placed.
    /// A geometry reader would not do: centred on an infinite box it lands at NaN.
    struct ChildProbe: Layout {
        let frames: Frames

        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
            subviews.first?.sizeThatFits(proposal) ?? .zero
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
            frames.child = bounds
            // The native frame centres an infinite child in an infinite box at NaN.
            subviews.first?.place(
                at: CGPoint(x: bounds.minX.isNaN ? 0 : bounds.minX, y: bounds.minY.isNaN ? 0 : bounds.minY),
                proposal: proposal
            )
        }
    }

    enum Child: CaseIterable {
        case fixed, greedy, flexible, text, image

        @ViewBuilder
        var view: some View {
            switch self {
            case .fixed: Color.red.frame(width: 44, height: 20)
            case .greedy: Color.red
            case .flexible: Color.red.frame(minWidth: 30, maxWidth: 120, minHeight: 10, maxHeight: 60)
            case .text: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit")
            case .image: Image(systemName: "star.fill").resizable().aspectRatio(contentMode: .fit)
            }
        }
    }

    struct Case: CustomStringConvertible {
        let width: Bounds
        let height: Bounds
        let proposal: ProposedViewSize
        let child: Child
        let alignment: (horizontal: HorizontalAlignment, vertical: VerticalAlignment, anchor: UnitPoint)
        let layoutDirection: LayoutDirection

        var description: String {
            func f(_ v: CGFloat?) -> String { v.map { "\($0)" } ?? "nil" }
            return "w \(f(width.min))...\(f(width.max)), h \(f(height.min))...\(f(height.max)), "
                + "proposal \(f(proposal.width)) x \(f(proposal.height)), \(child), "
                + "anchor \(alignment.anchor.x),\(alignment.anchor.y), \(layoutDirection)"
        }
    }

    static let bounds: [Bounds] = [
        (nil, nil), (40, nil), (nil, 150), (40, 150), (nil, .infinity), (0, .infinity), (400, nil), (0, nil),
    ]
    static let lengths: [CGFloat?] = [nil, 0, 300, .infinity]
    static let alignments: [(HorizontalAlignment, VerticalAlignment, UnitPoint)] = [
        (.leading, .top, .topLeading), (.center, .top, .top), (.trailing, .top, .topTrailing),
        (.leading, .center, .leading), (.center, .center, .center), (.trailing, .center, .trailing),
        (.leading, .bottom, .bottomLeading), (.center, .bottom, .bottom), (.trailing, .bottom, .bottomTrailing),
    ]

    /// SplitMix64, so the cases are random but the same on every run.
    struct Generator: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    static func cases(count: Int) -> [Case] {
        var generator = Generator(state: 42)
        return (0 ..< count).map { _ in
            let alignment = alignments.randomElement(using: &generator)!
            return Case(
                width: bounds.randomElement(using: &generator)!,
                height: bounds.randomElement(using: &generator)!,
                proposal: ProposedViewSize(
                    width: lengths.randomElement(using: &generator)!,
                    height: lengths.randomElement(using: &generator)!
                ),
                child: Child.allCases.randomElement(using: &generator)!,
                alignment: (alignment.0, alignment.1, alignment.2),
                layoutDirection: Bool.random(using: &generator) ? .leftToRight : .rightToLeft
            )
        }
    }

    static func render(_ view: some View) {
        let root = view.frame(width: 600, height: 600, alignment: .topLeading)
        #if canImport(UIKit)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
        window.rootViewController = UIHostingController(rootView: root)
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        window.isHidden = true
        #else
        let host = NSHostingView(rootView: root)
        host.frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        host.layoutSubtreeIfNeeded()
        #endif
    }

    static func frames(_ testCase: Case, custom: Bool) -> Frames {
        let frames = Frames()
        let child = ChildProbe(frames: frames) { testCase.child.view }
        let box: AnyView =
            if custom {
                AnyView(AdaptyUIBoxFrameLayout(
                    minWidth: testCase.width.min,
                    maxWidth: testCase.width.max,
                    minHeight: testCase.height.min,
                    maxHeight: testCase.height.max,
                    alignment: testCase.alignment.anchor
                ) { child })
            } else {
                AnyView(child.frame(
                    minWidth: testCase.width.min,
                    maxWidth: testCase.width.max,
                    minHeight: testCase.height.min,
                    maxHeight: testCase.height.max,
                    alignment: Alignment(horizontal: testCase.alignment.horizontal, vertical: testCase.alignment.vertical)
                ))
            }
        render(
            Root(proposal: testCase.proposal, frames: frames) { box }
                .environment(\.layoutDirection, testCase.layoutDirection)
        )
        return frames
    }

    static func same(_ lhs: CGRect?, _ rhs: CGRect?) -> Bool {
        guard let lhs, let rhs else { return lhs == nil && rhs == nil }
        func same(_ a: CGFloat, _ b: CGFloat) -> Bool { a == b || abs(a - b) < 0.0001 || (a.isNaN && b.isNaN) }
        return same(lhs.minX, rhs.minX) && same(lhs.minY, rhs.minY)
            && same(lhs.width, rhs.width) && same(lhs.height, rhs.height)
    }

    /// Random boxes against the native frame: proposals `nil`, zero, a number and
    /// infinity on each axis, every kind of bound, children that keep their size,
    /// take any offer, have bounds of their own, wrap or keep an aspect ratio,
    /// all nine alignments in both directions.
    @Test("Box frame places like the native frame")
    func placesLikeTheNativeFrame() {
        var mismatches: [String] = []
        var degenerate = 0
        for testCase in Self.cases(count: 3000) {
            let native = Self.frames(testCase, custom: false)
            let custom = Self.frames(testCase, custom: true)
            // An infinite box: the native frame has no place for the child either,
            // it lands at infinity or NaN. Only the box itself is compared.
            if let child = native.child, !(child.minX.isFinite && child.minY.isFinite) {
                degenerate += 1
                if !Self.same(native.box, custom.box) {
                    mismatches.append("\(testCase): native box \(String(describing: native.box)), custom box \(String(describing: custom.box))")
                }
                continue
            }
            if !Self.same(native.box, custom.box) || !Self.same(native.child, custom.child) {
                mismatches.append("\(testCase): native box \(String(describing: native.box)) child \(String(describing: native.child)), "
                    + "custom box \(String(describing: custom.box)) child \(String(describing: custom.child))")
            }
        }
        print("Box frame: \(degenerate) of \(Self.cases(count: 3000).count) cases place the child at infinity")
        #expect(mismatches.isEmpty, "\(mismatches.count) mismatches:\n\(mismatches.joined(separator: "\n"))")
    }

    /// A child that answers less than the proposal is placed with the proposal it
    /// was measured with, not with its own answer: on an axis without bounds
    /// (`min: 0` on the other one), and across a `fill_max` box, where the native
    /// frame takes the proposal on one axis and hands the child's answer back on
    /// the other.
    @Test(
        "Box frame places the child with the proposal it measured with",
        arguments: [
            (CGFloat?(nil), CGFloat?(nil), CGFloat?(0), CGFloat?(nil)),
            (nil, .infinity, nil, nil),
        ]
    )
    func placesWithTheMeasuredProposal(minWidth: CGFloat?, maxWidth: CGFloat?, minHeight: CGFloat?, maxHeight: CGFloat?) throws {
        let log = LayoutProposalTests.Log()
        Self.render(
            Root(proposal: ProposedViewSize(width: 342, height: 138), frames: Frames()) {
                AdaptyUIBoxFrameLayout(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                    alignment: .center
                ) {
                    LayoutProposalTests.Recorder(log: log) { Color.clear }
                }
            }
        )

        let placed = try #require(log.placed.last)
        #expect(placed == ProposedViewSize(width: 342, height: 138))
        #expect(log.measured.allSatisfy { $0 == placed })
    }
}
