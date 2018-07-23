import Foundation

public class Resolver<T> {

    let box: Box<Result<T>>

    init(_ box: Box<Result<T>>) {
        self.box = box
    }

    func fulfill(_ value: T) {
        box.seal(.fulfilled(value))
    }

    func reject(_ error: Error) {
        box.seal(.rejected(error))
    }
}