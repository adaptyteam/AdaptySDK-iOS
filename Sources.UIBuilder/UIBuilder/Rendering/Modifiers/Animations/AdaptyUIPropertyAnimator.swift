//
//  AdaptyUIPropertyAnimator.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 6/6/25.
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Animation.Timeline {
    @MainActor
    func animate<Value>(
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        switch loop {
        case .normal: // reset value and repeat
            AdaptyUIPropertyAnimator.animateBasicLoop(
                token: nil,
                timeline: self,
                startDelay: startDelay,
                loopCount: loopCount,
                from: start,
                to: end,
                updateBlock: updateBlock
            )
        case .pingPong: // animate back and repeat
            AdaptyUIPropertyAnimator.animatePingPongLoop(
                token: nil,
                timeline: self,
                startDelay: startDelay,
                loopCount: loopCount,
                from: start,
                to: end,
                updateBlock: updateBlock
            )
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
            do {
                try await Task.sleep(seconds: delay)
            } catch {
                token.invalidate()
                completion(token)
                return
            }

            guard token.isActive else {
                completion(token)
                return
            }

            onBeforeAnimation?()

            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                withAnimation(animation, body, completion: { completion(token) })
            } else {
                withAnimation(animation, body)
                do {
                    try await Task.sleep(seconds: duration)
                } catch {
                    token.invalidate()
                    completion(token)
                    return
                }
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
enum AdaptyUIPropertyAnimator {
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
                            Task { @MainActor in
                                do {
                                    try await Task.sleep(seconds: loopDelay)
                                } catch {
                                    token.invalidate()
                                    return
                                }
                                guard token.isActive else { return }

                                _ = animatePingPongLoop(
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

    static func animateBasicLoop<Value>(
        token: AdaptyUIAnimationToken?,
        timeline: VC.Animation.Timeline,
        startDelay: TimeInterval,
        loopCount: Int?,
        from start: Value,
        to end: Value,
        updateBlock: @escaping (Value) -> Void
    ) -> AdaptyUIAnimationToken {
        return timeline.withAsyncAnimation(
            token: token,
            delay: startDelay,
            onBeforeAnimation: { updateBlock(start) },
            body: { updateBlock(end) },
            completion: { token in
                guard token.isActive else { return }

                let loopLeftCount = (loopCount ?? .max) - 1

                if loopLeftCount > 0 {
                    Task { @MainActor in
                        do {
                            try await Task.sleep(seconds: timeline.loopDelay)
                        } catch {
                            token.invalidate()
                            return
                        }
                        guard token.isActive else { return }

                        _ = animateBasicLoop(
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
