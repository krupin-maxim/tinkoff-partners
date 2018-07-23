import Foundation


extension Array where Element : Hashable {

    func calcDifferWith(_ newArray: Array<Element>) -> (toAdd: Array<Element>, toRemove: Array<Element>) {
        let set = Set(self)
        let difference = set.symmetricDifference(newArray)
        return (toAdd: Array(difference.intersection(newArray)), toRemove: Array(difference.intersection(self)))
    }

}
