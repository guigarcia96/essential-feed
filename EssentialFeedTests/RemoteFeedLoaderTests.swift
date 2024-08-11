//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Guilherme Garcia on 10/08/24.
//

import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        // MARK: - GIVEN
        let (sut, client, spyURL) = makeSUT()
        
        // MARK: - WHEN
        sut.load(requestedURL: spyURL)
        
        // MARK: - THEN
        XCTAssertEqual(client.requestedURL, spyURL)
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // MARK: - GIVEN
        let (sut, client, spyURL) = makeSUT()
        
        // MARK: - WHEN
        sut.load(requestedURL: spyURL)
        sut.load(requestedURL: spyURL)
        
        // MARK: - THEN
        XCTAssertEqual(client.requestedURLs, [spyURL, spyURL])
        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    func test_load_deliversErrorOnClientError() {
        // MARK: - GIVEN
        let (sut, client, spyURL) = makeSUT()
        client.errorToBeReturned = NSError(domain: "Test", code: 0)
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        // MARK: - WHEN
        sut.load(requestedURL: spyURL) { capturedErrors.append($0) }
        
        // MARK: - THEN
        XCTAssertEqual(capturedErrors, [.conectivity])
    }
    
    //MARK: - HELPERS
    
    private func makeSUT() -> (sut: RemoteFeedLoader, client: HTTPClientSpy, url: URL) {
        let url = URL(string: "https://gui.com")!
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: clientSpy)
        return (sut, clientSpy, url)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestedURLs: [URL?] = []
        var errorToBeReturned: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            requestedURL = url
            requestedURLs.append(url)
            if let errorToBeReturned {
                completion(errorToBeReturned)
            }
        }
    }
    
}
