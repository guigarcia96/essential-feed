import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init() {
        func test_init_doesNotMessageStoreUponCreation() {
            let (_, store) = makeSUT()
            XCTAssertEqual(store.receivedMessages, [])
        }
    }
    
    //MARK: - HELPERS
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut,file: file, line: line)
        return (sut, store)
    }
}
