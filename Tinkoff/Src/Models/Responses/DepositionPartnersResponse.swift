import Foundation

public struct DepositionPartnersResponse: Response {

    public let resultCode: String
    public let trackingId: String
    public  let payload: [DepositionPartnersItem]?
    public let errorMessage: String?
    public let plainMessage: String?
}

public struct DepositionPartnersItem: Codable {

    let id: String
    let name: String
    let picture: String
    let url: String
    let hasLocations: Bool
    let isMomentary: Bool
    let depositionDuration: String
    let limitations: String
    let pointType: String
    let externalPartnerId: String
    let description: String

    public init(id: String, name: String, picture: String, url: String, hasLocations: Bool, isMomentary: Bool, depositionDuration: String, limitations: String, pointType: String, externalPartnerId: String, description: String) {
        self.id = id
        self.name = name
        self.picture = picture
        self.url = url
        self.hasLocations = hasLocations
        self.isMomentary = isMomentary
        self.depositionDuration = depositionDuration
        self.limitations = limitations
        self.pointType = pointType
        self.externalPartnerId = externalPartnerId
        self.description = description
    }

}
