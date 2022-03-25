//
//  HalfModalViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/25.
//

import UIKit

class HalfModalViewController: UIViewController {
    private var dataSource: [(title: String, description: String?)]
    
    init(photoDetail: PhotoDetailInfo) {
        let iso: String?
        if photoDetail.exif.iso != nil {
            iso = "\(photoDetail.exif.iso!)"
        } else {
            iso = nil
        }
        
        let aperture: String?
        if photoDetail.exif.aperture != nil {
            aperture = "𝑓/\(photoDetail.exif.aperture!)"
        } else {
            aperture = nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let publishedAt: String?
        if let createdAt = dateFormatter.date(from: String(photoDetail.createdAt.dropLast(15))) {
            dateFormatter.dateStyle = .short
            let date = dateFormatter.string(from: createdAt)
            publishedAt = date
        } else {
            publishedAt = nil
        }
        
        self.dataSource = [
            ("Maker", photoDetail.exif.maker),
            ("Focal Length", photoDetail.exif.focalLength),
            ("Model", photoDetail.exif.model),
            ("ISO", iso),
            ("Shutter Speed", photoDetail.exif.exposureTime),
            ("Dimensions", "\(photoDetail.width) x \(photoDetail.height)"),
            ("Aperture", aperture),
            ("Published", publishedAt),
        ]
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Views
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 1
        )
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            DetailInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: DetailInfoCollectionViewCell.reuseId
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension HalfModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailInfoCollectionViewCell.reuseId, for: indexPath) as! DetailInfoCollectionViewCell
        let item = dataSource[indexPath.item]
        cell.title = item.title
        cell.text = item.description ?? "-"
        return cell
    }
}
