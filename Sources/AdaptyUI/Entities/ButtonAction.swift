//
//  ButtonAction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public enum ButtonAction {
        case openUrl(String?)
        case restore
        case custom(String?)
        case close
    }
}
