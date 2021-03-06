//
//  PhotoDetailsViewModel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/30.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoDetailsViewModel {
    private let fetcher: PhotoFetchable
    init(photo: Photo, fetcher: PhotoFetchable) {
        self.fetcher = fetcher
        
        fetcher.photoDetails(byId: photo.id)
            .subscribe(onNext: { result in
                switch result {
                case .success(let photoDetails):
                    self.photo.accept(photoDetails)
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: Publishing
    let photo = BehaviorRelay<PhotoDetails?>(value: nil)
    let events = PublishSubject<NavigationEvent>()
    
    func selectUser() {
        guard let photo = photo.value else {
            print("No photo infomations")
            return
        }
        let viewModel = UserDetailsViewModel(user: photo.user, fetcher: self.fetcher)
        events.onNext(.presentUser(viewModel))
    }
}
