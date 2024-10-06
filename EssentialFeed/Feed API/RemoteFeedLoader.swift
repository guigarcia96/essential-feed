import Foundation

public final class RemoteFeedLoader {
    
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(requestedURL: URL, completion: @escaping (Result) -> Void) {
        client.get(from: requestedURL) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                let result  = FeedItemsMapper.map(data, from: response)
                completion(result)
            case .failure:
                completion(.failure(.conectivity))
            }
        }
    }
}
