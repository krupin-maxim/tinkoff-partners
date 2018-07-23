import FrameworkForPlayground
import PlaygroundSupport

let mainScreen = MainScreenController()
// mainScreen.pointsProvider = // Implement it for full fun (see CoreData.playground)

let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: mainScreen)

PlaygroundPage.current.liveView = parent
