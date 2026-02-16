//
//  AdaptyUIScreensViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Foundation

extension VC {
    func navigator(id: String) -> Navigator? {
        navigators[id] ?? navigators["default"]
    }
}

@MainActor
package final class AdaptyUIScreensViewModel: ObservableObject {
    private let logId: String
    private let viewConfiguration: VC

    var isRightToLeft: Bool { viewConfiguration.isRightToLeft }

    @Published
    private(set) var navigatorsViewModels: [AdaptyUINavigatorViewModel]

    package init(
        logId: String,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.viewConfiguration = viewConfiguration
        navigatorsViewModels = []
    }

    private var viewportSize: CGSize = .zero

    func setViewPortSize(_ size: CGSize) {
        viewportSize = size
        navigatorsViewModels.forEach { $0.setViewPortSize(size) }
    }

    // TODO: x refactor
    func present(
        screen: VS.ScreenInstance,
        transitionId: String
//        inAnimation: (CGSize) -> ScreenTransitionAnimation,
//        outAnimation: (CGSize) -> ScreenTransitionAnimation
    ) {
        Log.ui.verbose("#\(logId)# present screen:\(screen.id) in navigator:\(screen.navigatorId)")

        guard let navigatorConfig = viewConfiguration.navigator(id: screen.navigatorId) else {
            Log.ui.warn("#\(logId)# failed to present screen:\(screen.id) in navigator:\(screen.navigatorId) (navigator not found)")
            return // TODO: x error?
        }

        let transition = navigatorConfig.transitions?[transitionId]

        let screen = AdaptyUIScreenInstance(
            instance: screen,
            incomingTransition: transition?.incoming,
            outgoingTransition: transition?.outgoing
        )

        guard let navigatorVM = navigatorsViewModels.first(where: { $0.id == navigatorConfig.id }) else {
            navigatorsViewModels.append(
                AdaptyUINavigatorViewModel(
                    navigator: navigatorConfig,
                    screen: screen,
                    presentAnimationBuilder: navigatorsViewModels.isEmpty ? nil : ScreenTransitionAnimation.inAnimationBuilder(
                        transitionType: .directional,
                        transitionDirection: .bottomToTop,
                        transitionStyle: .move
                    ),
                    viewportSize: viewportSize
                    // TODO: x add in_animation and play onAppear
                )
            )

            return
        }

        navigatorVM.present(
            screen: screen,
            transitionId: transitionId
//            inAnimation: inAnimation,
//            outAnimation: outAnimation
        )
    }

    func dismiss(
        navigatorId: String,
        transitionId: String
    ) {
        Log.ui.verbose("#\(logId)# dismiss navigator:\(navigatorId)")

        guard let index = navigatorsViewModels.firstIndex(where: { $0.id == navigatorId }) else {
            Log.ui.error("#\(logId)# failed to dismiss navigator:\(navigatorId) (navigator not found)")

            return
        }

        let navigatorVM = navigatorsViewModels[index]

        navigatorVM.dismissNavigator(
            //            outAnimation: ScreenTransitionAnimation.outAnimationBuilder(
//                transitionType: .directional,
//                transitionDirection: .topToBottom,
//                transitionStyle: .move
//            ),
            transitionId: transitionId,
            completion: { [weak self] in
                self?.navigatorsViewModels.remove(at: index)
            }
        )
    }
}

// MARK: TODO: x remove animations

import Combine
import SwiftUI

enum TransitionType: String, CaseIterable {
    case none
    case fade
    case slideUp
    case slideDown
    case slideLeft
    case slideRight
    case moveUp
    case moveDown
    case moveLeft
    case moveRight
}

enum TransitionTypeCategory: String, CaseIterable {
    case none
    case fade
    case directional
}

enum TransitionDirection: String, CaseIterable {
    case rightToLeft
    case leftToRight
    case bottomToTop
    case topToBottom
}

enum TransitionStyle: String, CaseIterable {
    case slide
    case move
}

struct ScreenTransitionAnimation {
    var startOffset: CGSize = .zero
    var startOpacity: Double = 1.0
    var startZIndex: Double = 1.0

    var endOffset: CGSize = .zero
    var endOpacity: Double = 1.0
    var endZIndex: Double = 1.0

    var animation: Animation = .linear

    init(
        startOffset: CGSize = .zero,
        startOpacity: Double = 1.0,
        startZIndex: Double = 1.0,
        endOffset: CGSize = .zero,
        endOpacity: Double = 1.0,
        endZIndex: Double = 1.0,
        animation: Animation = .linear
    ) {
        self.startOffset = startOffset
        self.startOpacity = startOpacity
        self.startZIndex = startZIndex
        self.endOffset = endOffset
        self.endOpacity = endOpacity
        self.endZIndex = endZIndex
        self.animation = animation
    }
}

extension ScreenTransitionAnimation {
    static func inAnimationBuilder(
        transitionType: TransitionTypeCategory,
        transitionDirection: TransitionDirection,
        transitionStyle: TransitionStyle
    ) -> (CGSize) -> ScreenTransitionAnimation {
        { screenSize in
            switch (transitionType, transitionDirection, transitionStyle) {
            case (.none, _, _):
                return .init()
            case (.fade, _, _):
                return .init(
                    startOpacity: 0.0,
                    startZIndex: 1.0,
                    endZIndex: 1.0
                )
            case (_, .leftToRight, let style):
                return .init(
                    startOffset: .init(
                        width: style == .move ? -screenSize.width : -screenSize.width / 2, height: 0.0
                    ),
                    startZIndex: 0.0,
                    endZIndex: 0.0
                )
            case (_, .rightToLeft, _):
                return .init(
                    startOffset: .init(width: screenSize.width, height: 0.0),
                    startZIndex: 1.0,
                    endZIndex: 1.0
                )
            case (_, .topToBottom, _):
                return .init(
                    startOffset: .init(width: 0.0, height: -screenSize.height),
                    startZIndex: 1.0,
                    endZIndex: 1.0
                )
            case (_, .bottomToTop, _):
                return .init(
                    startOffset: .init(width: 0.0, height: screenSize.height),
                    startZIndex: 1.0,
                    endZIndex: 1.0
                )
            }
        }
    }

    static func outAnimationBuilder(
        transitionType: TransitionTypeCategory,
        transitionDirection: TransitionDirection,
        transitionStyle: TransitionStyle
    ) -> (CGSize) -> ScreenTransitionAnimation {
        { screenSize in
            switch (transitionType, transitionDirection, transitionStyle) {
            case (.none, _, _):
                return .init()
            case (.fade, _, _):
                return .init(
                    startZIndex: 0.0,
                    endOpacity: 0.0,
                    endZIndex: 0.0
                )
            case (_, .leftToRight, let style):
                return .init(
                    startZIndex: 1.0,
                    endOffset: .init(
                        width: screenSize.width,
                        height: 0.0
                    ),
                    endZIndex: 1.0
                )
            case (_, .rightToLeft, let style):
                return .init(
                    startZIndex: 0.0,
                    endOffset: .init(
                        width: style == .move ? -screenSize.width : -screenSize.width / 2,
                        height: 0.0
                    ),
                    endZIndex: 0.0
                )
            case (_, .topToBottom, let style):
                return .init(
                    startZIndex: 0.0,
                    endOffset: .init(
                        width: 0.0,
                        height: style == .move ? screenSize.height : screenSize.height / 2
                    ),
                    endZIndex: 0.0
                )
            case (_, .bottomToTop, let style):
                return .init(
                    startZIndex: 0.0,
                    endOffset: .init(
                        width: 0.0,
                        height: style == .move ? -screenSize.height : -screenSize.height / 2
                    ),
                    endZIndex: 0.0
                )
            }
        }
    }
}

#endif
