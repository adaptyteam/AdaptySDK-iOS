//
//  XCTestCase+getDataFromResource.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 21.11.2022
//

import XCTest

extension XCTestCase {
    enum TestError: Error {
        case resourceNotFound
    }

    func getData(fromResource fileName: String, withExtension ext: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: ext) else {
            XCTFail("Missing File: \(fileName).\(ext)")
            throw TestError.resourceNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            throw error
        }
    }

    func getData(fromJSON fileName: String) throws -> Data {
        try getData(fromResource: fileName, withExtension: "json")
    }
}
