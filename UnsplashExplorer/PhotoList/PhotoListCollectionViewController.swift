//
//  PhotoListCollectionViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import UIKit
import RxSwift
import RxCocoa

private let reuseIdentifier = "PhotoListCell"

class PhotoListCollectionViewController: UIViewController {
    var viewModel: PhotoListViewModel
    
    let disposeBag = DisposeBag()
    
    lazy var collectionView: UICollectionView = {
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        layout.cellPadding = self.cellPadding
        layout.numberOfColumns = self.numberOfColumns
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        return collectionView
    }()
    
    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    var cellPadding: CGFloat = 5
    var numberOfColumns = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind(viewModel: viewModel)
        
        viewModel.searchPhoto(byKeyword: "apple", page: 1, perPage: 10)
    }
    
    private func bind(viewModel: PhotoListViewModel) {
        viewModel.dataSource.bind(
            to: collectionView.rx.items(
                cellIdentifier: reuseIdentifier,
                cellType: PhotoListCell.self
            )
        ) { (index, photoInfo, cell) in
            cell.setup(
                backgroundColor: photoInfo.color.cgColor,
                username: photoInfo.user.name,
                thumbnailImageURL: URL(string: photoInfo.photoImageUrls.thumb),
                profileImageURL: URL(string: photoInfo.user.profileImage.small)
            )
        }
        .disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}

// MARK: - PhotoListLayoutDelegate

extension PhotoListCollectionViewController: PhotoListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let photoInfo = try? viewModel.dataSource.value()[indexPath.item] else {
            return 0
        }
        
        let inset = collectionView.contentInset
        let columnWidth = (collectionView.bounds.width - inset.right - inset.bottom - (self.cellPadding * CGFloat(self.numberOfColumns) * 2)) / CGFloat(self.numberOfColumns)
        let aspectRatio = CGFloat(photoInfo.height) / CGFloat(photoInfo.width)
        return columnWidth * aspectRatio
    }
}
