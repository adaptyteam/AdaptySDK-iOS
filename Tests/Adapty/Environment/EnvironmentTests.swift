//
//  EnvironmentTests.swift
//  AdaptyTests
//
//  Created by OpenAI on 05.08.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

@Suite(
    "Environment Tests",
    .component("Environment"),
    .owner("Aleksei Valiano"),
    .risk(.critical),
    .layer(.unit)
)
enum EnvironmentTests {
    struct EnvironmentApplicationTests {
        @Test func readsMinimumOSVersionFromMainBundle() {
            let key: String
            #if os(macOS) || targetEnvironment(macCatalyst)
            key = "LSMinimumSystemVersion"
            #else
            key = "MinimumOSVersion"
            #endif

            let expected = Bundle.main.infoDictionary?[key] as? String
            #expect(Environment.Application.minimumOSVersion == expected)
        }

        @Test func environmentSnapshotPreservesMinimumOSVersion() {
            let environment = makeEnvironment(minimumOSVersion: "15.0")

            #expect(environment.application.minimumOSVersion == "15.0")
        }

        @Test func environmentSnapshotPreservesMissingMinimumOSVersion() {
            let environment = makeEnvironment(minimumOSVersion: nil)

            #expect(environment.application.minimumOSVersion == nil)
        }
    }

    @Suite(.serialized)
    struct EnvironmentMetaTests {
        @Test func encodesMinimumOSVersion() async throws {
            let meta = await makeEnvironmentMeta(minimumOSVersion: "15.0")
            let object = try encodedObject(meta)

            #expect(object["app_minimum_os_version"] as? String == "15.0")
            #expect(object["app_version"] as? String == "4.2.0")
            #expect(object["app_build"] as? String == "105")
            #expect(object["platform"] as? String == "testOS")
        }

        @Test func omitsMissingMinimumOSVersion() async throws {
            let meta = await makeEnvironmentMeta(minimumOSVersion: nil)
            let object = try encodedObject(meta)

            #expect(object["app_minimum_os_version"] == nil)
        }

        @Test func createProfileRequiresEnvironmentMetaWithMinimumOSVersion() async throws {
            let harness = await ProfileRequestHarness()
            let environmentMeta = await makeEnvironmentMeta(minimumOSVersion: "15.0")

            await #expect(throws: HTTPError.self) {
                _ = try await harness.executor.createProfile(
                    userId: userId,
                    appAccountToken: nil,
                    parameters: nil,
                    environmentMeta: environmentMeta
                )
            }

            let request = try #require(harness.capturedRequest.value)
            let attributes = try encodedAttributes(request)
            let installationMeta = try #require(attributes["installation_meta"] as? [String: Any])

            #expect(request.httpMethod == "POST")
            #expect(request.url?.path == "/sdk/analytics/profiles/profile-id")
            #expect(installationMeta["app_minimum_os_version"] as? String == "15.0")
        }

        @Test func updateProfileIncludesEnvironmentMetaWithMinimumOSVersion() async throws {
            let harness = await ProfileRequestHarness()
            let environmentMeta = await makeEnvironmentMeta(minimumOSVersion: "12.0")

            await #expect(throws: HTTPError.self) {
                _ = try await harness.executor.updateProfile(
                    userId: userId,
                    parameters: nil,
                    environmentMeta: environmentMeta,
                    responseHash: nil
                )
            }

            let request = try #require(harness.capturedRequest.value)
            let attributes = try encodedAttributes(request)
            let installationMeta = try #require(attributes["installation_meta"] as? [String: Any])

            #expect(request.httpMethod == "PATCH")
            #expect(request.url?.path == "/sdk/analytics/profiles/profile-id")
            #expect(installationMeta["app_minimum_os_version"] as? String == "12.0")
        }

        @Test func profileRequestsOmitMissingMinimumOSVersion() async throws {
            let environmentMeta = await makeEnvironmentMeta(minimumOSVersion: nil)
            let createHarness = await ProfileRequestHarness()
            await #expect(throws: HTTPError.self) {
                _ = try await createHarness.executor.createProfile(
                    userId: userId,
                    appAccountToken: nil,
                    parameters: nil,
                    environmentMeta: environmentMeta
                )
            }

            let updateHarness = await ProfileRequestHarness()
            await #expect(throws: HTTPError.self) {
                _ = try await updateHarness.executor.updateProfile(
                    userId: userId,
                    parameters: nil,
                    environmentMeta: environmentMeta,
                    responseHash: nil
                )
            }

            let requests = try [
                #require(createHarness.capturedRequest.value),
                #require(updateHarness.capturedRequest.value),
            ]
            for attributes in try requests.map(encodedAttributes) {
                let installationMeta = try #require(attributes["installation_meta"] as? [String: Any])
                #expect(installationMeta["app_minimum_os_version"] == nil)
            }
        }

        @Test func updateProfileDoesNotRequireEnvironmentMeta() async throws {
            let harness = await ProfileRequestHarness()

            await #expect(throws: HTTPError.self) {
                _ = try await harness.executor.updateProfile(
                    userId: userId,
                    parameters: nil,
                    environmentMeta: nil,
                    responseHash: nil
                )
            }

            let request = try #require(harness.capturedRequest.value)
            let attributes = try encodedAttributes(request)

            #expect(attributes["installation_meta"] == nil)
        }

        private var userId: AdaptyUserId {
            AdaptyUserId(profileId: "profile-id", customerId: nil)
        }

        private func encodedAttributes(_ request: URLRequest) throws -> [String: Any] {
            let body = try #require(request.httpBody)
            let root = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
            let data = try #require(root["data"] as? [String: Any])
            return try #require(data["attributes"] as? [String: Any])
        }
    }

    private struct ProfileRequestHarness {
        let executor: Backend.MainExecutor
        let capturedRequest: CapturedURLRequest

        @BackendActor
        init() {
            let environment = makeEnvironment(minimumOSVersion: nil)
            let configuration = AdaptyConfiguration
                .builder(withAPIKey: "public_live_0000000000000000000000000000000000000000")
                .with(backendBaseUrl: URL(string: "https://example.com")!)
                .build()
            let httpConfiguration = MainHTTPConfiguration(with: configuration, environment: environment)
            let capturedRequest = CapturedURLRequest()

            executor = Backend.MainExecutor(
                manager: Backend.StateManager(with: configuration),
                session: HTTPSession(
                    configuration: httpConfiguration,
                    requestSign: { request, _ in
                        capturedRequest.record(request)
                        throw StopAfterCapturingRequest()
                    }
                )
            )
            self.capturedRequest = capturedRequest
        }
    }

    private final class CapturedURLRequest: @unchecked Sendable {
        private let lock = NSLock()
        private var _value: URLRequest?

        var value: URLRequest? {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }

        func record(_ request: URLRequest) {
            lock.lock()
            defer { lock.unlock() }
            _value = request
        }
    }

    private struct StopAfterCapturingRequest: Error {}

    private static func makeEnvironment(minimumOSVersion: String?) -> Environment {
        Environment(
            application: (
                installationIdentifier: "installation-id",
                version: "4.2.0",
                build: "105",
                minimumOSVersion: minimumOSVersion
            ),
            system: (name: "testOS", version: "1.0"),
            sessionIdentifier: "session-id"
        )
    }

    @AdaptyActor
    private static func makeEnvironmentMeta(minimumOSVersion: String?) async -> Environment.Meta {
        let instance = await Environment.instance
        Environment._instance = makeEnvironment(minimumOSVersion: minimumOSVersion)
        defer { Environment._instance = instance }
        return await Environment.Meta(includedAnalyticIds: false)
    }

    private static func encodedObject(_ value: some Encodable) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
#endif
