//
//  Models+BackendProduct.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 21.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Models_BackendProduct: XCTestCase {
    func test_Product_Ok() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("product_ok")
        let result = try decoder.decode(BackendProduct.self, from: data)
        
        XCTAssertEqual(result.vendorId, "yearly.premium.6999")
    }
    
    func test_Product_No_Timestamp() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("product_no_timestamp")
        
        let exp = expectation(description: "Error expectation")
        do {
            let _ = try decoder.decode(BackendProduct.self, from: data)
        } catch {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
    
    func test_Product_No_Title() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("product_no_title")
        let result = try decoder.decode(BackendProduct.self, from: data)
        
        XCTAssertEqual(result.vendorId, "yearly.premium.6999")
    }
    
    func test_Product_No_Id() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("product_no_id")
        
        let exp = expectation(description: "Error expectation")
        do {
            let _ = try decoder.decode(BackendProduct.self, from: data)
        } catch {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
