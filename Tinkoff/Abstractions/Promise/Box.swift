import Foundation

enum Sealant<R> {
    case pending(Handlers<R>)
    case resolved(R)
}

class Handlers<R> {
    var bodies: [(R) -> Void] = []

    func append(_ item: @escaping (R) -> Void) {
        bodies.append(item)
    }
}

public class Box<T> {

    private var sealant: Sealant<T>
    private let barrier: DispatchQueue = .init(label: "com.tinkoff.promise.barrier", attributes: .concurrent)

    init() {
        self.sealant = .pending(.init())
    }

    init(_ empty: ()) {
        self.sealant = .pending(.init())
    }

    func seal(_ value: T) {
        var handlers: Handlers<T>!
        barrier.sync(flags: .barrier) {
            guard case .pending(let _handlers) = self.sealant else {
                return // already fulfilled
            }
            handlers = _handlers
            sealant = .resolved(value)
        }

        if let handlers = handlers {
            handlers.bodies.forEach {
                $0(value)
            }
        }
    }

    func inspect() -> Sealant<T> {
        return barrier.sync {
            sealant
        }
    }

    func changeSealant(_ body: (Sealant<T>) -> Void) {
        var sealed: Bool = false
        barrier.sync(flags: .barrier) {
            switch sealant {
            case .pending:
                body(sealant)
            case .resolved:
                sealed = true
            }
        }
        if sealed {
            body(sealant)
        }
    }

}