//
//  Image.swift
//  Kingfisher
//
//  Created by Wei Wang on 16/1/6.
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


#if os(macOS)
import AppKit
#else // os(macOS)
import UIKit
import MobileCoreServices
#endif // os(macOS)

#if !os(watchOS)
import CoreImage
#endif

import CoreGraphics
import ImageIO

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif


// MARK: - Image Properties
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    #if os(macOS)
    var cgImage: CGImage? {
        return base.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    var scale: CGFloat {
        return 1.0
    }
    
    var images: [KFCrossPlatformImage]? { return nil }
    
    var duration: TimeInterval { return 0.0 }
    
    var size: CGSize {
        // Prefer to use pixel size of the image
        let pixelSize = base.representations.reduce(.zero) { size, rep in
            CGSize(
                width: max(size.width, CGFloat(rep.pixelsWide)),
                height: max(size.height, CGFloat(rep.pixelsHigh))
            )
        }
        // If the pixel size is zero (SVG or PDF, for example), use the size of the image.
        return pixelSize == .zero ? base.representations.reduce(.zero) { size, rep in
            CGSize(
                width: max(size.width, CGFloat(rep.size.width)),
                height: max(size.height, CGFloat(rep.size.height))
            )
        } : pixelSize
    }
    #else
    var cgImage: CGImage? { return base.cgImage }
    var scale: CGFloat { return base.scale }
    var images: [KFCrossPlatformImage]? { return base.images }
    var duration: TimeInterval { return base.duration }
    var size: CGSize { return base.size }
    #endif

    // Bitmap memory cost with bytes.
    var cost: Int {
        let pixels = Int(size.width * size.height * scale * scale)
        guard let cgImage = cgImage else {
            return pixels * 4
        }
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerFrame = pixels * bytesPerPixel

        if let images {
            let uniqueFrameCount = Set(images.map { ObjectIdentifier($0) }).count
            return bytesPerFrame * uniqueFrameCount
        } else {
            return bytesPerFrame
        }
    }
}

// MARK: - Image Conversion
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    #if os(macOS)
    static func image(cgImage: CGImage, scale: CGFloat, refImage: KFCrossPlatformImage?) -> KFCrossPlatformImage {
        return KFCrossPlatformImage(cgImage: cgImage, size: .zero)
    }
    
    /// The normalized image. On macOS, this getter returns the image itself without performing any additional operations.
    var normalized: KFCrossPlatformImage { return base }
    #else

    /// Create an image from a given `CGImage` with specified scale and orientation, tailored for `refImage`. This
    /// method signature is designed for compatibility with macOS versions.
    ///
    /// - Parameters:
    ///   - cgImage: The `CGImage` which is used to create the `UIImage` object.
    ///   - scale: The scale.
    ///   - refImage: The ref image which is used to determine the image orientation.
    /// - Returns: The created image object.
    static func image(cgImage: CGImage, scale: CGFloat, refImage: KFCrossPlatformImage?) -> KFCrossPlatformImage {
        return KFCrossPlatformImage(cgImage: cgImage, scale: scale, orientation: refImage?.imageOrientation ?? .up)
    }
    
    /// The normalized image for the current `base` image.
    ///
    /// This method attempts to redraw the image, taking orientation and scale into account.
    var normalized: KFCrossPlatformImage {
        // prevent animated image (GIF) lose it's images
        guard images == nil else { return base.copy() as! KFCrossPlatformImage }
        // No need to do anything if already up
        guard base.imageOrientation != .up else { return base.copy() as! KFCrossPlatformImage }

        return draw(to: size, inverting: true, refImage: KFCrossPlatformImage()) {
            fixOrientation(in: $0)
            return true
        }
    }

    func fixOrientation(in context: CGContext) {
        guard let cgImage else { return }

        var transform = CGAffineTransform.identity
        let orientation = base.imageOrientation

        switch orientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: .pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // Flip image one more time if needed for mirrored images. This is to prevent the flipped image.
        switch orientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        context.concatenate(transform)
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
    }
    #endif
}

// MARK: - Image Representation
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    /// Returns a data object that contains the specified image in PNG format.
    ///
    /// - Returns: PNG data of image.
    func pngRepresentation() -> Data? {
        #if os(macOS)
            guard let cgImage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using: .png, properties: [:])
        #else
            return base.pngData()
        #endif
    }

    /// Returns a data object that contains the specified image in JPEG format.
    ///
    /// - Parameter compressionQuality: The compression quality when converting image to JPEG data.
    /// - Returns: JPEG data of image.
    func jpegRepresentation(compressionQuality: CGFloat) -> Data? {
        #if os(macOS)
            guard let cgImage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using:.jpeg, properties: [.compressionFactor: compressionQuality])
        #else
            return base.jpegData(compressionQuality: compressionQuality)
        #endif
    }

    /// Returns a data representation for the `base` image with the specified `format`.
    ///
    /// - Parameters:
    ///   - format: The desired format for the output data. If set to `unknown`, the `base` image will be
    ///             converted to PNG representation.
    ///   - compressionQuality: The compression quality when converting the image to a lossy format data.
    ///
    /// - Returns: The resulting data representation.
    func data(format: ImageFormat, compressionQuality: CGFloat = 1.0) -> Data? {
        return autoreleasepool { () -> Data? in
            let data: Data?
            switch format {
            case .PNG: data = pngRepresentation()
            case .JPEG: data = jpegRepresentation(compressionQuality: compressionQuality)
            case .GIF, .unknown: data = normalized.kf.pngRepresentation()
            }
            
            return data
        }
    }
}

// MARK: - Creating Images
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    
    /// Creates an image from provided data. The system's image initializer is used; animated formats (such as GIF)
    /// decode to their first frame.
    ///
    /// - Parameters:
    ///   - data: The data representing the image.
    ///   - scale: The scale factor for the resulting image.
    /// - Returns: An `Image` object representing the image if successfully created. If the `data` is invalid or 
    /// unsupported, `nil` will be returned.
    static func image(data: Data, scale: CGFloat) -> KFCrossPlatformImage? {
        return KFCrossPlatformImage(data: data, scale: scale)
    }

}
