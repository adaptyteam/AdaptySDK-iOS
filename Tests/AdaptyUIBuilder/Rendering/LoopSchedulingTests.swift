//
//  LoopSchedulingTests.swift
//  AdaptyTests
//

#if canImport(UIKit)

@testable import AdaptyUIBuilder
import Foundation
import Testing

/// Loop iterations are planned from the previous planned start, so loops keep
/// their period and their offset from each other.
@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Animations"),
    .feature("Loop Scheduling"),
    .risk(.normal),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
struct LoopSchedulingTests {
    private let origin = DispatchTime(uptimeNanoseconds: 10_000_000_000)

    @Test("An iteration on time starts one period after the previous planned start")
    func onTime() {
        let now = origin + 2.5
        let next = AdaptyUIPropertyAnimator.nextIterationStart(after: origin, period: 3.0, now: now)
        let expected = origin + 3.0
        #expect(next == expected)
    }

    /// The time the previous iteration took to report completion does not move
    /// the next start: only the planned start counts.
    @Test("Completion delays do not accumulate over iterations")
    func noAccumulation() {
        var planned = origin
        for iteration in 1 ... 20 {
            let lateCompletion = planned + 2.9
            planned = AdaptyUIPropertyAnimator.nextIterationStart(after: planned, period: 3.0, now: lateCompletion)
            let seconds: Double = 3.0 * Double(iteration)
            let expected = origin + seconds
            #expect(planned == expected)
        }
    }

    /// A loop that fell behind restarts from now instead of replaying missed
    /// iterations back to back.
    @Test("A late iteration starts right away and becomes the new origin")
    func late() {
        let now = origin + 3.4
        let next = AdaptyUIPropertyAnimator.nextIterationStart(after: origin, period: 3.0, now: now)
        #expect(next == now)

        let after = AdaptyUIPropertyAnimator.nextIterationStart(after: next, period: 3.0, now: now + 1.0)
        let expected = now + 3.0
        #expect(after == expected)
    }
}

#endif
