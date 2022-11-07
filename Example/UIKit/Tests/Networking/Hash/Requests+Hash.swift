//
//  Requests+Hash.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 28.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_Hash: XCTestCase {
    func test_FetchProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: "profile")
        let profileId = TestsConstants.existingProfileId
        
        var hash: String?
        
        let firstExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchProfileRequest(profileId: profileId, responseHash: nil) { result in
            switch result {
            case .success(let profile):
                hash = profile.hash
            case .failure:
                XCTFail("Didn't expect error")
            }
            
            firstExpectation.fulfill()
        }
        
        wait(for: [firstExpectation], timeout: TestsConstants.timeoutInterval)
        
        guard let hash = hash else {
            XCTFail("Didn't expect nil here")
            return
        }
        
        let secondExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchProfileRequest(profileId: profileId, responseHash: hash) { result in
            secondExpectation.fulfill()
            
            switch result {
            case .success(let profile):
                XCTAssertNil(profile.value)
            case .failure:
                XCTFail("Didn't expect error")
            }
        }
        
        wait(for: [secondExpectation], timeout: TestsConstants.timeoutInterval)
    }
    
    func test_FetchAllProductsIds() throws {
        let (_, session) = Tester.createBackendAndSession(id: "profile")
        let profileId = TestsConstants.existingProfileId
        
        var hash: String?
        
        let firstExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchAllProductVendorIdsRequest(profileId: profileId, responseHash: nil) { result in
            switch result {
            case .success(let idsVH):
                hash = idsVH.hash
            case .failure:
                XCTFail("Didn't expect error")
            }
            
            firstExpectation.fulfill()
        }
        

        wait(for: [firstExpectation], timeout: TestsConstants.timeoutInterval)
        
        guard let hash = hash else {
            XCTFail("Didn't expect nil here")
            return
        }
        
        let secondExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchAllProductVendorIdsRequest(profileId: profileId, responseHash: hash) { result in
            secondExpectation.fulfill()
            
            switch result {
            case .success(let idsVH):
                XCTAssertNil(idsVH.value)
            case .failure:
                XCTFail("Didn't expect error")
            }
        }
        
        wait(for: [secondExpectation], timeout: TestsConstants.timeoutInterval)
    }
    
    func test_FetchAllProducts() throws {
        let (_, session) = Tester.createBackendAndSession(id: "profile")
        let profileId = TestsConstants.existingProfileId
        
        var hash: String?
        
        let firstExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchAllProductsRequest(profileId: profileId, responseHash: nil, syncedBundleReceipt: true) { result in
            switch result {
            case .success(let product):
                hash = product.hash
            case .failure:
                XCTFail("Didn't expect error")
            }
            
            firstExpectation.fulfill()
        }
        

        wait(for: [firstExpectation], timeout: TestsConstants.timeoutInterval)
        
        guard let hash = hash else {
            XCTFail("Didn't expect nil here")
            return
        }
        
        let secondExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchAllProductsRequest(profileId: profileId, responseHash: hash, syncedBundleReceipt: true) { result in
            secondExpectation.fulfill()
            
            switch result {
            case .success(let productVH):
                XCTAssertNil(productVH.value)
            case .failure:
                XCTFail("Didn't expect error")
            }
        }
        
        wait(for: [secondExpectation], timeout: TestsConstants.timeoutInterval)
    }
    
    func test_FetchPawayll() throws {
        let (_, session) = Tester.createBackendAndSession(id: "profile")
        let profileId = TestsConstants.existingProfileId
        
        var hash: String?
        
        let firstExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchPaywallRequest(paywallId: "example_ab_test", profileId: profileId, responseHash: nil, syncedBundleReceipt: true) { result in
            switch result {
            case .success(let paywall):
                hash = paywall.hash
            case .failure:
                XCTFail("Didn't expect error")
            }
            
            firstExpectation.fulfill()
        }
        

        wait(for: [firstExpectation], timeout: TestsConstants.timeoutInterval)
        
        guard let hash = hash else {
            XCTFail("Didn't expect nil here")
            return
        }
        
        let secondExpectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        session.performFetchPaywallRequest(paywallId: "example_ab_test", profileId: profileId, responseHash: hash, syncedBundleReceipt: true) { result in
            secondExpectation.fulfill()
            
            switch result {
            case .success(let paywall):
                XCTAssertNil(paywall.value)
            case .failure:
                XCTFail("Didn't expect error")
            }
        }
        
        wait(for: [secondExpectation], timeout: TestsConstants.timeoutInterval)
    }
}
