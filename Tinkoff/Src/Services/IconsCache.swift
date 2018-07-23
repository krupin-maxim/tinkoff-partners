import Foundation
import UIKit

public protocol IconsCache {
    func getImageWithName(_ name: String) throws -> Promise<(name: String, image: UIImage)>
    func getImage(name: String) throws -> Promise<UIImage>
}