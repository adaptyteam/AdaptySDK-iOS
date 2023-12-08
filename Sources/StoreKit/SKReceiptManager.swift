//
//  SKReceiptManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

final class SKReceiptManager: NSObject {
    private let queue: DispatchQueue
    private var refreshCompletionHandlers: [AdaptyResultCompletion<Data>]?
    private var validateCompletionHandlers: [AdaptyResultCompletion<VH<AdaptyProfile>>]?

    private let storage: ProfileStorage
    private let session: HTTPSession

    init(queue: DispatchQueue, storage: ProfileStorage, backend: Backend) {
        self.queue = queue
        session = backend.createHTTPSession(responseQueue: queue)
        self.storage = storage
        super.init()
    }

    func validateReceipt(refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            if let handlers = self.validateCompletionHandlers {
                self.validateCompletionHandlers = handlers + [completion]
                Log.debug("SKReceiptManager: Add handler to validateCompletionHandlers.count = \(self.validateCompletionHandlers?.count ?? 0)")

                return
            }
            self.validateCompletionHandlers = [completion]

            Log.debug("SKReceiptManager: Start validateReceipt validateCompletionHandlers.count = \(self.validateCompletionHandlers?.count ?? 0)")

            self.getReceipt(refreshIfEmpty: refreshIfEmpty) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    completedValidate(.failure(error))
                case let .success(receipt):
                    self.session.performValidateReceiptRequest(profileId: self.storage.profileId,
                                                               receipt: receipt,
                                                               completedValidate)
                }
            }
        }

        func completedValidate(_ result: AdaptyResult<VH<AdaptyProfile>>) {
            guard let handlers = validateCompletionHandlers, !handlers.isEmpty else {
                Log.error("SKReceiptManager: Not found validateCompletionHandlers")
                return
            }
            validateCompletionHandlers = nil
            Log.debug("SKReceiptManager: Call validateCompletionHandlers.count = \(handlers.count) with result = \(result)")

            handlers.forEach { $0(result) }
        }
    }

    func refreshReceiptIfEmpty() { getReceipt(refreshIfEmpty: true) { _ in } }

    func getReceipt(refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<Data>) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            let logName = "get_receipt"
            let stamp = Log.stamp
            Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: logName, callId: stamp, params: ["refresh_if_empty": .value(refreshIfEmpty)]))
            let result = self.bundleReceipt()

            switch result {
            case .success:
                Adapty.logSystemEvent(AdaptyAppleResponseParameters(methodName: logName, callId: stamp))
                completion(result)
                return
            case let .failure(error):
                Adapty.logSystemEvent(AdaptyAppleResponseParameters(methodName: logName, callId: stamp, error: error.description))
                if refreshIfEmpty {
                    self.refresh(completion)
                } else {
                    completion(result)
                    self.refresh { _ in }
                }
            }
        }
    }

    private func bundleReceipt() -> AdaptyResult<Data> {
        guard let url = Bundle.main.appStoreReceiptURL else {
            Log.error("SKReceiptManager: Receipt URL is nil.")
            return .failure(SKManagerError.receiptIsEmpty().asAdaptyError)
        }

        var data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            Log.error("SKReceiptManager: The receipt data failed to load. \(error)")
            return .failure(SKManagerError.receiptIsEmpty(error).asAdaptyError)
        }

        if data.isEmpty {
            Log.error("SKReceiptManager: The receipt data is empty.")
            return .failure(SKManagerError.receiptIsEmpty().asAdaptyError)
        }

        Log.verbose("SKReceiptManager: Loaded receipt")
        return .success(data)
    }

    private func refresh(_ completion: @escaping AdaptyResultCompletion<Data>) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            if let handlers = self.refreshCompletionHandlers {
                self.refreshCompletionHandlers = handlers + [completion]
                Log.debug("SKReceiptManager: Add handler to refreshCompletionHandlers.count = \(self.refreshCompletionHandlers?.count ?? 0)")

                return
            }

            self.refreshCompletionHandlers = [completion]

            Log.verbose("SKReceiptManager: Start refresh receipt")
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()

            Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: "refresh_receipt", callId: "SKR\(request.hash)"))
        }
    }

    fileprivate func completedRefresh(_ request: SKRequest, _ error: AdaptyError? = nil) {
        queue.async { [weak self] in

            Adapty.logSystemEvent(AdaptyAppleResponseParameters(methodName: "refresh_receipt", callId: "SKR\(request.hash)", error: error?.description))

            guard let self = self else { return }

            guard let handlers = self.refreshCompletionHandlers, !handlers.isEmpty else {
                Log.error("SKReceiptManager: Not found refreshCompletionHandlers")
                return
            }
            self.refreshCompletionHandlers = nil

            let result: AdaptyResult<Data>
            if let error = error {
                Log.error("SKReceiptManager: Refresh receipt failed. \(error)")
                result = .failure(error)
            } else {
                Log.verbose("SKReceiptManager: Refresh receipt success.")
                result = self.bundleReceipt()
            }

            Log.debug("SKReceiptManager: Call refreshCompletionHandlers.count = \(handlers.count) with result = \(result)")

            handlers.forEach { $0(result) }
        }
    }
}

extension SKReceiptManager: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        guard request is SKReceiptRefreshRequest else { return }
        completedRefresh(request)
        request.cancel()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard request is SKReceiptRefreshRequest else { return }
        completedRefresh(request, SKManagerError.refreshReceiptFailed(error).asAdaptyError)
        request.cancel()
    }
}
