//
//  AutocompletesView.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/25.
//

import UIKit
import SnapKit

class AutocompletesView: UIView {
    private lazy var labels: [AutocompleteLabel] = {
        var labels = [AutocompleteLabel]()
        for _ in 1...5 {
            let label = AutocompleteLabel()
            label.text = ""
            labels.append(label)
        }
        return labels
    }()
    
    var texts: [String] {
        get {
            labels.compactMap { label in
                label.text.isEmpty ? nil : label.text
            }
        }
        set {
            for i in 0..<5 {
                if newValue.count > i {
                    labels[i].text = newValue[i]
                } else {
                    labels[i].text = ""
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.backgroundColor = .blue
        backgroundColor = .red
        
        addSubview(stackView)
        snp.makeConstraints { make in
            make.height.equalTo(stackView.snp.height)
        }
        
        stackView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
        }
    }
}

class AutocompleteLabel: UIView {
    private lazy var searchIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .init(systemName: "magnifyingglass")
        return imageView
    }()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15)
        label.text = ""
        label.backgroundColor = .yellow
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    var text: String {
        get { textLabel.text ?? "" }
        set {
            if newValue.isEmpty {
                textLabel.text = ""
                searchIconView.isHidden = true
            } else {
                textLabel.text = newValue
                searchIconView.isHidden = false
            }
        }
    }
    
    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [searchIconView, textLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        self.addSubview(stackView)
        
        searchIconView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        stackView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(80)
        }
        snp.makeConstraints { make in
//            make.height.equalTo(80)
        }
    }
}

import SwiftUI

struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        MyView()
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
struct MyView: UIViewRepresentable {
    typealias UIViewType = UIView
    func makeUIView(context: Context) -> UIView {
        
//        let view = AutocompletesView()
//        view.texts = ["123","9","2","3","1"]
        
        let view = AutocompleteLabel()
        view.text = "12345"
        
        return view
        
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        
        
    }
    
}
