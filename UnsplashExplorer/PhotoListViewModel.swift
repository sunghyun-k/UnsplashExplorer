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
    let autocompletes = BehaviorRelay<[String]>(value: [])
    
    let dataSource = BehaviorRelay<[Photo]>(value: [])
    let errorMessage = BehaviorSubject<String>(value: "")
    
    let editorialPhotos = BehaviorRelay<[Photo]>(value: [])
    
    let photoDetails = BehaviorSubject<PhotoDetails?>(value: nil)
    
    // MARK: Properties
    private var totalPages = 0
    
    private let photoFetcher: PhotoFetchable
    private let disposeBag = DisposeBag()
    
    init(
        photoSearcher: PhotoFetchable,
        scheduler: SchedulerType = SerialDispatchQueueScheduler(
            internalSerialQueueName: "PhotoListViewModel"
        )
    ) {
        self.photoFetcher = photoSearcher
        searchText
            .skip(1)
            .throttle(.milliseconds(500), latest: true, scheduler: scheduler)
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                self.autocomplete(byKeyword: query)
            })
            .disposed(by: disposeBag)
    }
    
    private func autocomplete(byKeyword keyword: String) {
        guard !keyword.isEmpty else {
            autocompletes.accept([])
            return
        }
        photoFetcher.autocompleteResults(forQuery: keyword)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] autocompletes in
                guard let self = self else { return }
                self.autocompletes.accept(autocompletes)
            })
            .disposed(by: disposeBag)
    }
    
    func searchPhoto() {
        guard let keyword = try? searchText.value() else {
            return
        }
        self.dataSource.accept([])
        searchPhoto(byKeyword: keyword, page: 1, perPage: self.loadPerPage)
    }
    
    func loadMore(completion: (() -> Void)? = nil ) {
        guard let keyword = try? searchText.value(),
              totalPages > currentPage else {
            completion?()
            return
        }
        searchPhoto(
            byKeyword: keyword,
            page: currentPage + 1,
            perPage: loadPerPage,
            completion: completion
        )
    }
    
    private func searchPhoto(
        byKeyword keyword: String,
        page: Int,
        perPage: Int,
        completion: (() -> Void)? = nil
    ) {
        photoFetcher.searchPhotos(
            byQuery: keyword,
            page: page,
            perPage: perPage
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            switch value {
            case .success(let result):
                self.dataSource.accept(self.dataSource.value + result.results)
                self.totalPages = result.totalPages
            case .failure(let error):
                self.errorMessage.onNext("오류: \(error.localizedDescription)")
            }
            completion?()
        })
        .disposed(by: disposeBag)
    }
    
    func fetchPhotoDetail(id: String) {
        photoFetcher.photoDetails(byId: id)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .success(let photoDetails):
                    self.photoDetails.onNext(photoDetails)
                case .failure(let error):
                    self.errorMessage.onNext("오류: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func removeDetail() {
        photoDetails.onNext(nil)
    }
}
