//
//  TestBackendInstance.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 11.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

func HTTPAssertErrorBackendCodeEqual<T>(_ result: HTTPResponse<T>.Result, _ code: @autoclosure () -> Int) {
    switch result {
    case .success:
        XCTFail("There should be error!")
    case let .failure(error):
        HTTPAssertErrorBackendCodeEqual(error, code())
    }
}

func HTTPAssertErrorBackendCodeEqual(_ error: @autoclosure () -> HTTPError, _ code: @autoclosure () -> Int) {
    switch error() {
    case let .backend(_, _, statusCode, _):
        XCTAssertEqual(statusCode, code())
    default:
        XCTFail("Wrong error kind!")
    }
}
 
func HTTPAssertResponseSuccess<T>(_ result: HTTPResponse<T>.Result, _ code: @autoclosure () -> Int) {
    switch result {
    case .success:
        XCTAssertEqual(result.value?.statusCode, code())
    case let .failure(error):
        XCTFail(error.localizedDescription)
    }
}

func HTTPAssertResponseFailed<T>(_ result: HTTPResponse<T>.Result, _ code: @autoclosure () -> Int) {
    switch result {
    case .success:
        XCTFail("Wrong")
    case let .failure(error):
        HTTPAssertErrorBackendCodeEqual(error, code())
    }
}
