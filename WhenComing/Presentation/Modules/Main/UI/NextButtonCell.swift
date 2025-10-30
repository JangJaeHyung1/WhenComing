//
//  NextButtonCell.swift
//  WhenComing
//
//  Created by jh on 10/28/25.
//

import UIKit
import SnapKit

class NextButtonCell: UITableViewCell {
    static var cellId: String = "NextButtonCell"
    private let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+ 추가하기", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.layer.borderColor = UIColor.label.cgColor
        btn.layer.borderWidth = 1
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cellView)
        cellView.addSubview(nextButton)
        cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            nextButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            nextButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

