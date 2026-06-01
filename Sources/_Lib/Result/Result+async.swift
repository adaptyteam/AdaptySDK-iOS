//
//  Result+async.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2025.
//

package extension Result {
    @inlinable
    static func from(_ body: sending @escaping @isolated(any) () async throws(Failure) -> Success) async -> Self where Success: Sendable {
        do throws(Failure) {
            return try await .success(body())
        } catch {
            return .failure(error)
        }
    }
}
