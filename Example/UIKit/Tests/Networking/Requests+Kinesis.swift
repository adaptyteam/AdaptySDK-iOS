//
//  Requests+Kinesis.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 11.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_Kinesis: XCTestCase {
    func test_FetchKinesisCredentialsRequest() throws {
        let (_, session) = Tester.createBackendAndSession(id: "kinesis")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        Tester.fetchKinesisCredentials(session, profileId: profileId) { result in
            expectation.fulfill()

            switch result {
            case let .success(creds):
                XCTAssertFalse(creds.accessKeyId.isEmpty)
                XCTAssertFalse(creds.secretSigningKey.isEmpty)
                XCTAssertFalse(creds.sessionToken.isEmpty)
                XCTAssertFalse(creds.expiration < Date())
            case let .failure(error):
                XCTAssert(false, error.localizedDescription)
            }
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_FetchKinesisCredentialsRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: "kinesis_bad", secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchKinesisCredentialsRequest(profileId: profileId)
        session.perform(request) { (result: FetchKinesisCredentialsRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func generateEvents(profileId: String) throws -> [Data] {
        [
            try Event(type: .appOpened, profileId: profileId).encodeToData(),
            try Event(type: .paywallShowed(PaywallShowedParameters(variationId: "test_variation_id")), profileId: profileId).encodeToData(),
            try Event(type: .onboardingScreenShowed(OnboardingScreenParameters(name: "test_name", screenName: "test_screen", screenOrder: 0)), profileId: profileId).encodeToData(),
        ]
    }
    
    func test_SendKinesisEvent_withWrongCredentials() throws {

        let kinesisCredentials = KinesisCredentials(
            accessKeyId: "ASIAXAX3IHK7PF3666IT",
            secretSigningKey: "1ZfqDgBilSAfw42TUTTBOF84SOHw2r1tXSYv1iM+",
            sessionToken: "IQoJb3JpZ2luX2VjEIL//////////wEaCXVzLWVhc3QtMSJHMEUCIQCEFy/421Zq5OMq7ONz0Vi3BX4Ryg2Eyhz+xqcRoSr7VAIgNV2Oep8sRuylpd2tkETe/qhSrvWy/NSGjAy1UsvO0GsqlwQIWxACGgw0ODI2MzcwMDM0NTQiDJczjtzGY8cThb+e2ir0A1tayD18HWg3vn/Os2UypO/sR1ubdcuQAdCrEt3CmFxxLRN9TlV2xBKfVRdCQZth3xkscjVWu5uJqj8CglP0f0OqEHD848onsQd50TDQNerGcUWDr+6UDbBMh4Zdqrh6Z6Ca9QHchG1neqzR6Zx5Abbwhu6IydXa+i8OUGHh7NMcBGfV7s3kLreFa07eAdlz1OeYveAC15O2Mw4ZtAa7dUehxR8h4bePV2F9EKTUoK69VQCf/5FQRKrrTmmw2PVIDhXeG5ZJA+VKcJtcpaVagv7TFtzRaPLs0FI5mrZwgyNDDfYa59bBQuK7C6nCtjXq9w/H3lBedTLDBRKlZivyVVmx6QnwgtZ37Ibagy+di57gY/HIw0x6ZOiCH9IE4OsqOgb7mPvU5pBkXvb3Iq0+Ft5RPLYWQEbJDFAUWNCdlL4lvZaPLDCT1+jaczp32R0xnXD3OEjxISKVwfgomTGPf7iV+/WZC4dkjouY7fxTLx+fWJ7KmtoG7wAV98LTd6xIAnrTmW1l7TigzShgdIYs05jOvM7tjaLIjlk0ERzhaW8KpMYBS4yIDnFp9ttPgOJJh6Plfb+ZUAwZYHmRSKS2LOsRAxY5DunSmBvXoa75Fm1BH4gEMr7dv3eNve8B6RQiyjJOkd/vyAn8vR6Bgf+ja54e4afyML64xJoGOoUC4VTfmrM1Ryh4SvAbLDWOI408sXajNI3iu/UzpsMu/jrP/qkj91xQMdWgzTZ66IDttI9EBCOK6D4I4Yd6hIpC/dFy8f8evS0pqe9VDdW8/U+9SSv8AGxxgjYzNmLbk+lD31mgkipUn1zJZu+Ty6q9BTcdWUDw2UHE4Heiq/X+V53J4aMN6f8T1aeV0KqxjueYxNeFxi8O75jlEQs5jua00uNExMFw9C+JyCxEDbP0QlcIxhBBOPC8eKK/Kf6D8Uj21A12ln8vFFijS5zfvzJnDDG6SYuJIYW/qsc9S/ehezTWt9E1KihIGubUAj082lGmvOcuHt4DxNiCMqmtS/VzCz2C7vxJ",
            expiration: Date() + 120.0)
    
        let kinesis = Kinesis(credentials: kinesisCredentials)
        
        
        let expectationSendEvents = expectation(description: "Wait for send events to Kinesis")
        let kinesisSession = kinesis.createHTTPSession(responseQueue: .main) { error in
            print("#EVENTS# Error \(error)")
        }

        let profileId = UUID().uuidString.lowercased()
        let request = SendEventsRequest(events: try generateEvents(profileId: profileId), streamName: Kinesis.Configuration.publicStreamName)

        kinesisSession.perform(request) { (result: SendEventsRequest.Result) in
            expectationSendEvents.fulfill()
            HTTPAssertResponseFailed(result, 400)
        }
        
        wait(for: [expectationSendEvents], timeout: TestsConstants.timeoutInterval)

    }
    
    func test_SendKinesisEvent() throws {
        let (_, session) = Tester.createBackendAndSession(id: "kinesis")
        let profileId = UUID().uuidString.lowercased()
        let expectationKinesisCredentials = expectation(description: "Wait for fetch Kinesis credentials")

        var kinesisCredentials : KinesisCredentials?
        Tester.fetchKinesisCredentials(session, profileId: profileId) { result in
            expectationKinesisCredentials.fulfill()
            switch result {
            case let .success(creds):
                kinesisCredentials = creds
            case .failure:
                XCTFail("Fetching Kinesis Credentials Failed")
            }
        }

        wait(for: [expectationKinesisCredentials], timeout: TestsConstants.timeoutInterval)
        guard let kinesis = kinesisCredentials == nil ? nil : Kinesis(credentials: kinesisCredentials) else {
            XCTFail("Kinesis Credentials is nil")
            return
        }
        
        let expectationSendEvents = expectation(description: "Wait for send events to Kinesis")
        let kinesisSession = kinesis.createHTTPSession(responseQueue: .main) { error in
            print("#EVENTS# Error \(error)")
        }

        let request = SendEventsRequest(events: try generateEvents(profileId: profileId), streamName: Kinesis.Configuration.publicStreamName)

        kinesisSession.perform(request) { (result: SendEventsRequest.Result) in
            expectationSendEvents.fulfill()
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Sending Kinesis Event Failed")
            }
        }
        
        wait(for: [expectationSendEvents], timeout: TestsConstants.timeoutInterval)

    }
}
