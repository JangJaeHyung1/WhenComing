//
//  MainViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainViewController: UIViewController {

    private let segmentControlView: SegmentControlView = {
        let view = SegmentControlView(titles: ["출근길", "퇴근길"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
}



extension MainViewController {
    private func setUp() {
        configure()
        setNavi()
        addViews()
        setConstraints()
        bind()
        updateSegmentForCurrentTime()
        fetch()
    }
    private func configure() {
        view.backgroundColor = .systemBackground
    }
    
    private func fetch() {
        
    }

    /// 03:00 ≤ now < 15:00  => 출근(0)
    /// 15:00 ≤ now or now < 03:00 => 퇴근(1)
    private func updateSegmentForCurrentTime() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now) // 0...23, device timezone
        let isCommuteTime = (hour >= 3 && hour < 15)
        let targetIndex = isCommuteTime ? 0 : 1
        segmentControlView.select(index: targetIndex, animated: false)
    }
    
    private func bind() {
        segmentControlView.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    @objc private func segmentChanged(_ sender: SegmentControlView) {
        switch sender.selectedIndex {
        case 0:
            // 출근길 탭 선택 시 처리
            print("출근길 탭 선택")
        case 1:
            // 퇴근길 탭 선택 시 처리
            print("퇴근길 탭 선택")
        default:
            break
        }
    }
    
    private func setNavi() {
        self.navigationItem.title = "언제오지"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func addViews() {
        view.addSubview(segmentControlView)
    }
    
    private func setConstraints() {
        
        segmentControlView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(44)
        }
    }
}
