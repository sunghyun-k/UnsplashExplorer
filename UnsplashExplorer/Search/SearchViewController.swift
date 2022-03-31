//
//  SearchViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import UIKit
import RxSwift
import RxCocoa

private let autocompleteReuseId = "AutocompleteTableViewCell"

final class SearchViewController: UIViewController {
    private var searchViewModel: SearchViewModel
    private var autocompleteViewModel: AutocompleteViewModel
    
    // MARK: Configuration
    var cellPadding: CGFloat = 5
    var numberOfColumns = 2
    
    // MARK: Properties
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var collectionView: UICollectionView = {
        let layout = PhotoListCollectionViewLayout()
        layout.delegate = self
        layout.cellPadding = self.cellPadding
        layout.numberOfColumns = self.numberOfColumns
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoListCell.self, forCellWithReuseIdentifier: PhotoListCell.reuseId)
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    private lazy var backgroundTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 20)
        textView.textColor = .gray
        textView.textAlignment = .center
        textView.text = "검색 결과 없음"
        return textView
    }()
    
    private lazy var autocompletesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: autocompleteReuseId)
        return tableView
    }()
    
    // MARK: Prepare
    init(
        searchViewModel: SearchViewModel,
        autocompleteViewModel: AutocompleteViewModel
    ) {
        self.searchViewModel = searchViewModel
        self.autocompleteViewModel = autocompleteViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind(searchModel: searchViewModel, autocompleteModel: autocompleteViewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.contentInset = UIEdgeInsets(
            top: searchBar.frame.height + cellPadding,
            left: cellPadding,
            bottom: 0,
            right: cellPadding
        )
    }
    
    private func bind(searchModel: SearchViewModel, autocompleteModel: AutocompleteViewModel) {
        // collectionView 데이터 소스
        searchModel.photos
            .bind(to: collectionView.rx.items(
                cellIdentifier: PhotoListCell.reuseId,
                cellType: PhotoListCell.self
            )) { index, photo, cell in
                cell.setup(
                    backgroundColor: photo.color.cgColor,
                    username: photo.user.name,
                    thumbnailImageURL: URL(string: photo.imageURLs.small),
                    profileImageURL: URL(string: photo.user.profileImageURLs.small)
                )
            }
            .disposed(by: disposeBag)
        
        // searchBar 텍스트를 viewModel에 전달한다.
        searchBar.rx.text
            .subscribe(onNext: { text in
                autocompleteModel.searchText.accept(text ?? "")
            })
            .disposed(by: disposeBag)
        
        // 자동완성 셀 연결
        autocompleteModel.autocompletes
            .bind(to: autocompletesTableView.rx.items(
                cellIdentifier: autocompleteReuseId,
                cellType: UITableViewCell.self
            )) { index, autocomplete, cell in
                var content = cell.defaultContentConfiguration()
                content.image = UIImage(systemName: "magnifyingglass")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
                content.text = autocomplete
                content.textProperties.color = .darkGray
                content.imageProperties.maximumSize.width = 18
                content.imageToTextPadding = 10
                cell.contentConfiguration = content
            }
            .disposed(by: disposeBag)
        
        // autocomplete 선택 시 동작
        autocompletesTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let text = autocompleteModel.autocompletes.value[indexPath.item]
                self.searchBar.text = text
                self.finishSearchBar()
                searchModel.searchPhotos(byQuery: text)
            })
            .disposed(by: disposeBag)
        
        // searchBar 작동 시작시 자동완성 보이기
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.autocompletesTableView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        // search 버튼이 눌렸을 때 검색을 수행
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.finishSearchBar()
                searchModel.searchPhotos(byQuery: self.searchBar.text ?? "")
            })
            .disposed(by: disposeBag)
        
        // dataSource가 비어있는지 여부에 따라 배경 메시지를 토글한다.
        searchModel.photos
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                if data.isEmpty {
                    self.backgroundTextView.isHidden = false
                } else {
                    self.backgroundTextView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        // 스크롤 맨 밑에 도달 시 추가로 결과를 로드한다.
        collectionView.rx.contentOffset
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                let contentHeight = self.collectionView.contentSize.height
                if contentOffset.y > contentHeight - self.collectionView.frame.height {
                    searchModel.loadMore()
                }
            })
            .disposed(by: disposeBag)
        
        // 이미지 셀 선택 동작 바인딩
        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                searchModel.selectPhoto(at: indexPath.item)
            })
            .disposed(by: disposeBag)
        
        searchModel.events
            .subscribe(onNext: { event in
                switch event {
                case .presentPhoto(let viewModel):
                    let photoDetailsView = PhotoDetailsViewController(viewModel: viewModel)
                    self.navigationController?.pushViewController(photoDetailsView, animated: true)
                case .presentUser(let viewModel):
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        [
            collectionView,
            backgroundTextView,
            searchBar,
            autocompletesTableView
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
        autocompletesTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        backgroundTextView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(50)
        }
    }
    
    // MARK: Methods
    private func finishSearchBar() {
        self.searchBar.endEditing(true)
        self.autocompletesTableView.isHidden = true
        self.removeLayoutCache()
        if self.collectionView.numberOfItems(inSection: 0) > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
    private func removeLayoutCache() {
        guard let layout = collectionView.collectionViewLayout as? PhotoListCollectionViewLayout else {
            return
        }
        layout.removeLayoutCache()
        collectionView.contentSize.height = 0
    }
}

// MARK: - PhotoListLayoutDelegate

extension SearchViewController: PhotoListLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForCellAtIndexPath indexPath: IndexPath
    ) -> CGFloat {
        let photos = self.searchViewModel.photos.value
        guard photos.count > indexPath.item else { return 0 }
        let photo = photos[indexPath.item]
        
        let inset = collectionView.contentInset
        let contentWidth = collectionView.bounds.width - inset.right - inset.left
        let totalPadding = self.cellPadding * CGFloat(self.numberOfColumns) * 2
        let columnWidth = (contentWidth - totalPadding) / CGFloat(self.numberOfColumns)
        let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
        return columnWidth * aspectRatio
    }
}
