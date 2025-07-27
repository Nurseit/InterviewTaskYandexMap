import YandexMapsMobile

protocol MapViewControllerProtocol: AnyObject {
    func showAlert(with title: String)
    func showBottomSheet(with adress: String)
    func moving(point: YMKPoint)
}
protocol MapPresenterProtocol {
    var searchAddressBottomSheetView: SearchAddressBottomSheetViewDelegate? { get set }
    func confirmAddress(_ title: String)
    func saveAddress(_ title: String)
    func viewDidStopMoving(to point: YMKPoint)
    func fetchSearchedAddresses(text: String)
    func viewDidMovingBy(address: String, visibleRegion: YMKVisibleRegion)
}

final class MapPresenter: MapPresenterProtocol {
    weak var view: MapViewControllerProtocol?
    weak var searchAddressBottomSheetView: SearchAddressBottomSheetViewDelegate?
    private let yandexServices = YandexMapServices.shared
    private let addressRepository = AddressRepository()
    private var isFirstHandleLocation: Bool = true
    private var oldPoint: YMKPoint = YMKPoint()
    
    init(view: MapViewControllerProtocol? = nil) {
        self.view = view
    }
    
    func saveAddress(_ title: String) {
        addressRepository.create(address: title)
    }
    
    func confirmAddress(_ title: String) {
        view?.showAlert(with: title)
    }
    
    func viewDidStopMoving(to point: YMKPoint) {
        if !isFirstHandleLocation && point != oldPoint {
            let center = YMKPoint(latitude: point.latitude, longitude: point.longitude)
            yandexServices.getAdress(for: center) { [weak self] adress in
                self?.view?.showBottomSheet(with: adress ?? "Адресc не найден")
            }
        } else {
            isFirstHandleLocation = false
        }
        oldPoint = point
    }
    
    func fetchSearchedAddresses(text: String) {
        return yandexServices.searchAddress(query: text) { [weak self] addresses in
            self?.searchAddressBottomSheetView?.fill(addresses: addresses ?? [])
        }
    }
    
    func viewDidMovingBy(address: String, visibleRegion: YMKVisibleRegion) {
        yandexServices.getPoint(address, visibleRegion: visibleRegion) { [weak self] point in
            guard let self = self else { return }
            if let point = point {
                self.view?.moving(point: point)
                viewDidStopMoving(to: point)
            }
        }
    }
}
