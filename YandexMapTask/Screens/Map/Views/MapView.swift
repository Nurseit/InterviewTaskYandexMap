import UIKit
import YandexMapsMobile
import CoreLocation

final class MapView: UIView {
    private var mapView: YMKMapView!
    private var map: YMKMap!
    private let locationManager = CLLocationManager()
    private let searchView = SearchButtonView()
    private let placeMarkImageView = UIImageView()
    var searchButtonOnTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        addSubview()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        mapView = YMKMapView(frame: frame, vulkanPreferred: false)
        placeMarkImageView.image = UIImage(named: "ic_pin")
        searchView.onTap = { [unowned self] in searchButtonOnTap?() }
    }
    
    private func addSubview() {
        let views = [mapView, searchView, placeMarkImageView]
        views.forEach { view in
            if let view = view  {
                addSubview(view)
            }
        }
    }
    
    private func addConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        placeMarkImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
        }
        searchView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(50)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if map == nil {
            mapView.frame = bounds
            map = mapView.mapWindow.map
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func toggleShowSearchButton(state: Bool) {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            if state {
                searchView.alpha = 0
                searchView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.searchView.alpha = 1
                }
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.searchView.alpha = 0
                }) { _ in
                    self.searchView.isHidden = true
                }
            }
        }
    }
    
    func addTap(with listener: YMKMapCameraListener) {
        DispatchQueue.main.async { [weak self] in
            self?.mapView.mapWindow.map.addCameraListener(with: listener)
        }
    }
    
    func getVisibleRegion() -> YMKVisibleRegion {
        return mapView.mapWindow.map.visibleRegion
    }
    
    func moveTo(_ point: YMKPoint) {
        let camera = YMKCameraPosition(target: point, zoom: 17, azimuth: 150, tilt: 30)
        
        DispatchQueue.main.async { [weak self] in
            self?.mapView.mapWindow.map.move(with: camera,
                                       animation: YMKAnimation(type: .smooth, duration: 1),
                                       cameraCallback: nil)
        }
    }
}
extension MapView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        DispatchQueue.main.async { [weak self] in
            let target = YMKPoint(latitude: userLocation.coordinate.latitude,
                                  longitude: userLocation.coordinate.longitude)
            
            self?.mapView.mapWindow.map.move(
                with: YMKCameraPosition(target: target, zoom: 17.0, azimuth: 150.0, tilt: 30.0),
                animation: YMKAnimation(type: .smooth, duration: 1),
                cameraCallback: nil
            )
            let mapObjects = self?.mapView.mapWindow.map.mapObjects
            mapObjects?.addPlacemark().geometry = target
            self?.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error location: \(error.localizedDescription)")
    }
}

final private class SearchButtonView: UIView {
    private let placeholderView = UIView()
    private let iconImageView = UIImageView()
    private let searchLabel = UILabel()
    var onTap: (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "tab_bar_grey")?.cgColor
        placeholderView.layer.cornerRadius = 10
        placeholderView.backgroundColor = UIColor(named: "bg_placeholder")
        iconImageView.image = UIImage(named: "ic_search")
        searchLabel.text = "Поиск"
        searchLabel.font = .systemFont(ofSize: 17, weight: .bold)
        searchLabel.textColor = .black
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func addSubviews() {
       addSubview(placeholderView)
        placeholderView.addSubview(iconImageView)
        placeholderView.addSubview(searchLabel)
    }
    
    private func makeConstraints() {
        placeholderView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.size.equalTo(18)
        }
        
        searchLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
        }
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
