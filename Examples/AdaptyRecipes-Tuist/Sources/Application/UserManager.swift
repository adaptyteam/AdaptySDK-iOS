//
//  UserManager.swift
//  AdaptyRecipes-Tuist
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Foundation

class UserManager {
    private static let userIdKey = "app.user.id"

    static var currentUserId: String? {
        UserDefaults.standard.string(forKey: userIdKey)
    }

    static func login(to userId: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    static func logout() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}
