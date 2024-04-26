//
//  Text+CustomTag.swift
//
//
//  Created by Alexey Goncharov on 1.12.23..
//

import Adapty
import Foundation

extension AdaptyUI {
    typealias CustomTagConverter = (String) -> String?
}

extension String {
    private static let customTagPattern = "</[a-zA-Z_0-9-]+/>"

    private func removingCustomTagBrackets() -> Self {
        replacingOccurrences(of: "</", with: "")
            .replacingOccurrences(of: "/>", with: "")
    }

    func replaceCustomTags(converter: AdaptyUI.CustomTagConverter?, fallback: String?) -> String {
        guard let regex = try? NSRegularExpression(pattern: Self.customTagPattern) else {
            return self
        }

        let range = NSRange(startIndex ..< endIndex, in: self)
        let allTagsMatches = regex.matches(in: self, range: range)

        var replacementMap = [String: String?]()
        var unknownReplacementsCount = 0

        for match in allTagsMatches {
            guard let matchRange = Range(match.range, in: self) else { continue }

            let matchTag = String(self[matchRange])
            let matchTagContent = matchTag.removingCustomTagBrackets()
            let replacement = converter?(matchTagContent)

            replacementMap[matchTag] = replacement

            if AdaptyUI.ProductTag.fromRawMatch(matchTagContent) == nil, replacement == nil {
                unknownReplacementsCount += 1
            }
        }

        if unknownReplacementsCount > 0, let fallback = fallback {
            return fallback
        }

        var result = self

        for (tag, replacement) in replacementMap {
            if let replacement = replacement {
                result = result.replacingOccurrences(of: tag, with: replacement)
            }
        }

        return result
    }
}
