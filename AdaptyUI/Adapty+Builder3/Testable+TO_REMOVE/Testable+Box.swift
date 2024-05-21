//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

@testable import Adapty

@available(iOS 13.0, *)
extension AdaptyUI.Box {
    static var testBasicDog: Self {
        .init(
            //            width: .fixed(.screen(0.8)),
            width: nil,
            height: .fixed(.screen(0.5)),
            horizontalAlignment: .right,
            verticalAlignment: .center,
            content: .image(.init(asset: .urlDog,
                                  aspect: .fill,
                                  tint: nil), nil)
        )
    }
}

#endif
