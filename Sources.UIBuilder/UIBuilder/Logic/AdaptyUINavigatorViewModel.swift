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
    
    let incomingTransition: [VC.Animation]?
    let outgoingTransition: [VC.Animation]?
    
    @Published var playIncomingTransition: [VC.Animation]? = nil
    @Published var playOutgoingTransition: [VC.Animation]? = nil
    
    init(
        instance: VS.ScreenInstance,
        incomingTransition: [VC.Animation]?,
        outgoingTransition: [VC.Animation]?
    ) {
        self.instance = instance
        self.incomingTransition = incomingTransition
        self.outgoingTransition = outgoingTransition
    }
    
    func startIncomingTransition(_ animations: [VC.Animation]?) {
        playIncomingTransition = animations
    }
    
    func startOutgoingTransition(_ animations: [VC.Animation]?) {
        playOutgoingTransition = animations
    }

//    var offset: CGSize = .zero
//    var opacity: Double = 1.0
    var zIndex: Double = 1.0
}

@MainActor
package final class AdaptyUINavigatorViewModel: ObservableObject {
    var id: VC.NavigatorIdentifier { navigator.id }
    var order: Double { Double(navigator.order) }

    let navigator: VC.Navigator

    @Published
    private(set) var screens: [AdaptyUIScreenInstance]

    @Published
    private(set) var offset: CGSize
    @Published
    private(set) var opacity: Double

    private var viewportSize: CGSize = .zero
    private var presentAnimationBuilder: ((CGSize) -> ScreenTransitionAnimation)?

    init(
        navigator: VC.Navigator,
        screen: AdaptyUIScreenInstance,
        presentAnimationBuilder: ((CGSize) -> ScreenTransitionAnimation)?,
        viewportSize: CGSize
    ) {
        self.navigator = navigator
        self.viewportSize = viewportSize
        self.presentAnimationBuilder = presentAnimationBuilder

        offset = .zero
        opacity = 0.0

        screens = [screen]
    }

    func setViewPortSize(_ size: CGSize) {
        viewportSize = size
    }

    func reportOnAppear() {
//        if let presentAnimationBuilder {
//            presentNavigator(
//                inAnimation: presentAnimationBuilder,
//                completion: {}
//            )
//        } else {
            offset = .zero
            opacity = 1.0
//        }
    }

    func present(
        screen: AdaptyUIScreenInstance,
        transitionId: String
    ) {
        guard var currentScreen = screens.firstIfSingle else {
            // TODO: x throw error?
            return // in the process of animation, TODO: x think about force replacement?
        }

        guard currentScreen.id != screen.id else {
            return // TODO: x throw error?
        }
        
        let transition = navigator.transitions?[transitionId]
//        let inAnimation = transition?.incoming
        

//        let inAnimation = inAnimationBuilder(viewportSize)
//        let outAnimation = outAnimation(viewportSize)

//        currentScreen.offset = outAnimation.startOffset
//        currentScreen.opacity = outAnimation.startOpacity
//        currentScreen.zIndex = outAnimation.startZIndex
//
        var newScreen = screen
        
        currentScreen.startOutgoingTransition(transition?.outgoing)
        newScreen.startIncomingTransition(transition?.incoming)

//
//        newScreen.offset = inAnimation.startOffset
//        newScreen.opacity = inAnimation.startOpacity
//        newScreen.zIndex = inAnimation.startZIndex
//
//        screens[0] = currentScreen
        screens.append(newScreen)
//
//        withAnimation(inAnimation.animation) {
//            newScreen.offset = inAnimation.endOffset
//            newScreen.opacity = inAnimation.endOpacity
//            newScreen.zIndex = inAnimation.endZIndex
//
//            screens[1] = newScreen
//        }
//
//        withAnimation(outAnimation.animation) {
//            currentScreen.offset = outAnimation.endOffset
//            currentScreen.opacity = outAnimation.endOpacity
//            currentScreen.zIndex = outAnimation.endZIndex
//
//            screens[0] = currentScreen
//        }

        // TODO: x fix duration
//        screens.remove(at: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.screens.remove(at: 0)
//            completion()
        }
    }

    func presentNavigator(
        transitionId: String,
        completion: @escaping () -> Void
    ) {
        offset = .zero
        opacity = 1.0
        
//        let inAnimation = inAnimation(viewportSize)
//
//        offset = inAnimation.startOffset
//        opacity = inAnimation.startOpacity
//
//        withAnimation(inAnimation.animation) {
//            offset = inAnimation.endOffset
//            opacity = inAnimation.endOpacity
//        }
//
        // TODO: x fix duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            completion()
        }
    }

    func dismissNavigator(
        transitionId: String,
        completion: @escaping () -> Void
    ) {
//        let outAnimation = outAnimation(viewportSize)
//
//        withAnimation(outAnimation.animation) {
//            offset = outAnimation.endOffset
//            opacity = outAnimation.endOpacity
//        }
//
        // TODO: x fix duration
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            completion()
//        }
    }
}

#endif
