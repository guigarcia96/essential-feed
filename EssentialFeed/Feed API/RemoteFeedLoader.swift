import Foundation

public final class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case conectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
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
