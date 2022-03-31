//
//  BooksDetailViewController.swift
//  BooksFinder
//
//  Created by iOS_DEV on 2022/03/31.
//

import UIKit
import RxSwift
import RxCocoa

class BooksDetailViewController: UIViewController {
    private var disposeBag = DisposeBag()
    var bookItem: BookItem?
    @IBOutlet weak var bookCorverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleDataLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorDataLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionDataLabel: UILabel!
    
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUI()
        setBinding()
    }
    
    func setUI() {
        bookCorverImage.kf.setImage(with: bookItem?.volumeInfo?.imageLinks?.thumbnail)
        
        titleLabel.text = "title".localized
        authorLabel.text = "authors".localized
        descriptionLabel.text = "description".localized
     
        titleDataLabel.text = bookItem?.volumeInfo?.title
        authorDataLabel.text = BookInfoVM.authors(bookItem: bookItem)
        descriptionDataLabel.text = bookItem?.volumeInfo?.description
        
        previewButton.setTitle("preview".localized, for: .normal)
        infoButton.setTitle("info".localized, for: .normal)
    }
    
    func setBinding() {
        
        // 미리보기 링크
        previewButton.rx.tap
            .bind(with: self) { owner, _ in
                if let previewURL = owner.bookItem?.volumeInfo?.previewLink {
                    UIApplication.shared.open(previewURL)
                }
            }.disposed(by: disposeBag)
        
        // 상세정보 링크
        infoButton.rx.tap
            .bind(with: self) { owner, _ in
                if let infoURL = owner.bookItem?.volumeInfo?.infoLink {
                    UIApplication.shared.open(infoURL)
                }
            }.disposed(by: disposeBag)
    }
    
    static func show(bookItem:BookItem) -> UIViewController? {
        if let detailVC = BooksDetailViewController.instantiate(storyboard: .BookFinder, identifier: "BooksDetailViewController") as? BooksDetailViewController {
            detailVC.bookItem = bookItem
            return detailVC
        }
        return nil
    }
}
