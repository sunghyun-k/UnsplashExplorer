//
//  PhotoDetailViewController.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher

class PhotoDetailViewController: UIViewController {
    var viewModel: PhotoListViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var allViews = [
        photoImageView,
        userProfileImageView,
        nameLabel,
        usernameLabel,
        viewsLabel,
        downloadsLabel,
        dateLabel,
        gearLabel
    ]
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var profileImageSize: CGFloat = 40
    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = profileImageSize / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var viewsLabel: TitleInfoLabel = {
        let label = TitleInfoLabel()
        label.title = "Views"
        return label
    }()
    private lazy var downloadsLabel: TitleInfoLabel = {
        let label = TitleInfoLabel()
        label.title = "Downloads"
        return label
    }()
    
    private lazy var dateLabel: IconAndDescriptionLabel = {
        let label = IconAndDescriptionLabel()
        label.icon = UIImage(systemName: "calendar")!
        return label
    }()
    private lazy var gearLabel: IconAndDescriptionLabel = {
        let label = IconAndDescriptionLabel()
        label.icon = UIImage(systemName: "camera")!
        return label
    }()
    private lazy var lisenceLabel: IconAndDescriptionLabel = {
        let label = IconAndDescriptionLabel()
        label.setup(icon: UIImage(systemName: "checkmark.shield")!, description: "Free to use under the Unsplash License")
        return label
    }()
    
    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Prepare
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
        bind(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetViews()
    }
    
    private func bind(viewModel: PhotoListViewModel) {
        // photoDetail이 fetch되면 뷰에 표시한다
        viewModel.photoDetailInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] photo in
                guard let self = self else {
                    return
                }
                guard let photo = photo else {
                    self.dismiss(animated: true)
                    return
                }
                self.setup(photoDetail: photo)
            })
            .disposed(by: disposeBag)
        
        // TODO: 제스쳐 동작 설정
        let leftGesture = UISwipeGestureRecognizer()
        leftGesture.direction = .left
        
        let rightGesture = UISwipeGestureRecognizer()
        rightGesture.direction = .right
        
        [leftGesture, rightGesture].forEach {
            view.addGestureRecognizer($0)
        }
        
        leftGesture.rx.event.bind(onNext: { recognizer in
            print("swipe: \(recognizer.direction)")
        })
        .disposed(by: disposeBag)
        
        rightGesture.rx.event.bind(onNext: { recognizer in
            print("swipe: \(recognizer.direction)")
        })
        .disposed(by: disposeBag)
    }
    
    private func layout() {
        // 프로필 이미지 및 이름
        let nameStackView = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        nameStackView.axis = .vertical
        nameStackView.spacing = 2
        userProfileImageView.contentMode = .scaleAspectFit
        userProfileImageView.snp.makeConstraints { make in
            make.width.equalTo(profileImageSize)
            make.height.equalTo(userProfileImageView.snp.width)
        }
        let profileStackView = UIStackView(arrangedSubviews: [userProfileImageView, nameStackView])
        profileStackView.axis = .horizontal
        profileStackView.spacing = 8
        
        // 조회수, 다운로드 수
        let countRecordStackView = UIStackView(arrangedSubviews: [
            viewsLabel,
            downloadsLabel,
            UIView()
        ])
        countRecordStackView.axis = .horizontal
        countRecordStackView.spacing = 30
        viewsLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(80)
        }
        countRecordStackView.distribution = .fill
        
        // 사진 상세 정보
        let detailStackView = UIStackView(arrangedSubviews: [dateLabel, gearLabel, lisenceLabel])
        detailStackView.axis = .vertical
        detailStackView.spacing = 10
        
        // 최종 StackView
        let stackView = UIStackView(arrangedSubviews: [
            profileStackView,
            photoImageView,
            countRecordStackView,
            detailStackView,
            UIView()
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        let scrollView = UIScrollView()
        scrollView.addSubview(stackView)
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width).inset(10)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        // 사진
        photoImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(photoImageView.snp.width)
        }
    }
    
    private func setup(photoDetail: PhotoDetailInfo) {
        if let backgroundColor = photoDetail.color.cgColor {
            photoImageView.backgroundColor = UIColor(cgColor: backgroundColor)
        }
        let imageRatio = CGFloat(photoDetail.height) / CGFloat(photoDetail.width)
        photoImageView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(photoImageView.snp.width).multipliedBy(imageRatio)
        }
        
        self.photoImageView.kf.setImage(
            with: URL(string: photoDetail.imageURLs.regular),
            options: [.transition(.fade(0.5))]
        )
        self.userProfileImageView.kf.setImage(
            with: URL(string: photoDetail.user.profileImageURLs.medium),
            options: [.transition(.fade(0.5))]
        )
        nameLabel.text = photoDetail.user.name
        usernameLabel.text = photoDetail.user.username
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let views = numberFormatter.string(from: photoDetail.views as NSNumber)
        let downloads = numberFormatter.string(from: photoDetail.downloads as NSNumber)
        
        viewsLabel.text = views
        downloadsLabel.text = downloads
        // 2020-05-20T16:10:22-04:00
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let createdAt = dateFormatter.date(from: String(photoDetail.createdAt.dropLast(15))) {
            dateFormatter.dateStyle = .short
            let date = dateFormatter.string(from: createdAt)
            dateLabel.text = "Published on \(date)"
        }
        gearLabel.text = photoDetail.exif.name
        allViews.forEach { $0.isHidden = false }
    }
    
    // MARK: Methods
    
    private func resetViews() {
        photoImageView.image = nil
        photoImageView.backgroundColor = .lightGray
        userProfileImageView.image = nil
        nameLabel.text = nil
        usernameLabel.text = nil
        viewsLabel.text = nil
        downloadsLabel.text = nil
        dateLabel.text = nil
        gearLabel.text = nil
        
        allViews.forEach { $0.isHidden = true }
    }
}
