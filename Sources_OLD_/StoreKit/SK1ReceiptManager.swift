//
//  SK1ReceiptManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

private let log = Log.Category(name: "SK1ReceiptManager")

final class SK1ReceiptManager: NSObject {
    private let queue: DispatchQueue
    private var refreshCompletionHandlers: [AdaptyResultCompletion<Data>]?
    private var validateCompletionHandlers: [AdaptyResultCompletion<VH<AdaptyProfile>>]?

    private let storage: ProfileIdentifierStorage
    private let session: HTTPSession

    init(queue: DispatchQueue, storage: ProfileIdentifierStorage, backend: Backend, refreshIfEmpty: Bool) {
        self.queue = queue
        session = backend.createHTTPSession(responseQueue: queue)
        self.storage = storage
        super.init()
        if refreshIfEmpty {
            getReceipt(refreshIfEmpty: true) { _ in }
        }
    }

    func validateReceipt(refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        queue.async { [weak self] in
            guard let self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            if let handlers = self.validateCompletionHandlers {
                self.validateCompletionHandlers = handlers + [completion]
                log.debug("Add handler to validateCompletionHandlers.count = \(self.validateCompletionHandlers?.count ?? 0)")

                return
            }
            self.validateCompletionHandlers = [completion]

            log.debug("Start validateReceipt validateCompletionHandlers.count = \(self.validateCompletionHandlers?.count ?? 0)")

            self.getReceipt(refreshIfEmpty: refreshIfEmpty) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .failure(error):
                    completedValidate(.failure(error))
                case let .success(receipt):
                    self.session.performValidateReceiptRequest(
                        profileId: self.storage.profileId,
                        receipt: receipt,
                        completedValidate
                    )
                }
            }
        }

        func completedValidate(_ result: AdaptyResult<VH<AdaptyProfile>>) {
            guard let handlers = validateCompletionHandlers, !handlers.isEmpty else {
                log.error("Not found validateCompletionHandlers")
                return
            }
            validateCompletionHandlers = nil
            log.debug("Call validateCompletionHandlers.count = \(handlers.count) with result = \(result)")

            handlers.forEach { $0(result) }
        }
    }

    func getReceipt(refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<Data>) {
        queue.async { [weak self] in
            guard let self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            let logName = "get_receipt"
            let stamp = Log.stamp
            Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: logName, stamp: stamp, params: ["refresh_if_empty": refreshIfEmpty]))
            let result = self.bundleReceipt()

            switch result {
            case .success:
                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: logName, stamp: stamp))
                completion(result)
                return
            case let .failure(error):
                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: logName, stamp: stamp, error: error.description))
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
            log.error("Receipt URL is nil.")
            return .failure(SKManagerError.receiptIsEmpty().asAdaptyError)
        }

        var data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            log.error("The receipt data failed to load. \(error)")
            return .failure(SKManagerError.receiptIsEmpty(error).asAdaptyError)
        }

        if data.isEmpty {
            log.error("The receipt data is empty.")
            return .failure(SKManagerError.receiptIsEmpty().asAdaptyError)
        }

        log.verbose("Loaded receipt")
        return .success(data)
    }

    private func refresh(_ completion: @escaping AdaptyResultCompletion<Data>) {
        queue.async { [weak self] in
            guard let self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            if let handlers = self.refreshCompletionHandlers {
                self.refreshCompletionHandlers = handlers + [completion]
                log.debug("Add handler to refreshCompletionHandlers.count = \(self.refreshCompletionHandlers?.count ?? 0)")

                return
            }

            self.refreshCompletionHandlers = [completion]

            log.verbose("Start refresh receipt")
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()

            Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: "refresh_receipt", stamp: "SKR\(request.hash)"))
        }
    }

    fileprivate func completedRefresh(_ request: SKRequest, _ error: AdaptyError? = nil) {
        queue.async { [weak self] in

            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: "refresh_receipt", stamp: "SKR\(request.hash)", error: error?.description))

            guard let self else { return }

            guard let handlers = self.refreshCompletionHandlers, !handlers.isEmpty else {
                log.error("Not found refreshCompletionHandlers")
                return
            }
            self.refreshCompletionHandlers = nil

            let result: AdaptyResult<Data>
            if let error {
                log.error("Refresh receipt failed. \(error)")
                result = .failure(error)
            } else {
                log.verbose("Refresh receipt success.")
                result = self.bundleReceipt()
            }

            log.debug("Call refreshCompletionHandlers.count = \(handlers.count) with result = \(result)")

            handlers.forEach { $0(result) }
        }
    }
}

extension SK1ReceiptManager: SKRequestDelegate {
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
