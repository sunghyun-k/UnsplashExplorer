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
    private let thumbnailImageView = UIImageView()
    private let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    private let usernameLabel = UILabel()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        profileImageView.kf.cancelDownloadTask()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        attribute()
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
    
    private func attribute() {
        usernameLabel.textColor = .white
        usernameLabel.font = .systemFont(ofSize: 12)
    }
    
    private func layout() {
        let userInfoStackView = UIStackView(arrangedSubviews: [profileImageView, usernameLabel])
        userInfoStackView.axis = .horizontal
        userInfoStackView.alignment = .center
        userInfoStackView.spacing = 8
        
        [thumbnailImageView, userInfoStackView]
            .forEach { contentView.addSubview($0) }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        userInfoStackView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(20)
        }
    }
}
