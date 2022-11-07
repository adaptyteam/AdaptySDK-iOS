//
//  SKReceiptManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

final class SKReceiptManager: NSObject {
    private let queue: DispatchQueue
    private var completionHandlers: [ResultCompletion<Data>]?

    init(queue: DispatchQueue) {
        self.queue = queue
        super.init()
    }

    func prepare() { getReceipt(refreshIfEmpty: true) { _ in } }

    func getReceipt(refreshIfEmpty: Bool, _ completion: @escaping ResultCompletion<Data>) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

           let result = self.bundleReceipt()
                
            switch result {
            case .success:
                completion(result)
                return
            case .failure:
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
            Log.error("SKReceiptManager: Receipt Data did not loaded. \(error)")
            return .failure(SKManagerError.receiptIsEmpty(error).asAdaptyError)
        }

        if data.isEmpty {
            Log.error("SKReceiptManager: Receipt Data is empty")
            return .failure(SKManagerError.receiptIsEmpty().asAdaptyError)
        }

        Log.verbose("SKReceiptManager: Loaded receipt")
        return .success(data)
    }

    private func refresh(_ completion: @escaping ResultCompletion<Data>) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            if let handlers = self.completionHandlers {
                self.completionHandlers = handlers + [completion]
                return
            }

            self.completionHandlers = [completion]

            Log.verbose("SKReceiptManager: Start refresh receipt")
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()
        }
    }

    fileprivate func complatedRefresh(_ error: AdaptyError?) {
        queue.async { [weak self] in
            guard let self = self else { return }

            guard let handlers = self.completionHandlers, !handlers.isEmpty else {
                Log.error("SKReceiptManager: Not found completionHandlers")
                return
            }
            self.completionHandlers = nil

            let result: AdaptyResult<Data>
            if let error = error {
                Log.error("SKReceiptManager: Refresh receipt failed. \(error)")
                result = .failure(error)
            } else {
                Log.error("SKReceiptManager: Refresh receipt success.")
                result = self.bundleReceipt()
            }

            handlers.forEach { $0(result) }
        }
    }
}

extension SKReceiptManager: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        guard request is SKReceiptRefreshRequest else { return }
        complatedRefresh(nil)
        request.cancel()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard request is SKReceiptRefreshRequest else { return }
        complatedRefresh(SKManagerError.refreshReceiptFailed(error).asAdaptyError)
        request.cancel()
    }
}
