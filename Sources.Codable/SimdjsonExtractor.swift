//
//  SimdjsonExtractor.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 08.04.2026.
//


import Foundation
import CSimdjson

// MARK: - Ошибки

/// Ошибки извлечения JSON-фрагмента
public enum SimdjsonError: Error, Sendable, CustomStringConvertible {
    case parseError
    case pathNotFound(String)
    case serializationError
    case allocationError
    case unknown(Int32)

    init(code: SDJsonError, pointer: String = "") {
        switch code {
        case SDJSON_ERR_PARSE:          self = .parseError
        case SDJSON_ERR_PATH_NOT_FOUND: self = .pathNotFound(pointer)
        case SDJSON_ERR_SERIALIZE:      self = .serializationError
        case SDJSON_ERR_ALLOC:          self = .allocationError
        default:                        self = .unknown(Int32(code.rawValue))
        }
    }

    public var description: String {
        switch self {
        case .parseError:              return "Failed to parse JSON"
        case .pathNotFound(let path):  return "Path not found: \(path)"
        case .serializationError:      return "Failed to serialize JSON fragment"
        case .allocationError:         return "Memory allocation failed"
        case .unknown(let code):       return "Unknown error (code: \(code))"
        }
    }
}


// MARK: - Основной API

/// Быстрое извлечение JSON-фрагментов из большого JSON
/// без полной десериализации в память.
///
/// Использует simdjson On-Demand парсер — проходит по файлу
/// на скорости 1+ ГБ/с, материализует только запрошенные фрагменты.
///
/// ```swift
/// let data = try Data(contentsOf: fallbackURL)
/// let extractor = SimdjsonExtractor(data: data)
///
/// // Извлекаем placement — получаем Data с маленьким JSON-фрагментом
/// let placementData = try extractor.extract(pointer: "/placements/onboarding")
///
/// // Парсим только этот маленький кусок через обычный JSONDecoder
/// let placement = try JSONDecoder().decode(Placement.self, from: placementData)
/// ```
public final class SimdjsonExtractor: @unchecked Sendable {

    private let data: Data

    /// Создаёт экстрактор.
    /// - Parameter data: Полный JSON как `Data`. Хранится по ссылке (не копируется).
    public init(data: Data) {
        self.data = data
    }

    /// Создаёт экстрактор из файла.
    /// - Parameter url: URL файла с JSON.
    public convenience init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url, options: .mappedIfSafe) // mmap если возможно
        self.init(data: data)
    }

    // MARK: - Single extraction

    /// Извлекает JSON-фрагмент по JSON Pointer.
    ///
    /// - Parameter pointer: JSON Pointer (RFC 6901), напр. `"/placements/onboarding"`
    /// - Returns: `Data` с JSON-фрагментом, готовая для `JSONDecoder`
    /// - Throws: `SimdjsonError`
    public func extract(pointer: String) throws -> Data {
        try data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                throw SimdjsonError.parseError
            }

            let result = sdjson_extract(
                baseAddress.assumingMemoryBound(to: CChar.self),
                rawBuffer.count,
                pointer
            )

            if result.error != SDJSON_OK {
                throw SimdjsonError(code: result.error, pointer: pointer)
            }

            guard let fragmentPtr = result.data else {
                throw SimdjsonError.allocationError
            }

            // Копируем в Data и освобождаем C-буфер
            let fragmentData = Data(bytes: fragmentPtr, count: result.length)
            sdjson_free(fragmentPtr)
            return fragmentData
        }
    }

    // MARK: - Batch extraction

    /// Извлекает несколько JSON-фрагментов за один вызов.
    ///
    /// Каждый путь парсится с rewind, но padded_string создаётся один раз.
    ///
    /// - Parameter pointers: Массив JSON Pointer строк
    /// - Returns: Словарь `[pointer: Data]` для успешных извлечений
    /// - Throws: `SimdjsonError` если хотя бы одно извлечение провалилось
    public func extractMany(pointers: [String]) throws -> [String: Data] {
        try data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                throw SimdjsonError.parseError
            }

            let count = pointers.count

            // Подготавливаем C-массив указателей на строки
            var cPointers: [UnsafePointer<CChar>?] = []
            var cStrings: [ContiguousArray<CChar>] = []

            for p in pointers {
                var cStr = ContiguousArray(p.utf8CString)
                cStrings.append(cStr)
            }

            // Нужно получить стабильные указатели
            return try cStrings.withUnsafeBufferPointers { stablePtrs in
                var cPtrArray = stablePtrs.map { $0 }
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
                        // Освобождаем уже аллоцированные
                        for j in (i + 1)..<count {
                            if let ptr = results[j].data { sdjson_free(ptr) }
                        }
                        throw SimdjsonError(code: r.error, pointer: pointer)
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

    // MARK: - Typed extraction

    /// Извлекает и декодирует JSON-фрагмент в Swift-тип.
    ///
    /// ```swift
    /// let placement: Placement = try extractor.decode(
    ///     at: "/placements/onboarding",
    ///     as: Placement.self
    /// )
    /// ```
    public func decode<T: Decodable>(
        at pointer: String,
        as type: T.Type,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        let fragment = try extract(pointer: pointer)
        return try decoder.decode(type, from: fragment)
    }
}


// MARK: - Helper для withUnsafeBufferPointers

private extension Array where Element == ContiguousArray<CChar> {
    func withUnsafeBufferPointers<R>(
        _ body: ([UnsafePointer<CChar>?]) throws -> R
    ) rethrows -> R {
        // Рекурсивно собираем стабильные указатели
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
