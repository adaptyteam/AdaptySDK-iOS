//
//  ProfileIdentifierStorageMoke.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 18.11.2022
//

@testable import Adapty
import Foundation

final class ProfileIdentifierStorageMoke: ProfileIdentifierStorage {
    var profileId: String

    init() {
        profileId = Adapty.Configuration.existingProfileId
    }
}
