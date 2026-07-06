//
//  ImageProcessor.swift
//  Kingfisher
//
//  Created by Wei Wang on 2016/08/26.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import CoreGraphics

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#else
import UIKit
#endif

/// Represents an item which could be processed by an `ImageProcessor`.
enum ImageProcessItem: Sendable {
    
    /// Input image. The processor should provide a method to apply
    /// processing to this `image` and return the resulting image.
    case image(KFCrossPlatformImage)
    
    /// Input data. The processor should provide a method to apply
    /// processing to this `data` and return the resulting image.
    case data(Data)
}

/// An `ImageProcessor` is used to convert downloaded data into an image.
protocol ImageProcessor: Sendable {
    
    /// Identifier for the processor.
    ///
    /// This identifier is used to distinguish the processor when caching and retrieving an image. Ensure that
    /// processors with the same properties or functionality share the same identifier so that processed images can be
    /// retrieved with the correct key.
    ///
    /// > Important: Avoid using an empty string for a custom processor, as it is already reserved by the
    /// > `DefaultImageProcessor`. It is recommended to use a reverse domain name notation string for your identifier.
    var identifier: String { get }

    /// Process the input `ImageProcessItem` using this processor.
    ///
    /// - Parameters:
    ///   - item: The input item to be processed by `self`.
    ///   - options: The parsed options for processing the item.
    /// - Returns: The processed image.
    ///
    /// You should return `nil` if processing fails when converting an input item to an image. If the processing
    /// caller receives `nil`, an error will be reported, and the processing flow will stop. If processing flow is not
    /// critical for your use case, and the input item is already an image (`.image` case), you can also choose to
    /// return the input image itself to continue the processing pipeline.
    ///
    /// > Important: Most processors only support CG-based images. The watchOS is not supported for processors
    /// > containing a filter, and the input image will be returned directly on watchOS.
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage?
}

func ==(left: any ImageProcessor, right: any ImageProcessor) -> Bool {
    return left.identifier == right.identifier
}

func !=(left: any ImageProcessor, right: any ImageProcessor) -> Bool {
    return !(left == right)
}

/// The default processor. It converts the input data into a valid image.
///
/// Supported image formats include .PNG, .JPEG, and .GIF. If an image item is provided as the
/// ``ImageProcessItem/image(_:)`` case, ``DefaultImageProcessor`` will leave it unchanged and return the associated
/// image.
struct DefaultImageProcessor: ImageProcessor {
    
    /// A default instance of ``DefaultImageProcessor`` can be used across the framework.
    static let `default` = DefaultImageProcessor()
    
    let identifier = ""
    
    /// Create a ``DefaultImageProcessor``.
    ///
    /// Use ``DefaultImageProcessor/default`` to obtain an instance if you have no specific reason to create your own
    /// ``DefaultImageProcessor``.
    init() {}
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.kf.scaled(to: options.scaleFactor)
        case .data(let data):
            return KingfisherWrapper.image(data: data, scale: options.scaleFactor)
        }
    }
}
