//
//  EditorialViewModel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/30.
//

import Foundation
import RxSwift
import RxCocoa

class EditorialViewModel {
    private let fetcher: PhotoFetchable
    init(fetcher: PhotoFetchable) {
        self.fetcher = fetcher
        refresh()
    }
    
    private let disposeBag = DisposeBag()
    
    private var isFetching = false
    private var currentPage: Int {
        photos.value.count / loadPerPage + (photos.value.count % loadPerPage > 0 ? 1 : 0)
    }
    
    // MARK: Configuration
    var loadPerPage = 10
    
    // MARK: Publishing
    let photos = BehaviorRelay<[Photo]>(value: [])
    let events = PublishSubject<NavigationEvent>()
    
    func refresh() {
        guard !isFetching else { return }
        isFetching = true
        fetcher.editorial(page: 1, perPage: loadPerPage)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let photos):
                    self.photos.accept(photos)
                case .failure(let error):
                    print("Error: \(error)")
                }
                self.isFetching = false
            })
            .disposed(by: disposeBag)
    }
    
    func loadMore() {
        guard currentPage < 9999, !isFetching else { return }
        isFetching = true
        fetcher.editorial(page: currentPage + 1, perPage: loadPerPage)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let photos):
                    self.photos.accept(self.photos.value + photos)
                case .failure(let error):
                    print("Error: \(error)")
                }
                self.isFetching = false
            })
            .disposed(by: disposeBag)
    }
    
    func selectPhoto(at index: Int) {
        let photo = photos.value[index]
        let viewModel = PhotoDetailsViewModel(photo: photo, fetcher: self.fetcher)
        events.onNext(NavigationEvent.presentPhoto(viewModel))
    }
}

enum NavigationEvent {
    case presentUser(User)//(UserDetailsViewModel)
    case presentPhoto(PhotoDetailsViewModel)
}
