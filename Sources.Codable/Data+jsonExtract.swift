//
//  Data+JsonExtraxctor.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 08.04.2026.
//
import CSimdjson
import Foundation


public enum JsonExtractError: Error, Sendable, CustomStringConvertible {
    case parseError
    case pathNotFound(String)
    case serializationError
    case allocationError
    case unknown(Int32)

    init(code: SDJsonError, pointer: String = "") {
        switch code {
        case SDJSON_ERR_PARSE: self = .parseError
        case SDJSON_ERR_PATH_NOT_FOUND: self = .pathNotFound(pointer)
        case SDJSON_ERR_SERIALIZE: self = .serializationError
        case SDJSON_ERR_ALLOC: self = .allocationError
        default: self = .unknown(Int32(code.rawValue))
        }
    }

    public var description: String {
        switch self {
        case .parseError: "Failed to parse JSON"
        case let .pathNotFound(path): "Path not found: \(path)"
        case .serializationError: "Failed to serialize JSON fragment"
        case .allocationError: "Memory allocation failed"
        case let .unknown(code): "Unknown error (code: \(code))"
        }
    }
}

/// Fast extraction of JSON fragments from a large JSON
/// without full deserialization into memory.
///
/// Uses simdjson On-Demand parser — traverses the document
/// at 1+ GB/s, materializing only the requested fragments.
///
/// ```swift
/// let data = try Data(contentsOf: fallbackURL)
///
/// // Extract a placement — returns Data with a small JSON fragment
/// let placementData = try data.jsonExtract(pointer: "/placements/onboarding")
///
/// // Parse only this small piece with a regular JSONDecoder
/// let placement = try JSONDecoder().decode(Placement.self, from: placementData)
/// ```
public extension Data {
    /// Extracts a JSON fragment by JSON Pointer.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    /// - Returns: `Data` with the JSON fragment, ready for `JSONDecoder`
    /// - Throws: `JsonExtractorError`
    func jsonExtract(pointer: String) throws -> Data {
        try withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                throw JsonExtractError.parseError
            }

            let result = sdjson_extract(
                baseAddress.assumingMemoryBound(to: CChar.self),
                rawBuffer.count,
                pointer
            )

            if result.error != SDJSON_OK {
                throw JsonExtractError(code: result.error, pointer: pointer)
            }

            guard let fragmentPtr = result.data else {
                throw JsonExtractError.allocationError
            }

            // Copy into Data and free the C buffer
            let fragmentData = Data(bytes: fragmentPtr, count: result.length)
            sdjson_free(fragmentPtr)
            return fragmentData
        }
    }

    // MARK: - Batch extraction

    /// Extracts multiple JSON fragments in a single call.
    ///
    /// Each path is parsed with rewind, but padded_string is created only once.
    ///
    /// - Parameter pointers: Array of JSON Pointer strings
    /// - Returns: Dictionary `[pointer: Data]` of successful extractions
    /// - Throws: `JsonExtractorError` if at least one extraction fails
    func jsonExtractMany(pointers: [String]) throws -> [String: Data] {
        try withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                throw JsonExtractError.parseError
            }

            let count = pointers.count

            // Prepare C array of string pointers
//            var cPointers: [UnsafePointer<CChar>?] = []
            var cStrings: [ContiguousArray<CChar>] = []

            for p in pointers {
                let cStr = ContiguousArray(p.utf8CString)
                cStrings.append(cStr)
            }

            // Need to obtain stable pointers
            return try cStrings.withUnsafeBufferPointers { stablePtrs in
                var cPtrArray = stablePtrs.map(\.self)
                var results = [SDJsonResult](
                    repeating: SDJsonResult(data: nil, length: 0, error: SDJSON_OK),
                    count: count
                )

                cPtrArray.withUnsafeMutableBufferPointer { ptrBuf in
                    results.withUnsafeMutableBufferPointer { resBuf in
                        sdjson_extract_many(
                            baseAddress.assumingMemoryBound(to: CChar.self),
                            rawBuffer.count,
                            ptrBuf.baseAddress,
                            count,
                            resBuf.baseAddress
                        )
                    }
                }

                var dict = [String: Data](minimumCapacity: count)
                for (i, pointer) in pointers.enumerated() {
                    let r = results[i]
                    if r.error != SDJSON_OK {
                        // Free already allocated buffers
                        for j in (i + 1) ..< count {
                            if let ptr = results[j].data { sdjson_free(ptr) }
                        }
                        throw JsonExtractError(code: r.error, pointer: pointer)
                    }
                    if let ptr = r.data {
                        dict[pointer] = Data(bytes: ptr, count: r.length)
                        sdjson_free(ptr)
                    }
                }
                return dict
            }
        }
    }
}

// MARK: - Helper for withUnsafeBufferPointers

private extension [ContiguousArray<CChar>] {
    func withUnsafeBufferPointers<R>(
        _ body: ([UnsafePointer<CChar>?]) throws -> R
    ) rethrows -> R {
        // Recursively collect stable pointers
        var ptrs = [UnsafePointer<CChar>?](repeating: nil, count: count)
        return try withUnsafeBufferPointersImpl(index: 0, ptrs: &ptrs, body: body)
    }

    private func withUnsafeBufferPointersImpl<R>(
        index: Int,
        ptrs: inout [UnsafePointer<CChar>?],
        body: ([UnsafePointer<CChar>?]) throws -> R
    ) rethrows -> R {
        if index == count {
            return try body(ptrs)
        }
        return try self[index].withUnsafeBufferPointer { buf in
            ptrs[index] = buf.baseAddress
            return try withUnsafeBufferPointersImpl(
                index: index + 1,
                ptrs: &ptrs,
                body: body
            )
        }
    }
}

