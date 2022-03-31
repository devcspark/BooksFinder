//
//  BookFinderViewController.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2021/07/25.
//

import UIKit
import RxSwift
import RxCocoa

class BookFinderViewController: UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchKeyword: UISearchBar!
    @IBOutlet weak var totalCount: UILabel!
    @IBOutlet weak var notSearchLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private let bookInfoVM = BookInfoVM()
    private let refrashCtrl = UIRefreshControl()
    
    @IBOutlet weak var booksTableView: UITableView!
    
    let testButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("test", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUI()
        setBindings()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUI() {
        navigationItem.title = "Book finder"
        
        booksTableView.addSubview(refrashCtrl)
        booksTableView.isHidden = true
        
        notSearchLabel.text = "세글자이상 단어로 검색해보세요."
    }
    
    var lastCell:BookFinderCell?
    func setBindings() {
        
        // 검색키워드 동기화. 단어 입력 1초후 자동으로 검색. 3글자 이상검색.
        searchKeyword.rx.text.orEmpty
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter{ $0.count > 2 ? true : false }
            .asDriver { _ in .never() }
            .drive(with: self) { owner, word in
                owner.update(word: word)
            }.disposed(by: disposeBag)

        // 아이템 카운트 바인딩
        bookInfoVM.bookitemsCount
            .bind(to: totalCount.rx.text)
            .disposed(by: disposeBag)
        
        // Subject 구독
        bookInfoVM.bookitemsSubject
            .withUnretained(self)
            .filter { owner, items in
                owner.booksTableView.isHidden = (items.count == 0)
                owner.notSearchLabel.text = "'\(owner.searchKeyword.text ?? "")'로 검색된 정보가 없습니다.\n다른 단어로 검색해보세요."
                // 이건 당겨서 새로고침 인디케이터 정지
                if owner.refrashCtrl.isRefreshing {
                    owner.refrashCtrl.endRefreshing()
                }
                // 이건 화멵중앙 로딩 인디케이터...
                owner.loadingIndicator.isHidden = true
                return true
            }
            .map { $0.1 }
            .asDriver{ _ in .never() }
            .drive(booksTableView.rx.items) { [weak self] (table, row, item) in
                let cell = table.dequeueReusableCell(withIdentifier: "BookFinderCell") as! BookFinderCell
                let bookItem = self?.bookInfoVM.getBookItem(index: row)
                cell.setData(thumbnail: item.volumeInfo?.imageLinks?.smallThumbnail,
                             title: item.volumeInfo?.title,
                             author: BookInfoVM.authors(bookItem: bookItem),
                             published: self?.bookInfoVM.publishedDate(index: row))
                if table.numberOfRows(inSection: 0) == (row + 1) {
                    self?.lastCell = cell
                }
                return cell
            }
            .disposed(by: disposeBag)
        
        // 당겨서 새로고침 ( 첫페이지로 이동 )
        refrashCtrl.rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(with:self) { owner, _ in
                owner.update(word: owner.searchKeyword.text ?? "")
            }
            .disposed(by: disposeBag)
        
        // 아이템 선택
        booksTableView.rx.itemSelected
            .asDriver()
            .drive(with:self) { owner, index in
                if let book = owner.bookInfoVM.getBookItem(index: index.row),
                   let detailVC = BooksDetailViewController.show(bookItem: book) {
                    owner.navigationController?.pushViewController(detailVC, animated: true)
                }
            }.disposed(by: disposeBag)
        
        // 최하단 스크롤 시 다음페이지 호출
        booksTableView.rx.didScroll
            .asDriver()
            .drive(with: self) { owner, _ in
                let height: CGFloat = owner.booksTableView.frame.size.height
                let contentYOffset: CGFloat = owner.booksTableView.contentOffset.y
                let scrollViewHeight: CGFloat = owner.booksTableView.contentSize.height
                let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
                if distanceFromBottom < height {
                    owner.loadingIndicator.isHidden = !owner.bookInfoVM.nextPage()
                }
            }.disposed(by: disposeBag)
    }

    func update(word:String, page:Int = 0) {
        if word.isEmpty { return }
        
        loadingIndicator.isHidden = false
        searchKeyword.resignFirstResponder()
        bookInfoVM.query = word
        bookInfoVM.page = page
    }
}
