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

final class PhotoListCollectionViewController: UIViewController {
    var viewModel: PhotoListViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var collectionView: UICollectionView = {
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        layout.cellPadding = self.cellPadding
        layout.numberOfColumns = self.numberOfColumns
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
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
        
        layout()
        bind(viewModel: viewModel)
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
        
        _ = searchBar.rx.text
            .subscribe(onNext: {
                guard let text = $0,
                      !text.isEmpty else {
                    viewModel.dataSource.onNext([])
                    return
                }
                viewModel.searchQuery.onNext(text)
            })
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        [
            collectionView,
            searchBar
        ].forEach {
            view.addSubview($0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
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
