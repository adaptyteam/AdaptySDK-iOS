//
//  FlexStackLayoutTests.swift
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

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Flex Layout"),
    .feature("Flex Stack"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
enum FlexStackLayoutTests {
    typealias Solver = AdaptyUIFlexStackSolver

    struct SolverTests {
        /// A fixed box, a box that takes any width, and a `Spacer`: 8 pt minimum,
        /// otherwise whatever it is offered. Heights are fixed.
        enum Kind { case fixed(CGFloat), greedy, space }

        func solve(_ kinds: [Kind], width: CGFloat?, spacing: CGFloat = 0) -> Solver.Result {
            Solver.solve(
                axis: .horizontal,
                spacing: spacing,
                crossAnchor: 0.5,
                children: kinds.map {
                    if case .space = $0 { .init(isSpace: true, priority: 0) } else { .init(isSpace: false, priority: 0) }
                },
                proposedWidth: width,
                proposedHeight: 100,
                measure: { index, w, _ in
                    switch kinds[index] {
                    case let .fixed(length): CGSize(width: length, height: 20)
                    case .greedy: CGSize(width: w ?? 10, height: 30)
                    case .space: CGSize(width: max(8, w ?? 8), height: 8)
                    }
                }
            )
        }

        @Test("space takes what the other children leave")
        func spaceTakesTheRest() {
            let result = solve([.fixed(40), .space, .fixed(40)], width: 300)
            #expect(result.size == CGSize(width: 300, height: 20))
            #expect(result.frames.map(\.origin.x) == [0, 40, 260])
        }

        @Test("space yields to a flexible child and keeps its minimum")
        func spaceYieldsToFlexibleChild() {
            let result = solve([.fixed(40), .space, .greedy, .fixed(40)], width: 300, spacing: 10)
            #expect(result.frames.map(\.size.width) == [40, 8, 182, 40])
        }

        @Test("space has no cross size")
        func spaceHasNoCrossSize() {
            #expect(solve([.space], width: 300).size.height == 0)
        }

        @Test("unspecified width gives every child its ideal length")
        func unspecifiedWidth() {
            #expect(solve([.fixed(40), .space, .fixed(40)], width: nil).size == CGSize(width: 88, height: 20))
        }

        /// A native stack has no place for children of an infinite stack either;
        /// the frames stay finite so a mirrored layout does not land at NaN.
        @Test("an infinite proposal keeps the frames finite")
        func infiniteProposalKeepsFramesFinite() {
            let result = Solver.solve(
                axis: .horizontal,
                spacing: 8,
                crossAnchor: 0,
                children: [.init(isSpace: false, priority: 0), .init(isSpace: true, priority: 0), .init(isSpace: false, priority: 0)],
                proposedWidth: .infinity,
                proposedHeight: nil,
                measure: { _, w, h in CGSize(width: w ?? 10, height: h ?? 10) }
            )
            #expect(result.frames.allSatisfy { $0.origin.x.isFinite && $0.origin.y.isFinite })
        }

        @Test("a reported size proposed back gives the same frames")
        func reportedSizeIsStable() {
            let kinds: [Kind] = [.fixed(40), .space, .greedy, .fixed(40)]
            let measured = solve(kinds, width: nil, spacing: 8)
            let placed = solve(kinds, width: measured.size.width, spacing: 8)
            #expect(placed.size == measured.size)
            #expect(placed.frames.map(\.size.width) == measured.frames.map(\.size.width))
        }
    }

    /// Renders `AdaptyUIFlexStackLayout` next to the native `HStack` / `VStack` it
    /// replaces and checks that every child and the stack end up in the same place.
    @MainActor
    struct NativeParityTests {
        final class Frames {
            var all: [String: CGRect] = [:]
        }

        /// Passes everything through and records where it was placed.
        struct Probe: Layout {
            let name: String
            let frames: Frames

            func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
                subviews.first?.sizeThatFits(proposal) ?? .zero
            }

            func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
                frames.all[name] = bounds
                subviews.first?.place(at: bounds.origin, proposal: proposal)
            }
        }

        enum Kind: CustomStringConvertible {
            case fixed(CGFloat, CGFloat)
            case flexible(CGFloat, CGFloat?)
            case text(String)
            case priority(Double, CGFloat)
            case image
            case space

            var description: String {
                switch self {
                case let .fixed(w, h): "fixed \(w)x\(h)"
                case let .flexible(min, max): "flexible \(min)...\(max.map { "\($0)" } ?? "inf")"
                case let .text(s): "text \"\(s)\""
                case let .priority(p, w): "priority \(p) ideal \(w)"
                case .image: "image fit"
                case .space: "space"
                }
            }
        }

        struct Content: View {
            let kinds: [Kind]
            let custom: Bool
            let frames: Frames

            var body: some View {
                ForEach(0 ..< kinds.count, id: \.self) { index in
                    let name = "child \(index)"
                    switch kinds[index] {
                    case let .fixed(w, h):
                        Probe(name: name, frames: frames) { Color.red.frame(width: w, height: h) }
                    case let .flexible(min, max):
                        Probe(name: name, frames: frames) {
                            Color.red.frame(minWidth: min, maxWidth: max ?? .infinity, minHeight: min, maxHeight: max ?? .infinity)
                        }
                    case let .text(string):
                        Probe(name: name, frames: frames) { Text(string) }
                    case let .priority(priority, ideal):
                        Probe(name: name, frames: frames) {
                            Color.red.frame(
                                minWidth: 0, idealWidth: ideal, maxWidth: .infinity,
                                minHeight: 0, idealHeight: ideal, maxHeight: .infinity
                            )
                        }
                        .layoutPriority(priority)
                    case .image:
                        Probe(name: name, frames: frames) {
                            Image(systemName: "star.fill").resizable().aspectRatio(contentMode: .fit)
                        }
                    case .space:
                        if custom { Spacer().layoutValue(key: AdaptyUIFlexStackSpaceKey.self, value: true) } else { Spacer() }
                    }
                }
            }
        }

        struct Case: CustomStringConvertible {
            let kinds: [Kind]
            let horizontal: Bool
            let spacing: CGFloat
            let alignment: Int
            let size: CGSize
            let fixedSize: (horizontal: Bool, vertical: Bool)
            let layoutDirection: LayoutDirection

            var description: String {
                "\(horizontal ? "H" : "V") spacing \(spacing) alignment \(alignment) size \(size) fixedSize \(fixedSize) "
                    + "\(layoutDirection) kinds \(kinds)"
            }
        }

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
            var g = Generator(state: 7)
            let texts = ["Hi", "A longer line of text that wraps", "Two words"]
            return (0 ..< count).map { _ in
                let kinds: [Kind] = (0 ..< Int.random(in: 1 ... 5, using: &g)).map { _ in
                    switch Int.random(in: 0 ... 6, using: &g) {
                    case 0: .fixed(CGFloat(Int.random(in: 10 ... 120, using: &g)), CGFloat(Int.random(in: 10 ... 60, using: &g)))
                    case 1: .flexible(
                            CGFloat(Int.random(in: 0 ... 40, using: &g)),
                            Bool.random(using: &g) ? nil : CGFloat(Int.random(in: 50 ... 150, using: &g))
                        )
                    case 2: .text(texts.randomElement(using: &g)!)
                    case 3: .priority(Double(Int.random(in: -1 ... 1, using: &g)), CGFloat(Int.random(in: 10 ... 80, using: &g)))
                    case 4: .image
                    default: .space
                    }
                }
                return Case(
                    kinds: kinds,
                    horizontal: Bool.random(using: &g),
                    spacing: [0, 8, -6, 12].randomElement(using: &g)!,
                    alignment: Int.random(in: 0 ... 2, using: &g),
                    size: CGSize(width: CGFloat(Int.random(in: 40 ... 400, using: &g)), height: CGFloat(Int.random(in: 40 ... 400, using: &g))),
                    fixedSize: [(false, false), (true, false), (false, true), (true, true)].randomElement(using: &g)!,
                    layoutDirection: Bool.random(using: &g) ? .leftToRight : .rightToLeft
                )
            }
        }

        static func render(_ view: some View, _ size: CGSize) {
            let root = view.frame(width: size.width, height: size.height, alignment: .topLeading)
            #if canImport(UIKit)
            let window = UIWindow(frame: CGRect(origin: .zero, size: size))
            window.rootViewController = UIHostingController(rootView: root)
            window.makeKeyAndVisible()
            window.rootViewController?.view.layoutIfNeeded()
            window.isHidden = true
            #else
            let host = NSHostingView(rootView: root)
            host.frame = CGRect(origin: .zero, size: size)
            host.layoutSubtreeIfNeeded()
            #endif
        }

        static func frames(_ testCase: Case, custom: Bool) -> [String: CGRect] {
            let frames = Frames()
            let content = Content(kinds: testCase.kinds, custom: custom, frames: frames)
            let anchor = [CGFloat(0), 0.5, 1][testCase.alignment]
            let stack: AnyView =
                if custom {
                    AnyView(AdaptyUIFlexStackLayout(
                        conditions: [],
                        direction: testCase.horizontal ? .horizontal : .vertical,
                        screenSize: CGSize(width: 402, height: 874),
                        orientation: .portrait,
                        huggedAxes: [],
                        horizontalSpacing: testCase.spacing,
                        verticalSpacing: testCase.spacing,
                        verticalAnchor: anchor,
                        horizontalAnchor: anchor
                    ) { content })
                } else if testCase.horizontal {
                    AnyView(HStack(alignment: [VerticalAlignment.top, .center, .bottom][testCase.alignment], spacing: testCase.spacing) { content })
                } else {
                    AnyView(VStack(alignment: [HorizontalAlignment.leading, .center, .trailing][testCase.alignment], spacing: testCase.spacing) { content })
                }
            render(
                Probe(name: "stack", frames: frames) {
                    stack.fixedSize(horizontal: testCase.fixedSize.horizontal, vertical: testCase.fixedSize.vertical)
                }
                .environment(\.layoutDirection, testCase.layoutDirection),
                testCase.size
            )
            return frames.all
        }

        static func same(_ lhs: CGRect?, _ rhs: CGRect?) -> Bool {
            guard let lhs, let rhs else { return false }
            return abs(lhs.minX - rhs.minX) < 0.01 && abs(lhs.minY - rhs.minY) < 0.01
                && abs(lhs.width - rhs.width) < 0.01 && abs(lhs.height - rhs.height) < 0.01
        }

        /// Random stacks against the native ones: 1–5 children that keep their size,
        /// have bounds of their own, wrap, have a layout priority, keep an aspect
        /// ratio or are a `Spacer`; positive, zero and negative spacing; every
        /// cross alignment, both directions, both layout directions, and every
        /// combination of `fixedSize`.
        @Test("Flex stack places like the native stacks")
        func placesLikeTheNativeStacks() {
            var mismatches: [String] = []
            for testCase in Self.cases(count: 5000) {
                // Thousands of hosting views pile up otherwise and the process runs out.
                let (native, custom) = autoreleasepool { (Self.frames(testCase, custom: false), Self.frames(testCase, custom: true)) }
                let wrong = Set(native.keys).union(custom.keys).sorted().filter { !Self.same(native[$0], custom[$0]) }
                if !wrong.isEmpty {
                    mismatches.append("\(testCase): " + wrong.map {
                        "\($0) native \(native[$0].map { "\($0)" } ?? "-") custom \(custom[$0].map { "\($0)" } ?? "-")"
                    }.joined(separator: "; "))
                }
            }
            #expect(mismatches.isEmpty, "\(mismatches.count) mismatches:\n\(mismatches.joined(separator: "\n"))")
        }
    }
}
