//
//  AdaptyUIDecoratorModifier.swift
//
//
//  Created by Aleksey Goncharov on 24.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
extension InsettableShape {
    @ViewBuilder
    func fillImage(
        _ image: AdaptyUIResolvedImageAsset,
        tint: AdaptyUIResolvedColorAsset?
    ) -> some View {
        // Fill the shape with .clear so an unfilled Shape does not render
        // on top of the image with the foreground color.
        self.fill(.clear).background {
            AdaptyUIImageView(
                .resolvedImageAsset(
                    asset: image,
                    aspect: .fill,
                    tint: tint
                )
            )
        }
    }

    @ViewBuilder
    func fill(
        asset: AdaptyUIResolvedColorOrGradientOrImageAsset?
    ) -> some View {
        switch asset {
        case let .color(color):
            self.fillSolidColor(color)
        case let .colorGradient(colorGradient):
            self.fillColorGradient(colorGradient)
        case let .image(imageData):
            self.fillImage(imageData, tint: nil)
        case .none:
            self.fillSolidColor(.emptyAssetColor)
        }
    }

    @ViewBuilder
    func fillSolidColor(
        _ color: AdaptyUIResolvedColorAsset
    ) -> some View {
        self.fill(color)
    }

    @ViewBuilder
    func fillColorGradient(
        _ gradient: AdaptyUIResolvedGradientAsset
    ) -> some View {
        switch gradient {
        case let .linear(gradient):
            self.fill(gradient)
        case let .angular(gradient):
            self.fill(gradient)
        case let .radial(gradient):
            self.fill(gradient)
        }
    }
}

extension AdaptyUIResolvedGradientAsset {
    var shapeStyle: AnyShapeStyle {
        switch self {
        case let .linear(gradient): AnyShapeStyle(gradient)
        case let .angular(gradient): AnyShapeStyle(gradient)
        case let .radial(gradient): AnyShapeStyle(gradient)
        }
    }
}

extension AdaptyUIResolvedColorOrGradientAsset {
    var shapeStyle: AnyShapeStyle {
        switch self {
        case let .color(color): AnyShapeStyle(color)
        case let .colorGradient(gradient): gradient.shapeStyle
        }
    }
}

extension VC.BlendMode {
    var swiftUIBlendMode: SwiftUI.BlendMode {
        switch self {
        case .normal: .normal
        case .multiply: .multiply
        case .screen: .screen
        case .overlay: .overlay
        case .darken: .darken
        case .lighten: .lighten
        case .colorDodge: .colorDodge
        case .colorBurn: .colorBurn
        case .hardLight: .hardLight
        case .difference: .difference
        case .exclusion: .exclusion
        case .hue: .hue
        case .saturation: .saturation
        case .color: .color
        case .luminosity: .luminosity
        case .sourceAtop: .sourceAtop
        case .destinationOver: .destinationOver
        case .destinationOut: .destinationOut
        // ponytail: SwiftUI has no destinationIn; draw it normally until a
        // design needs it, then render the layer as a mask.
        case .destinationIn: .normal
        case .plusLighter: .plusLighter
        }
    }
}

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func clipShape(_ shape: VC.ShapeType) -> some View {
        switch shape {
        case let .rectangle(radii):
            self.clipShape(UnevenRoundedRectangle(cornerRadii: radii.systemRadii))
        case .circle:
            self.clipShape(Circle())
        case .curveUp:
            self.clipShape(CurveUpShape())
        case .curveDown:
            self.clipShape(CurveDownShape())
        }
    }
}

@MainActor
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
extension VC.ShapeType {
    @ViewBuilder
    func swiftUIShapeFill(_ style: AnyShapeStyle) -> some View {
        switch self {
        case let .rectangle(radii):
            UnevenRoundedRectangle(cornerRadii: radii.systemRadii).fill(style)
        case .circle:
            Circle().fill(style)
        case .curveUp:
            CurveUpShape().fill(style)
        case .curveDown:
            CurveDownShape().fill(style)
        }
    }

    /// Callers clip the result to the shape: the curves stroke on the path's center.
    @ViewBuilder
    func swiftUIShapeStroke(_ style: AnyShapeStyle, lineWidth: CGFloat) -> some View {
        switch self {
        case let .rectangle(radii):
            UnevenRoundedRectangle(cornerRadii: radii.systemRadii)
                .strokeBorder(style, lineWidth: lineWidth)
        case .circle:
            Circle().strokeBorder(style, lineWidth: lineWidth)
        case .curveUp:
            // Since there is no way to implement InsettableShape in a correct way, we make this hack with doubling the lineWidth
            CurveUpShape().stroke(style, lineWidth: lineWidth * 2.0)
        case .curveDown:
            CurveDownShape().stroke(style, lineWidth: lineWidth * 2.0)
        }
    }
}

private struct ResolvedShadow {
    let color: Color
    let radius: Double
    let offset: CGSize
}

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
private extension View {
    /// A translucent layer shows its shadow through itself, as the pre-layer
    /// element shadow did.
    func dropShadows(_ shadows: [ResolvedShadow]) -> some View {
        // ponytail: chained .shadow also shadows the previous shadow; draw a copy
        // per shadow if a design stacks several drops on one layer.
        shadows.reduce(AnyView(self)) { view, shadow in
            AnyView(view.shadow(color: shadow.color, radius: shadow.radius, x: shadow.offset.width, y: shadow.offset.height))
        }
    }
}

@MainActor
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIAnimatableDecoratorModifier: ViewModifier {
    private struct ShadowKey: Hashable {
        let kind: VC.Decorator.Shadow.Kind
        let id: Int
    }

    private struct ShadowOverride {
        var filling: VC.AssetReference?
        var blurRadius: Double?
        var offset: VC.Offset?
    }

    private let decorator: VC.Decorator
    private let includeBackground: Bool
    private var play: Binding<[VC.Animation]>

    // Animations address layers and shadows by id (`target_id`).
    @State private var animatedFillings: [Int: VC.AssetReference] = [:]
    @State private var animatedStrokeFillings: [Int: VC.AssetReference] = [:]
    @State private var animatedStrokeThicknesses: [Int: Double] = [:]
    @State private var animatedShadows: [ShadowKey: ShadowOverride] = [:]

    @State private var animationTokens = Set<AdaptyUIAnimationToken>()

    init(
        decorator: VC.Decorator,
        play: Binding<[VC.Animation]>,
        includeBackground: Bool
    ) {
        self.decorator = decorator
        self.play = play
        self.includeBackground = includeBackground
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        self.isolatedIfBlended(self.decorated(content))
            .onChange(of: play.wrappedValue) { self.startAnimations($0) }
            .onDisappear {
                self.animationTokens.forEach { $0.invalidate() }
                self.animationTokens.removeAll()
            }
    }

    private func decorated(_ content: Content) -> some View {
        self.clippedContent(content)
            .dropShadows(self.contentShadows)
            .background {
                // One gate for every underlay: 4.0.0 lost the includeBackground
                // modifier on the image branch, which is how the footer
                // background came back unconditionally (SDK-1169).
                ZStack {
                    ForEach(self.decorator.underlays.indices, id: \.self) {
                        self.layerView(self.decorator.underlays[$0])
                    }
                }
                .opacity(includeBackground ? 1.0 : 0.0)
            }
            .overlay {
                ZStack {
                    ForEach(self.decorator.overlays.indices, id: \.self) {
                        self.layerView(self.decorator.overlays[$0])
                    }
                }
            }
    }

    /// Layer blend modes compose within the element, not with the screen. The
    /// group stays off for plain layers: it changes edge antialiasing.
    @ViewBuilder
    private func isolatedIfBlended(_ view: some View) -> some View {
        if (self.decorator.underlays + self.decorator.overlays).contains(where: { $0.blend != .normal }) {
            view.compositingGroup()
        } else {
            view
        }
    }

    @ViewBuilder
    private func clippedContent(_ content: Content) -> some View {
        switch self.decorator.clip {
        case .content: content.clipShape(self.decorator.shapeType)
        case .none: content
        }
    }

    /// Drop shadows of `effects` layers follow the content, as the element-level
    /// shadow did before layers.
    private var contentShadows: [ResolvedShadow] {
        (self.decorator.underlays + self.decorator.overlays)
            .filter { if case .effects = $0.kind { true } else { false } }
            .flatMap { self.resolvedShadows($0, kind: .drop) }
    }

    @ViewBuilder
    private func layerView(_ layer: VC.Decorator.Layer) -> some View {
        Group {
            switch layer.kind {
            case .effects:
                EmptyView()
            case let .fill(asset):
                self.areaLayerView(layer, asset: asset, aspect: .fill)
            case let .image(asset, aspect):
                self.areaLayerView(layer, asset: asset, aspect: aspect)
            case let .stroke(asset, thickness):
                self.strokeLayerView(layer, asset: asset, thickness: thickness)
            }
        }
        .blendMode(layer.blend.swiftUIBlendMode)
    }

    @ViewBuilder
    private func areaLayerView(
        _ layer: VC.Decorator.Layer,
        asset: VC.AssetReference,
        aspect: VC.AspectRatio
    ) -> some View {
        let shape = self.decorator.shapeType
        let filling = layer.id.flatMap { animatedFillings[$0] } ?? asset
        let resolved = self.assetsViewModel.resolvedAsset(
            filling,
            mode: self.colorScheme.toVCMode,
            screen: screen
        ).asColorOrGradientOrImageAsset

        Group {
            switch resolved {
            // The extra clip repeats the edge antialiasing of the pre-layer
            // renderer, which clipped the filled shape once more.
            case let .color(color):
                shape.swiftUIShapeFill(self.withInnerShadows(AnyShapeStyle(color), layer))
                    .clipShape(shape)
            case let .colorGradient(gradient):
                shape.swiftUIShapeFill(self.withInnerShadows(gradient.shapeStyle, layer))
                    .clipShape(shape)
            case let .image(image):
                // ponytail: no inner shadows on images, ShapeStyle has no image fill
                // here; add an inner-shadow overlay when a design needs it.
                shape.swiftUIShapeFill(AnyShapeStyle(.clear))
                    .background {
                        AdaptyUIImageView(.resolvedImageAsset(asset: image, aspect: aspect, tint: nil))
                    }
                    .clipShape(shape)
            case .none:
                EmptyView()
            }
        }
        .dropShadows(self.resolvedShadows(layer, kind: .drop))
    }

    @ViewBuilder
    private func strokeLayerView(
        _ layer: VC.Decorator.Layer,
        asset: VC.AssetReference,
        thickness: Double
    ) -> some View {
        let shape = self.decorator.shapeType
        let filling = layer.id.flatMap { animatedStrokeFillings[$0] } ?? asset
        let lineWidth = layer.id.flatMap { animatedStrokeThicknesses[$0] } ?? thickness
        let resolved = self.assetsViewModel.resolvedAsset(
            filling,
            mode: self.colorScheme.toVCMode,
            screen: screen
        ).asColorOrGradientAsset

        if let resolved {
            shape.swiftUIShapeStroke(self.withInnerShadows(resolved.shapeStyle, layer), lineWidth: lineWidth)
                .clipShape(shape)
                .dropShadows(self.resolvedShadows(layer, kind: .drop))
        }
    }

    private func withInnerShadows(_ style: AnyShapeStyle, _ layer: VC.Decorator.Layer) -> AnyShapeStyle {
        self.resolvedShadows(layer, kind: .inner).reduce(style) { style, shadow in
            AnyShapeStyle(style.shadow(.inner(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.offset.width,
                y: shadow.offset.height
            )))
        }
    }

    private func resolvedShadows(_ layer: VC.Decorator.Layer, kind: VC.Decorator.Shadow.Kind) -> [ResolvedShadow] {
        layer.effects.filter { $0.kind == kind }.map { shadow in
            let animated = shadow.id.flatMap { animatedShadows[ShadowKey(kind: kind, id: $0)] }
            let offset = animated?.offset ?? shadow.offset
            return ResolvedShadow(
                color: self.assetsViewModel.resolvedAsset(
                    animated?.filling ?? shadow.filling,
                    mode: self.colorScheme.toVCMode,
                    screen: screen
                ).asColorAsset ?? .clear,
                radius: animated?.blurRadius ?? shadow.blurRadius,
                offset: CGSize(
                    width: offset.x.points(.horizontal, screenSize, safeArea),
                    height: offset.y.points(.vertical, screenSize, safeArea)
                )
            )
        }
    }

    private func startAnimations(_ animations: [VC.Animation]) {
        guard !animations.isEmpty else { return }

        var tokens = Set<AdaptyUIAnimationToken>()

        for animation in animations {
            let timeline = animation.timeline
            switch animation.kind {
            case let .background(value):
                let id = value.targetId
                self.animatedFillings[id] = value.color.start

                tokens.insert(
                    timeline.animate(
                        from: value.color.start,
                        to: value.color.end,
                        updateBlock: { self.animatedFillings[id] = $0 }
                    )
                )
            case let .border(value):
                let id = value.targetId

                if let color = value.color {
                    self.animatedStrokeFillings[id] = color.start

                    tokens.insert(
                        timeline.animate(
                            from: color.start,
                            to: color.end,
                            updateBlock: { self.animatedStrokeFillings[id] = $0 }
                        )
                    )
                }

                if let thickness = value.thickness {
                    self.animatedStrokeThicknesses[id] = thickness.start

                    tokens.insert(
                        timeline.animate(
                            from: thickness.start,
                            to: thickness.end,
                            updateBlock: { self.animatedStrokeThicknesses[id] = $0 }
                        )
                    )
                }
            case let .shadow(value):
                tokens.insert(self.animateShadow(value, key: ShadowKey(kind: .drop, id: value.targetId), timeline: timeline))
            case let .innerShadow(value):
                tokens.insert(self.animateShadow(value, key: ShadowKey(kind: .inner, id: value.targetId), timeline: timeline))
            default:
                break
            }
        }

        self.animationTokens = tokens
    }

    private func animateShadow(
        _ value: VC.Animation.ShadowParameters,
        key: ShadowKey,
        timeline: VC.Animation.Timeline
    ) -> AdaptyUIAnimationToken {
        self.animatedShadows[key] = ShadowOverride(
            filling: value.color?.start,
            blurRadius: value.blurRadius?.start,
            offset: value.offset?.start
        )

        return timeline.animate(
            from: (value.color?.start, value.blurRadius?.start, value.offset?.start),
            to: (value.color?.end, value.blurRadius?.end, value.offset?.end),
            updateBlock: { tuple in
                self.animatedShadows[key] = ShadowOverride(filling: tuple.0, blurRadius: tuple.1, offset: tuple.2)
            }
        )
    }
}

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func animatableDecorator(
        _ decorator: VC.Decorator?,
        play: Binding<[VC.Animation]>,
        includeBackground: Bool
    ) -> some View {
        if let decorator {
            modifier(
                AdaptyUIAnimatableDecoratorModifier(
                    decorator: decorator,
                    play: play,
                    includeBackground: includeBackground
                )
            )
        } else {
            self
        }
    }
}

#endif
