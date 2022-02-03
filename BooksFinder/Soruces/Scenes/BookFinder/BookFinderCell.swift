//
//  BookFinderCell.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2022/02/03.
//

import UIKit
import Kingfisher

class BookFinderCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var published: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        thumbnail.image = nil
    }
    
    func setData(thumbnail:URL?,
                 title:String?,
                 author:String?,
                 published:String?) {
        self.thumbnail.kf.setImage(with: thumbnail)
        self.title.text = title
        self.author.text = author
        self.published.text = published
    }
}
