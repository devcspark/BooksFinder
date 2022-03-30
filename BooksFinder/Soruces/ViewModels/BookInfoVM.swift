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
    //private var dataModel = BookInfoModel()
    private var bookItems = [BookItem]()
    private var maxPage = 1
    private let resultCount = 20

    // property output
    var bookitemsSubject = PublishSubject<[BookItem]>()
    var nowBooksCount:Int {
        get {
            return bookItems.count
        }
    }

    // property input
    var query = ""
    var page = 0 {
        didSet {
            update()
        }
    }
    
    func update() {
        if query.count < 4 { return }
        if maxPage < page { return }
                
        NetworkService.perform(BookInfoModel.getList(query, page, resultCount))
            .subscribe(with: self, onSuccess: { (owner, result:NetworkResult<BookInfo>) in
                switch result {
                case .success(let info):
                    if owner.page == 0 { owner.bookItems = [] }
                    if let items = info.items,
                       items.count > 0 {
                        owner.bookItems.append(contentsOf: items)
                        owner.maxPage = info.items?.count == owner.resultCount ? owner.page + 1 : owner.page
                    }else{
                        owner.maxPage = owner.page
                    }
                    
                    owner.bookitemsSubject.onNext(owner.bookItems)
                    break
                case .error(let err):
                    owner.bookitemsSubject.onError(err)
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func nextPage() {
        if maxPage > page {
            page += 1
        }
    }
}

extension BookInfoVM {
    /// complete output.
    /// 필요 시 구조체로 정의해도 됨.
    
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
