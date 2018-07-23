import Foundation
import UIKit

extension UIViewController {

    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        present(alertController, animated: true, completion: nil)
    }

    func showLocationAlert() {
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let openAction = UIAlertAction(title: "Настройки", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        self.showAlert(title: "Доступ к данным о местоположении закрыт",
            message: "Зайдите в Настройки служб геолокации и поставьте параметр \"При использовании программы\"",
            actions: [cancelAction, openAction])
    }

}