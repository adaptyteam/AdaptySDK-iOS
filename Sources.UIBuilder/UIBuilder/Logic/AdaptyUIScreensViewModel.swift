//
//  AdaptyUIScreensViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Foundation

@MainActor
package final class AdaptyUIBottomSheetViewModel: ObservableObject {
    @Published var isPresented: Bool = false

    var id: String
    var bottomSheet: VC.Screen

    init(id: String, bottomSheet: VC.Screen) {
        self.id = id
        self.bottomSheet = bottomSheet
    }
}

@MainActor
package final class AdaptyUIScreensViewModel: ObservableObject {
    private let logId: String
    private let viewConfiguration: AdaptyUIConfiguration
    let bottomSheetsViewModels: [AdaptyUIBottomSheetViewModel]

    @Published var currentScreenId: String?
    @Published var presentedScreensStack = [String]()

    package init(
        logId: String,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.viewConfiguration = viewConfiguration

        bottomSheetsViewModels = viewConfiguration.screens.map {
            .init(id: $0.key, bottomSheet: $0.value)
        }

        screensInstances = []
    }

//    func openScreen(id: String) {
//        currentScreenId = id
//    }

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

    // MARK: - New Navigation Logic, TODO: x refactor

    @Published var screensInstances: [ScreenInstance]
    @Published var popupInstance: ScreenInstance?

    private var screenContexts: [String: ScreenContext] = [:]

    func getContext(forScreenId screenId: String) -> ScreenContext {
        if let existingState = screenContexts[screenId] {
            return existingState
        }

        let newState = ScreenContext()
        screenContexts[screenId] = newState
        return newState
    }

    private var viewportSize: CGSize = .zero

    func setViewPortSize(_ size: CGSize) {
        viewportSize = size
    }

    func presentPopup(
        destinationId: String
    ) {
//        guard let newScreenModel = screens.first(where: { $0.id == destinationId }) else {
//            // TODO: throw error!
//
//            return
//        }
//
//        popupInstance = ScreenInstance(
//            screen: newScreenModel
//        )
    }
    
    private func initialNavigate(
        destinationId: String,
        destination: VC.Screen
    ) {
        
        var newInstance = ScreenInstance(
            id: destinationId,
            screen: destination,
            offset: .zero,
            opacity: 1.0,
            zIndex: .zero
        )

        screensInstances.append(newInstance)
    }

    func navigate(
        destinationId: String,
        inAnimation: ScreenTransitionAnimation,
        outAnimation: ScreenTransitionAnimation
    ) {
        guard let screenVC = viewConfiguration.screens[destinationId] else {
            return // TODO: x throw error?
        }
        
        if screensInstances.isEmpty {
            initialNavigate(
                destinationId: destinationId,
                destination: screenVC
            )

            return
        }
        
        guard screensInstances.count == 1 else {
            return // in the process of animation, TODO: x think about force replacement?
        }

        guard screensInstances[0].id != destinationId else {
            return // TODO: x think about instanceId ?
        }

        var currentInstance = screensInstances[0]

        currentInstance.offset = outAnimation.startOffset
        currentInstance.opacity = outAnimation.startOpacity
        currentInstance.zIndex = outAnimation.startZIndex

        var newInstance = ScreenInstance(
            id: destinationId,
            screen: screenVC,
            offset: inAnimation.startOffset,
            opacity: inAnimation.startOpacity,
            zIndex: inAnimation.startZIndex
        )

        screensInstances[0] = currentInstance
        screensInstances.append(newInstance)

        withAnimation(inAnimation.animation) {
            newInstance.offset = inAnimation.endOffset
            newInstance.opacity = inAnimation.endOpacity
            newInstance.zIndex = inAnimation.endZIndex

            screensInstances[1] = newInstance
        }

        withAnimation(outAnimation.animation) {
            currentInstance.offset = outAnimation.endOffset
            currentInstance.opacity = outAnimation.endOpacity
            currentInstance.zIndex = outAnimation.endZIndex

            screensInstances[0] = currentInstance
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.screensInstances.remove(at: 0)
//            completion()
            //            guard let transitioning = self.transitioningScreenInstance else { return }
            //            self.currentScreenInstance = transitioning
            //            self.transitioningScreenInstance = nil
        }
    }

    // TODO: x remove
    func navigate(
        destinationId: String,
        transitionType: TransitionTypeCategory,
        transitionDirection: TransitionDirection,
        transitionStyle: TransitionStyle
//        completion: @escaping () -> Void
    ) {
        let screenSize = viewportSize

        navigate(
            destinationId: destinationId,
            inAnimation: .inAnimation(
                transitionType: transitionType,
                transitionDirection: transitionDirection,
                transitionStyle: transitionStyle,
                screenSize: screenSize
            ),
            outAnimation: .outAnimation(
                transitionType: transitionType,
                transitionDirection: transitionDirection,
                transitionStyle: transitionStyle,
                screenSize: screenSize
            )
//            completion: completion
        )
    }
}

import Combine
import SwiftUI

class ScreenContext: ObservableObject {
//    @Published var progress: Double = 0.0
//    @Published var toggleEnabled: Bool = false
}

struct ScreenInstance: Identifiable {
    let id: String // TODO: x Identifiable?
    let instanceId: UUID = .init()
    let screen: VC.Screen

    var offset: CGSize = .zero
    var opacity: Double = 1.0
    var zIndex: Double = 1.0

    var templateId: String { screen.templateId } // TODO: x move to navigate?
}

// MARK: TODO: x remove models

struct ScreenModel: Identifiable {
    let id: String
    let title: String
    let body: String
    let backgroundColor: Color

    let previousScreenId: String?
    let nextScreenId: String?

    init(
        id: String,
        title: String,
        body: String,
        backgroundColor: Color,
        previousScreenId: String? = nil,
        nextScreenId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.backgroundColor = backgroundColor
        self.previousScreenId = previousScreenId
        self.nextScreenId = nextScreenId
    }
}

enum TransitionType: String, CaseIterable {
    case none = "None"
    case fade = "Fade"
    case slideUp = "Slide Up"
    case slideDown = "Slide Down"
    case slideLeft = "Slide Left"
    case slideRight = "Slide Right"
    case moveUp = "Move Up"
    case moveDown = "Move Down"
    case moveLeft = "Move Left"
    case moveRight = "Move Right"
}

enum TransitionTypeCategory: String, CaseIterable {
    case none = "None"
    case fade = "Fade"
    case directional = "Directional"
}

enum TransitionDirection: String, CaseIterable {
    case rightToLeft = "Right to Left"
    case leftToRight = "Left to Right"
    case bottomToTop = "Bottom to Top"
    case topToBottom = "Top to Bottom"

    var title: String {
        switch self {
        case .rightToLeft: "⬅️"
        case .leftToRight: "➡️"
        case .bottomToTop: "⬆️"
        case .topToBottom: "⬇️"
        }
    }
}

enum TransitionStyle: String, CaseIterable {
    case slide
    case move

    var title: String {
        switch self {
        case .slide: "Slide Over"
        case .move: "Move"
        }
    }
}

// MARK: TODO: x remove animations

struct ScreenTransition {
    var screenId: String // destination screen id
    var outAnimation: ScreenTransitionAnimation
    var inAnimation: ScreenTransitionAnimation
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
    static func inAnimation(
        transitionType: TransitionTypeCategory,
        transitionDirection: TransitionDirection,
        transitionStyle: TransitionStyle,
        screenSize: CGSize
    ) -> ScreenTransitionAnimation {
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

    static func outAnimation(
        transitionType: TransitionTypeCategory,
        transitionDirection: TransitionDirection,
        transitionStyle: TransitionStyle,
        screenSize: CGSize
    ) -> ScreenTransitionAnimation {
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

#endif
