import Foundation

enum DPI: String {
    case mdpi
    case xhdpi
    case xxhdpi

    static func getValue(by scale: Int) -> String {
        switch scale {
        case 1: return mdpi.rawValue
        case 2: return xhdpi.rawValue
        case _: return xxhdpi.rawValue
        }
    }
}

class Consts {

    static let IMAGE_HOST = "https://static.tinkoff.ru/icons/deposition-partners-v3/"
    static let API_HOST = "https://api.tinkoff.ru/"
    static let API_VERSION = "v1"
    static let ICONS_RELOAD_TIMEOUT: Double = 60 * 60 // in seconds
    static let ICONS_MAP_SIZE: Double = 25
    static let PERSISTANT_CONTAINER_NAME: String = "Tinkoff"
    static let PARTNERS_LIFETIME: Double = 60 * 60 // in seconds
    static let PARTNERS_LIFETIME_KEY : String = "LastUpdatePartners"

}