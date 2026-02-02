//
//  AdaptyUIScreensViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Foundation

// TODO: x move out
extension Array {
    var firstIfSingle: Element? {
        guard count == 1 else { return nil }
        return first
    }
}

struct AdaptyUIScreenInstance: Identifiable {
    var id: String { instance.id }

    let instance: VS.ScreenInstance
    let configuration: VC.Screen // TODO: x remove
    let template: VC.Template_legacy

    var offset: CGSize = .zero
    var opacity: Double = 1.0
    var zIndex: Double = 1.0
}

@MainActor // TODO: x deprecated
package final class AdaptyUIBottomSheetViewModel: ObservableObject {
    @Published var isPresented: Bool = false

    var id: String
    var bottomSheet: VC.Screen

    init(id: String, bottomSheet: VC.Screen) {
        self.id = id
        self.bottomSheet = bottomSheet
    }
}

typealias AdaptyUINavigatorId = String

@MainActor
package final class AdaptyUINavigatorViewModel: ObservableObject {
    let id: AdaptyUINavigatorId
    let zIndexBase: Double

    @Published
    private(set) var screens: [AdaptyUIScreenInstance]

    private var viewportSize: CGSize = .zero

    init(
        id: String,
        zIndexBase: Double,
        screen: AdaptyUIScreenInstance
    ) {
        self.id = id
        self.zIndexBase = zIndexBase

        screens = [screen]
    }

    func setViewPortSize(_ size: CGSize) {
        viewportSize = size
    }

    func reportOnAppear(_ animationBuilder: (CGSize) -> ScreenTransitionAnimation) {
        // TODO: x implement
    }

    func present(
        screen: AdaptyUIScreenInstance,
        inAnimation inAnimationBuilder: (CGSize) -> ScreenTransitionAnimation,
        outAnimation outAnimation: (CGSize) -> ScreenTransitionAnimation
    ) {
        guard var currentScreen = screens.firstIfSingle else {
            // TODO: x throw error?
            return // in the process of animation, TODO: x think about force replacement?
        }

        guard currentScreen.id != screen.id else {
            return // TODO: x throw error?
        }

        let inAnimation = inAnimationBuilder(viewportSize)
        let outAnimation = outAnimation(viewportSize)

        currentScreen.offset = outAnimation.startOffset
        currentScreen.opacity = outAnimation.startOpacity
        currentScreen.zIndex = outAnimation.startZIndex

        var newScreen = screen

        newScreen.offset = inAnimation.startOffset
        newScreen.opacity = inAnimation.startOpacity
        newScreen.zIndex = inAnimation.startZIndex

        screens[0] = currentScreen
        screens.append(newScreen)

        withAnimation(inAnimation.animation) {
            newScreen.offset = inAnimation.endOffset
            newScreen.opacity = inAnimation.endOpacity
            newScreen.zIndex = inAnimation.endZIndex

            screens[1] = newScreen
        }

        withAnimation(outAnimation.animation) {
            currentScreen.offset = outAnimation.endOffset
            currentScreen.opacity = outAnimation.endOpacity
            currentScreen.zIndex = outAnimation.endZIndex

            screens[0] = currentScreen
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.screens.remove(at: 0)
//            completion()
            //            guard let transitioning = self.transitioningScreenInstance else { return }
            //            self.currentScreenInstance = transitioning
            //            self.transitioningScreenInstance = nil
        }
    }
}

@MainActor
package final class AdaptyUIScreensViewModel: ObservableObject {
    private let logId: String
    private let viewConfiguration: AdaptyUIConfiguration

    var isRightToLeft: Bool { viewConfiguration.isRightToLeft }

    @Published
    private(set) var presentedScreensStack = [String]() // TODO: x deprecated
    let bottomSheetsViewModels: [AdaptyUIBottomSheetViewModel] // TODO: x deprecated

    @Published
    private(set) var navigators: [AdaptyUINavigatorViewModel]

    package init(
        logId: String,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.viewConfiguration = viewConfiguration

        bottomSheetsViewModels = viewConfiguration.screens.map {
            .init(id: $0.key, bottomSheet: $0.value)
        }

        navigators = []
    }

    func setViewPortSize(_ size: CGSize) {
        navigators.forEach { $0.setViewPortSize(size) }
    }

    // TODO: x refactor
    func present(
        screen: VS.ScreenInstance,
        in navigatorId: AdaptyUINavigatorId,
        inAnimation: (CGSize) -> ScreenTransitionAnimation,
        outAnimation: (CGSize) -> ScreenTransitionAnimation
    ) {
        // TODO: extract
        let screenConfiguration = screen.configuration

        guard let screenTemplate = VC.Template_legacy(rawValue: screenConfiguration.templateId)
        else {
            // no screen found or unsupported template
            return // TODO: x throw error?
        }

        let screen = AdaptyUIScreenInstance(
            instance: screen,
            configuration: screenConfiguration,
            template: screenTemplate
        )

        guard let navigator = navigators.first(where: { $0.id == navigatorId }) else {
            navigators.append(
                AdaptyUINavigatorViewModel(
                    id: navigatorId,
                    zIndexBase: Double(navigators.count * 1_000),
                    screen: screen
                )
            )

            return
        }

        navigator.present(
            screen: screen,
            inAnimation: inAnimation,
            outAnimation: outAnimation
        )
    }

    // MARK: - Old Deprecated Logic

    // TODO: x deprecate
    func presentScreen(id: String) {
        Log.ui.verbose("#\(logId)# presentScreen \(id)")

        if presentedScreensStack.contains(where: { $0 == id }) {
            Log.ui.warn("#\(logId)# presentScreen \(id) Already Presented!")
            return
        }

        for bottomSheetVM in bottomSheetsViewModels {
            if bottomSheetVM.id == id {
                bottomSheetVM.isPresented = true
                presentedScreensStack.append(id)
            }
        }
    }

    // TODO: x deprecate
    func dismissScreen(id: String) {
        Log.ui.verbose("#\(logId)# dismissScreen \(id)")
        presentedScreensStack.removeAll(where: { $0 == id })

        for bottomSheetVM in bottomSheetsViewModels {
            if bottomSheetVM.id == id {
                bottomSheetVM.isPresented = false
            }
        }
    }

    // TODO: x deprecate
    func dismissTopScreen() {
        guard let topScreenId = presentedScreensStack.last else { return }

        dismissScreen(id: topScreenId)
    }

    // TODO: x deprecate
    package func resetScreensStack() {
        Log.ui.verbose("#\(logId)# resetScreensStack")
        presentedScreensStack.removeAll()
        bottomSheetsViewModels.forEach { $0.isPresented = false }
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
