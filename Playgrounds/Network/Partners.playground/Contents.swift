import UIKit
import FrameworkForPlayground
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// https://api.tinkoff.ru/v1/deposition_partners?accountType=Credit

let networkManager = HTTPApiManager()

firstly {
    try networkManager.api( .depositionPartners(accountType: .credit), DepositionPartnersResponse.self)
}
    .done { payload in
        log(payload)
    }
    .catchError {
        log($0)
    }

