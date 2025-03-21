//
//  ImageDataProvider.swift
//  Kingfisher
//
//  Created by onevcat on 2018/11/13.
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

/// Represents a data provider to provide image data to Kingfisher when setting with
/// ``Source/provider(_:)`` source. Compared to ``Source/network(_:)`` member, it gives a chance
/// to load some image data in your own way, as long as you can provide the data
/// representation for the image.
protocol ImageDataProvider: Sendable {
    
    /// The key used in cache.
    var cacheKey: String { get }
    
    /// Provides the data which represents image. Kingfisher uses the data you pass in the
    /// handler to process images and caches it for later use.
    ///
    /// - Parameter handler: The handler you should call when you prepared your data.
    ///                      If the data is loaded successfully, call the handler with
    ///                      a `.success` with the data associated. Otherwise, call it
    ///                      with a `.failure` and pass the error.
    ///
    /// - Note: If the `handler` is called with a `.failure` with error,
    /// a ``KingfisherError/ImageSettingErrorReason/dataProviderError(provider:error:)`` will be finally thrown out to
    /// you as the ``KingfisherError`` from the framework.
    func data(handler: @escaping @Sendable (Result<Data, any Error>) -> Void)

    /// The content URL represents this provider, if exists.
    var contentURL: URL? { get }
}

extension ImageDataProvider {
    var contentURL: URL? { return nil }
    func convertToSource() -> Source {
        .provider(self)
    }
}

/// Represents an image data provider for loading from a local file URL on disk.
/// Uses this type for adding a disk image to Kingfisher. Compared to loading it
/// directly, you can get benefit of using Kingfisher's extension methods, as well
/// as applying ``ImageProcessor``s and storing the image to ``ImageCache`` of Kingfisher.
struct LocalFileImageDataProvider: ImageDataProvider {

    // MARK: Properties

    /// The file URL from which the image be loaded.
    let fileURL: URL
    private let loadingQueue: ExecutionQueue

    // MARK: Initializers

    /// Creates an image data provider by supplying the target local file URL.
    ///
    /// - Parameters:
    ///   - fileURL: The file URL from which the image be loaded.
    ///   - cacheKey: The key is used for caching the image data. By default,
    ///               the `absoluteString` of ``LocalFileImageDataProvider/fileURL`` is used.
    ///   - loadingQueue: The queue where the file loading should happen. By default, the dispatch queue of
    ///                   `.global(qos: .userInitiated)` will be used.
    init(
        fileURL: URL,
        cacheKey: String? = nil,
        loadingQueue: ExecutionQueue = .dispatch(DispatchQueue.global(qos: .userInitiated))
    ) {
        self.fileURL = fileURL
        self.cacheKey = cacheKey ?? fileURL.localFileCacheKey
        self.loadingQueue = loadingQueue
    }

    // MARK: Protocol Conforming

    /// The key used in cache.
    var cacheKey: String

    func data(handler: @escaping @Sendable (Result<Data, any Error>) -> Void) {
        loadingQueue.execute {
            handler(Result(catching: { try Data(contentsOf: fileURL) }))
        }
    }
    
    var data: Data {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                loadingQueue.execute {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /// The URL of the local file on the disk.
    var contentURL: URL? {
        return fileURL
    }
}

/// Represents an image data provider for loading image from a given Base64 encoded string.
struct Base64ImageDataProvider: ImageDataProvider {

    // MARK: Properties
    /// The encoded Base64 string for the image.
    let base64String: String

    // MARK: Initializers

    /// Creates an image data provider by supplying the Base64 encoded string.
    ///
    /// - Parameters:
    ///   - base64String: The Base64 encoded string for an image.
    ///   - cacheKey: The key is used for caching the image data. You need a different key for any different image.
    init(base64String: String, cacheKey: String) {
        self.base64String = base64String
        self.cacheKey = cacheKey
    }

    // MARK: Protocol Conforming

    /// The key used in cache.
    var cacheKey: String

    func data(handler: (Result<Data, any Error>) -> Void) {
        let data = Data(base64Encoded: base64String)!
        handler(.success(data))
    }
}

/// Represents an image data provider for a raw data object.
struct RawImageDataProvider: ImageDataProvider {

    // MARK: Properties

    /// The raw data object to provide to Kingfisher image loader.
    let data: Data

    // MARK: Initializers

    /// Creates an image data provider by the given raw `data` value and a `cacheKey` be used in Kingfisher cache.
    ///
    /// - Parameters:
    ///   - data: The raw data represents an image.
    ///   - cacheKey: The key is used for caching the image data. You need a different key for any different image.
    init(data: Data, cacheKey: String) {
        self.data = data
        self.cacheKey = cacheKey
    }

    // MARK: Protocol Conforming
    
    /// The key used in cache.
    var cacheKey: String

    func data(handler: @escaping (Result<Data, any Error>) -> Void) {
        handler(.success(data))
    }
}
