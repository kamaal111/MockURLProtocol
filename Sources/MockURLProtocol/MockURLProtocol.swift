//
//  MockURLProtocol.swift
//
//
//  Created by Kamaal M Farah on 23/04/2022.
//

import Foundation

public struct MockedResponse {
    public let data: Data
    public let statusCode: Int
    public let url: URL

    public init(data: Data, statusCode: Int, url: URL) {
        self.data = data
        self.statusCode = statusCode
        self.url = url
    }
}

public class MockURLProtocol: URLProtocol {
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    public static func makeRequests(with responses: [MockedResponse]) {
        var count = 0
        Self.requestHandler = { _ in
            let current = responses[count]
            let response = HTTPURLResponse(
                url: current.url,
                statusCode: current.statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            count += 1
            return (response, current.data)
        }
    }

    public static func makeRequest(withResponseData responseJSON: Data, statusCode: Int, url: URL) {
        Self.requestHandler = { _ in
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (response, responseJSON)
        }
    }

    public static func makeRequest(withResponseJSONString response: String, statusCode: Int, url: URL) {
        let data = response.data(using: .utf8)!
        makeRequest(withResponseData: data, statusCode: statusCode, url: url)
    }

    public static func makeRequest(withResponse response: some Encodable, statusCode: Int, url: URL) throws {
        let data = try JSONEncoder().encode(response)
        makeRequest(withResponseData: data, statusCode: statusCode, url: url)
    }

    override public class func canInit(with _: URLRequest) -> Bool { true }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override public func startLoading() {
        guard let handler = Self.requestHandler else { return }

        let (response, data): (HTTPURLResponse, Data?)
        do {
            (response, data) = try handler(request)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() { }
}
