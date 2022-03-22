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
    var cellPadding: CGFloat = 5
    var numberOfColumns = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        photoInfos = loadSample()
        
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        layout.cellPadding = self.cellPadding
        layout.numberOfColumns = self.numberOfColumns
        collectionView.collectionViewLayout = layout
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoInfos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoInfo = photoInfos[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoListCell
        cell.setup(
            backgroundColor: photoInfo.color.cgColor,
            username: photoInfo.user.name,
            thumbnailImageURL: URL(string: photoInfo.photoImageUrls.thumb),
            profileImageURL: URL(string: photoInfo.user.profileImage.small)
        )
        return cell
    }
}

private extension PhotoListCollectionViewController {
    func loadSample() -> [PhotoInfo] {
        let sample: PhotoSearchResult = UnsplashExplorer.load("sample.json")
        return sample.results
    }
}

extension PhotoListCollectionViewController: PhotoListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let photoItem = photoInfos[indexPath.item]
        
        let inset = collectionView.contentInset
        let columnWidth = (collectionView.bounds.width - inset.right - inset.bottom - (self.cellPadding * CGFloat(self.numberOfColumns) * 2)) / CGFloat(self.numberOfColumns)
        let aspectRatio = CGFloat(photoItem.height) / CGFloat(photoItem.width)
        return columnWidth * aspectRatio
    }
}
