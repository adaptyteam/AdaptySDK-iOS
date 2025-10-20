//
//  WrongProfileIdError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.09.2025.
//

import Foundation

struct WrongProfileIdError: Error {
    let source: AdaptyError.Source
    init(
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.source = AdaptyError.Source(file: file, function: function, line: line)
    }
}

extension WrongProfileIdError: CustomStringConvertible {
    var description: String {
        "WrongProfileError(\(source))"
    }
}
