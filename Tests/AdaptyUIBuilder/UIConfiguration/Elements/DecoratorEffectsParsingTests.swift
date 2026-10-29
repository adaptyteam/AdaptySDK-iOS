@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite("Decorator Effects Parsing", .tags(.codable))
struct DecoratorEffectsParsingTests {
    @Test("Shadow kinds use string identifiers for Codable", arguments: [
        ("drop_shadow", VC.Decorator.Shadow.Kind.drop),
        ("inner_shadow", VC.Decorator.Shadow.Kind.inner),
    ])
    func shadowKindCodable(identifier: String, expected: VC.Decorator.Shadow.Kind) throws {
        let kind = try Json(deserilized: identifier).decode(VC.Decorator.Shadow.Kind.self)
        #expect(kind == expected)

        #expect(try Json.encode(kind) == Json(deserilized: identifier))
    }

    @Test("Shadow kinds reject numeric raw values", arguments: [Json("0"), Json("1")])
    func shadowKindRejectsNumbers(value: Json) {
        #expect(throws: DecodingError.self) { try value.decode(VC.Decorator.Shadow.Kind.self) }
    }

    @Test("Both planes retain ordered layers, shadows, IDs and defaults")
    func orderedPlanes() throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(##"""
        {
          "type":"rect", "rect_corner_radius":12, "clip":"none", "blur_radius":3,
          "underlays":[
            {"id":90,"type":"fill","asset_id":"#FF0000","effects":[
              {"id":8,"type":"drop_shadow","color":"#000000","offset":[2,3]},
              {"id":2,"type":"inner_shadow","color":"#FFFFFF","blur_radius":4}
            ]},
            {"id":7,"type":"image","asset_id":"photo"}
          ],
          "overlays":[
            {"id":40,"type":"stroke","asset_id":"#00FF00"},
            {"id":6,"type":"fill","asset_id":{"var":"theme.paint"},"blend":"destination_in"}
          ]
        }
        """##))
        try #require(value.underlays.count == 2 && value.overlays.count == 2)
        #expect(value.underlays.map(\.id) == [90, 7])
        #expect(value.overlays.map(\.id) == [40, 6])
        let fill = value.underlays[0]
        try #require(fill.effects.count == 2)
        #expect(fill.effects.map(\.id) == [8, 2])
        #expect(fill.effects.map(\.kind) == [.drop, .inner])
        #expect(fill.blend == .normal)
        try DecoratorEffectsFixtures.expectColor(fill.effects[0].filling, "#000000")
        try DecoratorEffectsFixtures.expectColor(fill.effects[1].filling, "#FFFFFF")
        #expect(fill.effects.map(\.blurRadius) == [0, 4])
        guard case let .point(x) = fill.effects[0].offset.x,
              case let .point(y) = fill.effects[0].offset.y else {
            Issue.record("Expected point offsets")
            return
        }
        #expect(x == 3)
        #expect(y == 2)
        #expect(fill.effects[1].offset.isZero)
        #expect(value.clip == .none)
        #expect(value.blurRadius == 3)
        guard case let .fill(asset: fillAsset) = fill.kind,
              case let .image(asset: .assetId(imageId), aspect: aspect) = value.underlays[1].kind,
              case let .stroke(asset: borderAsset, thickness: thickness) = value.overlays[0].kind,
              case let .fill(asset: .variable(binding)) = value.overlays[1].kind else {
            Issue.record("Expected typed fill, image, stroke and binding")
            return
        }
        try DecoratorEffectsFixtures.expectColor(fillAsset, "#FF0000")
        try DecoratorEffectsFixtures.expectColor(borderAsset, "#00FF00")
        #expect(imageId == "photo")
        #expect(aspect == .fill)
        #expect(thickness == 1)
        #expect(binding.path == ["theme", "paint"])
        #expect(value.overlays[1].blend == .destinationIn)
        guard case let .rectangle(radius) = value.shapeType else {
            Issue.record("Expected rectangle")
            return
        }
        #expect(radius.topLeading == 12)
    }

    @Test("Each plane can be present alone", arguments: ["underlays", "overlays"])
    func singlePlane(key: String) throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [
            key: [["id": 3, "type": "fill", "asset_id": "#FF0000"]],
        ]))
        #expect(value.underlays.map(\.id) == (key == "underlays" ? [3] : []))
        #expect(value.overlays.map(\.id) == (key == "overlays" ? [3] : []))
        #expect(value.clip == .content)
    }

    @Test("Missing, null or empty planes produce no layers", arguments: [
        Json(##"{}"##), Json(##"{"underlays":[],"overlays":[]}"##),
        Json(##"{"underlays":null}"##), Json(##"{"overlays":null}"##),
        Json(##"{"underlays":null,"overlays":null}"##),
    ])
    func emptyPlanes(json: Json) throws {
        let value = try DecoratorEffectsFixtures.decorator(json)
        #expect(value.underlays.isEmpty && value.overlays.isEmpty)
    }

    @Test("All twenty blend modes survive extraction", arguments: [
        "normal", "multiply", "screen", "overlay", "darken", "lighten",
        "color_dodge", "color_burn", "hard_light", "difference", "exclusion",
        "hue", "saturation", "color", "luminosity", "source_atop",
        "destination_over", "destination_out", "destination_in", "plus_lighter",
    ])
    func blendModes(mode: String) throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [
            "underlays": [["id": 1, "type": "fill", "asset_id": "#FFFFFF", "blend": mode]],
        ]))
        try #require(value.underlays.count == 1)
        #expect(value.underlays[0].blend.rawValue == mode)
        #expect(VC.BlendMode.allCases.count == 20)
    }

    @Test("Invalid blend values use the layer default but are not enum identifiers", arguments: [
        Json(##""soft_light""##), Json(##""plus_darker""##), Json(##""unknown""##),
        Json(##"true"##), Json(##"0"##),
    ])
    func invalidBlend(value: Json) throws {
        #expect(throws: DecodingError.self) { try value.decode(Schema.BlendMode.self) }
        let decorator = try DecoratorEffectsFixtures.decorator(Json(deserilized: [
            "underlays": [["type": "fill", "asset_id": "#FFFFFF", "blend": value.deserilized]],
        ]))
        try #require(decorator.underlays.count == 1)
        #expect(decorator.underlays[0].blend == .normal)
    }

    @Test("Malformed plane payloads fail decoding", arguments: [
        Json(##"{}"##), Json(##"false"##),
    ], ["underlays", "overlays"])
    func invalidArrays(value: Json, key: String) throws {
        try DecoratorEffectsFixtures.reject(Json(deserilized: [key: value.deserilized]))
    }

    @Test("Invalid layer and shadow payloads fail decoding", arguments: [
        Json(##"{"id":0,"type":"fill","asset_id":"#FFFFFF"}"##),
        Json(##"{"id":-1,"type":"fill","asset_id":"#FFFFFF"}"##),
        Json(##"{"id":1.5,"type":"fill","asset_id":"#FFFFFF"}"##),
        Json(##"{"id":"1","type":"fill","asset_id":"#FFFFFF"}"##),
        Json(##"{"id":1,"type":123}"##),
        Json(##"{"id":1,"type":"fill"}"##),
        Json(##"{"id":1,"type":"fill","value":"#FFFFFF"}"##),
        Json(##"{"id":1,"type":"stroke","color":"#FFFFFF"}"##),
        Json(##"{"id":1,"type":"image","asset_id":"photo","aspect":"tile"}"##),
        Json(##"{"id":1,"type":"stroke","asset_id":"#FFFFFF","thickness":"wide"}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":{}}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[null]}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[true]}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[{"type":0,"color":"#000000"}]}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[{"id":0,"color":"#000000"}]}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[{"id":-1,"color":"#000000"}]}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[{"id":1.5,"color":"#000000"}]}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[{"id":2,"type":"inner_shadow"}]}"##),
        Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":[{"type":"unknown"},{"type":"drop_shadow","color":"#000000","blur_radius":"bad"}]}"##),
    ])
    func invalidPayload(layer: Json) throws {
        try DecoratorEffectsFixtures.reject(Json(deserilized: ["underlays": [layer.deserilized]]))
    }

    @Test("Unknown layers are skipped without changing known or legacy layers", arguments: ["underlays", "overlays"])
    func unknownLayers(key: String) throws {
        let layers = Json(##"""
        [
          {"type":"future_before","id":-1,"effects":false},
          {"id":11,"type":"fill","asset_id":"#112233"},
          {"type":"future_middle"},
          {"id":12,"type":"stroke","asset_id":"#445566"},
          {"id":13,"type":"image","asset_id":"photo"},
          {"id":14,"type":"effects"},
          {"id":15},
          {"id":16,"type":null},
          {"type":"future_after","asset_id":false}
        ]
        """##)
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [
            "background": "#FFFFFF", "border": "#000000", key: layers.deserilized,
        ]))
        let decoded = key == "underlays" ? value.underlays : value.overlays
        #expect(decoded.map(\.id) == [0, 11, 12, 13, 14, 15, 16])
        let explicit = Array(decoded.dropFirst())
        try #require(explicit.count == 6)
        guard case .fill = explicit[0].kind,
              case let .stroke(_, thickness) = explicit[1].kind,
              case let .image(_, aspect) = explicit[2].kind,
              case .effects = explicit[3].kind,
              case .effects = explicit[4].kind,
              case .effects = explicit[5].kind else {
            Issue.record("Expected known layer kinds and effects defaults")
            return
        }
        #expect(thickness == 1)
        #expect(aspect == .fill)
    }

    @Test("An array of unknown layers produces no layers", arguments: [
        Json(##"[{"id":1,"type":"unknown","asset_id":"#FFFFFF"}]"##),
        Json(##"[{"type":"future_one"},{"type":"future_two","id":0,"effects":false}]"##),
    ], ["underlays", "overlays"])
    func allLayersUnknown(layers: Json, key: String) throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [key: layers.deserilized]))
        #expect(value.underlays.isEmpty && value.overlays.isEmpty)
    }

    @Test("Null effects produce no shadows without removing the layer", arguments: ["underlays", "overlays"])
    func nullEffects(key: String) throws {
        let layer = Json(##"{"id":1,"type":"fill","asset_id":"#FFFFFF","effects":null}"##)
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [key: [layer.deserilized]]))
        let layers = key == "underlays" ? value.underlays : value.overlays
        #expect(layers.map(\.id) == [1])
        let decoded = try #require(layers.first)
        #expect(decoded.effects.isEmpty)
        guard case let .fill(asset) = decoded.kind else {
            Issue.record("Expected retained fill layer")
            return
        }
        try DecoratorEffectsFixtures.expectColor(asset, "#FFFFFF")
    }

    @Test("IDs are optional and shadows default to drop")
    func optionalIDs() throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(##"""
        {"underlays":[{"type":"fill","asset_id":"#FFFFFF","effects":[{"color":"#000000"}]}],
         "overlays":[{"type":"stroke","asset_id":"#000000"}]}
        """##))
        try #require(value.underlays.count == 1 && value.overlays.count == 1)
        let layer = value.underlays[0]
        #expect(layer.id == nil)
        #expect(value.overlays[0].id == nil)
        try #require(layer.effects.count == 1)
        let shadow = layer.effects[0]
        #expect(shadow.id == nil)
        #expect(shadow.kind == .drop)
        #expect(shadow.blurRadius == 0)
        #expect(shadow.offset.isZero)
        try DecoratorEffectsFixtures.expectColor(shadow.filling, "#000000")
    }

    @Test("Effects layers preserve shadows", arguments: [
        Json(##"{"id":3,"type":"effects","asset_id":"#FFFFFF","effects":[{"id":9,"type":"inner_shadow","color":"#000000"}]}"##),
        Json(##"{"id":3,"asset_id":"#FFFFFF","effects":[{"id":9,"type":"inner_shadow","color":"#000000"}]}"##),
    ])
    func effectsLayer(layer: Json) throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: ["overlays": [layer.deserilized]]))
        try #require(value.overlays.count == 1)
        let layer = value.overlays[0]
        guard case .effects = layer.kind else {
            Issue.record("Expected effects-only layer")
            return
        }
        #expect(layer.id == 3)
        #expect(layer.effects.map(\.id) == [9])
        #expect(layer.effects.map(\.kind) == [.inner])
    }

    @Test("Unknown effects are skipped without changing known effects", arguments: ["underlays", "overlays"])
    func unknownEffects(key: String) throws {
        let layer = Json(##"""
        {"type":"effects","effects":[
          {"type":"future_blur","id":-1,"color":false,"payload":{"nested":[1,2]}},
          {"id":11,"type":"drop_shadow","color":"#000000","blur_radius":2},
          {"type":"future_glow"},
          {"id":12,"type":"inner_shadow","color":"#FFFFFF","blur_radius":3},
          {"id":13,"color":"#FF0000"},
          {"id":14,"type":null,"color":"#00FF00"},
          {"type":"future_shadow","id":"invalid"}
        ]}
        """##)
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [key: [layer.deserilized]]))
        let layers = key == "underlays" ? value.underlays : value.overlays
        let effects = try #require(layers.first).effects
        #expect(effects.map(\.id) == [11, 12, 13, 14])
        #expect(effects.map(\.kind) == [.drop, .inner, .drop, .drop])
        #expect(effects.map(\.blurRadius) == [2, 3, 0, 0])
        for (effect, color) in zip(effects, ["#000000", "#FFFFFF", "#FF0000", "#00FF00"]) {
            try DecoratorEffectsFixtures.expectColor(effect.filling, color)
        }
    }

    @Test("An array of unknown effects produces no shadows", arguments: [
        Json(##"[{"id":2,"type":"unknown","color":"#000000"}]"##),
        Json(##"[{"type":"future_blur"},{"type":"future_glow","color":false}]"##),
    ])
    func allEffectsUnknown(effects: Json) throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [
            "underlays": [["type": "effects", "effects": effects.deserilized]],
        ]))
        let layer = try #require(value.underlays.first)
        #expect(layer.effects.isEmpty)
    }

    @Test("Legacy combinations normalize to paint or effects layers", arguments: 0..<16)
    func legacyNormalization(mask: Int) throws {
        let hasBackground = mask & 1 != 0
        let hasBorder = mask & 2 != 0
        let hasDrop = mask & 4 != 0
        let hasInner = mask & 8 != 0
        var fields: [String: Any] = [:]
        if hasBackground { fields["background"] = "#FF0000" }
        if hasBorder { fields["border"] = "#00FF00" }
        if hasDrop { fields["shadow"] = ["color": "#000000"] }
        if hasInner { fields["inner_shadow"] = ["color": "#FFFFFF"] }
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: fields))
        #expect(value.underlays.count == (hasBackground || hasDrop ? 1 : 0))
        #expect(value.overlays.count == (hasBorder ? 1 : 0))
        if hasBackground || hasDrop {
            let layer = try #require(value.underlays.first)
            #expect(layer.id == 0)
            #expect(layer.blend == .normal)
            if hasBackground {
                guard case let .image(asset, aspect) = layer.kind else {
                    Issue.record("Expected normalized legacy background")
                    return
                }
                try DecoratorEffectsFixtures.expectColor(asset, "#FF0000")
                #expect(aspect == .fill)
            } else {
                guard case .effects = layer.kind else {
                    Issue.record("Expected standalone drop shadow layer")
                    return
                }
            }
            let kinds: [VC.Decorator.Shadow.Kind] = (hasDrop ? [.drop] : []) + (hasBackground && hasInner ? [.inner] : [])
            #expect(layer.effects.map(\.kind) == kinds)
            #expect(layer.effects.count == kinds.count)
            #expect(layer.effects.allSatisfy { $0.id == 0 && $0.blurRadius == 0 && $0.offset.isZero })
            for shadow in layer.effects {
                try DecoratorEffectsFixtures.expectColor(shadow.filling, shadow.kind == .drop ? "#000000" : "#FFFFFF")
            }
        }
        if hasBorder {
            let layer = try #require(value.overlays.first)
            #expect(layer.id == 0)
            #expect(layer.blend == .normal)
            #expect(layer.effects.isEmpty)
            guard case let .stroke(asset, thickness) = layer.kind else {
                Issue.record("Expected normalized legacy border")
                return
            }
            try DecoratorEffectsFixtures.expectColor(asset, "#00FF00")
            #expect(thickness == 1)
        }
    }

    @Test("Legacy layers precede explicit layers in each plane")
    func mixedFields() throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(##"""
        {"background":"#FF0000","border":"#00FF00","thickness":4,
         "shadow":{"color":"#000000","blur_radius":3},
         "inner_shadow":{"color":"#FFFFFF","blur_radius":2},
         "underlays":[{"id":7,"type":"fill","asset_id":"#0000FF"},{"id":3,"type":"image","asset_id":"photo"}],
         "overlays":[{"id":9,"type":"stroke","asset_id":"#FFFFFF","thickness":5}]}
        """##))
        try #require(value.underlays.count == 3 && value.overlays.count == 2)
        #expect(value.underlays.map(\.id) == [0, 7, 3])
        #expect(value.overlays.map(\.id) == [0, 9])
        #expect(value.underlays[0].effects.map(\.kind) == [.drop, .inner])
        #expect(value.underlays[0].effects.map(\.blurRadius) == [3, 2])
        guard case let .stroke(_, legacyThickness) = value.overlays[0].kind,
              case let .stroke(_, explicitThickness) = value.overlays[1].kind else {
            Issue.record("Expected legacy and explicit strokes")
            return
        }
        #expect(legacyThickness == 4)
        #expect(explicitThickness == 5)
    }

    @Test("Image aspect, texture paints and bindings remain distinct", arguments: ["fit", "fill", "stretch"])
    func imageAssets(aspect: String) throws {
        let value = try DecoratorEffectsFixtures.decorator(Json(deserilized: [
            "underlays": [
                ["id": 1, "type": "image", "asset_id": "photo", "aspect": aspect],
                ["id": 2, "type": "fill", "asset_id": "photo"],
                ["id": 3, "type": "stroke", "asset_id": "photo", "thickness": 4],
                ["id": 4, "type": "image", "asset_id": ["var": "current.image"]],
            ],
        ]))
        try #require(value.underlays.count == 4)
        guard case let .image(asset: .assetId(image), aspect: scale) = value.underlays[0].kind,
              case let .fill(asset: .assetId(fill)) = value.underlays[1].kind,
              case let .stroke(asset: .assetId(stroke), thickness: thickness) = value.underlays[2].kind,
              case let .image(asset: .variable(binding), aspect: defaultAspect) = value.underlays[3].kind else {
            Issue.record("Expected image, fill, stroke and binding")
            return
        }
        #expect(image == "photo" && fill == "photo" && stroke == "photo")
        #expect(scale.rawValue == aspect)
        #expect(thickness == 4)
        #expect(defaultAspect == .fill)
        #expect(binding.path == ["current", "image"])
    }

    @Test("Image references survive localization and asset fallback")
    func imageResolution() throws {
        let decorator = Json(##"{"underlays":[{"id":1,"type":"image","asset_id":"photo"}]}"##)
        let localizations = Json(##"[{"id":"en","assets":[{"id":"photo","type":"image","custom_id":"localized","url":"https://example.com/localized.png"}]}]"##)
        let localized = try DecoratorEffectsFixtures.configuration(decorator, localizations: localizations)
        #expect(localized.assets["photo"]?.customId == "localized")
        let fallbackAssets = Json(##"[{"id":"photo","type":"future_image","fallback_asset_id":"real"},{"id":"real","type":"image","custom_id":"fallback","url":"https://example.com/image.png"}]"##)
        let fallback = try DecoratorEffectsFixtures.configuration(decorator, assets: fallbackAssets)
        #expect(fallback.assets["photo"]?.customId == "fallback")
        for configuration in [localized, fallback] {
            let value = try #require(DecoratorEffectsFixtures.properties(configuration).decorator)
            try #require(value.underlays.count == 1)
            guard case .image(asset: .assetId("photo"), aspect: _) = value.underlays[0].kind,
                  case .image = configuration.assets["photo"] else {
                Issue.record("Expected image reference and resolved image asset")
                return
            }
        }
    }

    @Test("Gradient references are retained by fill and stroke", arguments: ["fill", "stroke"])
    func gradientAssets(type: String) throws {
        let assets = Json(##"""
        [{"id":"gradient","type":"linear-gradient",
          "points":{"x0":0,"y0":0,"x1":1,"y1":1},
          "values":[{"color":"#FF0000","p":0},{"color":"#0000FF","p":1}]}]
        """##)
        let configuration = try DecoratorEffectsFixtures.configuration(Json(deserilized: [
            "overlays": [["id": 1, "type": type, "asset_id": "gradient"]],
        ]), assets: assets)
        let value = try #require(DecoratorEffectsFixtures.properties(configuration).decorator)
        try #require(value.overlays.count == 1)
        let asset: VC.AssetReference
        switch value.overlays[0].kind {
        case let .fill(reference):
            #expect(type == "fill")
            asset = reference
        case let .stroke(reference, thickness):
            #expect(type == "stroke")
            #expect(thickness == 1)
            asset = reference
        default:
            Issue.record("Expected gradient paint")
            return
        }
        guard case .assetId("gradient") = asset, case .colorGradient = configuration.assets["gradient"] else {
            Issue.record("Expected retained gradient asset")
            return
        }
    }

    @Test("Animation kinds retain target IDs and payload after layer reordering", arguments: [false, true], ["event_handlers", "on_appear", "transition_in"])
    func animationTargets(reversed: Bool, field: String) throws {
        let layers = [
            Json(##"{"id":90,"type":"fill","asset_id":"#FFFFFF","effects":[{"id":12,"type":"drop_shadow","color":"#000000"}]}"##),
            Json(##"{"id":3,"type":"image","asset_id":"photo","effects":[{"id":40,"type":"inner_shadow","color":"#FFFFFF"}]}"##),
        ]
        let decorator = try Json(deserilized: [
            "underlays": (reversed ? Array(layers.reversed()) : layers).map { try $0.deserilized },
            "overlays": [["id": 2, "type": "stroke", "asset_id": "#000000"]],
        ])
        let entries = [
            Json(##"{"type":"background","target_id":90,"color":{"start":"#FFFFFF","end":"#000000"}}"##),
            Json(##"{"type":"border","target_id":2,"thickness":{"start":1,"end":5}}"##),
            Json(##"{"type":"shadow","target_id":12,"blur_radius":{"start":0,"end":3}}"##),
            Json(##"{"type":"inner_shadow","target_id":40,"offset":{"start":[0,0],"end":[1,2]}}"##),
        ]
        // transition_in holds one animation; exercise all kinds in separate configurations.
        let targetIDs: [Int?] = [90, 2, 12, 40]
        let batches: [([Json], [Int?])] = field == "transition_in"
            ? entries.enumerated().map { ([$0.element], [targetIDs[$0.offset]]) }
            : [(entries, targetIDs)]
        for (batch, expectedIDs) in batches {
            let properties = try DecoratorEffectsFixtures.properties(
                decorator, animations: Json(deserilized: batch.map { try $0.deserilized }), animationField: field
            )
            let value = try #require(properties.decorator)
            #expect(value.underlays.map(\.id) == (reversed ? [3, 90] : [90, 3]))
            #expect(value.overlays.map(\.id) == [2])
            try #require(properties.eventHandlers.count == 1)
            let decoded = properties.eventHandlers[0].animations
            try #require(decoded.count == batch.count)
            #expect(decoded.map(DecoratorEffectsFixtures.targetId) == expectedIDs)
            for animation in decoded {
                switch animation.kind {
                case let .background(parameters):
                    #expect(parameters.targetId == 90)
                    try DecoratorEffectsFixtures.expectColor(parameters.color.start, "#FFFFFF")
                    try DecoratorEffectsFixtures.expectColor(parameters.color.end, "#000000")
                case let .border(parameters):
                    #expect(parameters.targetId == 2)
                    #expect(parameters.thickness?.start == 1 && parameters.thickness?.end == 5)
                case let .shadow(parameters):
                    #expect(parameters.targetId == 12)
                    #expect(parameters.blurRadius?.start == 0 && parameters.blurRadius?.end == 3)
                case let .innerShadow(parameters):
                    #expect(parameters.targetId == 40)
                    #expect(parameters.offset?.start.isZero == true)
                    guard case let .point(x)? = parameters.offset?.end.x,
                          case let .point(y)? = parameters.offset?.end.y else {
                        Issue.record("Expected shadow offset animation")
                        return
                    }
                    #expect(x == 2 && y == 1)
                default: Issue.record("Expected decorator animation")
                }
            }
        }
    }

    @Test("Missing and zero target IDs normalize to zero", arguments: ["background", "border", "shadow", "inner_shadow"], [false, true])
    func defaultAnimationTargets(type: String, explicitZero: Bool) throws {
        var animation: [String: Any] = [
            "type": type, "color": ["start": "#FFFFFF", "end": "#000000"],
        ]
        if explicitZero { animation["target_id"] = 0 }
        let animations = Json(deserilized: [animation])
        for field in ["event_handlers", "on_appear", "transition_in"] {
            let properties = try DecoratorEffectsFixtures.properties(Json(##"{"background":"#FFFFFF"}"##), animations: animations, animationField: field)
            try #require(properties.eventHandlers.count == 1)
            let decoded = properties.eventHandlers[0].animations
            try #require(decoded.count == 1)
            #expect(DecoratorEffectsFixtures.targetId(decoded[0]) == 0)
        }
    }

    @Test("Malformed animation targets and missing payloads fail decoding", arguments: [
        Json(##"{"type":"background","target_id":"1","color":{"start":"#FFFFFF","end":"#000000"}}"##),
        Json(##"{"type":"border","target_id":"1","thickness":{"start":1,"end":2}}"##),
        Json(##"{"type":"shadow","target_id":"1","blur_radius":{"start":0,"end":2}}"##),
        Json(##"{"type":"inner_shadow","target_id":"1","blur_radius":{"start":0,"end":2}}"##),
        Json(##"{"type":"background"}"##), Json(##"{"type":"border"}"##),
        Json(##"{"type":"shadow"}"##), Json(##"{"type":"inner_shadow"}"##),
    ])
    func invalidAnimation(animation: Json) throws {
        #expect(throws: DecodingError.self) { try animation.decode(Schema.Animation.self) }
        for field in ["event_handlers", "transition_in"] {
            #expect(throws: (any Error).self) {
                try DecoratorEffectsFixtures.properties(Json(##"{}"##), animations: Json(deserilized: [animation.deserilized]), animationField: field)
            }
        }
    }

    @Test("Decorator layers are shared by simple and composite elements", arguments: [
        Json(##"{"type":"text","string_id":"title"}"##),
        Json(##"{"type":"box","content":{"type":"text","string_id":"title","decorator":{"overlays":[{"id":1,"type":"fill","asset_id":"#000000"}]}}}"##),
        Json(##"{"type":"deck","items":[{"type":"deck_item","content":{"type":"text","string_id":"title"}}]}"##),
    ])
    func commonProperties(element: Json) throws {
        let value = try #require(DecoratorEffectsFixtures.properties(Json(##"{"overlays":[{"id":1,"type":"fill","asset_id":"#FFFFFF"}]}"##), element: element).decorator)
        #expect(value.overlays.map(\.id) == [1])
        try #require(value.overlays.count == 1)
        guard case let .fill(asset) = value.overlays[0].kind else {
            Issue.record("Expected common fill layer")
            return
        }
        try DecoratorEffectsFixtures.expectColor(asset, "#FFFFFF")
    }

    @Test("Element blend is read from the element itself", arguments: [
        Json(##"{"type":"text","string_id":"title","blend":"multiply"}"##),
        Json(##"{"type":"box","width":60,"offset":[20,0],"blend":"multiply"}"##),
    ])
    func elementBlend(element: Json) throws {
        let value = try DecoratorEffectsFixtures.properties(Json(##"{"type":"rect"}"##), element: element)
        #expect(value.blend == .multiply)
    }

    @Test("Element blend survives nesting in a stack")
    func nestedElementBlend() throws {
        let configuration = try DecoratorEffectsFixtures.configuration(
            Json(##"{"type":"rect"}"##),
            element: Json(##"{"type":"z_stack","content":[{"type":"box","width":60},{"type":"box","width":60,"blend":"multiply"}]}"##)
        )
        let screen = try #require(configuration.screens["main"])
        let blends = screen.poolElements.compactMap { $0.properties?.blend }
        #expect(blends.contains(.multiply), "\(blends)")
    }
}

private enum DecoratorEffectsFixtures {
    static let imageAssets = Json(##"[{"id":"photo","type":"image","url":"https://example.com/image.png"}]"##)

    static func properties(
        _ decorator: Json,
        animations: Json = Json(##"[]"##),
        animationField: String = "event_handlers",
        assets: Json = imageAssets,
        localizations: Json = Json(##"[]"##),
        element: Json = Json(##"{"type":"text","string_id":"title"}"##)
    ) throws -> VC.Element.Properties {
        try properties(configuration(decorator, animations: animations, animationField: animationField, assets: assets, localizations: localizations, element: element))
    }

    static func properties(_ configuration: VC) throws -> VC.Element.Properties {
        let screen = try #require(configuration.screens["main"])
        return try #require(screen.poolElements[screen.content].properties)
    }

    static func decorator(_ json: Json) throws -> VC.Decorator {
        try #require(properties(json).decorator)
    }

    static func configuration(
        _ decorator: Json,
        animations: Json = Json(##"[]"##),
        animationField: String = "event_handlers",
        assets: Json = imageAssets,
        localizations: Json = Json(##"[]"##),
        element: Json = Json(##"{"type":"text","string_id":"title"}"##)
    ) throws -> VC {
        var content = try #require(element.deserilized as? [String: Any])
        content["decorator"] = try decorator.deserilized
        if animationField == "event_handlers" {
            content[animationField] = [["triggers": [["events": ["on_will_appear"]]], "animations": try animations.deserilized]]
        } else if animationField == "transition_in" {
            content[animationField] = try #require((animations.deserilized as? [Any])?.first)
        } else {
            content[animationField] = try animations.deserilized
        }
        let json = try Json(deserilized: [
            "format": "5.2.0", "assets": assets.deserilized,
            "localizations": localizations.deserilized,
            "screens": ["main": ["content": content]],
        ])
        let schema = try AdaptyUISchema(from: json.data, configuration: .init(device: .phone))
        let environment = try DecoratorClipFixtures.configuration().environment
        return try schema.extractUIConfiguration(id: "decorator-effects-test", withLocaleId: "en", envoriment: environment)
    }

    static func targetId(_ animation: VC.Animation) -> Int? {
        switch animation.kind {
        case let .background(parameters): parameters.targetId
        case let .border(parameters): parameters.targetId
        case let .shadow(parameters), let .innerShadow(parameters): parameters.targetId
        default: nil
        }
    }

    static func expectColor(_ reference: VC.AssetReference, _ hex: String) throws {
        let expected = try #require(Schema.Color(rawValue: hex))
        guard case let .color(color) = reference else {
            Issue.record("Expected inline color")
            return
        }
        #expect(color.data == expected.data)
    }

    static func reject(_ decorator: Json) throws {
        #expect(throws: DecodingError.self) { try decorator.decode(Schema.Decorator.self) }
        #expect(throws: (any Error).self) { try properties(decorator) }
    }
}
