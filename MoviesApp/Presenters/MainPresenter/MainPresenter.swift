//
//  MainPresenter.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/9/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation
import TMDBSwift
import XCDYouTubeKit

protocol MainPresenterProtocol {
    init(view: MainViewControllerProtocol)
    func configurateCell(_ cell: MainVCTableViewCellProtocol, path: IndexPath)
    func getCellCount() -> Int
}

class MainPresenter:MainPresenterProtocol {
    weak var view: MainViewControllerProtocol?
    
    let baseImageUrl = "https://image.tmdb.org/t/p/original"
    var movies: [MoviesType:[MovieEntity]] = [:]
    
    enum MoviesType: Int, CaseIterable {
        case upcoming = 0
        case topRated
        case popular
        
        var title: String {
            switch self {
            case .topRated: return "Top Rated"
            case .upcoming: return "Upcoming"
            case .popular: return "Popular"
            }
        }
    }
    
    required init(view: MainViewControllerProtocol) {
        self.view = view
        
        MoviesType.allCases.forEach({
            movies[$0] = []
        })
        
        loadData()
    }
    
    func configurateCell(_ cell: MainVCTableViewCellProtocol, path: IndexPath) {
        guard let cellType = MoviesType(rawValue: path.row) else { return }
        let presenter = MainTableCellPresenter(view: cell)
        presenter.cellData = movies[cellType] ?? []
        
        var cellCopy = cell
        
        cellCopy.display(title: cellType.title)
        cellCopy.setupPresenter(value: presenter)
        
        cellCopy.cellHandler = { [weak self] path in
            guard let `self` = self else { return }
            
            let id = (self.movies[cellType] ?? [])[safe: path.item]?.id
            self.getTrailer(movieID: id, completion: { [weak self] youtubeKey in
                self?.view?.showEndPage(youtubeKey)
            })
        }
    }
    
    func getCellCount() -> Int {
        return MoviesType.allCases.count
    }
    
    func loadData() {
        loadUpocomingMovies()
        loadTopRatedMovies()
        loadPopularMovies()
    }
    
    fileprivate func loadUpocomingMovies() {
        MovieMDB.upcoming(page: 1, language: "en") { [weak self]
            data, upcomingMovies in
            
            guard let `self` = self, let movies = upcomingMovies else { return }
            
            self.proccessResponse(loadedMovies: movies, type: .upcoming)
        }
    }
    
    fileprivate func loadTopRatedMovies() {
        MovieMDB.toprated(language: "en", page: 1) { [weak self]
            data, topRatedMovies in
            
            guard let `self` = self, let movies = topRatedMovies else { return }
            
            self.proccessResponse(loadedMovies: movies, type: .topRated)
        }
    }
    
    fileprivate func loadPopularMovies() {
        MovieMDB.popular(language: "en", page: 1){ [weak self]
            data, popularMovies in
            guard let `self` = self, let movies = popularMovies else { return }
            
            self.proccessResponse(loadedMovies: movies, type: .popular)
        }
    }
    
    fileprivate func proccessResponse(loadedMovies: [MovieMDB], type: MoviesType) {
        for i in 0..<loadedMovies.count {
            let item = MovieEntity(id: loadedMovies[i].id, title: loadedMovies[i].title, overview: loadedMovies[i].overview)
            
            self.getPosters(movieItem: item, isLast: i == loadedMovies.count-1, type: type)
        }
    }
    
    fileprivate func getPosters(movieItem: MovieEntity, isLast: Bool, type: MoviesType) {
        
        MovieMDB.images(movieID: movieItem.id, language: "en") { [weak self]
            data, imgs in
            
            guard let `self` = self, let images = imgs else { return }
            
            let backrops = self.baseImageUrl + (images.backdrops[safe: 0]?.file_path ?? "")
            let poster = self.baseImageUrl + (images.posters[safe: 0]?.file_path ?? "")
            
            var item = movieItem
            item.backrops = backrops
            item.poster = poster
            
            self.movies[type]?.append(item)
            
            if isLast {
                self.view?.reloadTableView()
            }
        }
    }
    
    fileprivate func getTrailer(movieID: Int?, completion: @escaping (String) -> Void) {
        MovieMDB.videos(movieID: movieID, language: "en") { [weak self]
            apiReturn, videos in
            
            guard let item = videos?.first, item.site == "YouTube" else { return completion("")}
            
            self?.getYoutubeLink(item.key) { [weak self] url in
                completion(url)
            }
        }
    }
    
    fileprivate func getYoutubeLink(_ youtubeKey: String, completion: @escaping (String) -> Void) {
        XCDYouTubeClient.default().getVideoWithIdentifier(youtubeKey) { [weak self] (video, error) in
            if let streamURL = (video?.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??
                video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
                video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ??
                video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]) {
                completion(streamURL.absoluteString)
            } else {
                completion("")
            }
        }
    }
}
