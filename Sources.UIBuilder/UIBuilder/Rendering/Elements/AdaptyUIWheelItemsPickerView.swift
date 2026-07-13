//
//  AdaptyUIWheelItemsPickerView.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 24.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIWheelItemsPickerView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var customTagResolverViewModel: AdaptyUITagResolverViewModel

    private var picker: VC.WheelItemsPicker

    init(_ picker: VC.WheelItemsPicker) {
        self.picker = picker
    }

    private var currentSelectedIndex: Int {
        guard let firstItem = picker.items.first else { return 0 }

        switch firstItem.value.wrapped {
        case is Bool:
            let current = stateViewModel.getValue(picker.value, defaultValue: false, screen: screen)
            return picker.items.firstIndex { ($0.value.wrapped as? Bool) == current } ?? 0
        case is String:
            let sentinel = "\u{0}__adapty_no_value__"
            let current = stateViewModel.getValue(picker.value, defaultValue: sentinel, screen: screen)
            return picker.items.firstIndex { ($0.value.wrapped as? String) == current } ?? 0
        default:
            let current = stateViewModel.getValue(picker.value, defaultValue: Double.nan, screen: screen)
            guard !current.isNaN else { return 0 }
            return picker.items.firstIndex { item in
                switch item.value.wrapped {
                case let v as Double: v == current
                case let v as Int: Double(v) == current
                case let v as UInt: Double(v) == current
                case let v as Int32: Double(v) == current
                case let v as UInt32: Double(v) == current
                default: false
                }
            } ?? 0
        }
    }

    private func itemText(for item: VC.WheelItemsPicker.Item) -> Text {
        guard let richText = stateViewModel.viewConfiguration.strings[item.stringId] else {
            return Text(item.stringId)
        }
        return richText.convertToSwiftUIText(
            defaultAttributes: nil,
            assetsCache: assetsViewModel.cache,
            stateViewModel: stateViewModel,
            tagValues: nil,
            internalTagResolver: { tag in
                tag == "VALUE" ? item.value.wrapped : nil
            },
            customTagResolver: customTagResolverViewModel,
            productInfo: nil,
            colorScheme: colorScheme,
            screen: screen
        )
    }

    private func writeSelectedValue(_ index: Int) {
        guard picker.items.indices.contains(index) else { return }
        do {
            try stateViewModel.stateHolder.state.setValue(
                variable: picker.value,
                value: picker.items[index].value,
                screenInstance: screen
            )
        } catch {
            Log.ui.error("WheelItemsPicker setValue error: \(error)")
        }
    }

    var body: some View {
        Picker(
            "",
            selection: Binding(
                get: { currentSelectedIndex },
                set: { newIndex in writeSelectedValue(newIndex) }
            )
        ) {
            ForEach(picker.items.indices, id: \.self) { index in
                itemText(for: picker.items[index])
                    .tag(index)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
    }
}

#endif
