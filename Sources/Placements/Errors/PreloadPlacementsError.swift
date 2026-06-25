//
//  PreloadPlacementsError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.06.2026.
//
import Foundation

struct PreloadPlacementsError: Error {
    let source: AdaptyError.Source
    let originalErrors: [String: AdaptyError]

    init(
        _ errors: [String: AdaptyError?],
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        source = .init(file: file, function: function, line: line)
        originalErrors = errors.compactMapValues { $0 }
    }
}

extension PreloadPlacementsError: CustomAdaptyError {
    static let errorDomain = AdaptyError.AdaptyErrorDomain

    var originalError: (any Error)? {
        nil
    }

    var adaptyErrorCode: AdaptyError.ErrorCode {
        .networkFailed
    }

    var description: String {
        "AdaptyError.preloadPlacementsFailed(\(source), \(originalErrors))"
    }

    var debugDescription: String {
        "Failed to preload \(originalErrors.count) placement(s): \(originalErrors)"
    }
}

public extension AdaptyError {
    var preloadErrors: [String: AdaptyError]? {
        (wrapped as? PreloadPlacementsError)?.originalErrors
    }
}
