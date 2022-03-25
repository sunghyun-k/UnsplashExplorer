//
//  TitleInfoLabel.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/24.
//

import UIKit
import SnapKit

class TitleInfoLabel: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var text: String? {
        get { infoLabel.text }
        set { infoLabel.text = newValue }
    }
    
    func setup(title: String, info: String) {
        titleLabel.text = title
        infoLabel.text = info
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, infoLabel])
        stackView.axis = .vertical
        stackView.spacing = 3
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.height.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.width.equalTo(infoLabel.snp.width)
        }
    }
}

