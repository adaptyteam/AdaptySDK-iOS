//
//  Text+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension AdaptyUI.RichText.TextAttributes {
    var uiFont: UIFont { font.uiFont(size: size) }
    var uiColor: UIColor? { color.asColor?.uiColor }
    var backgroundUIColor: UIColor? { background?.asColor?.uiColor }
}
