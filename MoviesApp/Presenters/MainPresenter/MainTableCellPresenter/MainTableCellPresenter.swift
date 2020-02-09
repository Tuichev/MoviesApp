//
//  MainTableCellPresenter.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/9/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation

protocol MainTableCellPresenterProtocol {
    init(view: MainVCTableViewCellProtocol)
    func getCellCount() -> Int
    func configurateCell(_ cell: MainCollectionViewCellProtocol, path: IndexPath)
}

class MainTableCellPresenter: MainTableCellPresenterProtocol {
    weak var view:MainVCTableViewCellProtocol?
    
    var cellData: [MovieEntity] = [] {
        didSet {
            self.view?.reloadCollectionView()
        }
    }
    
    required init(view: MainVCTableViewCellProtocol) {
        self.view = view
    }
    
    func getCellCount() -> Int {
        return cellData.count
    }
    
    func configurateCell(_ cell: MainCollectionViewCellProtocol, path: IndexPath) {
        guard let item = cellData[safe: path.item] else { return }
        
        cell.display(name: item.title)
        cell.display(poster: item.poster)
    }
    
}
