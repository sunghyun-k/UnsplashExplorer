//
//  PhotoListCollectionViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import UIKit

private let reuseIdentifier = "PhotoListCell"

class PhotoListCollectionViewController: UICollectionViewController {
    
    var photoInfos = [PhotoInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        photoInfos = loadSample()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoInfos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoInfo = photoInfos[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoListCell
        cell.setup(
            backgroundColor: photoInfo.color.cgColor,
            username: photoInfo.user.name,
            thumbnailImageURL: URL(string: photoInfo.urls.thumb),
            profileImageURL: URL(string: photoInfo.user.profileImage.small)
        )
        return cell
    }
}

extension PhotoListCollectionViewController {
    private func loadSample() -> [PhotoInfo] {
        let sample: PhotoSearchResult = UnsplashExplorer.load("sample.json")
        return sample.results
    }
}
