//
//  PremiumStuffView.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import SwiftUI

struct PremiumStuffView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.Palette.background.ignoresSafeArea()
            VStack {
                Spacer()
                Image.Gallery.diamond
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                Spacer()
            }.padding()
        }
    }
}

struct PremiumStuffView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumStuffView()
    }
}
