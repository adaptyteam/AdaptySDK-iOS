//
//  LogsObserver.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 01.11.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Foundation

struct LogItem: Identifiable {
    let level: Adapty.LogLevel
    let message: String
    let id = UUID().uuidString
    let date = Date()
}

class LogsObserver: ObservableObject {
    static let fileNameFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        return f
    }()
    
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return f
    }()
    
    static let shared = LogsObserver()
    
    @Published var messages = [LogItem]()
    
    func postMessage(_ level: Adapty.LogLevel, _ message: String) {
        let item = LogItem(level: level, message: message)
        
        DispatchQueue.main.async { [weak self] in
            self?.messages.append(item)
        }
    }
}

extension LogsObserver {
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveLogToFile() -> URL? {
        let logString = messages.map { "\(Self.formatter.string(from: $0.date)) \($0.message)" }.joined(separator: "\n")
        let filename = "adapty_log_\(Self.fileNameFormatter.string(from: Date())).log"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            try logString.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            return filePath
        } catch {
            return nil
        }
    }
}
