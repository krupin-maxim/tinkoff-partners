import Foundation

public class HTTPApiManager: ApiManager {

    public init(){}

    public func api<TResponse: Response>(_ api: Api, _: TResponse.Type) throws -> Promise<TResponse.TPayload> {
        return try request(api: api)
            .map { data, response in
                do {
                    return (data: try JSONDecoder().decode(TResponse.self, from: data), http: response as? HTTPURLResponse)
                } catch {
                    throw ApiError.jsonError(error)
                }
            }.map { (input:(data: TResponse, http: HTTPURLResponse?)) in
                if let statusCode = input.http?.statusCode, (statusCode != 200 && statusCode != 201) {
                    throw ApiError.serverError
                }
                if input.data.resultCode == "OK", let payload = input.data.payload {
                    return payload
                } else {
                    throw ApiError.responseError(resultCode: input.data.resultCode, errorMessage: input.data.errorMessage, plainMessage: input.data.plainMessage)
                }
            }
    }

    public func request(api: Api) throws -> Promise<(data: Data, response: URLResponse)> {
        let query = api.query
        let fullPath = api.baseURL + query.path
        guard var url = URL(string: fullPath) else {
            throw ApiError.badUrl
        }
        url = url.appendingQueryParameters(query.params)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        log("request: \(request)")
        // В реальных приложениях здесь делается несколько попыток в случае сетевой ошибки
        return URLSession.shared.dataTask(.promise, with: request)
            .mapError(body: { ApiError.networkError($0) })
    }

}

fileprivate protocol URLQueryParameterStringConvertible {
    var queryParameters: String { get }
}

extension Dictionary: URLQueryParameterStringConvertible where Key == String, Value == String {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
    */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

}

fileprivate extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
    */
    func appendingQueryParameters(_ parametersDictionary: Dictionary<String, String>?) -> URL {
        guard let parametersDictionary = parametersDictionary else {
            return self
        }
        let ulrString: String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        guard let result = URL(string: ulrString) else {
            return self
        }
        return result
    }
}