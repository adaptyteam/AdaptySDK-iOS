//
//  AdaptyUIPropertyAnimator.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 6/6/25.
//

#if canImport(UIKit)

import SwiftUI

extension VC.Animation.Timeline {
    @MainActor
    func animate<Value>(
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        switch loop {
        case .normal:
            if loopDelay == 0 {
                // Use native SwiftUI repeat for smooth looping without frame gaps
                AdaptyUIPropertyAnimator.animateWithNativeRepeat(
                    timeline: self,
                    startDelay: startDelay,
                    loopCount: loopCount,
                    autoreverses: false,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            } else {
                // Manual loop needed for delay between iterations
                AdaptyUIPropertyAnimator.animateBasicLoop(
                    token: nil,
                    timeline: self,
                    startDelay: startDelay,
                    loopCount: loopCount,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            }
        case .pingPong:
            if loopDelay == 0 && pingPongDelay == 0 {
                // Use native SwiftUI repeat for smooth looping without frame gaps
                AdaptyUIPropertyAnimator.animateWithNativeRepeat(
                    timeline: self,
                    startDelay: startDelay,
                    loopCount: loopCount,
                    autoreverses: true,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            } else {
                // Manual loop needed for delays between iterations
                AdaptyUIPropertyAnimator.animatePingPongLoop(
                    token: nil,
                    timeline: self,
                    startDelay: startDelay,
                    loopCount: loopCount,
                    from: start,
                    to: end,
                    updateBlock: updateBlock
                )
            }
        default: // no repeat
            AdaptyUIPropertyAnimator.animateOnce(
                token: nil,
                timeline: self,
                startDelay: startDelay,
                from: start,
                to: end,
                updateBlock: updateBlock
            )
        }
    }

    @MainActor
    @discardableResult
    func withAsyncAnimation(
        token: AdaptyUIAnimationToken? = nil,
        delay: TimeInterval,
        onBeforeAnimation: (() -> Void)?,
        body: @escaping () -> Void,
        completion: @escaping (AdaptyUIAnimationToken) -> Void
    ) -> AdaptyUIAnimationToken {
        let token = token ?? .create()
        let animation = interpolator.createAnimation(duration: duration)

        Task { @MainActor in
            try await Task.sleep(seconds: delay)

            guard token.isActive else {
                completion(token)
                return
            }

            onBeforeAnimation?()

            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                withAnimation(animation, body, completion: { completion(token) })
            } else {
                withAnimation(animation, body)
                try await Task.sleep(seconds: duration)
                completion(token)
            }
        }

        return token
    }
}

typealias AdaptyUIAnimationToken = UUID

@MainActor
extension AdaptyUIAnimationToken {
    private static var storage = Set<UUID>()

    fileprivate static func create() -> Self {
        let token: Self = UUID()
        storage.insert(token)
        return token
    }

    var isActive: Bool {
        Self.storage.contains(self)
    }

    func invalidate() {
        Self.storage.remove(self)
    }
}

@MainActor
enum AdaptyUIPropertyAnimator {
    @discardableResult
    static func animatePingPongLoop<Value>(
        token: AdaptyUIAnimationToken?,
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        loopCount: Int?,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        let loopDelay = timeline.loopDelay
        let pingPongDelay = timeline.pingPongDelay

        return timeline.withAsyncAnimation(
            token: token,
            delay: startDelay,
            onBeforeAnimation: { updateBlock(start) },
            body: { updateBlock(end) },
            completion: { token in
                guard token.isActive else { return }

                timeline.withAsyncAnimation(
                    token: token,
                    delay: pingPongDelay,
                    onBeforeAnimation: nil,
                    body: { updateBlock(start) },
                    completion: { token in
                        let loopLeftCount = (loopCount ?? .max) - 1

                        if loopLeftCount > 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + loopDelay) {
                                guard token.isActive else { return }

                                animatePingPongLoop(
                                    token: token,
                                    timeline: timeline,
                                    startDelay: 0.0,
                                    loopCount: loopLeftCount,
                                    from: start,
                                    to: end,
                                    updateBlock: updateBlock
                                )
                            }
                        } else {
                            token.invalidate()
                        }
                    }
                )
            }
        )
    }

    @discardableResult
    static func animateBasicLoop<Value>(
        token: AdaptyUIAnimationToken?,
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        loopCount: Int?,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        timeline.withAsyncAnimation(
            token: token,
            delay: startDelay,
            onBeforeAnimation: { updateBlock(start) },
            body: { updateBlock(end) },
            completion: { token in
                guard token.isActive else { return }

                let loopLeftCount = (loopCount ?? .max) - 1

                if loopLeftCount > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeline.loopDelay) {
                        guard token.isActive else { return }

                        animateBasicLoop(
                            token: token,
                            timeline: timeline,
                            startDelay: 0.0,
                            loopCount: loopLeftCount,
                            from: start,
                            to: end,
                            updateBlock: updateBlock
                        )
                    }
                } else {
                    token.invalidate()
                }
            }
        )
    }

    @discardableResult
    static func animateWithNativeRepeat<Value>(
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        loopCount: Int?,
        autoreverses: Bool,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        let token = AdaptyUIAnimationToken.create()
        let baseAnimation = timeline.interpolator.createAnimation(duration: timeline.duration)

        let animation: Animation
        if let loopCount {
            let count = autoreverses ? loopCount * 2 : loopCount
            animation = baseAnimation.repeatCount(count, autoreverses: autoreverses)
        } else {
            animation = baseAnimation.repeatForever(autoreverses: autoreverses)
        }

        Task { @MainActor in
            if startDelay > 0 {
                try await Task.sleep(seconds: startDelay)
                guard token.isActive else { return }
            }

            updateBlock(start)

            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                if loopCount != nil {
                    withAnimation(animation) {
                        updateBlock(end)
                    } completion: {
                        token.invalidate()
                    }
                } else {
                    withAnimation(animation) {
                        updateBlock(end)
                    }
                }
            } else {
                withAnimation(animation) {
                    updateBlock(end)
                }
                if let loopCount {
                    let totalSegments = autoreverses ? loopCount * 2 : loopCount
                    try await Task.sleep(seconds: timeline.duration * Double(totalSegments))
                    token.invalidate()
                }
            }
        }

        return token
    }

    static func animateOnce<Value>(
        token: AdaptyUIAnimationToken?,
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        timeline.withAsyncAnimation(
            token: nil,
            delay: startDelay,
            onBeforeAnimation: { updateBlock(start) },
            body: { updateBlock(end) },
            completion: { $0.invalidate() }
        )
    }
}

#endif
