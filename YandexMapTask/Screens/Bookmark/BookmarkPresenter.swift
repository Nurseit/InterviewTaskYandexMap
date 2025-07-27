import Foundation

protocol BookmarkPresenterProtocol {
    func deleteBookmark(at index: UUID)
    func fetchAddress() -> [Address]
}

final class BookmarkPresenter: BookmarkPresenterProtocol {
    private let addressRepository = AddressRepository()
    
    init() {}
    
    func fetchAddress() -> [Address]{
        return addressRepository.fetch()
    }
    
    func deleteBookmark(at index: UUID) {
        addressRepository.deleteAddress(by: index)
    }
}
