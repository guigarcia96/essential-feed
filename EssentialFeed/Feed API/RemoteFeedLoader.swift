//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Guilherme Garcia on 11/08/24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    
    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(requestedURL: URL) {
        client.get(from: requestedURL)
    }
}
