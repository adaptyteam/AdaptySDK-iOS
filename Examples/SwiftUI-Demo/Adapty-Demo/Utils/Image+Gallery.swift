//
//  Image+Gallery.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
    enum Gallery {
        enum Name {
            static let thinking = "Adapty-Thinking-Face"
            static let sunglasses = "Adapty-Face-with-Sunglasses"
            static let diamond = "Adapty-Diamonds"
            static let duck = "Adapty-Duck"
        }
        static let thinking = Image(Name.thinking)
        static let sunglasses = Image(Name.sunglasses)
        static let diamond = Image(Name.diamond)
        static let duck = Image(Name.duck)
    }

    enum System {
        enum Name {
            static let locked = "lock.fill"
            static let unlocked = "lock.open.fill"
            static let close = "xmark"
            static let profile = "person.fill"
            static let profileLoggedOut = "person"
            static let login = "figure.wave.circle"
            static let logout = "figure.wave.circle.fill"
        }
        static let close = Image(systemName: Name.close)
        static let locked = Image(systemName: Name.locked)
        static let unlocked = Image(systemName: Name.unlocked)
        static let profile = Image(systemName: Name.profile)
        static let profileLoggedOut = Image(systemName: Name.profileLoggedOut)
        static let login = Image(systemName: Name.login)
        static let logout = Image(systemName: Name.logout)
    }
}
