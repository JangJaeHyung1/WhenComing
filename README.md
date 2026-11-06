
# 언제오지 (WhenComing)

국토교통부 TAGO API를 기반으로 실시간 대중교통 도착 정보를 제공하는 iOS 앱입니다.  
버스 정류장 검색, 도착 예정 시간 조회 등을 지원하며, 사용자의 이동 흐름에 맞춘 직관적인 UI를 제공하는 것을 목표로 개발 중입니다.

## 구조 및 아키텍처

- Clean Architecture 기반의 계층 분리 (Presentation / Domain / Data)
- 의존성 주입(DI) 및 네트워크 모듈화 구조 구성
- TAGO API 응답에 맞춘 DTO 정의 및 Entity 매핑 완료
- API 호출 로직 및 예외 처리 흐름 구현 완료
- RxSwift 기반 MVVM으로 화면과 ViewModel 구성

## 프로젝트 디렉터리 구조

아래는 Git에서 관리하는 주요 소스 및 설정 파일의 구조입니다. `.DS_Store`와 Xcode의 사용자별 설정 파일은 제외했습니다.

```text
WhenComing/
├── WhenComing/
│   ├── Application/
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   ├── Base.lproj/
│   │   ├── LaunchScreen.storyboard
│   │   └── Main.storyboard
│   ├── Data/
│   │   ├── DataSource/
│   │   │   ├── BusArrivalRemoteDataSource.swift
│   │   │   ├── BusCityCodeLocalDataSource.swift
│   │   │   ├── BusRouteRemoteDataSource.swift
│   │   │   ├── BusStationRemoteDataSource.swift
│   │   │   └── FavoriteBusLocalDataSource.swift
│   │   ├── DTOs/
│   │   │   ├── BusRoute/
│   │   │   │   ├── BusRouteDTO.swift
│   │   │   │   ├── BusRouteInfoDTO.swift
│   │   │   │   └── SpecificBusArrivalDTO.swift
│   │   │   └── BusStation/
│   │   │       ├── ArroundBusStationDTO.swift
│   │   │       ├── BusCityCodeDTO.swift
│   │   │       ├── BusStaionDTO.swift
│   │   │       ├── BusStationArrivalInfoDTO.swift
│   │   │       └── StationThrghBusDTO.swift
│   │   ├── Network/
│   │   │   ├── APIEndpoint.swift
│   │   │   ├── APIError.swift
│   │   │   ├── APIPath.swift
│   │   │   ├── NetworkConfig.swift
│   │   │   └── NetworkService.swift
│   │   └── Repositories/
│   │       ├── BusArrivalRepositoryImpl.swift
│   │       ├── BusCityCodeRepositoryImpl.swift
│   │       ├── BusRouteRepositoryImpl.swift
│   │       ├── BusStationRepositoryImpl.swift
│   │       └── FavoriteBusRepositoryImpl.swift
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── BusRoute/
│   │   │   │   ├── BusRouteEntity.swift
│   │   │   │   ├── BusRouteInfoEntity.swift
│   │   │   │   ├── FavoriteBusEntity.swift
│   │   │   │   └── SpecificBusArrivalEntity.swift
│   │   │   └── BusStation/
│   │   │       ├── AroundBusStationEntity.swift
│   │   │       ├── BusCityCodeEntity.swift
│   │   │       ├── BusStationArrivalInfoEntity.swift
│   │   │       ├── BusStationEntity.swift
│   │   │       └── StationThrghBusEntity.swift
│   │   ├── Interfaces/
│   │   │   ├── BusArrivalRepositoryProtocol.swift
│   │   │   ├── BusCityCodeRepositoryProtocol.swift
│   │   │   ├── BusRouteRepositoryProtocol.swift
│   │   │   ├── BusStationRepositoryProtocol.swift
│   │   │   └── FavoriteBusRepositoryProtocol.swift
│   │   └── UseCases/
│   │       ├── BusRoute/
│   │       │   ├── Favorite/
│   │       │   │   ├── ObserveFavoriteBusListUseCase.swift
│   │       │   │   ├── ObserveFavoriteBusUseCase.swift
│   │       │   │   └── ToggleFavoriteBusUseCase.swift
│   │       │   ├── GetBusRouteInfoListUseCase.swift
│   │       │   ├── GetBusRouteListUseCase.swift
│   │       │   └── GetSpecificBusArrivalUseCase.swift
│   │       └── BusStation/
│   │           ├── CityCodeUseCase.swift
│   │           ├── GetBusArrivalInfoUseCase.swift
│   │           ├── GetCityCodeListUseCase.swift
│   │           ├── GetNearbyStationListUseCase.swift
│   │           ├── GetStationThrghBusListUseCase.swift
│   │           └── SearchStationByNameUseCase.swift
│   ├── Presentation/
│   │   ├── Modules/
│   │   │   ├── BusRoute/
│   │   │   │   ├── ViewModel/
│   │   │   │   │   ├── BusRouteDIContainer.swift
│   │   │   │   │   └── BusRouteViewModel.swift
│   │   │   │   └── BusRouteViewController.swift
│   │   │   ├── BusStation/
│   │   │   │   ├── UI/
│   │   │   │   │   └── BusStationTableViewCell.swift
│   │   │   │   ├── ViewModel/
│   │   │   │   │   ├── BusStationDIContainer.swift
│   │   │   │   │   └── BusStationViewModel.swift
│   │   │   │   └── BusStaionViewController.swift
│   │   │   ├── Main/
│   │   │   │   ├── UI/
│   │   │   │   │   ├── MainFavoriteBusCell.swift
│   │   │   │   │   ├── NextButtonCell.swift
│   │   │   │   │   └── SegmentControlView.swift
│   │   │   │   ├── ViewModel/
│   │   │   │   │   ├── MainDIContainer.swift
│   │   │   │   │   └── MainViewModel.swift
│   │   │   │   └── MainViewController.swift
│   │   │   ├── Search/
│   │   │   │   ├── ViewModel/
│   │   │   │   │   ├── SearchDIContainer.swift
│   │   │   │   │   └── SearchViewModel.swift
│   │   │   │   └── SearchViewController.swift
│   │   │   └── SetRegion/
│   │   │       ├── UI/
│   │   │       │   └── CityCell.swift
│   │   │       ├── ViewModel/
│   │   │       │   ├── RegionViewModel.swift
│   │   │       │   └── SetRegionDIContainer.swift
│   │   │       └── SetRegionViewController.swift
│   │   └── Resources/
│   │       └── Assets.xcassets/
│   │           ├── AccentColor.colorset/
│   │           │   └── Contents.json
│   │           ├── AppIcon.appiconset/
│   │           │   ├── Contents.json
│   │           │   ├── Group 248.png
│   │           │   └── Group 249.png
│   │           └── Contents.json
│   ├── Utilities/
│   │   └── Extensions/
│   │       ├── DesignSystem.swift
│   │       └── Extension.swift
│   ├── .gitignore
│   ├── Info.plist
│   └── ViewController.swift
├── WhenComing.xcodeproj/
│   ├── project.xcworkspace/
│   │   └── xcshareddata/
│   │       └── swiftpm/
│   │           └── Package.resolved
│   └── project.pbxproj
├── .coderabbit.yaml
├── .gitignore
└── README.md
```

| 경로 | 역할 |
| --- | --- |
| `WhenComing.xcodeproj/` | Xcode 프로젝트 설정과 Swift Package 의존성 버전 정보를 관리합니다. |
| `WhenComing/Application/` | 앱과 화면 생명주기의 진입점(`AppDelegate`, `SceneDelegate`)입니다. |
| `WhenComing/Presentation/Modules/` | `Main`, `Search`, `SetRegion`, `BusStation`, `BusRoute` 화면별 ViewController, ViewModel, UI 구성 요소와 DIContainer를 둡니다. |
| `WhenComing/Presentation/Resources/` | 앱 아이콘과 색상 등 이미지 에셋을 관리합니다. |
| `WhenComing/Domain/` | 비즈니스 Entity, Repository 인터페이스, UseCase를 정의합니다. |
| `WhenComing/Data/` | API 응답 DTO, 로컬·원격 DataSource, 네트워크 코드, Repository 구현을 둡니다. |
| `WhenComing/Utilities/Extensions/` | 공통 확장과 색상·폰트 정의를 둡니다. |
| `WhenComing/Base.lproj/`, `WhenComing/Info.plist` | 스토리보드와 앱 설정을 관리합니다. |
| `WhenComing/ViewController.swift` | Xcode 기본 ViewController 파일입니다. |

## 진행 현황

- API 연동 및 데이터 처리 구조 구현 완료
- 주요 화면과 RxSwift 데이터 바인딩 구현 중
- Clean Architecture 기반 디렉토리 및 DIContainer 구성 완료

## 사용 기술

- Swift 5, UIKit, RxSwift
- Clean Architecture, MVVM
- URLSession, Codable
- Swift Concurrency (async/await)



## Archive

### 검색 결과 통합 리스트 구성

검색 페이지에 정류소와 버스 노선이 하나의 리스트에 나타나도록 설계했습니다.
두 개의 entity를 통합된 리스트에 노출시켜야 했는데, 통일된 entity를 새로 만들거나 두 개의 섹션으로 나누어 표현하기보다는 enum을 사용하여 하나의 배열로 관리하도록 구성했습니다.

이를 통해 화면에서는 하나의 datasource만 바인딩하면서도, 각 검색 결과 타입에 따라 cell 표시 방식을 분기할 수 있습니다.
추후 지하철 검색 결과가 추가되더라도 enum case를 추가하는 방식으로 확장할 수 있어 수정 범위를 줄일 수 있습니다.

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

<br>

### 검색어 입력 debounce 및 이전 Task 취소 처리

검색창 입력은 사용자가 한 글자씩 입력할 때마다 이벤트가 발생하기 때문에, 매 입력마다 API 요청을 보내면 불필요한 네트워크 호출이 많아질 수 있습니다.
이를 방지하기 위해 검색어 입력에 debounce를 적용하여, 사용자의 입력이 일정 시간 멈춘 뒤 검색 요청이 실행되도록 구성했습니다.

또한 새로운 검색어가 입력되면 이전 검색 요청이 아직 진행 중일 수 있으므로, 기존 Task를 취소하고 새로운 Task를 생성하도록 처리했습니다.
cancel()은 진행 중인 작업을 즉시 강제 종료하는 것이 아니라 취소 상태를 표시하는 방식이기 때문에, Task 내부에서 취소 여부를 확인하고 결과 반영을 중단하도록 했습니다.
마지막으로 요청 당시의 검색어와 현재 검색어가 같은지 한 번 더 검증하여, 이전 요청이 늦게 완료되더라도 현재 검색 결과를 덮어쓰지 않도록 방지했습니다.

```
self.searchTask?.cancel()

self.itemsRelay.accept([])
self.currentQuery = q
self.pageNum = 1
self.isLastPage = false
self.isFetchMoreRelay.accept(false)

self.isLoadingRelay.accept(true)

self.searchTask = Task { [weak self] in
    guard let self = self else { return }

    async let routesTask = self.getRouteUseCase.execute(
        cityCode: self.cityCode,
        routeNo: q
    )
    async let stationsTask = self.searchStationByNameUseCase.execute(
        pageNo: 1,
        cityCode: self.cityCode,
        stationName: q
    )

    let routes = (try? await routesTask) ?? []
    let stations = (try? await stationsTask) ?? []

    if Task.isCancelled {
        await MainActor.run {
            self.isLoadingRelay.accept(false)
        }
        return
    }

    let routeItems = Array(routes.prefix(20)).map { SearchItem.route($0) }
    let stationItems = stations.map { SearchItem.station($0) }
    let allItems = routeItems + stationItems

    await MainActor.run {
        guard self.currentQuery == q else { return }
        self.isLoadingRelay.accept(false)
        self.itemsRelay.accept(allItems)
    }
}
```

<br>

### 즐겨찾기 목록 선노출을 위한 Entity 구성

즐겨찾기 Entity에서 API 호출에 필요한 값뿐만 아니라 버스 번호, 정류장명 등 즉시 표시 가능한 정보도 함께 저장했습니다.
즐겨찾기 목록은 앱 진입 후 빠르게 표시되어야 하는 화면이기 때문에, API 응답을 기다린 뒤 모든 정보를 보여주는 방식보다 저장된 기본 정보를 먼저 노출하는 방식을 선택했습니다.

이를 통해 목록을 불러올 때 기본 정보를 먼저 표시하고, API 호출이 완료되면 남은 도착 시간과 남은 정류장 수 등을 추가로 갱신하여 사용자의 대기 경험을 개선했습니다.

```
struct FavoriteBusEntity: Codable {
    var id: String { "\(isGoToWork)|\(cityCode)|\(stationId)|\(routeId)" }
    var isGoToWork: Bool

    // api 호출용
    var cityCode: String
    var stationId: String
    var routeId: String

    // view 노출용
    let stationName: String
    let routeNo: String
    let routeType: String

    // 추후 정렬용으로 사용할 수 있음
    let latitude: Double
    let longitude: Double
}
```

<br>

### API 응답 형태 대응

네트워크 통신 결과 JSON 값에 대하여 기본적으로 배열 DTO로 포맷팅했습니다.
하지만 값이 하나일 경우 배열 형태가 아니라 단일 객체로 들어와 DTO 포맷 불일치 에러가 발생했습니다.
따라서 JSON item 값이 배열일 경우와 배열이 아닐 경우를 모두 고려하여 해결했습니다.

```
struct BusRouteItems: Decodable {
    let item: [BusRouteDTO]

    private enum CodingKeys: String, CodingKey {
        case item
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let list = try? container.decode([BusRouteDTO].self, forKey: .item) {
            self.item = list
        } else if let single = try? container.decode(BusRouteDTO.self, forKey: .item) {
            self.item = [single]
        } else {
            self.item = []
        }
    }
}
```
