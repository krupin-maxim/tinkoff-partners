import Foundation

public extension URLSession {

    func dataTask(_: PromiseNamespacer, with request: URLRequest) -> Promise<(data: Data, response: URLResponse)> {
        return Promise { resolver in
            self.dataTask(with: request, completionHandler: adapter(resolver))
                .resume()
        }
    }

}

public enum PromiseNamespacer {
    case promise
}

private func adapter(_ resolver: Resolver<(data: Data, response: URLResponse)>) -> (Data?, URLResponse?, Error?) -> Void {
    return { data, response, error in
        if let data = data, let response = response {
            resolver.fulfill((data: data, response: response))
        } else if let error = error {
            resolver.reject(error)
        } else {
            resolver.reject(PromiseError.invalidCallingConvention)
        }
    }
}