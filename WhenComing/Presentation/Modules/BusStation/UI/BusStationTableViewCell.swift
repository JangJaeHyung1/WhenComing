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
    
    private let busLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textColor = .label
        lbl.font = .systemFont(ofSize: 17, weight: .bold)
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = true
        //    lbl.adjustsFontSizeToFitWidth = true
        //    lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    private let timeLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 1
        lbl.textColor = .systemOrange
        lbl.lineBreakMode = .byWordWrapping
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    private let starImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "star")
        img.tintColor = .systemYellow
        img.translatesAutoresizingMaskIntoConstraints = false
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        //img.layer.masksToBounds = true
        return img
    }()
    
    private let starBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        
        cellView.addSubview(busLbl)
        cellView.addSubview(timeLbl)
        cellView.addSubview(starImage)
        cellView.addSubview(starBtn)
        setConstraints()
    }
    
    private func setConstraints() {
        cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(60)
        }
        
        busLbl.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        starImage.snp.makeConstraints { make in
            make.width.height.equalTo(26)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        starBtn.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.center.equalTo(starImage)
        }
        
        timeLbl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(starImage.snp.leading).offset(-10)
        }
    }
    func configure(busNumber: String, busType: String, busTime: Int?, busStationAgo: Int?) {
        busLbl.text = "\(busNumber)   \(busType)"
        if let busTime = busTime, let busStationAgo = busStationAgo {
            let min = Int(busTime / 60)
            let seconds = busTime - (min * 60)
            let timeText = min == 0 ? "곧 도착" : "\(min)분 \(seconds)초 (\(busStationAgo)정거장 전)"
            timeLbl.textColor = .systemOrange
            timeLbl.text = timeText
        } else {
            timeLbl.textColor = .secondaryLabel
            timeLbl.text = "도착 정보 없음"
        }
    }
}
