//
//  AdaptyUIRiveOptions.swift
//  AdaptyUIBuilder
//
//  PoC: basic layout options for the `rive` element.
//  Deliberately not gated on UIKit: these are plain schema values, shared by the
//  element model (VC.Rive) and the addon context.
//
//  Note the contract is intentionally narrower than Lottie's: Rive has no runtime
//  speed API and loop is authored into the file, so neither is exposed here.
//

import Foundation

/// How the animation is fitted into the element's frame. Neutral SDK vocabulary;
/// the mapping to Rive's own `Fit` (contain/cover/fill) lives in the AdaptyRive target.
public enum AdaptyUIRiveFit: String, Sendable, Decodable {
    /// Scale to fit, preserving aspect ratio (no cropping).
    case fit
    /// Scale to fill, preserving aspect ratio (crops overflow).
    case fill
    /// Stretch to fill, ignoring aspect ratio.
    case stretch
}

/// A data-binding value injected into a Rive view-model property (`values` in the schema).
/// The JSON scalar type picks the case: `true`/`false` → bool, number → number, string → string.
/// The addon maps each to the matching Rive property (`NumberProperty`/`BoolProperty`/`StringProperty`).
public enum AdaptyUIRiveValue: Sendable, Equatable {
    case number(Double)
    case boolean(Bool)
    case string(String)
}

extension AdaptyUIRiveValue: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Bool before number: a JSON number must not be read as a bool, and `true`/`false`
        // must not fall through to number/string.
        if let bool = try? container.decode(Bool.self) {
            self = .boolean(bool)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "rive value must be a bool, number, or string"
            )
        }
    }
}
