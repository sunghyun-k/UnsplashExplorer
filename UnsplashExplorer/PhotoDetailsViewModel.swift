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
    private let photoFetcher: PhotoFetchable
    init(photo: Photo, photoSearcher: PhotoFetchable) {
        self.photoFetcher = photoSearcher
        
        photoFetcher.photoDetails(byId: photo.id)
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
    
    func selectUser() {
        
    }
}
