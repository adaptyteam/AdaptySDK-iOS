//
//  StoreKitMessageManager.swift
//  AdaptySDK
//

import Foundation
import StoreKit

#if os(iOS) || os(visionOS)
@available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
actor StoreKitMessageManager {
    typealias DisplayAction<M: Sendable> = @MainActor @Sendable (M) throws -> Void
    typealias ErrorHandler = @Sendable (AdaptyStoreMessageType, any Error) -> Void

    enum DisplayError: Error {
        case cancelled
        case sceneUnavailable
    }

    private var task: Task<Void, Never>?
    private let errorHandler: ErrorHandler

    private var pending: [StoreKit.Message] = []
    private var isShowing = false

    init(
        errorHandler: @escaping ErrorHandler = logError
    ) async {
        self.errorHandler = errorHandler
        task = nil
        task = Task {
            for await message in StoreKit.Message.messages {
                enqueue(message)
            }
        }
    }

    deinit {
        task?.cancel()
    }

    private func enqueue(_ message: StoreKit.Message) {
        guard !pending.contains(message) else { return }
        pending.append(message)
    }

    func pendingTypes() -> Set<AdaptyStoreMessageType> {
        Set(pending.map { message in
            AdaptyStoreMessageType(message.reason)
        })
    }

    func show(
        matching filter: Set<AdaptyStoreMessageType>?,
        display: @escaping DisplayAction<StoreKit.Message>
    ) async throws(AdaptyError) {
        let selection =
            if let filter {
                pending.filter { message in
                    filter.contains(AdaptyStoreMessageType(message.reason))
                }
            } else {
                pending
            }

        guard !selection.isEmpty else { return }
        guard !isShowing else { throw .storeMessageShowInProgress() }

        isShowing = true
        defer { isShowing = false }

        for message in selection {
            guard !Task.isCancelled else { throw .taskCancelled() }

            let performDisplay: @MainActor @Sendable () throws -> Void = {
                guard !Task.isCancelled else { throw DisplayError.cancelled }
                try display(message)
            }

            do {
                try await performDisplay()
                pending.removeAll { $0 == message }
            } catch DisplayError.cancelled {
                throw .taskCancelled()
            } catch DisplayError.sceneUnavailable {
                throw .storeMessageSceneUnavailable()
            } catch {
                errorHandler(AdaptyStoreMessageType(message.reason), error)
            }
        }
    }

    private nonisolated static func logError(
        type: AdaptyStoreMessageType,
        error: any Error
    ) {
        let nsError = error as NSError
        Log.storeMessages.error("Store message display failed. type: \(type.rawValue), domain: \(nsError.domain), code: \(nsError.code), description: \(nsError.localizedDescription)")
    }
}

#endif
