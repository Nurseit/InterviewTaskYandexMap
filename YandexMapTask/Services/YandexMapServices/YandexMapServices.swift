import YandexMapsMobile
import CoreLocation

final class YandexMapServices {
    static let shared = YandexMapServices()
    private let searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
    private var searchSession: YMKSearchSession?
    private var currentPoint = YMKPoint(latitude: 41.31, longitude: 69.21)
    
    private init() {}
    
    func getAdress(for point: YMKPoint, completion: @escaping (String?) -> Void) {
        currentPoint = point
        let searchOptions = YMKSearchOptions()
        searchOptions.searchTypes = .geo

        searchSession = searchManager.submit(
                            with: point,
                            zoom: 16,
                            searchOptions: searchOptions,
                            responseHandler: { response, err in
                                if let error = err {
                                    print("Ошибка: \(error.localizedDescription)")
                                    return
                                }
                                
                                guard let result = response?.collection.children.first,
                                      let metadata = result.obj?.metadataContainer,
                                      let adressMeta = metadata.getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata
                                else {
                                    completion(nil)
                                    return
                                }
                                
                                completion(adressMeta.address.formattedAddress)
                            }
                        )
    }
    
    func searchAddress(query: String, completion: @escaping ([String]?) -> Void) {
        let searchOptions = YMKSearchOptions()
        searchOptions.resultPageSize = 20
        
        searchSession = searchManager.submit(
            withText: query,
            geometry: YMKGeometry(boundingBox: YMKBoundingBox(
                southWest: currentPoint,
                northEast: currentPoint
            )),
            searchOptions: searchOptions,
            responseHandler: { response, error in
                if let items = response?.collection.children {
                    let results = items.compactMap { $0.obj?.name }
                    completion(results)
                }
            }
        )
    }
    
    func getPoint(_ place: String, visibleRegion: YMKVisibleRegion, completion: @escaping (YMKPoint?) -> Void) {
        let globalBoundingBox = YMKBoundingBox(
            southWest: YMKPoint(latitude: -90.0, longitude: -180.0),
            northEast: YMKPoint(latitude: 90.0, longitude: 180.0)
        )
        let globalGeometry = YMKGeometry(boundingBox: globalBoundingBox)
        
        searchSession = searchManager.submit(
            withText: place,
            geometry: globalGeometry,
            searchOptions: YMKSearchOptions(),
            responseHandler: {(response, error) in
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    return
                }

                if let response = response,
                   let firstResult = response.collection.children.first,
                   let point = firstResult.obj?.geometry.first?.point
                {
                    completion(point)
                }
            }
        )
    }
}
