
# 언제오지 (WhenComing)

국토교통부 TAGO API를 기반으로 실시간 대중교통 도착 정보를 제공하는 iOS 앱입니다.  
버스 정류장 검색, 도착 예정 시간 조회 등을 지원하며, 사용자의 이동 흐름에 맞춘 직관적인 UI를 제공하는 것을 목표로 개발 중입니다.

## 구조 및 아키텍처

- Clean Architecture 기반의 계층 분리 (Presentation / Domain / Data)
- 의존성 주입(DI) 및 네트워크 모듈화 구조 구성
- TAGO API 응답에 맞춘 DTO 정의 및 Entity 매핑 완료
- API 호출 로직 및 예외 처리 흐름 구현 완료
- RxSwift 기반 MVVM 아키텍처 적용 예정 (UI 작업 전)

## 진행 현황

- API 연동 및 데이터 처리 구조 구현 완료
- UI/UX 구현 및 데이터 바인딩 작업 진행 예정
- Clean Architecture 기반 디렉토리 및 DIContainer 구성 완료

## 사용 기술

- Swift 5, UIKit, RxSwift
- Clean Architecture, MVVM
- URLSession, Codable
- Swift Concurrency (async/await)



## Archive 

검색 페이지에 정류소와 버스 노선이 하나의 리스트에 나타나도록 설계하였습니다. 
두개의 entity를 통합된 리스트에 노출시켜야하는데, 통일된 enitiy를 새로 만들거나 두개의 섹션으로 나누어 리스트를 표현하기 보다는 enum을 사용하여 하나의 배열로 나타내어 쉽게 표현할수 있도록 하였습니다. 
추가될 (지하철 검색결과) 사항에 대해서도 enum case로 수정이 용이합니다.

```
vm.output.items
            .drive(
                tableView.rx.items(
                    cellIdentifier: "cell",
                    cellType: UITableViewCell.self
                )
            ) { row, item, cell in

                switch item {
                case .route(let route):
                    cell.textLabel?.text = "\(route.routeNo) \(route.routeType)"
                case .station(let station):
                    if let stationNum = station.stationNumber {
                        cell.textLabel?.text = "\(station.name) (\(stationNum)) 버스역"
                    } else {
                        cell.textLabel?.text = "\(station.name) 버스역"
                    }
                    
                }
            }
            .disposed(by: disposeBag)
```

