//
//  VC.Element.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    enum Element: Sendable, Hashable {
        case space(Int)
        indirect case stack(Stack, Properties?)
        case text(Text, Properties?)
        case textField(TextField, Properties?)
        case slider(Slider, Properties?)
        case image(Image, Properties?)
        case video(VideoPlayer, Properties?)
        indirect case button(Button, Properties?)
        indirect case box(Box, Properties?)
        indirect case row(Row, Properties?)
        indirect case column(Column, Properties?)
        indirect case section(Section, Properties?)
        case toggle(Toggle, Properties?)
        case timer(Timer, Properties?)
        indirect case pager(Pager, Properties?)

        case unknown(String, Properties?)
    }
}
