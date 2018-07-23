import Foundation

public struct DepositionPointsResponse: Response {

    public let resultCode: String
    public let trackingId: String
    public let payload: [DepositionPointsItem]?
    public let errorMessage: String?
    public let plainMessage: String?

}

public struct DepositionPointsItem: Codable {
    let externalId: String
    let partnerName: String
    let workHours: String?
    let fullAddress: String
    let location: PartnerLocation

    public init(externalId: String, partnerName: String, workHours: String, fullAddress: String, latitude: Float, longitude: Float) {
        self.externalId = externalId
        self.partnerName = partnerName
        self.workHours = workHours
        self.fullAddress = fullAddress
        self.location = PartnerLocation(latitude: latitude, longitude: longitude)
    }
}

public struct PartnerLocation: Codable {
    let latitude: Float
    let longitude: Float

    init(latitude: Float, longitude: Float) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
