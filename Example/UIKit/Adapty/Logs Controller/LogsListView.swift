//
//  LogsListView.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 01.11.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import SwiftUI
import Adapty

struct LogItemView: View {
    let item: LogItem

    @ViewBuilder func image() -> some View {
        switch item.level {
        case .error:
            Image(systemName: "xmark.octagon")
                .foregroundColor(.red)
        case .warn:
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
        case .info:
            Image(systemName: "checkmark.seal")
                .foregroundColor(.green)
        case .verbose:
            Image(systemName: "gearshape")
                .foregroundColor(.blue)
        case .debug:
            Image(systemName: "ladybug")
                .foregroundColor(.brown)
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            image()
                .padding(.top, 10.0)

            VStack(alignment: .leading) {
                Text(item.date.formatted(date: .omitted, time: .complete))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(item.message)
                    .font(.caption)
            }
        }
    }
}

struct LogsListView: View {
    @EnvironmentObject var observer: LogsObserver

    var body: some View {
        List {
            ForEach(observer.messages) {
                LogItemView(item: $0)
            }
        }
    }
}
