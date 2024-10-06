//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Guilherme Garcia on 10/08/24.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
