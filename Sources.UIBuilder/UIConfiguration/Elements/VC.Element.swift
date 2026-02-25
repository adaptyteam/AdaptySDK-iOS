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
        indirect case text(Text, Properties?)
        indirect case textField(TextField, Properties?)
        indirect case slider(Slider, Properties?)
        indirect case image(Image, Properties?)
        indirect case video(VideoPlayer, Properties?)
        indirect case button(Button, Properties?)
        indirect case box(Box, Properties?)
        indirect case row(Row, Properties?)
        indirect case column(Column, Properties?)
        indirect case section(Section, Properties?)
        indirect case toggle(Toggle, Properties?)
        indirect case timer(Timer, Properties?)
        indirect case pager(Pager, Properties?)

        case screenHolder
        indirect case unknown(String, Properties?)
    }
}
