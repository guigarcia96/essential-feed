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
                let data = makeItemsJson(items: [])
                client.complete(withStatusCode: code, data: data, at: index)
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
        let (sut, client, _) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJson(items: [])
            client.complete(withStatusCode: 200, data: emptyListJSON, at: 0)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithItemJSONList() {
        let (sut, client, _) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "httos://image-url1.com")!)
        
        let item2 = makeItem(id: UUID(), imageURL: URL(string: "httos://image-url2.com")!)
        
        let items = [item1.model, item2.model]
        expect(sut, toCompleteWith: .success(items)) {
            let itemsJson = makeItemsJson(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: itemsJson, at: 0)
        }
     
    }
    
    //MARK: - HELPERS
    
    private func makeSUT() -> (sut: RemoteFeedLoader, client: HTTPClientSpy, url: URL) {
        let url = URL(string: "https://gui.com")!
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: clientSpy)
        return (sut, clientSpy, url)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any])  {
        let item: FeedItem = .init(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any](), { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        })
        return (item, json)
    }
    
    private func makeItemsJson(items: [[String: Any]]) -> Data {
        let json = [
            "items": items
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
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
        
        func complete(withStatusCode code: Int, data: Data,  at index: Int = 0) {
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
