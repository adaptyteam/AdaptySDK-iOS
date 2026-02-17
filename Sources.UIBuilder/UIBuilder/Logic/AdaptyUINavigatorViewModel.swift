//
//  AdaptyUINavigatorViewModel.swift
//  Adapty
//
//  Created by Alex Goncharov on 11/02/2026.
//

#if canImport(UIKit)

import Foundation
import SwiftUI

@MainActor
final class AdaptyUIScreenInstance: ObservableObject {
    var id: String { instance.id }
    var configuration: VC.Screen { instance.configuration }

    let instance: VS.ScreenInstance
    var zIndex: Double = 1.0

    @Published var playIncomingTransition: [VC.Animation]? = nil
    @Published var playOutgoingTransition: [VC.Animation]? = nil

    init(
        instance: VS.ScreenInstance
    ) {
        self.instance = instance
    }

    func startIncomingTransition(_ animations: [VC.Animation]?) {
        playIncomingTransition = animations
    }

    func startOutgoingTransition(_ animations: [VC.Animation]?) {
        playOutgoingTransition = animations
    }
}

@MainActor
package final class AdaptyUINavigatorViewModel: ObservableObject {
    let navigator: VC.Navigator
    let appearTransitionId: String

    var id: VC.NavigatorIdentifier { navigator.id }
    var order: Double { Double(navigator.order) }

    var appearTransition: VC.Navigator.AppearanceTransition? {
        navigator.appearances?[appearTransitionId]
    }

    @Published
    private(set) var screens: [AdaptyUIScreenInstance]

    init(
        navigator: VC.Navigator,
        screen: AdaptyUIScreenInstance,
        appearTransitionId: String
    ) {
        self.navigator = navigator
        self.appearTransitionId = appearTransitionId

        screens = [screen]
    }

    @Published var backgroundAnimation: VC.Animation.Background? = nil
    @Published var contentAnimations: [VC.Animation]? = nil

    func startScreenTransition(
        _ screen: AdaptyUIScreenInstance,
        transitionId: String,
        completion: (() -> Void)?
    ) {
        guard var currentScreen = screens.firstIfSingle else {
            // TODO: x throw error?
            return // in the process of animation, TODO: x think about force replacement?
        }

        guard currentScreen.id != screen.id else {
            return // TODO: x throw error?
        }

        guard let transition = navigator.transitions?[transitionId] else {
            screens.removeAll()
            screens.append(screen)
            completion?()
            return
        }

        var newScreen = screen

        currentScreen.startOutgoingTransition(transition.outgoing)
        newScreen.startIncomingTransition(transition.incoming)

        screens.append(newScreen)

        DispatchQueue.main.asyncAfter(
            deadline: .now() + transition.totalDuration
        ) { [weak self] in
            self?.screens.remove(at: 0)
            completion?()
        }
    }

    func startNavigatorTransition(
        transitionId: String,
        completion: (() -> Void)?
    ) {
        guard let transition = navigator.appearances?[transitionId] else {
            completion?()
            return
        }

        backgroundAnimation = transition.background
        contentAnimations = transition.content

        if let completion {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + transition.totalDuration
            ) { [weak self] in
                completion()
            }
        }
    }
}

// TODO: x move out
extension VC.Animation.Background {
    var initialBackground: VC.AssetReference {
        range.start
    }
}

extension VC.Navigator.AppearanceTransition {
    var totalDuration: TimeInterval {
        let backgroundTimeline: [VC.Animation.Timeline] = if let background { [background.timeline] } else { [] }

        return
            (backgroundTimeline + (content?.map(\.timeline) ?? []))
                .map { $0.duration + $0.startDelay }
                .max { $0 > $1 } ?? 0.0
    }

    var initialContentOpacity: Double {
        content?
            .compactMap {
                if case let .opacity(timeline, range) = $0 {
                    return (timeline: timeline, range: range)
                } else {
                    return nil
                }
            }
            .min(by: { lhs, rhs in lhs.timeline.startDelay < rhs.timeline.startDelay })
            .map { $0.range.start } ?? 1.0
    }
}

extension VC.Navigator.ScreenTransition {
    var totalDuration: TimeInterval {
        ((incoming ?? []) + (outgoing ?? [])).totalDuration
    }
}

extension [VC.Animation] {
    var totalDuration: TimeInterval {
        map(\.timeline)
            .map { $0.duration + $0.startDelay }
            .max { $0 > $1 } ?? 0.0
    }
}

#endif
