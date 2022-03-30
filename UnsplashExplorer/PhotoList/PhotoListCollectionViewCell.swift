//
//  PhotoListCell.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import UIKit
import SnapKit
import Kingfisher

final class PhotoListCollectionViewCell: UICollectionViewCell {
    static let reuseId = "PhotoListCollectionViewCell"
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let profileImageSize: CGFloat = 24
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = profileImageSize / 2
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(profileImageSize)
        }
        return imageView
    }()
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        profileImageView.kf.cancelDownloadTask()
        
        thumbnailImageView.image = nil
        profileImageView.image = nil
        usernameLabel.text = nil
        backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func setup(
        backgroundColor: CGColor?,
        username: String,
        thumbnailImageURL: URL?,
        profileImageURL: URL?
    ) {
        self.backgroundColor = UIColor(
            cgColor: backgroundColor
            ?? CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        )
        usernameLabel.text = username
        thumbnailImageView.kf.setImage(
            with: thumbnailImageURL,
            options: [.transition(.fade(0.5))]
        )
        profileImageView.kf.setImage(with: profileImageURL)
    }
    
    private func layout() {
        thumbnailImageView.clipsToBounds = true
        
        let userStackView = UIStackView(arrangedSubviews: [profileImageView, usernameLabel])
        userStackView.axis = .horizontal
        userStackView.alignment = .center
        userStackView.spacing = 8
        
        let gradientView = GradientView()
        [
            thumbnailImageView,
            gradientView,
            userStackView
        ].forEach { contentView.addSubview($0) }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.bottom.width.equalToSuperview()
            make.height.equalTo(44)
        }
        
        userStackView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(10)
        }
    }
}

class GradientView: UIView {
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    init() {
        super.init(frame: .zero)
        
        guard let layer = self.layer as? CAGradientLayer else { return }
        layer.colors = [
          UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
          UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor,
          UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        ]
        layer.locations = [0, 0.45, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
