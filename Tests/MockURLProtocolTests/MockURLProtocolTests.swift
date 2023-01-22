//
//  MockURLProtocolTests.swift
//
//
//  Created by Kamaal M Farah on 23/04/2022.
//

import XCTest
@testable import MockURLProtocol

final class MockURLProtocolTests: XCTestCase {
    func testMultipleURLSessions() async throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        let url1 = URL(string: "https://first.com")!
        let url2 = URL(string: "https://second.com")!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "https://kamaal.io")!,
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
