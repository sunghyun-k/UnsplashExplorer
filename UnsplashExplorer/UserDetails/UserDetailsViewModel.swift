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
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: Publishing
    let user = BehaviorRelay<UserDetails?>(value: nil)
    
    func selectPhoto() {
        
    }
}
