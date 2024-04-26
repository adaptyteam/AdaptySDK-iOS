//
//  Style+TemplateFlat.swift
//  
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import Foundation

extension AdaptyUI.OldViewStyle {
    var background: AdaptyUI.Filling {
        get throws {
            guard let result = items["background"]?.asFilling else {
                throw AdaptyUIError.componentNotFound("background")
            }
            return result
        }
    }

    var coverImageShape: AdaptyUI.Decorator {
        get throws {
            guard let result = items["cover_image"]?.asShape else {
                throw AdaptyUIError.componentNotFound("cover_image")
            }
            return result
        }
    }
}
