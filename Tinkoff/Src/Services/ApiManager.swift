import Foundation
import MapKit.MKGeometry

public enum Api {
    public enum AccountType: String {
        case credit = "Credit"
    }
    case depositionPoints(center: CLLocationCoordinate2D, radius: Double, partners: [String]?)
    case depositionPartners(accountType: AccountType)
}

extension Api {

    var baseURL: String {
        return Consts.API_HOST + Consts.API_VERSION + "/"
    }

    var query: (path: String, params: [String: String]?) {
        switch self {
        case .depositionPoints(let center, let radius, let partners):
            var params = [
                "latitude": "\(center.latitude)",
                "longitude": "\(center.longitude)",
                "radius": "\(Int(radius))"
            ]
            if let partners: [String] = partners {
                params["partners"] = partners.joined(separator: ",")
            }
            return (path: "deposition_points", params: params)
        case .depositionPartners(let accountType):
            return (path: "deposition_partners", params: ["accountType": accountType.rawValue])
        }
    }
}

public enum ApiError: Error {
    case badUrl
    case networkError(Error)
    case serverError
    case responseError(resultCode: String, errorMessage: String?, plainMessage: String?)
    case jsonError(Error)
}

public protocol ApiManager {
    func api<TResponse: Response>(_ api: Api, _: TResponse.Type) throws -> Promise<TResponse.TPayload>
}