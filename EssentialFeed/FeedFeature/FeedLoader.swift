//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Guilherme Garcia on 10/08/24.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
