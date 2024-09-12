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
        let (sut, client, _) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.conectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError, at: 0)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client, _) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client, _) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON, at: 0)
        }
    }
    
    func test_load_deliversNoItemOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client, spyURL) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON, at: 0)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithItemJSONList() {
        let (sut, client, spyURL) = makeSUT()
        
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "httos://image-url.com")!)
        let itemJSON = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "httos://image-url2.com")!)
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.description,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJSON = [
            "items": [itemJSON, item2JSON]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: itemJSON)
        expect(sut, toCompleteWith: .success([item1, item2])) {
            client.complete(withStatusCode: 200, data: jsonData, at: 0)
        }
     
    }
    
    //MARK: - HELPERS
    
    private func makeSUT() -> (sut: RemoteFeedLoader, client: HTTPClientSpy, url: URL) {
        let url = URL(string: "https://gui.com")!
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: clientSpy)
        return (sut, clientSpy, url)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, file: StaticString = #filePath, line: UInt = #line, when action: () -> Void) {
        let (_, _ , spyURL) = makeSUT()
        var capturedResult = [RemoteFeedLoader.Result]()
        
        sut.load(requestedURL: spyURL) { capturedResult.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(),  at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }
    
}
