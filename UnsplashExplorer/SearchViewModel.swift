//
//  SearchViewModel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/30.
//

import Foundation
import RxSwift
import RxCocoa

class AutocompleteViewModel {
    private let fetcher: AutocompleteFetchable
    init(fetcher: AutocompleteFetchable) {
        self.fetcher = fetcher
        searchText
            .skip(1)
            .throttle(.milliseconds(500), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                fetcher.autocompleteResults(forQuery: query)
                    .bind(to: self.autocompletes)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Publishing
    let searchText = BehaviorRelay<String>(value: "")
    let autocompletes = BehaviorRelay<[String]>(value: [])
    
    private let disposeBag = DisposeBag()
}

class SearchViewModel {
    private let photoFetcher: PhotoFetchable
    let autocompleteViewModel: AutocompleteViewModel
    init(photoFetcher: PhotoFetchable, autocompleteViewModel: AutocompleteViewModel) {
        self.photoFetcher = photoFetcher
        self.autocompleteViewModel = autocompleteViewModel
    }
    private let disposeBag = DisposeBag()
    
    private var totalPages = 0
    private var isFetching = false
    private var currentPage: Int {
        photos.value.count / loadPerPage + (photos.value.count % loadPerPage > 0 ? 1 : 0)
    }
    
    // MARK: Configuration
    var loadPerPage = 20
    
    // MARK: Publishing
    let photos = BehaviorRelay<[Photo]>(value: [])
    let events = PublishSubject<NavigationEvent>()
    
    func searchPhotos() {
        isFetching = true
        photoFetcher.searchPhotos(byQuery: autocompleteViewModel.searchText.value, page: 1, perPage: loadPerPage)
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
        photoFetcher.searchPhotos(byQuery: autocompleteViewModel.searchText.value, page: currentPage + 1, perPage: loadPerPage)
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
        let viewModel = PhotoDetailsViewModel(photo: photo, photoSearcher: self.photoFetcher)
        events.onNext(NavigationEvent.presentPhoto(viewModel))
    }
}
