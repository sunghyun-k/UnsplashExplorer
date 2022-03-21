//
//  ImageSearcherError.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation

enum ImageSearcherError: Error {
    case parsing(description: String)
    case network(description: String)
}
