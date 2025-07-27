import UIKit
import SnapKit
import YandexMapsMobile

final class MapViewController: UIViewController {
    private let contentView = MapView()
    var presenter: MapPresenterProtocol?
    private var debounceWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        addConstraints()
        contentView.addTap(with: self)
        contentView.searchButtonOnTap = { [unowned self] in
            showSearchBottomSheet()
        }
    }
    
    private func addSubview() {
        view.addSubview(contentView)
    }
    
    private func addConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func showSearchBottomSheet() {
        let searchAdressView = SearchAddressBottomSheetView()
        let bottomSheetViewController = BottomSheetViewController(sheetView: searchAdressView)
        searchAdressView.bottomSheetViewHeight = bottomSheetViewController.view.frame.height
        presenter?.searchAddressBottomSheetView = searchAdressView
        contentView.toggleShowSearchButton(state: false)
        
        searchAdressView.onTextHandle = { [unowned self] text in
            presenter?.fetchSearchedAddresses(text: text)
        }
        searchAdressView.onSelectedAddressHandle = { [unowned self, weak bottomSheetViewController] address in
            let region = self.contentView.getVisibleRegion()
            bottomSheetViewController?.dismissSheet()
            presenter?.viewDidMovingBy(address: address, visibleRegion: region)
        }
        bottomSheetViewController.onDismiss = { [unowned self] in
            contentView.toggleShowSearchButton(state: true)
        }
        bottomSheetViewController.willDismiss = { [weak searchAdressView] in
            searchAdressView?.hideKeyboard()
        }
        present(bottomSheetViewController, animated: true)
    }
}

extension MapViewController: MapViewControllerProtocol {
    func moving(point: YMKPoint) {
        contentView.moveTo(point)
    }
    
    func showAlert(with message: String) {
        let alertVC = UIAlertController(title: "Адресс", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        let ok = UIAlertAction(title: "Подтвердить", style: .default) { [unowned self] action in
            presenter?.saveAddress(message)
        }
        
        alertVC.addAction(cancel)
        alertVC.addAction(ok)
        present(alertVC, animated: true)
    }
    
    func showBottomSheet(with adress: String) {
        let adressView = MapAdressBottomSheetView()
        let bottomSheetViewController = BottomSheetViewController(sheetView: adressView)
        
        adressView.setTitle(text: adress)
        adressView.onTapAddFavourite = { [unowned self, weak bottomSheetViewController] in
            bottomSheetViewController?.dismiss(animated: true)
            presenter?.confirmAddress(adress)
        }
        adressView.onTapClose = { [weak bottomSheetViewController] in
            bottomSheetViewController?.dismiss(animated: true)
        }
        present(bottomSheetViewController, animated: true)
    }
}

extension MapViewController: YMKMapCameraListener {
    func onCameraPositionChanged(
        with map: YMKMap,
        cameraPosition: YMKCameraPosition,
        cameraUpdateReason: YMKCameraUpdateReason,
        finished: Bool)
    {
        guard finished else { return }
        
        debounceWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.presenter?.viewDidStopMoving(to: cameraPosition.target)
        }
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
}
