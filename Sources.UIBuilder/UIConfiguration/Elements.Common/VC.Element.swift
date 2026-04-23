//
//  VC.Element.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension VC {
    enum Element: Sendable, Hashable {
        indirect case stack(Stack, Properties?)
        indirect case text(Text, Properties?)
        indirect case textField(TextField, Properties?)
        indirect case slider(Slider, Properties?)
        indirect case image(Image, Properties?)
        indirect case video(VideoPlayer, Properties?)
        indirect case button(Button, Properties?)
        indirect case box(Box, Properties?)
        indirect case row(Row, Properties?)
        indirect case column(Column, Properties?)
        indirect case legacyRow(LegacyRow, Properties?)
        indirect case legacyColumn(LegacyColumn, Properties?)
        indirect case section(Section, Properties?)
        indirect case toggle(Toggle, Properties?)
        indirect case timer(Timer, Properties?)
        indirect case pager(Pager, Properties?)
        indirect case dateTimePicker(DateTimePicker, Properties?)
        indirect case wheelItemsPicker(WheelItemsPicker, Properties?)
        indirect case wheelRangePicker(WheelRangePicker, Properties?)
        indirect case linearProgress(LinearProgress, Properties?)
        indirect case radialProgress(RadialProgress, Properties?)
        indirect case textProgress(TextProgress, Properties?)

        case screenHolder
        indirect case unknown(String)
    }
}

extension VC.Element {
    var properties: VC.Element.Properties? {
        switch self {
        case .screenHolder, .unknown:
            nil
        case let .box(_, properties),
             let .stack(_, properties),
             let .text(_, properties),
             let .image(_, properties),
             let .textField(_, properties),
             let .button(_, properties),
             let .row(_, properties),
             let .column(_, properties),
             let .legacyRow(_, properties),
             let .legacyColumn(_, properties),
             let .section(_, properties),
             let .toggle(_, properties),
             let .timer(_, properties),
             let .slider(_, properties),
             let .pager(_, properties),
             let .video(_, properties),
             let .dateTimePicker(_, properties),
             let .wheelItemsPicker(_, properties),
             let .wheelRangePicker(_, properties),
             let .linearProgress(_, properties),
             let .radialProgress(_, properties),
             let .textProgress(_, properties)
             :
            properties
        }
    }
}

