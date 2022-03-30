//
//  BooksFinderTests.swift
//  BooksFinderTests
//
//  Created by ParkChunsoo on 2021/07/21.
//

import XCTest
import RxSwift
@testable import BooksFinder

class BooksFinderTests: XCTestCase {

    var disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func getBooksTest() throws {
        let expectation = XCTestExpectation(description: "Test Complete")
        
        NetworkService.perform(BookInfoModel.getList("swift", 0, 20))
            .catchAndReturn( .error(.unknown) )
            .subscribe(with:self) { (owner, result:NetworkResult<BookInfo>) in
                switch result {
                case .success(let info):
                    XCTAssertNotNil(info.kind, "Error 발생")
                    if let booksCount = info.totalItems,
                       let loadCount = info.items?.count {
                        print("BookInfo items total count = \(booksCount), load count = \(loadCount)")
                    }
                case .error(let err):
                    print("err = \(err)")
                    XCTAssertThrowsError(err)
                }
                
                expectation.fulfill()
            }.disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        
        try getBooksTest()
        
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
