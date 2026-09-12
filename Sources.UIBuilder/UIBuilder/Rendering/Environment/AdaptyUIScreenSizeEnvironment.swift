//
//  AdaptyUIScreenSizeEnvironment.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .init(width: 320, height: 480)
}

struct AdaptyUIScreenInstanceKey: EnvironmentKey {
    static let defaultValue: VS.ScreenInstance = .init(
        id: "fake",
        navigatorId: "fake",
        configuration: .init(
            id: "fake",
            poolElements: [.unknown("fake")],
            layoutBehaviour: .default,
            cover: nil,
            content: 0,
            footer: nil,
            background: nil,
            overlay: nil,
            screenActions: .empty,
            contentScrollValue: nil,
            footerScrollValue: nil
        ),
        contextPath: []
    )
}

struct AdaptyUIScreenInstanceIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

struct AdaptyUIDisplayMissingTagsKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var adaptyScreenSize: CGSize {
        get { self[AdaptyUIScreenSizeKey.self] }
        set { self[AdaptyUIScreenSizeKey.self] = newValue }
    }

    var adaptyScreenInstance: VS.ScreenInstance {
        get { self[AdaptyUIScreenInstanceKey.self] }
        set { self[AdaptyUIScreenInstanceKey.self] = newValue }
    }

    var adaptyScreenInstanceId: String? {
        get { self[AdaptyUIScreenInstanceIdKey.self] }
        set { self[AdaptyUIScreenInstanceIdKey.self] = newValue }
    }

    var adaptyDisplayMissingTags: Bool {
        get { self[AdaptyUIDisplayMissingTagsKey.self] }
        set { self[AdaptyUIDisplayMissingTagsKey.self] = newValue }
    }
}

/// Narrows `adaptyScreenSize` to the area above an overlaid footer, height only.
///
/// Flat and hero append a footer-height filler below their scrolling content, so a
/// `.screen` height inside it has to resolve against the screen less the footer or
/// the footer is reserved twice.
struct AdaptyUIScreenSizeAboveFooterModifier: ViewModifier {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    let footerHeight: CGFloat

    func body(content: Content) -> some View {
        content.withScreenSize(
            CGSize(width: screenSize.width, height: max(0, screenSize.height - footerHeight))
        )
    }
}

extension View {
    package func withScreenSize(_ value: CGSize) -> some View {
        environment(\.adaptyScreenSize, value)
    }

    func withScreenSizeAboveFooter(_ footerHeight: CGFloat) -> some View {
        modifier(AdaptyUIScreenSizeAboveFooterModifier(footerHeight: footerHeight))
    }

    func withScreenInstance(_ value: VS.ScreenInstance) -> some View {
        environment(\.adaptyScreenInstance, value)
    }

    func withDisplayMissingTags(_ value: Bool) -> some View {
        environment(\.adaptyDisplayMissingTags, value)
    }
}

#endif
