//
//  AdaptyTimelineComponentView.swift
//
//
//  Created by Alexey Goncharov on 13.7.23..
//

import Adapty
import UIKit

extension AdaptyUI {
    struct TimelineEntry {
        let text: AdaptyUI.RichText
        let image: AdaptyUI.ImageData
        let imageColor: AdaptyUI.Color?

        let shape: AdaptyUI.Decorator
        let gradient: AdaptyUI.ColorGradient
    }
}

extension AdaptyUI.OldViewItem {
    var asTimelineEntry: AdaptyUI.TimelineEntry? {
        guard
            case let .object(customObject) = self,
            customObject.type == "timeline_entry",
            let text = customObject.properties["text"]?.asText,
            let image = customObject.properties["image"]?.asImage,
            let shape = customObject.properties["shape"]?.asShape,
            let gradient = customObject.properties["gradient"]?.asColorGradient
        else { return nil }

        return .init(
            text: text,
            image: image,
            imageColor: customObject.properties["image_color"]?.asColor,
            shape: shape,
            gradient: gradient
        )
    }
}

final class AdaptyTimelineEntrySideComponentView: UIView {
    let timelineEntry: AdaptyUI.TimelineEntry

    init(timelineEntry: AdaptyUI.TimelineEntry) throws {
        self.timelineEntry = timelineEntry

        super.init(frame: .zero)
        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shapeView?.layer.applyShapeMask(timelineEntry.shape.shapeType)
        gradientLayer?.frame = gradientView?.bounds ?? .zero
    }

    private var shapeView: UIView?
    private var gradientView: UIView?
    private var gradientLayer: CAGradientLayer?

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false

        let shapeView = AdaptyShapeWithFillingView(shape: timelineEntry.shape)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let imageColor = timelineEntry.imageColor?.uiColor {
            imageView.setImage(timelineEntry.image, renderingMode: .alwaysTemplate)
            imageView.tintColor = imageColor
        } else {
            imageView.setImage(timelineEntry.image)
        }

        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false

        let gradientLayer = CAGradientLayer.create(timelineEntry.gradient)
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradientLayer)

        addSubview(gradientView)
        addSubview(shapeView)
        shapeView.addSubview(imageView)

        addConstraints([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 28.0),

            shapeView.topAnchor.constraint(equalTo: topAnchor),
            shapeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shapeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shapeView.heightAnchor.constraint(equalTo: shapeView.widthAnchor, multiplier: 1.0),

            gradientView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gradientView.topAnchor.constraint(equalTo: shapeView.bottomAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 3.0),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        shapeView.addConstraints([
            imageView.centerXAnchor.constraint(equalTo: shapeView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: shapeView.centerYAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 16.0),
            imageView.heightAnchor.constraint(equalToConstant: 16.0),
        ])

        self.shapeView = shapeView
        self.gradientView = gradientView
        self.gradientLayer = gradientLayer
    }
}

final class AdaptyTimelineComponentView: UIStackView {
    let block: AdaptyUI.OldFeaturesBlock
    let tagConverter: AdaptyUI.CustomTagConverter?

    init(block: AdaptyUI.OldFeaturesBlock, tagConverter: AdaptyUI.CustomTagConverter?) throws {
        guard block.type == .timeline else {
            throw AdaptyUIError.wrongComponentType("type")
        }

        self.block = block
        self.tagConverter = tagConverter

        super.init(frame: .zero)
        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createItemView(_ entry: AdaptyUI.TimelineEntry) throws -> UIView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8.0
        stack.alignment = .fill
        stack.distribution = .fill

        let sideView = try AdaptyTimelineEntrySideComponentView(timelineEntry: entry)
        stack.addArrangedSubview(sideView)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = entry.text.attributedString(
            paragraph: .init(lineSpacing: 2.0),
            tagConverter: tagConverter
        )

        stack.addArrangedSubview(label)

        stack.addConstraint(sideView.widthAnchor.constraint(equalToConstant: 28.0))

        return stack
    }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .fill
        distribution = .equalSpacing
        spacing = 8.0

        let entries = block.orderedItems.compactMap { $0.value.asTimelineEntry }

        for entry in entries {
            addArrangedSubview(try createItemView(entry))
        }
    }
}
