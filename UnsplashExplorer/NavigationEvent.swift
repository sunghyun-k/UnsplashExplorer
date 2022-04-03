//
//  NavigationEvent.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/04/03.
//

import Foundation

enum NavigationEvent {
    case presentUser(UserDetailsViewModel)
    case presentPhoto(PhotoDetailsViewModel)
}
