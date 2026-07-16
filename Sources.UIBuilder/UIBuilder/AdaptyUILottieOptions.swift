//
//  AdaptyUILottieOptions.swift
//  AdaptyUIBuilder
//
//  PoC: basic playback / layout options for the `lottie` element.
//  Deliberately not gated on UIKit: these are plain schema values, shared by the
//  element model (VC.Lottie) and the addon context.
//

import Foundation

/// Playback loop mode for the `lottie` element.
public enum AdaptyUILottieLoop: String, Sendable, Decodable {
    /// Play once and stop on the last frame.
    case once
    /// Loop from the beginning until stopped.
    case loop
    /// Play forward, then backwards, repeatedly.
    case pingPong = "ping_pong"
}

/// How the animation is fitted into the element's frame.
public enum AdaptyUILottieFit: String, Sendable, Decodable {
    /// Scale to fit, preserving aspect ratio (no cropping).
    case fit
    /// Scale to fill, preserving aspect ratio (crops overflow).
    case fill
    /// Stretch to fill, ignoring aspect ratio.
    case stretch
}
