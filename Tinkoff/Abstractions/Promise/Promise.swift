import Foundation

public class Promise<T> {

    let box: Box<Result<T>>

    init(_ empty: ()) {
        self.box = Box(())
    }

    init(resolver body: (Resolver<T>) throws -> Void) {
        self.box = Box()
        let resolver = Resolver(box)
        do {
            try body(resolver)
        } catch {
            resolver.reject(error)
        }
    }

    public func tap(_ body: @escaping (Result<T>) -> Void) -> Self {
        pipe(to: body)
        return self
    }

    public func map<U>(on: DispatchQueue = DispatchQueue.main, transform: @escaping(T) throws -> U) -> Promise<U> {
        let result = Promise<U>.init(())
        pipe { resultValue in
            switch resultValue {
            case .fulfilled(let value):
                on.async {
                    do {
                        result.box.seal(.fulfilled(try transform(value)))
                    } catch {
                        result.box.seal(.rejected(error))
                    }
                }
            case .rejected(let error):
                result.box.seal(.rejected(error))
            }
        }
        return result
    }

    public func then<U>(on: DispatchQueue = DispatchQueue.main, body: @escaping(T) throws -> Promise<U>) -> Promise<U> {
        let result = Promise<U>.init(())
        pipe { resultValue in
            switch resultValue {
            case .fulfilled(let value):
                on.async {
                    do {
                        let bodyPromise = try body(value)
                        bodyPromise.pipe(to: result.box.seal)
                    } catch {
                        result.box.seal(.rejected(error))
                    }
                }
            case .rejected(let error):
                result.box.seal(.rejected(error))
            }
        }
        return result
    }

    @discardableResult
    public func done(on: DispatchQueue = DispatchQueue.main, body: @escaping(T) throws -> Void) -> Promise<Void> {
        let result = Promise<Void>.init(())
        pipe { resultValue in
            switch resultValue {
            case .fulfilled(let value):
                on.async {
                    do {
                        try body(value)
                        result.box.seal(.fulfilled(()))
                    } catch {
                        result.box.seal(.rejected(error))
                    }
                }
            case .rejected(let error):
                result.box.seal(.rejected(error))
            }
        }
        return result
    }

    @discardableResult
    public func catchError(on: DispatchQueue = DispatchQueue.main, body: @escaping(Error) -> Void) -> Promise<Void> {
        let result = Promise<Void>.init(())

        pipe { resultValue in
            switch resultValue {
            case .rejected(let error):
                on.async {
                    body(error)
                    result.box.seal(.fulfilled(()))
                }
            case .fulfilled:
                result.box.seal(.fulfilled(()))
            }
        }

        return result
    }

    public func mapError(on: DispatchQueue = DispatchQueue.main, body: @escaping(Error) -> Error) -> Promise<T> {
        let result = Promise<T>.init(())

        pipe { resultValue in
            switch resultValue {
            case .rejected(let error):
                on.async {
                    result.box.seal(.rejected(body(error)))
                }
            case .fulfilled(let value):
                result.box.seal(.fulfilled(value))
            }
        }

        return result
    }

    fileprivate func pipe(to: @escaping (Result<T>) -> Void) {
        switch box.inspect() {
        case .pending:
            box.changeSealant { sealant in
                switch sealant {
                case .pending(let handlers):
                    handlers.append(to)
                case .resolved(let value):
                    to(value)
                }
            }
        case .resolved(let value):
            to(value)
        }
    }

    var isPending: Bool {
        switch box.inspect() {
        case .pending: return true
        case .resolved: return false
        }
    }

}

public func firstly<T>(execute body: () throws -> Promise<T>) -> Promise<T> {
    let result = Promise<T>.init(())
    do {
        try body().pipe(to: result.box.seal)
    } catch {
        result.box.seal(.rejected(error))
    }
    return result
}