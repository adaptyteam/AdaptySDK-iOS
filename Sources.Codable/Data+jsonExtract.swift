//
//  Data+JsonExtraxctor.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 08.04.2026.
//
import CSimdjson
import Foundation

public enum JsonExtractError: Error, Sendable, CustomStringConvertible {
    case dataIsEmpty
    case pathNotFound(path: String)
    case serializationError(path: String)
    case allocationMemoryError
    case unknown(Int32, path: String)

    init(code: SDJsonError, path: String) {
        switch code {
        case SDJSON_ERR_PARSE: self = .dataIsEmpty
        case SDJSON_ERR_PATH_NOT_FOUND: self = .pathNotFound(path: path)
        case SDJSON_ERR_SERIALIZE: self = .serializationError(path: path)
        case SDJSON_ERR_ALLOC: self = .allocationMemoryError
        default: self = .unknown(Int32(code.rawValue), path: path)
        }
    }

    public var description: String {
        switch self {
        case .dataIsEmpty: "Failed to parse JSON, data is empty"
        case let .pathNotFound(path): "Path not found: \(path)"
        case let .serializationError(path): "Failed to serialize JSON fragment: \(path)"
        case .allocationMemoryError: "Memory allocation failed"
        case let .unknown(code, path): "Unknown error (code: \(code)) for: \(path)"
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
    func jsonExtract(pointer: String) throws(JsonExtractError) -> Data {
        let extractionResult: Result<Data, JsonExtractError> =
            withUnsafeBytes { rawBuffer in
                guard let baseAddress = rawBuffer.baseAddress else {
                    return .failure(.dataIsEmpty)
                }

                let result = sdjson_extract(
                    baseAddress.assumingMemoryBound(to: CChar.self),
                    rawBuffer.count,
                    pointer
                )

                if result.error != SDJSON_OK {
                    return .failure(JsonExtractError(code: result.error, path: pointer))
                }

                guard let fragmentPtr = result.data else {
                    return .failure(.allocationMemoryError)
                }

                // Copy into Data and free the C buffer
                let fragmentData = Data(bytes: fragmentPtr, count: result.length)
                sdjson_free(fragmentPtr)
                return .success(fragmentData)
            }
        return try extractionResult.get()
    }

    func jsonExtractIfPresent(pointer: String) throws(JsonExtractError) -> Data? {
        do {
            return try jsonExtract(pointer: pointer)
        } catch .pathNotFound {
            return nil
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
    func jsonExtractMany(pointers: [String]) throws(JsonExtractError) -> [String: Data] {
        let extractionResult: Result<[String: Data], JsonExtractError> =
            withUnsafeBytes { rawBuffer in
                guard let baseAddress = rawBuffer.baseAddress else {
                    return .failure(.dataIsEmpty)
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
                return cStrings.withUnsafeBufferPointers { stablePtrs in
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
                            return .failure(JsonExtractError(code: r.error, path: pointer))
                        }
                        if let ptr = r.data {
                            dict[pointer] = Data(bytes: ptr, count: r.length)
                            sdjson_free(ptr)
                        }
                    }
                    return .success(dict)
                }
            }
        return try extractionResult.get()
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

