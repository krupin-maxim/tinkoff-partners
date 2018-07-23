import FrameworkForPlayground

print ("- - - - - Init state")
let partners = Partner.getAll(accountType: "Credit", in: CoreDataStack.shared.readContext)
log(partners)

print("- - - - Access")
log(partners?.first?.externalPartnerId)

let points = PartnerPoint.getAll(in: CoreDataStack.shared.readContext)
log(points)

let partnerItem = DepositionPartnersItem(
    id: "local", name: "local", picture: "local", url: "local", hasLocations: true, isMomentary: true, depositionDuration: "local", limitations: "local", pointType: "local", externalPartnerId: "local", description: "local"
)

let partner = Partner(context: CoreDataStack.shared.writeContext)
partner.fill(by: partnerItem, accountType: "Credit")
//CoreDataStack.shared.writeContext.insert(partner)

let pointItem = DepositionPointsItem(
externalId: "Local", partnerName: "Local", workHours: "Local", fullAddress: "Local", latitude: 0, longitude: 0
)

let point = PartnerPoint(context: CoreDataStack.shared.writeContext)
point.fill(by: pointItem)
//CoreDataStack.shared.writeContext.insert(point)

point.toPartner = partner

try CoreDataStack.shared.writeContext.save()
try CoreDataStack.shared.masterContext.save()

print("- - - - -  Add something")
let partners1 = Partner.getAll(accountType: "Credit", in: CoreDataStack.shared.readContext)
log(partners1)

let points1 = PartnerPoint.getAll(in: CoreDataStack.shared.readContext)
log(points1)

Partner.deleteAll(in: CoreDataStack.shared.writeContext)
try CoreDataStack.shared.writeContext.save()
try CoreDataStack.shared.masterContext.save()


print("- - - - -  Delete all")
let partners2 = Partner.getAll(accountType: "Credit", in: CoreDataStack.shared.readContext)
log(partners2)

let points2 = PartnerPoint.getAll(in: CoreDataStack.shared.readContext)
log(points2)
