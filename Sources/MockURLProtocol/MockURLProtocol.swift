//
//  MockURLProtocol.swift
//
//
//  Created by Kamaal M Farah on 23/04/2022.
//

import Foundation

public class MockURLProtocol: URLProtocol {
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override public class func canInit(with _: URLRequest) -> Bool { true }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override public func startLoading() {
        let handler = MockURLProtocol.requestHandler!

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
