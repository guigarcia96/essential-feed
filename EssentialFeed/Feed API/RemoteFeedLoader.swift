//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Guilherme Garcia on 11/08/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(requestedURL: URL, completion: @escaping (RemoteFeedLoader.Error) -> Void) {
        client.get(from: requestedURL) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.conectivity)
            }
        }
    }
}
