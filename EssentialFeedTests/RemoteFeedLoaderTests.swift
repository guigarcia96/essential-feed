//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Guilherme Garcia on 10/08/24.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(requestedURL: URL) {
        client.get(from: requestedURL)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        // MARK: - GIVEN
        let client = HTTPClientSpy()
        let url: URL = URL(string: "https://gui.com")!
        let sut = RemoteFeedLoader(client: client)
        
        // MARK: - WHEN
        sut.load(requestedURL: url)
        
        // MARK: - THEN
        XCTAssertNotNil(client.requestedURL)
    }
}
