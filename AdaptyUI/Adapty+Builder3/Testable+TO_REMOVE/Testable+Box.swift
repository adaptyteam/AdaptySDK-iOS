//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

@testable import Adapty

@available(iOS 15.0, *)
extension AdaptyUI.Box {
    static var testBasicDog: Self {
        .create(
            height: .fixed(.screen(0.5)),
            horizontalAlignment: .right,
            content: .image(.create(
                asset: .urlDog,
                aspect: .fill
            ), nil)
        )
    }

    static var testCircleDog: Self {
        .create(
            width: .fixed(.point(280)),
            height: .fixed(.point(280)),
            content: .image(.create(
                asset: .urlDog,
                aspect: .fill
            ), nil)
        )
    }
}

#endif
