//
//  AdaptyUIDateTimePickerView.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 17.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIDateTimePickerView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel

    private var picker: VC.DateTimePicker

    init(_ picker: VC.DateTimePicker) {
        self.picker = picker
    }

    private var dateBinding: Binding<Date> {
        let doubleBinding = stateViewModel.createBinding(
            picker.value,
            defaultValue: Date().timeIntervalSince1970 * 1000.0,
            screen: screen
        )
        return Binding(
            get: { Date(timeIntervalSince1970: doubleBinding.wrappedValue / 1000.0) },
            set: { doubleBinding.wrappedValue = $0.timeIntervalSince1970 * 1000.0 }
        )
    }

    private var displayedComponents: DatePickerComponents {
        var components: DatePickerComponents = []
        if picker.components.contains(.date) {
            components.insert(.date)
        }
        if picker.components.contains(.hourAndMinute) {
            components.insert(.hourAndMinute)
        }
        if components.isEmpty {
            return [.date, .hourAndMinute]
        }
        return components
    }

    @ViewBuilder
    private var datePickerView: some View {
        if let minDate = picker.minDate, let maxDate = picker.maxDate {
            DatePicker(
                "",
                selection: dateBinding,
                in: minDate ... maxDate,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
        } else if let minDate = picker.minDate {
            DatePicker(
                "",
                selection: dateBinding,
                in: minDate...,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
        } else if let maxDate = picker.maxDate {
            DatePicker(
                "",
                selection: dateBinding,
                in: ...maxDate,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
        } else {
            DatePicker(
                "",
                selection: dateBinding,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var styledDatePickerView: some View {
        switch picker.kind {
        case .compact:
            datePickerView.datePickerStyle(.compact)
        case .wheel:
            datePickerView.datePickerStyle(.wheel)
        case .graphical:
            datePickerView.datePickerStyle(.graphical)
        }
    }

    var body: some View {
        styledDatePickerView
            .tint(
                assetsViewModel.resolvedAsset(
                    picker.color,
                    mode: colorScheme.toVCMode,
                    screen: screen
                ).asColorAsset
            )
    }
}

#endif
