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
        sut.load(requestedURL: spyURL) {_ in }
        
        // MARK: - THEN
        XCTAssertEqual(client.requestedURLs, [spyURL])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // MARK: - GIVEN
        let (sut, client, spyURL) = makeSUT()
        
        // MARK: - WHEN
        sut.load(requestedURL: spyURL) {_ in }
        sut.load(requestedURL: spyURL) {_ in }
        
        // MARK: - THEN
        XCTAssertEqual(client.requestedURLs, [spyURL, spyURL])
        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    func test_load_deliversErrorOnClientError() {
        // MARK: - GIVEN
        let (sut, client, spyURL) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        // MARK: - WHEN
        sut.load(requestedURL: spyURL) { capturedErrors.append($0) }
        client.complete(with: clientError, at: 0)
        
        // MARK: - THEN
        XCTAssertEqual(capturedErrors, [.conectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        // MARK: - GIVEN
        let (sut, client, spyURL) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        // MARK: - WHEN
        sut.load(requestedURL: spyURL) { capturedErrors.append($0) }
        client.complete(withStatusCode: 400, at: 0)
        
        // MARK: - THEN
        XCTAssertEqual(capturedErrors, [.invalidData])
    }
    
    //MARK: - HELPERS
    
    private func makeSUT() -> (sut: RemoteFeedLoader, client: HTTPClientSpy, url: URL) {
        let url = URL(string: "https://gui.com")!
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: clientSpy)
        return (sut, clientSpy, url)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            messages[index].completion(nil, response)
        }
    }
    
}
