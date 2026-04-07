//
//  SwiftUI+TextField.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 13/03/2026.
//

#if canImport(UIKit)

import SwiftUI

// MARK: - Line Limit

extension View {
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @ViewBuilder
    func applyLineLimit(
        kind: VC.TextField.Kind,
        minRows: Int?,
        maxRows: Int?
    ) -> some View {
        switch kind {
        case .singleLine:
            lineLimit(1)
        case .multiLine:
            switch (minRows, maxRows) {
            case (.none, .none):
                lineLimit(nil)
            case (.some(let minRows), .none):
                lineLimit(minRows...)
            case (.none, .some(let maxRows)):
                lineLimit(maxRows)
            case (.some(let minRows), .some(let maxRows)):
                lineLimit(minRows ... maxRows)
            }
        }
    }
}

// MARK: - Text Attributes

extension View {
    @ViewBuilder
    func applyTextAttributes(
        _ attr: VC.RichText.Attributes?,
        assetsCache: AdaptyUIAssetsCache,
        colorScheme: ColorScheme
    ) -> some View {
        let fontAsset = assetsCache.cachedAsset(attr?.fontAssetId, mode: colorScheme.toVCMode).asFontAsset
        let colorAsset = assetsCache.cachedAsset(attr?.txtColor, mode: colorScheme.toVCMode).asColorAsset

        let resolvedFont: Font? = fontAsset.map { fa in
            Font(attr?.size.map { fa.font.withSize(CGFloat($0)) } ?? fa.font)
        } ?? attr?.size.map { Font.system(size: CGFloat($0)) }

        let tracking = CGFloat(fontAsset?.defaultLetterSpacing ?? 0)

        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self
                .font(resolvedFont)
                .foregroundColor(colorAsset ?? fontAsset?.defaultColor)
                .underline(attr?.underline ?? false)
                .strikethrough(attr?.strike ?? false)
                .tracking(tracking)
        } else {
            self
                .font(resolvedFont)
                .foregroundColor(colorAsset ?? fontAsset?.defaultColor)
        }
    }
}

// MARK: - Input Constraints

private enum TextFieldConstraintRegexCache {
    nonisolated(unsafe) static var cache: [String: NSRegularExpression] = [:]

    static func regex(for pattern: String) -> NSRegularExpression? {
        if let cached = cache[pattern] { return cached }
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        self.cache[pattern] = regex
        return regex
    }
}

private func applyTextConstraints(
    _ newValue: String,
    constraints: VC.TextField.InputConstraints,
    lastValid: Binding<String>,
    text: Binding<String>
) {
    var filtered = newValue

    // maxLength is measured in Unicode extended grapheme clusters (Swift String.count)
    if let max = constraints.maxLength, filtered.count > max {
        filtered = String(filtered.prefix(max))
    }

    if let pattern = constraints.regex,
       !filtered.isEmpty,
       let regex = TextFieldConstraintRegexCache.regex(for: pattern)
    {
        let range = NSRange(filtered.startIndex..., in: filtered)
        if let match = regex.firstMatch(in: filtered, range: range),
           match.range == range
        {
            // whole string matched — keep filtered as-is
        } else {
            filtered = lastValid.wrappedValue
        }
    }

    if filtered != newValue {
        text.wrappedValue = filtered
    }
    lastValid.wrappedValue = filtered
}

extension View {
    @ViewBuilder
    func applyInputConstraints(
        _ constraints: VC.TextField.InputConstraints?,
        text: Binding<String>,
        lastValid: Binding<String>
    ) -> some View {
        if let constraints {
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                self
                    .onAppear { lastValid.wrappedValue = text.wrappedValue }
                    .onChange(of: text.wrappedValue) { _, newValue in
                        applyTextConstraints(
                            newValue,
                            constraints: constraints,
                            lastValid: lastValid,
                            text: text
                        )
                    }
            } else {
                self
                    .onAppear { lastValid.wrappedValue = text.wrappedValue }
                    .onChange(of: text.wrappedValue) { newValue in
                        applyTextConstraints(
                            newValue,
                            constraints: constraints,
                            lastValid: lastValid,
                            text: text
                        )
                    }
            }
        } else {
            self
        }
    }
}


// MARK: - Focus ID

@MainActor
private struct FocusIdModifier: ViewModifier {
    let focusId: String
    @EnvironmentObject var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject var navigatorViewModel: AdaptyUINavigatorViewModel
    @Environment(\.adaptyScreenInstance) var screen: VS.ScreenInstance
    @FocusState private var isFocused: Bool

    private var onFocusChangeActions: [VC.Action]? {
        navigatorViewModel.navigator.defaultScreenActions.onFocusChange
            ?? navigatorViewModel.screens.last?.configuration.screenActions.onFocusChange
    }

    private func handleFocusChanged(oldFocusId: String?, newFocusId: String?) {
        if let actions = onFocusChangeActions, !actions.isEmpty {
            stateViewModel.fireFocusChangeActions(
                oldFocusId: oldFocusId,
                newFocusId: newFocusId,
                actions: actions,
                screen: screen
            )
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            content
                .focused($isFocused)
                .onChange(of: stateViewModel.focusedId) { oldId, newId in
                    isFocused = (newId == focusId)
                }
                .onChange(of: isFocused) { _, focused in
                    let oldFocusId = stateViewModel.focusedId
                    if focused {
                        stateViewModel.focusedId = focusId
                        handleFocusChanged(oldFocusId: oldFocusId, newFocusId: focusId)
                    } else if oldFocusId == focusId {
                        stateViewModel.focusedId = nil
                        handleFocusChanged(oldFocusId: oldFocusId, newFocusId: nil)
                    }
                }
        } else {
            content
                .focused($isFocused)
                .onChange(of: stateViewModel.focusedId) { newId in
                    isFocused = (newId == focusId)
                }
                .onChange(of: isFocused) { focused in
                    let oldFocusId = stateViewModel.focusedId
                    if focused {
                        stateViewModel.focusedId = focusId
                        handleFocusChanged(oldFocusId: oldFocusId, newFocusId: focusId)
                    } else if oldFocusId == focusId {
                        stateViewModel.focusedId = nil
                        handleFocusChanged(oldFocusId: oldFocusId, newFocusId: nil)
                    }
                }
        }
    }
}

extension View {
    @ViewBuilder
    func applyFocusId(_ focusId: String?) -> some View {
        if let focusId {
            modifier(FocusIdModifier(focusId: focusId))
        } else {
            self
        }
    }
}

#endif
