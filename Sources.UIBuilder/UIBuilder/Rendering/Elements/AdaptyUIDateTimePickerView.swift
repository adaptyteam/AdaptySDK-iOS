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
    @EnvironmentObject
    private var flowViewModel: AdaptyUIFlowViewModel

    private var picker: VC.DateTimePicker

    init(_ picker: VC.DateTimePicker) {
        self.picker = picker
    }

    private func dateBinding(in range: ClosedRange<Date>) -> Binding<Date> {
        let doubleBinding = stateViewModel.createBinding(
            picker.value,
            defaultValue: Date().timeIntervalSince1970 * 1000.0,
            screen: screen
        )
        return Binding(
            get: {
                let date = Date(timeIntervalSince1970: doubleBinding.wrappedValue / 1000.0).clampedToCalendarRange ?? Date()
                return Swift.min(Swift.max(date, range.lowerBound), range.upperBound)
            },
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

    private var flowStartedAt: Date {
        flowViewModel.flowStartedAt ?? Date()
    }

    private var dateRange: ClosedRange<Date> {
        let startAt = flowStartedAt
        let resolvedMin = picker.minDate?.asDate(startAt: startAt).clampedToCalendarRange ?? .distantPast
        let resolvedMax = picker.maxDate?.asDate(startAt: startAt).clampedToCalendarRange ?? .distantFuture
        guard resolvedMin <= resolvedMax else {
            Log.ui.warn("DateTimePicker: min (\(resolvedMin)) is later than max (\(resolvedMax)); clamping min to max")
            return resolvedMax ... resolvedMax
        }
        return resolvedMin ... resolvedMax
    }

    private var datePickerView: some View {
        let range = dateRange
        return DatePicker(
            "",
            selection: dateBinding(in: range),
            in: range,
            displayedComponents: displayedComponents
        )
        .labelsHidden()
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

private extension Date {
    /// `UICalendarView` aborts on a date outside `distantPast ... distantFuture`.
    var clampedToCalendarRange: Date? {
        guard timeIntervalSince1970.isFinite else { return nil }
        return Swift.min(Swift.max(self, .distantPast), .distantFuture)
    }
}

#endif
