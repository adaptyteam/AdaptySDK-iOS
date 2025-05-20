//
//  ApplicationContentView.swift
//  OnboardingsDemo-SwiftUI
//
//  Created by Aleksey Goncharov on 05.08.2024.
//

import SwiftUI

struct ApplicationContentView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        List {
            Section {
                Button {
                    withAnimation {
                        viewModel.onboardingFinished = false
                    }
                } label: {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Welcome to Onboardings SDK!")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ApplicationContentView()
        .environmentObject(ViewModel())
}
