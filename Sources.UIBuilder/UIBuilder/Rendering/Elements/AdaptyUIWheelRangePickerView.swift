//
//  AdaptyUIWheelRangePickerView.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 17.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIWheelRangePickerView: View {
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

    private var picker: VC.WheelRangePicker

    init(_ picker: VC.WheelRangePicker) {
        self.picker = picker
    }

    private var stepsCount: Int {
        guard picker.stepValue > 0, picker.maxValue >= picker.minValue else { return 0 }
        return Int(((picker.maxValue - picker.minValue) / picker.stepValue).rounded(.down)) + 1
    }

    private func value(at index: Int) -> Double {
        picker.minValue + Double(index) * picker.stepValue
    }

    private func formattedText(for value: Double) -> Text {
        let richText = picker.format.item(byValue: value)
        return richText.convertToSwiftUIText(
            defaultAttributes: picker.format.textAttributes,
            assetsCache: assetsViewModel.cache,
            stateViewModel: stateViewModel,
            tagValues: nil,
            internalTagResolver: { tag in
                tag == "VALUE" ? value : nil
            },
            customTagResolver: customTagResolverViewModel,
            productInfo: nil,
            colorScheme: colorScheme,
            screen: screen
        )
    }

    var body: some View {
        Picker(
            "",
            selection: stateViewModel.createBinding(
                picker.value,
                defaultValue: picker.minValue,
                screen: screen
            )
        ) {
            ForEach(0 ..< stepsCount, id: \.self) { index in
                let value = value(at: index)
                formattedText(for: value)
                    .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
    }
}

#endif
