import Foundation

public protocol Response : Codable {
    associatedtype TPayload

    var resultCode: String {get}
    var trackingId: String {get}
    var payload: TPayload? {get}
    var errorMessage: String? {get}
    var plainMessage: String? {get}
}