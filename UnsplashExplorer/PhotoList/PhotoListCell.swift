//
//  PhotoListCell.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import UIKit
import SnapKit
import Kingfisher

final class PhotoListCell: UICollectionViewCell {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        profileImageView.kf.cancelDownloadTask()
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
        thumbnailImageView.kf.setImage(with: thumbnailImageURL)
        profileImageView.kf.setImage(with: profileImageURL)
    }
    
    private func layout() {
        thumbnailImageView.clipsToBounds = true
        
        let userInfoStackView = UIStackView(arrangedSubviews: [profileImageView, usernameLabel])
        userInfoStackView.axis = .horizontal
        userInfoStackView.alignment = .center
        userInfoStackView.spacing = 15
        
        [
            thumbnailImageView,
            userInfoStackView
        ].forEach { contentView.addSubview($0) }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        userInfoStackView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(20)
        }
    }
}
