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
    // MARK: Configuration
    var loadPerPage = 20
    var currentPage: Int {
        dataSource.value.count / loadPerPage
    }
    
    let searchQuery = BehaviorSubject<String>(value: "")
    let dataSource = BehaviorRelay<[PhotoInfo]>(value: [])
    let errorMessage = BehaviorSubject<String>(value: "")
    
    let photoDetail = BehaviorSubject<PhotoDetailInfo?>(value: nil)
    
    private var isFetching = false
    
    private let photoSearcher: PhotoSearchable
    private let disposeBag = DisposeBag()
    
    init(
        photoSearcher: PhotoSearchable,
        scheduler: SchedulerType = SerialDispatchQueueScheduler(
            internalSerialQueueName: "PhotoListViewModel"
        )
    ) {
        self.photoSearcher = photoSearcher
        searchQuery
            .skip(1)
            .throttle(.milliseconds(1000), latest: true, scheduler: scheduler)
            .subscribe(onNext: { [weak self] query in
                guard let self = self,
                      !query.isEmpty else {
                    self?.dataSource.accept([])
                    return
                }
                self.searchPhoto(
                    byKeyword: query,
                    page: 1,
                    perPage: self.loadPerPage
                )
            })
            .disposed(by: disposeBag)
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
                self.dataSource.accept(result.results)
            case .failure(let error):
                self.errorMessage.onNext("오류: \(error.localizedDescription)")
            }
        })
        .disposed(by: disposeBag)
    }
    
    func loadMore() {
        guard let keyword = try? searchQuery.value(),
              !keyword.isEmpty,
              !isFetching else {
            return
        }
        isFetching = true
        photoSearcher.searchPhotos(
            byKeyword: keyword,
            page: currentPage + 1,
            perPage: loadPerPage
        )
        .subscribe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            switch value {
            case .success(let result):
                self.dataSource.accept(self.dataSource.value + result.results)
            case .failure(let error):
                self.errorMessage.onNext("오류: \(error.localizedDescription)")
            }
            self.isFetching = false
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Sample
    func loadSample() {
        dataSource.accept(sample())
    }
    
    private func sample() -> [PhotoInfo] {
        let sample: SearchPhotosResponse = UnsplashExplorer.load("sample.json")
        return sample.results
    }
}
