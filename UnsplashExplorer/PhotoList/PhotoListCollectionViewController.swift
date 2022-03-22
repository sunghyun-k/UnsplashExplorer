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
        collectionView.collectionViewLayout = layout()
    }
    
    //MARK: UICollectionViewCompositionalLayout
    
    private func layout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            sectionNumber, environment -> NSCollectionLayoutSection? in
//            guard let self = self else { return nil }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.45))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            return section
        }
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
