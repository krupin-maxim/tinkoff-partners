import Foundation

public extension UserDefaults {

    func updatePartners() {
        set(Date().timeIntervalSince1970, forKey: Consts.PARTNERS_LIFETIME_KEY)
        synchronize()
    }

    func needUpdatePartners() -> Bool {
        guard let updateTimeNumber = object(forKey: Consts.PARTNERS_LIFETIME_KEY) as? TimeInterval else {
            return true
        }
        return Date(timeIntervalSince1970: updateTimeNumber).timeIntervalSinceNow * -1 > Consts.PARTNERS_LIFETIME
    }


}