//
//  SearchViewModel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/30.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    private let photoFetcher: PhotoFetchable
    init(photoFetcher: PhotoFetchable) {
        self.photoFetcher = photoFetcher
    }
    
    private let disposeBag = DisposeBag()
    
    private var totalPages = 0
    private var isFetching = false
    private var currentPage: Int {
        photos.value.count / loadPerPage + (photos.value.count % loadPerPage > 0 ? 1 : 0)
    }
    
    private var query = ""
    
    // MARK: Configuration
    var loadPerPage = 20
    
    // MARK: Publishing
    let photos = BehaviorRelay<[Photo]>(value: [])
    let events = PublishSubject<NavigationEvent>()
    
    func searchPhotos(byQuery query: String) {
        guard !query.isEmpty else { return }
        isFetching = true
        self.query = query
        photoFetcher.searchPhotos(byQuery: query, page: 1, perPage: loadPerPage)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let results):
                    self.photos.accept(results.photos)
                    self.totalPages = results.totalPages
                case .failure(let error):
                    print("Error: \(error)")
                }
                self.isFetching = false
            })
            .disposed(by: disposeBag)
    }
    
    func loadMore() {
        guard currentPage < totalPages, !isFetching else { return }
        photoFetcher.searchPhotos(byQuery: self.query, page: currentPage + 1, perPage: loadPerPage)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let results):
                    self.photos.accept(self.photos.value + results.photos)
                case .failure(let error):
                    print("Error: \(error)")
                }
                self.isFetching = false
            })
            .disposed(by: disposeBag)
    }
    
    func selectPhoto(at index: Int) {
        let photo = photos.value[index]
        let viewModel = PhotoDetailsViewModel(photo: photo, fetcher: self.photoFetcher)
        events.onNext(.presentPhoto(viewModel))
    }
}
