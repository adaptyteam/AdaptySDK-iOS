//
//  Data+Curl.swift
//  SwiftyCURL
//
//  Created by Zakk Hoyt on 4/22/18.
//  Copyright © 2018 Zakk Hoyt. All rights reserved.
//

import Foundation

extension Data {
    func curlRepresentation(response: URLResponse?) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
                return json.description
            }
        } catch {
            return "Error printing payload: " + error.localizedDescription
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: self, options: []) as? NSArray {
                return json.description
            }
        } catch {
            return "Error printing payload: " + error.localizedDescription
        }

        if let str = String(data: self, encoding: .utf8) {
            return str
        }

//        // TODO: What happens when we get here?
//        // Payload is neither dictionary nor array
//        // User could expect Int, UInt, Double, Bool, etc..
//        // Casting from data doesn't have a way to measure success
//        let value = self.withUnsafeBytes { (ptr: UnsafePointer<Int>) -> Int in
//            return ptr.pointee
//        }
//        return "\(value)"

        var output = """
        Unable to represent payload with text.
        Received payload of \(count) bytes.
        """
        if let response {
            output += "\nExpected payload of \(response.expectedContentLength) bytes."
            if let mimeType = response.mimeType {
                output += "\nMIME Type: \(mimeType)."
            }
            if let textEncodingName = response.textEncodingName {
                output += "\nText Encoding: \(textEncodingName)."
            }
            if let suggestedFilename = response.suggestedFilename {
                output += "\nSuggested File Name: \(suggestedFilename)."
            }
        }
        return output
    }
}
