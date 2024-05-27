//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 21.05.2024.
//

#if DEBUG

@testable import Adapty
import Foundation

@available(iOS 15.0, *)
extension AdaptyUI.ImageData {
    static var urlDog: Self {
        .url(URL(string: "https://media.istockphoto.com/id/1411469044/photo/brown-dog-beagle-sitting-on-path-in-autumn-natural-park-location-among-orange-yellow-fallen.jpg?s=612x612&w=0&k=20&c=Ul6dwTVshdIYOACMbUEbA0WDiNbbTamtXL5GOL0KKK0=")!,
             previewRaster: nil)
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Image {
    static var test: Self {
        .init(asset: .urlDog,
              aspect: .fit,
              tint: nil)
    }

    static var testFill: Self {
        .init(asset: .urlDog,
              aspect: .fill,
              tint: nil)
    }
}

#endif
