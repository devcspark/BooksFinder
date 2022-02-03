//
//  BookInfoModel.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2021/07/21.
//

import Foundation
import ObjectMapper
import Alamofire
import RxSwift

// MARK: - Table
class BookInfo: Mappable {
    
    var kind: String?
    var totalItems:Int?
    var items:[BookItem]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        kind <- map["kind"]
        totalItems <- map["totalItems"]
        items <- map["items"]
    }
}

// MARK: - Cells ans Detail View
class VolumeInfo: Mappable {
    
    class IndustryIdentifiers:Mappable {
        var type:String?
        var identifier:String?
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            type <- map["type"]
            identifier <- map["identifier"]
        }
    }
    
    class ReadingModes: Mappable {
        var text:Bool?
        var image:Bool?
        
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            text <- map["text"]
            image <- map["image"]
        }
    }
    
    class PanelizationSummary: Mappable {
        var containsEpubBubbles:Bool?
        var containsImageBubbles:Bool?
        
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            containsEpubBubbles <- map["containsEpubBubbles"]
            containsImageBubbles <- map["containsImageBubbles"]
        }
    }
    
    class ImageLinks: Mappable {
        var smallThumbnail:URL?
        var thumbnail:URL?
        
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            smallThumbnail <- (map["smallThumbnail"], URLTransform())
            thumbnail <- (map["thumbnail"], URLTransform())
        }
    }
    
    var title:String?
    var authors:[String]?
    var publisher:String?
    var publishedDate:String?
    var description:String?
    var industryIdentifiers:[IndustryIdentifiers]?
    var readingModes:ReadingModes?
    var pageCount:Int?
    var printType:String?
    var categories:[String]?
    var maturityRating:String?
    var allowAnonLogging: Bool?
    var contentVersion: String?
    var panelizationSummary:PanelizationSummary?
    var language:String?
    var previewLink:URL?
    var infoLink:URL?
    var canonicalVolumeLink:URL?
    var imageLinks:ImageLinks?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        authors <- map["authors"]
        publisher <- map["publisher"]
        publishedDate <- map["publishedDate"]
        description <- map["description"]
        industryIdentifiers <- map["industryIdentifiers"]
        readingModes <- map["readingModes"]
        pageCount <- map["pageCount"]
        printType <- map["printType"]
        maturityRating <- map["maturityRating"]
        allowAnonLogging <- map["allowAnonLogging"]
        contentVersion <- map["contentVersion"]
        panelizationSummary <- map["panelizationSummary"]
        language <- map["language"]
        
        previewLink <- (map["previewLink"], URLTransform())
        infoLink <- (map["infoLink"], URLTransform())
        canonicalVolumeLink <- (map["canonicalVolumeLink"], URLTransform())
        
        imageLinks <- map["imageLinks"]
    }
}

class BookItem: Mappable {
    class SaleInfo: Mappable {
        var country:String?
        var saleability:String?
        var isEbook:Bool?
        
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            country <- map["country"]
            saleability <- map["saleability"]
            isEbook <- map["isEbook"]
        }
    }
    
    class AccessInfo: Mappable {
        
        class IsAvailable: Mappable {
            var isAvailable:Bool?
            required init?(map: Map) {
            }
            func mapping(map: Map) {
                isAvailable <- map["isAvailable"]
            }
        }
        
        var country:String?
        var viewability:String?
        var embeddable:Bool?
        var publicDomain:Bool?
        var textToSpeechPermission:String?
        var epub:IsAvailable?
        var pdf:IsAvailable?
        var webReaderLink:URL?
        var accessViewStatus:String?
        var quoteSharingAllowed:Bool?
        
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            country <- map["country"]
            viewability <- map["viewability"]
            embeddable <- map["embeddable"]
            publicDomain <- map["publicDomain"]
            textToSpeechPermission <- map["textToSpeechPermission"]
            epub <- map["epub"]
            pdf <- map["pdf"]
            webReaderLink <- (map["webReaderLink"], URLTransform())
            accessViewStatus <- map["accessViewStatus"]
            quoteSharingAllowed <- map["quoteSharingAllowed"]
        }
    }
    
    class SearchInfo: Mappable {
        var textSnippet:String?
        
        required init?(map: Map) {
        }
        func mapping(map: Map) {
            textSnippet <- map["textSnippet"]
        }
    }
    
    var kind:String?
    var id:String?
    var etag:String?
    var selfLink:URL?
    var volumeInfo:VolumeInfo?
    var saleInfo:SaleInfo?
    var accessInfo:AccessInfo?
    var searchInfo:SearchInfo?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        kind <- map["kind"]
        id <- map["id"]
        etag <- map["etag"]
        
        selfLink <- (map["selfLink"], URLTransform())
        
        volumeInfo <- map["volumeInfo"]
        saleInfo <- map["saleInfo"]
        accessInfo <- map["accessInfo"]
    }
}


class BookInfoModel {
    private var disposeBag = DisposeBag()
    private enum BookInfoService: NetworkUtil {
        case getList(String, Int, Int)      // 검색쿼리, 페이지(0 base), 맥스
        
        var path: String {
            switch self {
            case .getList:
                return "/books/v1/volumes"
            }
        }
        
        var method: HTTPMethod {
            return .get
        }
        
        var parameters: Parameters {
            var param = Parameters()
            switch self {
            case .getList(let query, let page, let pageCount):
                param["q"] = query
                param["startIndex"] = page * pageCount
                param["maxResults"] = pageCount
            }
            return param
        }
    }
    
    func getList(query:String, page:Int, resultCount:Int) -> Observable<BookInfo> {
        return Observable.create { observe in
            NetworkService().perform(BookInfoService.getList(query, page, resultCount))
                .subscribe { (result:NetworkResult<BookInfo>) in
                    switch result {
                    case .success(let obj):
                        observe.onNext(obj)
                    case .error(let err):
                        observe.onError(err)
                    }
                }.disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
        /*
        return Single.create(subscribe: { single in
            NetworkService().perform(BookInfoService.getList(query, page, resultCount)) { (result: NetworkResult<BookInfo>) in
                switch result {
                case .success(let t):
                    single(.success(t))
                case .error(let networkError):
                    single(.failure(networkError))
                }
            }

            return Disposables.create()
        })
         */
    }
}
