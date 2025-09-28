//
//  CityCell.swift
//  WhenComing
//
//  Created by jh on 9/28/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class CityCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    static let cellId = "CityCell"
    
    private let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.systemGray3.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    private let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textColor = .black
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = true
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        //        cellView.setShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        cellView.setShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        contentView.addSubview(cellView)
        cellView.addSubview(titleLbl)
        setConstraints()
    }
    
    private func setConstraints() {
        cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0).isActive = true
        cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0).isActive = true
        
        titleLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    func configure(with presentable: BusCityCodeEntity) {
        titleLbl.text = presentable.name
        
    }
}
