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

    @State private var selectedIndex: Int = 0

    init(_ picker: VC.WheelItemsPicker) {
        self.picker = picker
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
                get: { selectedIndex },
                set: { newIndex in
                    selectedIndex = newIndex
                    writeSelectedValue(newIndex)
                }
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
