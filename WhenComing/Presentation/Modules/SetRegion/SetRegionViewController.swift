//
//  SetRegionViewController.swift
//  WhenComing
//
//  Created by jh on 2/1/25.
//

import UIKit
import RxSwift
import RxCocoa

class SetRegionViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var vm = BusStationDIContainer().makeBusStationViewModel()
    
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
        setNavi()
        addViews()
        setConstraints()
        bind()
        fetch()
    }
    private func configure() {
        view.backgroundColor = .white
    }
    
    private func fetch() {
        vm.input.fetchCityCodesTrigger.accept(())
        
    }
    
    private func bind() {
        // MARK: - input
        
        
    }
    
    private func setNavi() {
        //        self.navigationItem.title = "<#title#>"
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        //        self.navigationItem.largeTitleDisplayMode = .always
        //        self.navigationItem.setHidesBackButton(true, animated: true)
        //        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        //        self.navigationController?.navigationBar.isHidden = false
        //        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func addViews() {
        
    }
    
    private func setConstraints() {
    }
}
