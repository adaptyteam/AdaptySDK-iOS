//
//  AdaptyUISchema+Decodable.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 09.04.2026.
//

import Foundation

public extension AdaptyUISchema {
    init(from jsonData: Data) throws {
        self = try Self.decodeOnLargeStack {
            try JSONDecoder().decode(AdaptyUISchema.self, from: jsonData)
        }
    }

    init(from jsonData: String) throws {
        try self.init(from: jsonData.data(using: .utf8) ?? Data())
    }
}

extension AdaptyUISchema {
    private final class DecodeResultBox<T>: @unchecked Sendable {
        var value: Result<T, any Swift.Error>?
    }

    /// Runs the decoding closure on a thread with an 8 MB stack
    /// to avoid stack overflow from deeply nested UI element recursion.
    static func decodeOnLargeStack<T>(
        _ body: @escaping @Sendable () throws -> T
    ) throws -> T {
        if Thread.isMainThread {
            return try body()
        }

        let resultBox = DecodeResultBox<T>()
        let sema = DispatchSemaphore(value: 0)
        let thread = Thread {
            resultBox.value = Result { try body() }
            sema.signal()
        }
        thread.stackSize = 8 * 1024 * 1024
        thread.qualityOfService = Thread.current.qualityOfService
        thread.start()
        sema.wait()
        return try resultBox.value!.get()
    }
}
