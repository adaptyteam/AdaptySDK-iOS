//
//  ApplicationSplashView.swift
//  OnboardingsDemo-SwiftUI
//
//  Created by Aleksey Goncharov on 06.08.2024.
//

import SwiftUI

struct ApplicationSplashView: View {
    var body: some View {
        ZStack {
            Color.white

            VStack(spacing: 32) {
                Image("SplashIcon")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .alignmentGuide(VerticalAlignment.center) { dimension in
                        dimension[VerticalAlignment.bottom]
                    }

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accent))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    ApplicationSplashView()
}
