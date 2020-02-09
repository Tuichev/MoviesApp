//
//  ViewController.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import UIKit
import AVKit

protocol MainViewControllerProtocol: class {
    func reloadTableView()
    func showEndPage(_ videoKey: String)
}


class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let rowHeight: CGFloat = 260
    let headerHeight: CGFloat = 200
    var presenter: MainPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainPresenter(view: self)
        setupViews()
    }
    
    func setupViews() {
        setupTableView()
    }
    
    func setupTableView() {
        self.tableView.backgroundColor = .black
        
        self.tableView.registerCell(MainVCTableViewCell.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getCellCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.createCell(MainVCTableViewCell.self, indexPath)
        presenter.configurateCell(cell, path: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "headerImage")
        imageView.contentMode = .scaleAspectFill
        
        header.addSubview(imageView)
        header.constrainToEdges(imageView)
        return header
    }
    
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
}

extension MainViewController: MainViewControllerProtocol {
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadTable(isAnimate: true)
        }
    }
    
    func showEndPage(_ videoKey: String) {
        DispatchQueue.main.async {
            let videoURL = URL(string: videoKey)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}
