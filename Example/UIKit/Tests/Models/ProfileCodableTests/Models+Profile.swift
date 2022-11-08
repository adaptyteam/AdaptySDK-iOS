//
//  Models+AdaptyProfile.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 20.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Models_Profile: XCTestCase {
    var backend: Backend!
    var session: HTTPSession!
    var decoder: JSONDecoder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        (backend, session) = Tester.createBackendAndSession(id: "test")
        decoder = session.configuration.decoder
    }
    
    func test_Profile_Empty() throws {
        let data = try Tester.jsonDataNamed("profile_empty")
        let result = try decoder.decode(AdaptyProfile.self, from: data)

        XCTAssertNil(result.customerUserId)
    }
    
    func test_Profile_Full() throws {
        let data = try Tester.jsonDataNamed("profile_full")
        let result = try decoder.decode(AdaptyProfile.self, from: data)

        XCTAssertNil(result.customerUserId)
    }
    
    func test_Profile_CustomAttributes() throws {
        let data = try Tester.jsonDataNamed("profile_custom_attributes")
        let result = try decoder.decode(AdaptyProfile.self, from: data)

        XCTAssertNil(result.customerUserId)
    }
}
