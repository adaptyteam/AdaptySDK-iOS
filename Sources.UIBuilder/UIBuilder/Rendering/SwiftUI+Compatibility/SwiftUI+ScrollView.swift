//
//  SwiftUI+ScrollView.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit)

import SwiftUI

extension View {
    @ViewBuilder
    func scrollIndicatorsHidden_compatible() -> some View {
        if #available(iOS 16.0, *) {
            scrollIndicators(.hidden)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyScrollAnchor(_ id: String?) -> some View {
        if let id {
            self.id(id)
        } else {
            self
        }
    }

    @ViewBuilder
    func scrollToFocusedField(
        using scrollProxy: ScrollViewProxy,
        stateViewModel: AdaptyUIStateViewModel
    ) -> some View {
        onChange(of: stateViewModel.focusedId) { [weak stateViewModel] focusedId in
            guard let focusedId, let stateViewModel else { return }
            stateViewModel.isAutoScrollingToFocus = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak stateViewModel] in
                withAnimation {
                    scrollProxy.scrollTo(focusedId, anchor: .center)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak stateViewModel] in
                    stateViewModel?.isAutoScrollingToFocus = false
                }
            }
        }
    }

}

@MainActor
struct KeyboardBottomPaddingModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            ) { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = frame.height
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            ) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = 0
                }
            }
    }
}

extension View {
    func keyboardBottomPadding() -> some View {
        modifier(KeyboardBottomPaddingModifier())
    }
}

#endif
