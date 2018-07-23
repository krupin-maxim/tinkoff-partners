import FrameworkForPlayground
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let name = "euroset.png"

let imageView1 = UIImageView()
imageView1.contentMode = .center
imageView1.backgroundColor = .red

imageView1.image = UIImage(named: "euroset", in: Bundle(for: MainScreenController.self), compatibleWith: nil)?.circularImage(size: CGSize(width: 25, height: 25))

let (parent, child) = playgroundControllers(device: .phone4_7inch, orientation: .portrait)

PlaygroundPage.current.liveView = parent


child.view.addSubview(imageView1)
imageView1.frame = CGRect(x: 0, y: 0, width: 100, height: 100)


