//
//  Task+Result.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.10.2025.
//


package typealias AdaptyResultTask<Success> = Task<AdaptyResult<Success>, Never>

//#if swift(>=6.3)
//package extension Task {
//    @inlinable
//    static func withThrowsTyped<T, E: Error>(
//        priority: TaskPriority? = nil,
//        adaptyResult operation: sending @escaping @isolated(any) () async throws(E) -> T
//    ) -> Task<T, E> where Success == T, Failure == E {
//        Task<T, E>(priority: priority, operation: operation)
//    }
//
//    @inlinable
//    static func detachedWithThrowsTyped<T, E: Error>(
//        priority: TaskPriority? = nil,
//        adaptyResult operation: sending @escaping @isolated(any) () async throws(E) -> T
//    ) -> Task<T, E> where Success == T, Failure == E {
//        Task<T, E>.detached(priority: priority, operation: operation)
//    }
//
//    @inlinable
//    func valueWithThrowsTyped() async throws(Failure) -> Success {
//        try await value
//    }
//}
//#else

package extension Task where Failure == Never {
    @inlinable
    static func withThrowsTyped<T, E: Error>(
        priority: TaskPriority? = nil,
        adaptyResult operation: sending @escaping @isolated(any) () async throws(E) -> T
    ) -> Task<Result<T, E>, Never> where Success == Result<T, E> {
        Task<Result<T, E>, Never>(priority: priority, operation: {
            do throws(E) {
                return try await .success(operation())
            } catch {
                return .failure(error)
            }
        })
    }

    @inlinable
    static func detachedWithThrowsTyped<T, E: Error>(
        priority: TaskPriority? = nil,
        adaptyResult operation: sending @escaping @isolated(any) () async throws(E) -> T
    ) -> Task<Result<T, E>, Never> where Success == Result<T, E> {
        Task<Result<T, E>, Never>.detached(priority: priority, operation: {
            do throws(E) {
                return try await .success(operation())
            } catch {
                return .failure(error)
            }
        })
    }

    @inlinable
    func valueWithThrowsTyped<T, E: Error>() async throws(E) -> T
        where Success == Result<T, E>
    {
        try await value.get()
    }
}
//#endif

