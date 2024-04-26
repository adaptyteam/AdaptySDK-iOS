//
//  Style+TemplateBasic.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import Foundation

extension AdaptyUI.OldViewStyle {
    var backgroundImage: AdaptyUI.ImageData {
        get throws {
            guard let result = items["background_image"]?.asImage else {
                throw AdaptyUIError.componentNotFound("background_image")
            }
            return result
        }
    }

    var coverImage: AdaptyUI.ImageData {
        get throws {
            guard let result = items["cover_image"]?.asImage else {
                throw AdaptyUIError.componentNotFound("cover_image")
            }
            return result
        }
    }

    var contentShape: AdaptyUI.Decorator {
        get throws {
            guard let result = items["main_content_shape"]?.asShape else {
                throw AdaptyUIError.componentNotFound("main_content_shape")
            }
            return result
        }
    }

    var titleRows: AdaptyUI.RichText? {
        items["title_rows"]?.asText
    }

    var purchaseButton: AdaptyUI.OldButton {
        get throws {
            guard let result = items["purchase_button"]?.asButton else {
                throw AdaptyUIError.componentNotFound("purchase_button")
            }
            return result
        }
    }

    var closeButton: AdaptyUI.OldButton {
        get throws {
            guard let result = items["close_button"]?.asButton else {
                throw AdaptyUIError.componentNotFound("close_button")
            }
            return result
        }
    }
}
