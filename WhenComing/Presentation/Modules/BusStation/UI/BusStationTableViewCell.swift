//
//  BusStationTableViewCell.swift
//  WhenComing
//
//  Created by jh on 12/9/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class BusStationTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    static let cellId = "BusStationTableViewCell"
    
    private let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        
        setConstraints()
    }
    
    private func setConstraints() {
        cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func configure(busNumber: String, busType: String, busTime: String) {
        
    }
}
