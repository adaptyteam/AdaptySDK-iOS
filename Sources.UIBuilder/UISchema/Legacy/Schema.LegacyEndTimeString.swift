//
//  Schema.LegacyEndTimeString.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.03.2026.
//

import Foundation

private extension Schema {
    struct LegacyEndTimeString: RawRepresentable, Codable {
        let rawValue: String
        let components: DateComponents

        func date(in timeZone: TimeZone?) -> Date? {
            guard let timeZone else { return nil }
            var components = components
            components.timeZone = timeZone
            return components.date
        }

        init?(rawValue: String) {
            let array: [Int]

            do {
                let arrayString = rawValue.components(separatedBy: CharacterSet(charactersIn: " -:.,;/\\"))

                array = try arrayString.map {
                    guard let value = Int($0) else { throw NSError() }
                    return value
                }

            } catch {
                return nil
            }

            guard array.count >= 6 else { return nil }

            self.rawValue = rawValue
            components = DateComponents(
                calendar: Calendar(identifier: .gregorian),
                year: array[0],
                month: array[1],
                day: array[2],
                hour: array[3],
                minute: array[4],
                second: array[5]
            )
        }
    }
}

extension KeyedDecodingContainer {
    func decodeLegacyEndTimeString(forKey key: Key, in timeZone: TimeZone?) throws -> Date {
        let dt = try decode(Schema.LegacyEndTimeString.self, forKey: key)
        guard let date = dt.date(in: timeZone) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "wrong date '\(dt.rawValue)'")
        }
        return date
    }
}

