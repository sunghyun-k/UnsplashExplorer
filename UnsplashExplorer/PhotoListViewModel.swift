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
        dataSource.value.count / loadPerPage + (dataSource.value.count % loadPerPage > 0 ? 1 : 0)
    }
    
    // MARK: Publishing
    let searchText = BehaviorSubject<String>(value: "")
    let dataSource = BehaviorRelay<[PhotoInfo]>(value: [])
    let errorMessage = BehaviorSubject<String>(value: "")
    
    let photoDetail = BehaviorSubject<PhotoDetailInfo?>(value: nil)
    
    // MARK: Properies
    private var totalPages = 0
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
        searchText
            .skip(1)
            .throttle(.milliseconds(1000), latest: true, scheduler: scheduler)
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                self.searchPhoto(byKeyword: query)
            })
            .disposed(by: disposeBag)
    }
    
    private func searchPhoto(byKeyword keyword: String) {
        
        photoSearcher.searchPhotos(
            byKeyword: keyword,
            page: 1,
            perPage: self.loadPerPage
        )
        .subscribe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            switch value {
            case .success(let result):
                self.dataSource.accept(result.results)
                self.totalPages = result.totalPages
            case .failure(let error):
                self.dataSource.accept([])
                self.errorMessage.onNext("오류: \(error.localizedDescription)")
            }
        })
        .disposed(by: disposeBag)
    }
    
    func loadMore() {
        guard let keyword = try? searchText.value(),
              !isFetching,
              totalPages > currentPage else {
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
