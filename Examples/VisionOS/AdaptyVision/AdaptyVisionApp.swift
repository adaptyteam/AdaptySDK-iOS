//
//  AdaptyVisionApp.swift
//  AdaptyVision
//
//  Created by Aleksey Goncharov on 23.1.24..
//

import SwiftUI
import Adapty

@main
struct AdaptyVisionApp: App {
    init() {
        Adapty.activate("public_live_iNuUlSsN.83zcTTR8D5Y8FI9cGUI6")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
