//
//  ImageSearcher.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation
import RxSwift

protocol ImageSearchable {
    func search(
        byKeyword keyword: String,
        page: Int,
        perPage: Int
    ) -> Single<Result<SearchResult, Error>>
}

class ImageSearcher {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}
