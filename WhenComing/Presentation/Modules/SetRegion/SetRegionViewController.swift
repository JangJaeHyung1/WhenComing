//
//  SetRegionViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SetRegionViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var vm = BusStationDIContainer().makeBusStationViewModel()
    
    
    var cityCodes: [String] = ["서울","부산","대구","대전","울산","제주","마산","전북","서울","부산",
                               "대구","대전","울산","제주","마산","전북","서울","부산","대구","대전",
                               "울산","제주","마산","전북","서울","부산","대구","대전","울산","제주",]
    var collectionView: UICollectionView!
    
    
    private let nextBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .systemGray4
        btn.isEnabled = false
        btn.tintColor = .white
        btn.setTitle("다음", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


extension SetRegionViewController {
    private func setUp() {
        configure()
        setCollectionView()
        setNavi()
        addViews()
        setConstraints()
        bind()
        fetch()
    }
    
    
    
    private func setCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
//        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CityCell.self, forCellWithReuseIdentifier: CityCell.cellId)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionCellUI()
    }
    private func configure() {
        view.backgroundColor = .white
    }
    
    private func fetch() {
        vm.input.fetchCityCodesTrigger.accept(())
        
    }
    func enableBtn() {
        nextBtn.isEnabled = true
        nextBtn.backgroundColor = .systemBlue
    }
    
    private func bind() {
        // MARK: - input

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        // MARK: - items
        vm.output.cityCodes
            .drive(collectionView.rx.items(
                cellIdentifier: CityCell.cellId,
                cellType: CityCell.self
            )) { _, entity, cell in
                cell.configure(with: entity)
            }
            .disposed(by: disposeBag)

        // MARK: - selection (optional)
        collectionView.rx.modelSelected(BusCityCodeEntity.self)
            .subscribe(onNext: { [weak self] entity in
                guard let self else { return }
                enableBtn()
            })
            .disposed(by: disposeBag)
        
        vm.output.error.asObservable()
            .subscribe(onNext:{ [weak self] res in
                guard let self else { return }
                print("🔴error:\(res.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setNavi() {
        self.navigationItem.title = "지역 선택"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func addViews() {
        view.addSubview(collectionView)
        view.addSubview(nextBtn)
    }
    
    private func setConstraints() {
        nextBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(42)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-18)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top).offset(-12)
        }
    }
}



extension SetRegionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interval:CGFloat = 8
        let width: CGFloat = ( UIScreen.main.bounds.width - interval * 3 - ( 12 * 2)) / 3
        return CGSize(width: width , height: 40 )
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    //collection VC section 마진값
    func collectionCellUI(){
        let interval:CGFloat = 12
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: interval , left: interval, bottom: 0, right: interval)
        self.collectionView.collectionViewLayout = flowLayout
    }
}
