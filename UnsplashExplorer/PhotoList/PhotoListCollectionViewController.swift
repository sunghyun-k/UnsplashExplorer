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
        
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        photoInfos = loadSample()
        
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        
    }
    
    //MARK: UICollectionViewCompositionalLayout
    
    private func layout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(2/3)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        
        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
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
        CGFloat([50,900].randomElement()!)
    }
}
