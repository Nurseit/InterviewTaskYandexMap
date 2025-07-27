import CoreData

final class AddressRepository {

    private let coreDataServices = CoreDataServices.shared
    private let context = CoreDataServices.shared.context

    func create(address: String) {
        let newAddress = Address(context: context)
        newAddress.id = UUID()
        newAddress.name = address

        coreDataServices.saveContext()
    }

    func deleteAddress(by id: UUID) {
        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            if let address = try context.fetch(fetchRequest).first {
                context.delete(address)
                coreDataServices.saveContext()
            } else {
                print("Address with id \(id) not found.")
            }
        } catch {
            print("Failed to delete address by id: \(error)")
        }
    }

    func fetch() -> [Address] {
        let request: NSFetchRequest<Address> = Address.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch addresses: \(error)")
            return []
        }
    }
}
