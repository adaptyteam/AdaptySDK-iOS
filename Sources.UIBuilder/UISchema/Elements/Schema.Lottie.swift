//
//  Schema.Lottie.swift
//  AdaptyUIBuilder
//
//  Proof of concept: schema for the Lottie animation element.
//

import Foundation

extension Schema {
    typealias Lottie = VC.Lottie
}

extension Schema.Lottie: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        .lottie(self, properties)
    }
}

extension Schema.Lottie: Decodable {
    enum CodingKeys: String, CodingKey {
        case animationId = "animation_id"
        case texts
        case colors
        case loop
        case speed
        case autoplay
        case fit
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            animationId: container.decode(String.self, forKey: .animationId),
            texts: container.decodeIfPresent([String: String].self, forKey: .texts) ?? [:],
            colors: container.decodeIfPresent([String: String].self, forKey: .colors) ?? [:],
            loop: container.decodeIfPresent(AdaptyUILottieLoop.self, forKey: .loop) ?? .loop,
            speed: container.decodeIfPresent(Double.self, forKey: .speed) ?? 1.0,
            autoplay: container.decodeIfPresent(Bool.self, forKey: .autoplay) ?? true,
            fit: container.decodeIfPresent(AdaptyUILottieFit.self, forKey: .fit) ?? .fit
        )
    }
}
