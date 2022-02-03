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

    var disposebag = DisposeBag()
    var bookModel = BookInfoModel()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func getBooksTest() throws {
        let expectation = XCTestExpectation(description: "Test Complete")
        
        bookModel.getList(query: "swift", page:1, resultCount: 20)
            .catchAndReturn(BookInfo(JSON: [:])!)
            .subscribe(onNext: { book in
                XCTAssertNotNil(book.kind, "Error 발생")
                if let booksCount = book.totalItems,
                   let loadCount = book.items?.count {
                    print("BookInfo items total count = \(booksCount), load count = \(loadCount)")
                }
                expectation.fulfill()
            }).disposed(by: disposebag)
        
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
