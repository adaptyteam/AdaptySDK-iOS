//
//  AdaptyVisionApp.swift
//  AdaptyVision
//
//  Created by Aleksey Goncharov on 23.1.24..
//

import SwiftUI

@main
struct AdaptyVisionApp: App {
    let vm = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
    }
}
