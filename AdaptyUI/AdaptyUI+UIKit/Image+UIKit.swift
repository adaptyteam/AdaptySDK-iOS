//
//  Image+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 13.0, *)
extension UIImageView {
    func setImage(_ img: AdaptyUI.ImageData,
                  renderingMode: UIImage.RenderingMode = .automatic) {
        switch img {
        case .none:
            break
        case let .raster(data):
            image = UIImage(data: data)?.withRenderingMode(renderingMode)
        case let .resorces(name):
            image = UIImage(named: name)?.withRenderingMode(renderingMode)
        case let .url(url, previewData):
            let previewImage: UIImage? = if let previewData { UIImage(data: previewData) } else { nil }

            let logId = AdaptyUI.generateLogId()

            AdaptyUI.writeLog(level: .verbose, message: "#AdaptyMediaCache# setImage START (\(url)) [\(logId)]")

            kf.setImage(
                with: .network(url),
                placeholder: previewImage?.withRenderingMode(renderingMode),
                options: [
                    .targetCache(AdaptyUI.imageCache),
                    .downloader(AdaptyUI.imageDownloader),
                    .imageModifier(RenderingModeImageModifier(renderingMode: renderingMode)),
                ],
                completionHandler: { result in
                    switch result {
                    case let .success(imgResult):
                        AdaptyUI.writeLog(level: .verbose, message: "#AdaptyMediaCache# setImage SUCCESS, cacheType = \(imgResult.cacheType) [\(logId)]")
                    case let .failure(error):
                        AdaptyUI.writeLog(level: .error, message: "#AdaptyMediaCache# setImage ERROR: \(error) [\(logId)]")
                    }
                }
            )
        }
    }
}

@available(iOS 13.0, *)
extension UIButton {
    func setBackgroundImage(_ img: AdaptyUI.ImageData,
                            for state: UIControl.State,
                            renderingMode: UIImage.RenderingMode = .automatic) {
        switch img {
        case .none:
            break
        case let .raster(data):
            setBackgroundImage(UIImage(data: data), for: state)
        case let .resorces(name):
            setBackgroundImage(UIImage(named: name), for: state)
        case let .url(url, previewData):
            let previewImage: UIImage? = if let previewData { UIImage(data: previewData) } else { nil }

            let logId = AdaptyUI.generateLogId()

            AdaptyUI.writeLog(level: .verbose, message: "#AdaptyMediaCache# setBackgroundImage START (\(url)) [\(logId)]")

            kf.setBackgroundImage(
                with: .network(url),
                for: state,
                placeholder: previewImage?.withRenderingMode(renderingMode),
                options: [
                    .targetCache(AdaptyUI.imageCache),
                    .downloader(AdaptyUI.imageDownloader),
                    .imageModifier(RenderingModeImageModifier(renderingMode: renderingMode)),
                ],
                completionHandler: { result in
                    switch result {
                    case let .success(imgResult):
                        AdaptyUI.writeLog(level: .verbose, message: "#AdaptyMediaCache# setBackgroundImage SUCCESS, cacheType = \(imgResult.cacheType) [\(logId)]")
                    case let .failure(error):
                        AdaptyUI.writeLog(level: .error, message: "#AdaptyMediaCache# setBackgroundImage ERROR: \(error) [\(logId)]")
                    }
                }
            )
        }
    }
}

#endif
