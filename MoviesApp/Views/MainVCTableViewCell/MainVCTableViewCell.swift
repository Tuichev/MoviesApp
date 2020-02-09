//
//  MainVCTableViewCell.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/9/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import UIKit

protocol MainVCTableViewCellProtocol: class {
    func display(title: String?)
    func setupPresenter(value: MainTableCellPresenter)
    func reloadCollectionView()
    var cellHandler: ((IndexPath) -> Void)? { get set }
}

class MainVCTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var movieNameLabel: UILabel!
    
    var presenter: MainTableCellPresenterProtocol?
    var cellHandler: ((IndexPath) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    func setupView() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        self.collectionView.registerCell(MainCollectionViewCell.self)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}

extension MainVCTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.getCellCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.createCell(MainCollectionViewCell.self, indexPath)
        presenter?.configurateCell(cell, path: indexPath)
        
        return cell
    }
}

extension MainVCTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellHandler?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    //minimum spacing between 2 items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //minimum vertical line spacing here between two lines in collectionview
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
    
}

extension MainVCTableViewCell: MainVCTableViewCellProtocol {
    func display(title: String?) {
        self.movieNameLabel.text = title
    }
    
    func setupPresenter(value: MainTableCellPresenter){
        self.presenter = value
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
