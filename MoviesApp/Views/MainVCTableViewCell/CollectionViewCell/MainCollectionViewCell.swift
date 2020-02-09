//
//  MainCollectionViewCell.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/9/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import UIKit
import SDWebImage

protocol MainCollectionViewCellProtocol {
    func display(name: String?)
    func display(poster: String?)
}

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.posterImageView.sd_cancelCurrentImageLoad()
        self.posterImageView.image = nil
        
        self.nameLabel.text = nil
    }
    
}

extension MainCollectionViewCell: MainCollectionViewCellProtocol {
    func display(name: String?) {
        self.nameLabel.text = name
    }
    
    func display(poster: String?) {
        self.posterImageView.sd_setImage(with: URL(string: poster ?? ""), completed: nil)
    }
}
