import FrameworkForPlayground
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let name = "euroset.png"

let imageView1 = UIImageView()
imageView1.contentMode = .center

let iconsCache = HTTPIconsCache()
let promise1 = try iconsCache.getImage(name: name)

promise1.done{ image in
    imageView1.image = image
}

let (parent, child) = playgroundControllers(device: .phone4_7inch, orientation: .portrait)

PlaygroundPage.current.liveView = parent


child.view.addSubview(imageView1)
imageView1.frame = CGRect(x: 0, y: 0, width: 100, height: 100)


