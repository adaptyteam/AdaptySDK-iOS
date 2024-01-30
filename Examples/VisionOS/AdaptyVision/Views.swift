//
//  Views.swift
//  AdaptyVision
//
//  Created by Aleksey Goncharov on 23.1.24..
//

import SwiftUI

struct ListItemView: View {
    let title: String
    let subtitle: String?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let subtitle = subtitle {
                Text(subtitle)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ListSelectedItemView: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ListStatusItemView: View {
    enum State {
        case loading
        case success
        case failure
    }

    let title: String
    let state: State
    let expanded: Bool?
    var action: (() -> Void)?

    var body: some View {
        Button(action: action ?? {}) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 8.0)
                switch state {
                case .loading:
                    ProgressView()
                case .success:
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                case .failure:
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                }

                Spacer()

                if let expanded = expanded {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                }
            }
        }
    }
}
