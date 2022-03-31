//
//  AutocompleteViewModel.swift
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
