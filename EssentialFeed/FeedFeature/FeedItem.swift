//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Guilherme Garcia on 10/08/24.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
}
