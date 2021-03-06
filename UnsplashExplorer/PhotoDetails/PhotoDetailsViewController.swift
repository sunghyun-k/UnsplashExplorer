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

class PhotoDetailsViewController: UIViewController {
    var viewModel: PhotoDetailsViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: Views
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var userStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    private lazy var profileImageSize: CGFloat = 40
    private lazy var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = profileImageSize / 2
        imageView.layer.cornerCurve = .circular
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
    
    private lazy var viewsLabel: VLabeledTextLabel = {
        let label = VLabeledTextLabel()
        label.title = "Views"
        return label
    }()
    private lazy var downloadsLabel: VLabeledTextLabel = {
        let label = VLabeledTextLabel()
        label.title = "Downloads"
        return label
    }()
    
    private lazy var dateLabel: LeftIconLabel = {
        let label = LeftIconLabel()
        label.icon = UIImage(systemName: "calendar")!
        return label
    }()
    private lazy var gearLabel: LeftIconLabel = {
        let label = LeftIconLabel()
        label.icon = UIImage(systemName: "camera")!
        return label
    }()
    private lazy var lisenceLabel: LeftIconLabel = {
        let label = LeftIconLabel()
        label.setup(icon: UIImage(systemName: "checkmark.shield")!, description: "Free to use under the Unsplash License")
        return label
    }()
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        return button
    }()
    
    init(viewModel: PhotoDetailsViewModel) {
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
    
    private func bind(viewModel: PhotoDetailsViewModel) {
        // photoDetail??? fetch?????? ?????? ????????????
        viewModel.photo
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
        
        // infoButton Tapped
        infoButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                guard let detail = viewModel.photo.value else { return }
                let halfModal = HalfModalViewController(photoDetail: detail)
                self.present(halfModal, animated: false)
            }
            .disposed(by: disposeBag)
        
        viewModel.events
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .presentUser(let viewModel):
                    let userDetailsView = UserDetailsViewController(viewModel: viewModel)
                    self.navigationController?.pushViewController(userDetailsView, animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        let userTap = UITapGestureRecognizer()
        userTap.delaysTouchesBegan = false
        userTap.delaysTouchesEnded = false
        
        userStackView.addGestureRecognizer(userTap)
        userTap.rx.event
            .bind(onNext: { _ in
                viewModel.selectUser()
            })
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        // ????????? ????????? ??? ??????
        let nameStackView = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        nameStackView.axis = .vertical
        nameStackView.spacing = 2
        userProfileImageView.contentMode = .scaleAspectFit
        userProfileImageView.snp.makeConstraints { make in
            make.width.equalTo(profileImageSize)
            make.height.equalTo(userProfileImageView.snp.width)
        }
        
        [userProfileImageView, nameStackView].forEach {
            userStackView.addArrangedSubview($0)
        }
        
        // ?????????, ???????????? ???
        let countRecordStackView = UIStackView(arrangedSubviews: [
            viewsLabel,
            downloadsLabel,
            UIView(),
            infoButton
        ])
        countRecordStackView.axis = .horizontal
        countRecordStackView.distribution = .fillEqually
        viewsLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(80)
        }
        countRecordStackView.distribution = .fill
        countRecordStackView.setCustomSpacing(30, after: viewsLabel)
        
        // ?????? ?????? ??????
        let detailStackView = UIStackView(arrangedSubviews: [dateLabel, gearLabel, lisenceLabel])
        detailStackView.axis = .vertical
        detailStackView.spacing = 10
        
        // ?????? StackView
        let stackView = UIStackView(arrangedSubviews: [
            userStackView,
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
            make.width.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        // ??????
        photoImageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(photoImageView.snp.width)
        }
    }
    
    private func setup(photoDetail: PhotoDetails) {
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
        usernameLabel.text = "@\(photoDetail.user.username)"
        
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
    }
}
