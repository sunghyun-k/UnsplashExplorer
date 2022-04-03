//
//  UserDetailsViewModel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/31.
//

import Foundation
import RxSwift
import RxCocoa

class UserDetailsViewModel {
    private let fetcher: PhotoFetchable
    init(user: User, fetcher: PhotoFetchable) {
        self.fetcher = fetcher
        self.userSimple = user
        fetcher.userDetails(byUsername: user.username)
            .subscribe(onNext: { result in
                switch result {
                case .success(let userDetails):
                    self.user.accept(userDetails)
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
            .disposed(by: disposeBag)
        fetchPhotos()
    }
    
    var loadPerPage = 20
    
    private let disposeBag = DisposeBag()
    
    private var isFetching = false
    
    private let userSimple: User
    
    // MARK: Publishing
    let user = BehaviorRelay<UserDetails?>(value: nil)
    let photos = BehaviorRelay<[Photo]>(value: [])
    let events = PublishSubject<NavigationEvent>()
    
    func fetchPhotos() {
        guard !isFetching else { return }
        isFetching = true
        fetcher.userPhotos(byUsername: userSimple.username, page: 1, perPage: loadPerPage)
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
    
    func selectPhoto(at index: Int) {
        let photo = photos.value[index]
        let viewModel = PhotoDetailsViewModel(photo: photo, fetcher: self.fetcher)
        events.onNext(NavigationEvent.presentPhoto(viewModel))
    }
}
