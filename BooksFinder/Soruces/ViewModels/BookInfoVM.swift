//
//  BookInfoVM.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2022/02/02.
//

import Foundation
import RxSwift

class BookInfoVM {
    private var disposeBag = DisposeBag()
    private var bookItems = [BookItem]()
    private var maxPage = 1
    private let resultCount = 20                // 우선 한페이지에 20개씩으로 가져옴.
    /*
     현재 Books API가 이상한지 total값이 페이징 할때마다 변동됩니다.
     때문에 첫 페이지에서 가져온 값을 한번만 전달합니다.
     */
    private var totalCount:Int = 0
    private var nowBooksCount:Int = 0 {                                 // 현재 불러온 값
        didSet {
            // 현재 카운트가 저장되면 내려주자...
            bookitemsCount.onNext(String(format: "Items (%d/%d)", bookItems.count, totalCount))
        }
    }

    // property output
    var bookitemsSubject = PublishSubject<[BookItem]>()     // 책아이템 리스트
    var bookitemsCount = BehaviorSubject<String>(value: "Items (0/0)")  // 아이템 카운트
    
    // property input
    var query = ""
    var page = 0 {
        didSet {
            update()
        }
    }
    
    func update() {
        if maxPage < page { return }
        
        NetworkService.perform(BookInfoModel.getList(query, page, resultCount))
            .subscribe(with: self, onSuccess: { (owner, result:NetworkResult<BookInfo>) in
                switch result {
                case .success(let info):
                    if owner.page == 0 {
                        owner.bookItems = []
                        if let totalItems = info.totalItems {
                            owner.totalCount = totalItems
                        }
                    }
                    if let items = info.items,
                       items.count > 0 {
                        owner.bookItems.append(contentsOf: items)
                        owner.maxPage = info.items?.count == owner.resultCount ? owner.page + 1 : owner.page
                    }else{
                        owner.maxPage = owner.page
                    }
                    
                    owner.nowBooksCount = owner.bookItems.count
                    owner.bookitemsSubject.onNext(owner.bookItems)
                    break
                case .error(let err):
                    owner.bookitemsSubject.onError(err)
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func nextPage() -> Bool {
        if maxPage > page {
            page += 1
            return true
        }
        return false
    }
    
    func getBookItem(index:Int) -> BookItem? {
        guard index < bookItems.count else { return nil }
        return bookItems[index]
    }
}

extension BookInfoVM {
    /// complete output.
    /// 필요 시 구조체로 정의해도 됨.
    
    // 저자
    static func authors(bookItem:BookItem?) -> String? {
        if let authors = bookItem?.volumeInfo?.authors {
            var authorString = "by "
            if authors.count > 1 {
                for (i, author) in authors.enumerated() {
                    switch i {
                    case 0:
                        authorString += author
                    case 1:
                        authorString += " and " + author
                    default:
                        authorString += ", " + author
                    }
                }
                return authorString
            }
            if let author = authors.first {
                return authorString + author
            }
        }
        return nil
    }
    
    // 출시일
    func publishedDate(index:Int) -> String? {
        if let pubDate = bookItems[index].volumeInfo?.publishedDate {
            return "Published " + pubDate
        }
        return nil
    }
}
