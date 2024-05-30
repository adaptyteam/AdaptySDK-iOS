//
//  Pager.swift
//
//
//  Created by Aleksei Valiano on 30.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Pager {}
}

#if DEBUG
    package extension AdaptyUI.Pager {
        static func create(
        ) -> Self {
            .init(
            )
        }
    }
#endif
