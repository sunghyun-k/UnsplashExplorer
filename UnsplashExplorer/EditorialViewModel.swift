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
    private let photoFetcher: PhotoFetchable
    init(photoSearcher: PhotoFetchable) {
        self.photoFetcher = photoSearcher
    }
    
    private let disposeBag = DisposeBag()
    
    private var isFetching = false
    private var currentPage: Int {
        dataSource.value.count / loadPerPage + (dataSource.value.count % loadPerPage > 0 ? 1 : 0)
    }
    
    // MARK: Configuration
    var loadPerPage = 20
    
    // MARK: Publishing
    let dataSource = BehaviorRelay<[Photo]>(value: [])
    let events = PublishSubject<Event>()
    
    func refresh() {
        photoFetcher.editorial(page: 1, perPage: loadPerPage)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .success(let photos):
                    self.dataSource.accept(photos)
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func loadMore() {
        guard currentPage < 9999, !isFetching else { return }
        isFetching = true
        photoFetcher.editorial(page: currentPage + 1, perPage: loadPerPage)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .success(let photos):
                    self.dataSource.accept(self.dataSource.value + photos)
                case .failure(let error):
                    print("Error: \(error)")
                }
                self.isFetching = false
            })
            .disposed(by: disposeBag)
    }
    
    func selectPhoto(at index: Int) {
        let photo = dataSource.value[index]
        events.onNext(Event.presentPhoto(photo))
    }
}

extension EditorialViewModel {
    enum Event {
        case presentUser(User)//(UserDetailsViewModel)
        case presentPhoto(Photo)//(PhotoDetailsViewModel)
    }
}
