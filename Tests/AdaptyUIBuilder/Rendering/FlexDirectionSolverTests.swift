//
//  FlexDirectionSolverTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Flex Layout"),
    .feature("Flex Direction"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
struct FlexDirectionSolverTests {
    typealias Solver = AdaptyUIFlexDirectionSolver

    static let phone = CGSize(width: 402, height: 874)

    /// Solves with an `h_stack` direction and counts how often the natural size
    /// was asked.
    final class Natural {
        var size: CGSize
        var asked = 0
        init(_ size: CGSize = CGSize(width: 360, height: 44)) { self.size = size }
    }

    static func solve(
        _ conditions: [VC.Condition],
        width: CGFloat?,
        height: CGFloat? = nil,
        hugsWidth: Bool = false,
        hugsHeight: Bool = false,
        screen: CGSize = phone,
        orientation: VC.Orientation = .portrait,
        natural: Natural = Natural()
    ) -> VC.Flex.Direction {
        Solver.direction(
            conditions: conditions,
            direction: .horizontal,
            proposedWidth: width,
            proposedHeight: height,
            hugsWidth: hugsWidth,
            hugsHeight: hugsHeight,
            screen: screen,
            orientation: orientation,
            naturalSize: {
                natural.asked += 1
                return natural.size
            }
        )
    }

    @Test("A specified proposal is compared")
    func specifiedProposal() {
        let wide: [VC.Condition] = [.availableWidth(min: 300, max: nil)]
        #expect(Self.solve(wide, width: 200) == .vertical)
        #expect(Self.solve(wide, width: 300) == .horizontal)
        #expect(Self.solve([.availableHeight(min: 100, max: nil)], width: 200, height: 120) == .horizontal)
    }

    /// The spec scenario: a cell 200 wide on a 402 screen.
    @Test("A cell narrower than the screen reads the cell")
    func cellNarrowerThanScreen() {
        #expect(Self.solve([.availableWidth(min: 300, max: nil)], width: 200) == .vertical)
    }

    @Test("No proposal reads the screen")
    func noProposalReadsTheScreen() {
        let natural = Natural()
        #expect(Self.solve([.availableWidth(min: 600, max: nil)], width: nil, natural: natural) == .vertical)
        #expect(Self.solve([.availableHeight(min: 700, max: nil)], width: 300, height: nil, natural: natural) == .horizontal)
        #expect(natural.asked == 0)
    }

    /// The spec scenarios under `shrink`: the length laid out in `direction`
    /// decides, not the screen and not the opposite direction.
    @Test(
        "A hugged axis without a proposal reads the natural length in direction",
        arguments: [(CGFloat(360), VC.Flex.Direction.horizontal), (240, .vertical)]
    )
    func huggedAxisReadsTheNaturalLength(naturalWidth: CGFloat, expected: VC.Flex.Direction) {
        let natural = Natural(CGSize(width: naturalWidth, height: 44))
        for screen in [Self.phone, CGSize(width: 1024, height: 1366)] {
            #expect(
                Self.solve([.availableWidth(min: 300, max: nil)], width: nil, hugsWidth: true, screen: screen, natural: natural)
                    == expected
            )
        }
    }

    @Test("A hugged axis with a proposal reads the proposal")
    func huggedAxisWithAProposal() {
        let natural = Natural(CGSize(width: 240, height: 44))
        #expect(Self.solve([.availableWidth(min: 300, max: nil)], width: 320, hugsWidth: true, natural: natural) == .horizontal)
        #expect(natural.asked == 0)
    }

    @Test("The natural size is asked once, and only for a compared axis")
    func naturalSizeIsAskedOnlyWhenRead() {
        let natural = Natural()
        _ = Self.solve(
            [.availableWidth(min: 300, max: nil), .availableWidth(min: nil, max: 500), .availableHeight(min: 10, max: nil)],
            width: nil,
            height: nil,
            hugsWidth: true,
            hugsHeight: true,
            natural: natural
        )
        #expect(natural.asked == 1)

        let unread = Natural()
        _ = Self.solve([.screenWidth(min: 300, max: nil)], width: nil, hugsWidth: true, natural: unread)
        #expect(unread.asked == 0)
    }

    @Test("Zero and infinity on one axis go through the same rule")
    func zeroAndInfinityProbes() {
        let wide: [VC.Condition] = [.availableWidth(min: 300, max: nil)]
        #expect(Self.solve(wide, width: 0) == .vertical)
        #expect(Self.solve(wide, width: .infinity) == .horizontal)
        #expect(Self.solve([.availableWidth(min: nil, max: 500)], width: .infinity) == .vertical)
        #expect(Self.solve(wide, width: 320, height: 0) == .horizontal)
        #expect(Self.solve(wide, width: 320, height: .infinity) == .horizontal)
    }

    @Test("The answer depends only on the arguments")
    func answerDependsOnlyOnTheArguments() {
        let conditions: [VC.Condition] = [.availableWidth(min: 300, max: nil)]
        let first = Self.solve(conditions, width: 320)
        _ = Self.solve(conditions, width: 0)
        _ = Self.solve(conditions, width: nil, hugsWidth: true, natural: Natural(CGSize(width: 10, height: 10)))
        _ = Self.solve(conditions, width: .infinity)
        #expect(Self.solve(conditions, width: 320) == first)
    }

    @Test("Screen and orientation conditions ignore the proposal")
    func screenAndOrientationConditions() {
        #expect(Self.solve([.screenWidth(min: 400, max: nil)], width: 10) == .horizontal)
        #expect(Self.solve([.orientation(.landscape)], width: 1000) == .vertical)
        #expect(Self.solve([], width: 0) == .horizontal)
    }

    @Test("All conditions must hold")
    func allConditionsMustHold() {
        #expect(Self.solve([.availableWidth(min: 300, max: nil), .orientation(.portrait)], width: 320) == .horizontal)
        #expect(Self.solve([.availableWidth(min: 300, max: nil), .orientation(.landscape)], width: 320) == .vertical)
    }
}
