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
    enum JsonValueInfo: Sendable, Equatable {
        case object(keys: [String])
        case array(count: Int)
        case string
        case number
        case bool
        case null
    }

    struct JsonPropertyRange: Sendable, Equatable {
        public let key: Range<Int>?
        public let value: Range<Int>

        public func key(from str: String) -> String? {
            guard let key else { return nil }
            return substring(from: str, range: key)
        }

        public func value(from str: String) -> String? {
            substring(from: str, range: value)
        }

        private func substring(from str: String, range: Range<Int>) -> String? {
            let vStart = str.utf8.index(str.startIndex, offsetBy: range.lowerBound)
            let vEnd = str.utf8.index(str.startIndex, offsetBy: range.upperBound)
            return String(str.utf8[vStart ..< vEnd])
        }
    }

    /// Extracts a JSON fragment at the given path.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    ///
    /// Returns raw `Data` suitable for `JSONDecoder`. For `null` values
    /// the result is the four-byte literal `null`.
    func jsonExtract(pointer: String) throws(JsonExtractError) -> Data {
        try withJsonBytes { base, length throws(JsonExtractError) in
            let result = sdjson_extract(base, length, pointer)

            if result.error != SDJSON_OK {
                throw JsonExtractError(code: result.error, path: pointer)
            }

            guard let fragmentPtr = result.data else {
                throw JsonExtractError.allocationMemoryError
            }

            let fragmentData = Data(bytes: fragmentPtr, count: result.length)
            sdjson_free(fragmentPtr)
            return fragmentData
        }
    }

    /// Extracts a JSON fragment, returning `nil` when the path does not exist.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    ///
    /// A JSON `null` value is returned as `Data("null")`, not `nil`.
    @inlinable
    func jsonExtractIfPresent(pointer: String) throws(JsonExtractError) -> Data? {
        do {
            return try jsonExtract(pointer: pointer)
        } catch .pathNotFound {
            return nil
        }
    }

    /// Extracts a JSON fragment, returning `nil` when the path does not exist
    /// **or** the value is JSON `null`.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    func jsonExtractIfExist(pointer: String) throws(JsonExtractError) -> Data? {
        do {
            let value = try jsonExtract(pointer: pointer)
            return value == null ? nil : value
        } catch .pathNotFound {
            return nil
        }
    }

    /// Returns `true` if the path exists in the JSON, even if the value is `null`.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    func jsonContains(pointer: String) throws(JsonExtractError) -> Bool {
        try withJsonBytes { base, length throws(JsonExtractError) in
            var outError = SDJSON_OK
            let found = sdjson_exists(base, length, pointer, &outError)

            if outError != SDJSON_OK {
                throw JsonExtractError(code: outError, path: pointer)
            }

            return found
        }
    }

    /// Returns `true` if the path exists **and** its value is not JSON `null`.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    @inlinable
    func jsonExist(pointer: String) throws(JsonExtractError) -> Bool {
        do {
            let value = try jsonFastInspect(pointer: pointer)
            return value == .null ? false : true
        } catch .pathNotFound {
            return false
        }
    }

    /// Returns the JSON type at the given path without extra work.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    ///
    /// For objects and arrays, `keys` / `count` are not populated
    /// (always empty list / zero). Use ``jsonInspect(pointer:)`` when you
    /// need that detail.
    func jsonFastInspect(pointer: String) throws(JsonExtractError) -> JsonValueInfo {
        try withJsonBytes { base, length throws(JsonExtractError) in
            let result = sdjson_type(base, length, pointer)

            if result.error != SDJSON_OK {
                throw JsonExtractError(code: result.error, path: pointer)
            }

            return switch result.type {
            case SDJSON_TYPE_OBJECT: .object(keys: [])
            case SDJSON_TYPE_ARRAY: .array(count: 0)
            case SDJSON_TYPE_STRING: .string
            case SDJSON_TYPE_NUMBER: .number
            case SDJSON_TYPE_BOOL: .bool
            case SDJSON_TYPE_NULL: .null
            default: .null
            }
        }
    }

    /// Returns the JSON type at the given path together with structural detail:
    /// object key names for objects, element count for arrays.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    func jsonInspect(pointer: String) throws(JsonExtractError) -> JsonValueInfo {
        try withJsonBytes { base, length throws(JsonExtractError) in
            let result = sdjson_inspect(base, length, pointer)

            if result.error != SDJSON_OK {
                if let keysPtr = result.keys { sdjson_free(keysPtr) }
                throw JsonExtractError(code: result.error, path: pointer)
            }

            defer {
                if let keysPtr = result.keys { sdjson_free(keysPtr) }
            }

            switch result.type {
            case SDJSON_TYPE_OBJECT:
                var keys: [String] = []
                if let keysPtr = result.keys, result.keys_length > 0 {
                    keys = parseNullSeparatedKeys(keysPtr, length: result.keys_length)
                }
                return .object(keys: keys)
            case SDJSON_TYPE_ARRAY:
                return .array(count: result.count)
            case SDJSON_TYPE_STRING: return .string
            case SDJSON_TYPE_NUMBER: return .number
            case SDJSON_TYPE_BOOL: return .bool
            case SDJSON_TYPE_NULL: return .null
            default: return .null
            }
        }
    }

    // MARK: - Range

    /// Returns UTF-8 byte ranges of the key name and the value in the
    /// original JSON buffer.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), e.g. `"/placements/onboarding"`
    ///
    /// `key` points to the property name **without** surrounding quotes.
    /// For array elements `key` is `nil`.
    func jsonExtractRange(pointer: String) throws(JsonExtractError) -> JsonPropertyRange {
        try withJsonBytes { base, length throws(JsonExtractError) in
            let result = sdjson_range(base, length, pointer)

            if result.error != SDJSON_OK {
                throw JsonExtractError(code: result.error, path: pointer)
            }

            let keyRange: Range<Int>?
            if result.key_offset >= 0 {
                let start = Int(result.key_offset)
                keyRange = start ..< (start + Int(result.key_length))
            } else {
                keyRange = nil
            }

            let valueStart = Int(result.value_offset)
            let valueRange = valueStart ..< (valueStart + Int(result.value_length))

            return JsonPropertyRange(key: keyRange, value: valueRange)
        }
    }

    // MARK: - Batch extraction

    /// Extracts multiple JSON fragments in a single call.
    ///
    /// - Parameter pointers: Array of JSON Pointer (RFC 6901) strings
    ///
    /// The padded buffer is allocated once and reused for every pointer,
    /// making this faster than calling ``jsonExtract(pointer:)`` in a loop.
    func jsonExtractMany(pointers: [String]) throws(JsonExtractError) -> [String: Data] {
        try withJsonBytes { base, length throws(JsonExtractError) in
            let count = pointers.count

            let cStrings: [ContiguousArray<CChar>] = pointers.map {
                ContiguousArray($0.utf8CString)
            }

            return try cStrings.withUnsafeBufferPointers { stablePtrs throws(JsonExtractError) in
                var cPtrArray = stablePtrs.map(\.self)
                var results = [SDJsonResult](
                    repeating: SDJsonResult(data: nil, length: 0, error: SDJSON_OK),
                    count: count
                )

                cPtrArray.withUnsafeMutableBufferPointer { ptrBuf in
                    results.withUnsafeMutableBufferPointer { resBuf in
                        sdjson_extract_many(
                            base,
                            length,
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
                        for j in (i + 1) ..< count {
                            if let ptr = results[j].data { sdjson_free(ptr) }
                        }
                        throw JsonExtractError(code: r.error, path: pointer)
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

    private func withJsonBytes<R>(
        _ body: (UnsafePointer<CChar>, Int) throws(JsonExtractError) -> R
    ) throws(JsonExtractError) -> R {
        guard !isEmpty else { throw JsonExtractError.dataIsEmpty }
        let extractionResult: Result<R, JsonExtractError> = withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else {
                return .failure(.dataIsEmpty)
            }
            do throws(JsonExtractError) {
                let r = try body(base.assumingMemoryBound(to: CChar.self), rawBuffer.count)
                return .success(r)
            } catch {
                return .failure(error)
            }
        }
        return try extractionResult.get()
    }
}

// MARK: - Private helpers

private let null = "null".data(using: .utf8)!

private func parseNullSeparatedKeys(
    _ ptr: UnsafePointer<CChar>,
    length: Int
) -> [String] {
    var keys: [String] = []
    var offset = 0

    while offset < length {
        let str = String(cString: ptr.advanced(by: offset))
        keys.append(str)
        offset += str.utf8.count + 1 // +1 для \0
    }

    return keys
}

// MARK: - Helper for withUnsafeBufferPointers

private extension [ContiguousArray<CChar>] {
    func withUnsafeBufferPointers<R, E: Error>(
        _ body: ([UnsafePointer<CChar>?]) throws(E) -> R
    ) throws(E) -> R {
        // Recursively collect stable pointers
        var ptrs = [UnsafePointer<CChar>?](repeating: nil, count: count)
        return try withUnsafeBufferPointersImpl(index: 0, ptrs: &ptrs, body: body)
    }

    private func withUnsafeBufferPointersImpl<R, E: Error>(
        index: Int,
        ptrs: inout [UnsafePointer<CChar>?],
        body: ([UnsafePointer<CChar>?]) throws(E) -> R
    ) throws(E) -> R {
        if index == count {
            return try body(ptrs)
        }
        return try self[index].withUnsafeBufferPointer { buf throws(E) in
            ptrs[index] = buf.baseAddress
            return try withUnsafeBufferPointersImpl(
                index: index + 1,
                ptrs: &ptrs,
                body: body
            )
        }
    }
}

