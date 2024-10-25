import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "anyError", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://test.com")!
}
