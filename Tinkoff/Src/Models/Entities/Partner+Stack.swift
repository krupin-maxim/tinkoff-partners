import Foundation
import CoreData

public extension Partner {

    public func fill(by response: DepositionPartnersItem, accountType: String) -> Partner {
        self.depositionDuration = response.depositionDuration
        self.descr = response.description
        self.externalPartnerId = response.externalPartnerId
        self.hasLocations = response.hasLocations
        self.id = response.id
        self.isMomentary = response.isMomentary
        self.limitations = response.limitations
        self.name = response.name
        self.picture = response.picture
        self.pointType = response.pointType
        self.url = response.url

        self.accountType = accountType

        return self
    }

    static func getAll(accountType: String, in context: NSManagedObjectContext) -> [Partner]? {
        do {
            let fetchRequest: NSFetchRequest<Partner> = Partner.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "accountType = %@", accountType)
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            log(error)
            return nil
        }
    }

    static func deleteAll(in context: NSManagedObjectContext) {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Partner.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        } catch {
            log(error)
        }
    }


}
