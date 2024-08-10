//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Guilherme Garcia on 10/08/24.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}


protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
