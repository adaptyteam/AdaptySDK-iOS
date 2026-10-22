//
//  AdaptyUITextField.swift
//  Adapty
//
//  Created by Alex Goncharov on 15/01/2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUITextField: View {
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var customTagResolverViewModel: AdaptyUITagResolverViewModel

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    private var textField: VC.TextField
    private var focusId: String?

    init(_ textField: VC.TextField, focusId: String?) {
        self.textField = textField
        self.focusId = focusId
    }

    @State private var lastConstrainedText: String = ""

    private var text: Binding<String> {
        stateViewModel.createBinding(
            textField.value,
            defaultValue: "",
            screen: screen
        )
    }

    private var isValid: Bool {
        guard let validation = textField.validation else { return true }
        return stateViewModel.getValue(validation, defaultValue: true, screen: screen)
    }

    private var activeTextAttributes: VC.TextAttributes? {
        if !isValid, let invalid = textField.invalidTextAttributes { return invalid }
        return textField.defaultTextAttributes
    }

    private var resolvedRichTextAttributes: VC.RichText.Attributes? {
        assetsViewModel.cache.resolveDataBinding(activeTextAttributes, screen)
    }

    private var promptText: Text? {
        guard let placeholder = textField.placeholder else { return nil }
        let (richText, tagValues, _) = assetsViewModel.resolvedText(
            placeholder.value,
            screen: screen,
            // Product placeholders are intentionally unsupported in text fields:
            // a placeholder is hint text shown while empty, so resolving dynamic
            // product values there is out of scope (see UIBuilder docs).
            productsInfoProvider: nil
        )
        return richText.convertToSwiftUIText(
            defaultAttributes: placeholder.defaultTextAttributes,
            assetsCache: assetsViewModel.cache,
            stateViewModel: stateViewModel,
            tagValues: tagValues,
            internalTagResolver: nil,
            customTagResolver: customTagResolverViewModel,
            productInfo: nil,
            colorScheme: colorScheme,
            screen: screen
        )
    }

    @ViewBuilder
    private var coreTextComponent: some View {
        if textField.secureEntry {
            SecureField(
                text: text,
                prompt: promptText,
                label: { EmptyView() }
            )
        } else {
            // axis: .vertical is multi-line only. With it, SwiftUI treats the
            // Return key as a newline-insert and .onSubmit never fires —
            // single-line fields would silently drop submit_action.
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *),
               textField.kind == .multiLine
            {
                TextField(
                    text: text,
                    prompt: promptText,
                    axis: .vertical,
                    label: { EmptyView() }
                )
                .applyLineLimit(
                    kind: textField.kind,
                    minRows: textField.minRows,
                    maxRows: textField.maxRows
                )
            } else {
                TextField(
                    text: text,
                    prompt: promptText,
                    label: { EmptyView() }
                )
                .lineLimit(1)
            }
        }
    }

    var body: some View {
        coreTextComponent
            .applyScrollAnchor(focusId)
            .applyFocusId(focusId)
            .onSubmit {
                stateViewModel.execute(
                    actions: textField.keyboardSubmitActions,
                    screen: screen
                )
            }
            .modifier(TextFieldAlignmentModifier(alignment: textField.horizontalAlign))
            .applyTextAttributes(
                resolvedRichTextAttributes,
                assetsCache: assetsViewModel.cache,
                colorScheme: colorScheme
            )
            .applyInputConstraints(
                textField.inputConstraints,
                text: text,
                lastValid: $lastConstrainedText
            )
            .applyKeyboardOptions(textField.keyboardOptions)
    }
}

// iOS 26+ TextField resolves .leading against the system direction and
// ignores an RTL layoutDirection override. Pin the field to LTR and pass
// the physical side instead.
private struct TextFieldAlignmentModifier: ViewModifier {
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    let alignment: VC.HorizontalAlignment

    @ViewBuilder
    func body(content: Content) -> some View {
        let logical = alignment.textAlignment(with: layoutDirection)
        if layoutDirection == .rightToLeft {
            content
                .multilineTextAlignment(logical.mirrored)
                .environment(\.layoutDirection, .leftToRight)
        } else {
            content.multilineTextAlignment(logical)
        }
    }
}

private extension TextAlignment {
    var mirrored: TextAlignment {
        switch self {
        case .leading: .trailing
        case .trailing: .leading
        default: self
        }
    }
}

#endif
