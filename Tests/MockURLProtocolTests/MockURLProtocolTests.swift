//
//  MockURLProtocolTests.swift
//
//
//  Created by Kamaal M Farah on 23/04/2022.
//

import XCTest
@testable import MockURLProtocol

final class MockURLProtocolTests: XCTestCase {
    var urlSession: URLSession!
    let url = URL(string: "https://kamaal.io")!

    override func setUp() async throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
    }

    func testMultipleResponses() async throws {
        let responses = [
            MockedResponse(data: #"{"message": "I should be first"}"#.data(using: .utf8)!, statusCode: 200, url: url),
            MockedResponse(data: #"{"message": "I should be second"}"#.data(using: .utf8)!, statusCode: 201, url: url),
            MockedResponse(data: #"{"message": "I should be third"}"#.data(using: .utf8)!, statusCode: 202, url: url),
        ]
        MockURLProtocol.makeRequests(with: responses)

        var receivedResponses: [(Data, HTTPURLResponse)] = []
        for _ in responses {
            let (data, response) = try await urlSession.data(from: url)
            let httpResonse = try XCTUnwrap(response as? HTTPURLResponse)
            receivedResponses.append((data, httpResonse))
        }

        XCTAssertEqual(receivedResponses.count, responses.count)
        for (index, (data, response)) in receivedResponses.enumerated() {
            XCTAssertEqual(response.statusCode, responses[index].statusCode)
            XCTAssertEqual(data, responses[index].data)
        }
    }

    func testMultipleURLSessions() async throws {
        let url1 = URL(string: "https://first.com")!
        let url2 = URL(string: "https://second.com")!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: self.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            var responseBody: String?
            if request.url == url1 {
                responseBody = """
                {
                    "details": "What what!"
                }
                """
            } else if request.url == url2 {
                responseBody = """
                {
                    "message": "So cool"
                }
                """
            }

            let data = responseBody?.data(using: .utf8)
            return (response, data)
        }

        async let (data1, _) = urlSession.data(from: url1)
        async let (data2, _) = urlSession.data(from: url2)

        let data = try await [data1, data2]

        let response1 = try XCTUnwrap(try JSONSerialization.jsonObject(with: data[0], options: []) as? [String: String])
        XCTAssertEqual(response1.count, 1)
        XCTAssertEqual(response1["details"], "What what!")

        let response2 = try XCTUnwrap(try JSONSerialization.jsonObject(with: data[1], options: []) as? [String: String])
        XCTAssertEqual(response2.count, 1)
        XCTAssertEqual(response2["message"], "So cool")

        XCTAssertTrue(true)
    }
}
