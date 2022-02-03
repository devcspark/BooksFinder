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
    private var dataModel = BookInfoModel()
    private var bookItems = [BookItem]()
    
    var totalBooksCount = 0
    var bookitemsSubject = PublishSubject<[BookItem]>()
    
    var query = ""
    var page = 0 {
        didSet {
            update()
        }
    }
    
    private let resultCount = 20
    private var totalPage = 1
    
    func update() {
        if query.count < 4 { return }
        if totalPage < page + 1 { return }
        
        dataModel.getList(query: query, page: page, resultCount: resultCount)
            .subscribe(with: self, onNext: { owner, info in
                if owner.page == 0 { owner.bookItems = [] }
                if let items = info.items {
                    owner.bookItems.append(contentsOf: items)
                }
                owner.totalBooksCount = info.totalItems ?? 0
                owner.totalPage = ((info.totalItems ?? 1) / owner.resultCount) + 1
                owner.bookitemsSubject.onNext(owner.bookItems)
                
            }, onError: { owner, error in
                owner.bookitemsSubject.onError(error)
            })
            .disposed(by: disposeBag)
    }
    
    func nextPage() {
        if totalPage > page {
            page += 1
        }
    }
}

extension BookInfoVM {
    // 저자
    func authors(index:Int) -> String? {
        if let authors = bookItems[index].volumeInfo?.authors {
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
