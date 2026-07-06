//
//  ImageDrawing.swift
//  Kingfisher
//
//  Created by onevcat on 2018/09/28.
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

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Image Scaling
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    /// Returns an image object associated with the `base` image with a given scale.
    ///
    /// - Parameter scale: The target scale factor for the new image.
    /// - Returns: The image with the target scale.
    ///
    /// > If the base image is not a CG-based image, the `base` image itself is returned.
    func scaled(to scale: CGFloat) -> KFCrossPlatformImage {
        guard scale != self.scale else {
            return base
        }
        guard let cgImage = cgImage else {
            assertionFailure("[Kingfisher] Scaling only works for CG-based image.")
            return base
        }
        return KingfisherWrapper.image(cgImage: cgImage, scale: scale, refImage: base)
    }
}

// MARK: - Decoding Image
extension KingfisherWrapper where Base: KFCrossPlatformImage {
    
    /// Returns the decoded image of the `base` image. 
    ///
    /// On iOS 15 or later, this is identical to the `UIImage.preparingForDisplay` method.
    ///
    /// In previous versions, this method draws the image in a plain context and returns the data from it. Using this
    ///  method can improve drawing performance when an image is created from data but hasn't been displayed for the
    ///  first time.
    ///
    /// > This method is only applicable to CG-based images. The current image scale is preserved.
    /// > For any non-CG-based image or animated image, the `base` image itself is returned.
    var decoded: KFCrossPlatformImage { return decoded(scale: scale) }
    
    /// Returns the decoded image of the `base` image at a given `scale`.
    ///
    /// On iOS 15 or later, this is identical to the `UIImage.preparingForDisplay` method.
    ///
    /// In previous versions, this method draws the image in a plain context and returns the data from it. Using this
    ///  method can improve drawing performance when an image is created from data but hasn't been displayed for the
    ///  first time.
    ///
    /// > This method is only applicable to CG-based images. The current image scale is preserved.
    /// > For any non-CG-based image or animated image, the `base` image itself is returned.
    func decoded(scale: CGFloat) -> KFCrossPlatformImage {
        // Prevent animated image (multi-frame) losing its frames.
        if images != nil { return base }
        
        // For older system versions, revert to the drawing for decoding.
        guard let imageRef = cgImage else {
            assertionFailure("[Kingfisher] Decoding only works for CG-based image.")
            return base
        }
        
        #if !os(watchOS) && !os(macOS)
        // In newer system versions, use `preparingForDisplay`.
        if #available(iOS 15.0, tvOS 15.0, visionOS 1.0, *) {
            if base.scale == scale, let image = base.preparingForDisplay() {
                return image
            }
            let scaledImage = KFCrossPlatformImage(cgImage: imageRef, scale: scale, orientation: base.imageOrientation)
            if let image = scaledImage.preparingForDisplay() {
                return image
            }
        }
        #endif

        let size = CGSize(width: CGFloat(imageRef.width) / scale, height: CGFloat(imageRef.height) / scale)
        return draw(to: size, inverting: true, scale: scale) { context in
            context.draw(imageRef, in: CGRect(origin: .zero, size: size))
            return true
        }
    }
}

extension KingfisherWrapper where Base: KFCrossPlatformImage {
    func draw(
        to size: CGSize,
        inverting: Bool,
        scale: CGFloat? = nil,
        refImage: KFCrossPlatformImage? = nil,
        draw: (CGContext) -> Bool // Whether use the refImage (`true`) or ignore image orientation (`false`)
    ) -> KFCrossPlatformImage
    {
        #if os(macOS) || os(watchOS)
        let targetScale = scale ?? self.scale
        GraphicsContext.begin(size: size, scale: targetScale)
        guard let context = GraphicsContext.current(size: size, scale: targetScale, inverting: inverting, cgImage: cgImage) else {
            assertionFailure("[Kingfisher] Failed to create CG context for blurring image.")
            return base
        }
        defer { GraphicsContext.end() }
        let useRefImage = draw(context)
        guard let cgImage = context.makeImage() else {
            return base
        }
        let ref = useRefImage ? (refImage ?? base) : nil
        return KingfisherWrapper.image(cgImage: cgImage, scale: targetScale, refImage: ref)
        #else
        
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = scale ?? self.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        var useRefImage: Bool = false
        let image = renderer.image { rendererContext in
            
            let context = rendererContext.cgContext
            if inverting { // If drawing a CGImage, we need to make context flipped.
                context.scaleBy(x: 1.0, y: -1.0)
                context.translateBy(x: 0, y: -size.height)
            }
            
            useRefImage = draw(context)
        }
        if useRefImage {
            guard let cgImage = image.cgImage else {
                return base
            }
            let ref = refImage ?? base
            return KingfisherWrapper.image(cgImage: cgImage, scale: format.scale, refImage: ref)
        } else {
            return image
        }
        #endif
    }
}
