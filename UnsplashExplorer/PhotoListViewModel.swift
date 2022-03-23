//
//  PhotoListViewModel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoListViewModel {
    let searchQuery = BehaviorSubject<String>(value: "")
    let currentPage = BehaviorSubject<Int>(value: 0)
    let dataSource = BehaviorSubject<[PhotoInfo]>(value: [])
    let errorMessage = BehaviorSubject<String>(value: "")
    
    private let photoSearcher: PhotoSearchable
    private var disposeBag = DisposeBag()
    
    init(
        photoSearcher: PhotoSearchable,
        scheduler: SchedulerType = SerialDispatchQueueScheduler(
            internalSerialQueueName: "PhotoListViewModel"
        )
    ) {
        self.photoSearcher = photoSearcher
        _ = searchQuery
            .skip(1)
            .throttle(.milliseconds(500), latest: false, scheduler: scheduler)
            .subscribe { [weak self] query in
                self?.searchPhoto(
                    byKeyword: query,
                    page: 1,
                    perPage: 10
                )
            }
    }
    
    func searchPhoto(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) {
        photoSearcher.searchPhotos(
            byKeyword: keyword,
            page: page,
            perPage: perPage
        )
        .subscribe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            switch value {
            case .success(let result):
                self.dataSource.onNext(result.results)
            case .failure(let error):
                self.errorMessage.onNext("오류: \(error.localizedDescription)")
            }
        })
        .disposed(by: disposeBag)
    }
    
    func loadSample() {
        dataSource.onNext(sample())
    }
    
    private func sample() -> [PhotoInfo] {
        let sample: PhotoSearchResult = UnsplashExplorer.load("sample.json")
        return sample.results
    }
}
