//
//  Shape.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Shape {
        static let defaultType: ShapeType = .rectangle(cornerRadius: .none)

        public let background: Filling?
        public let border: Border?
        public let type: ShapeType
        
    }
}

extension AdaptyUI.Shape {
    public struct Border {
        public let filling: AdaptyUI.Filling
        public let thickness: Double
    }
}

extension AdaptyUI.Shape.Border {
    init?(filling: AdaptyUI.Filling?, thickness: Double?) {
        guard let filling else { return nil }
        self.init(filling: filling, thickness: thickness)
    }
}
