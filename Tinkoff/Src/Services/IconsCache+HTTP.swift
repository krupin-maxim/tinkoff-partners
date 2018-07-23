import Foundation
import UIKit

enum IconsCacheError: Error {
    case badHostURL
    case badImageData
    case badResponse
    case badResize
}

public class HTTPIconsCache : IconsCache {

    let promiseCache = NSCache<NSString, Promise<UIImage>>.init()
    private let barrier: DispatchQueue = .init(label: "com.tinkoff.iconsCache.barrier", attributes: .concurrent)

    public init() {
    }

    // MARK: -- IconsCache

    public func getImageWithName(_ name: String) throws -> Promise<(name: String, image: UIImage)> {
        return try getImage(name: name).map { image in
            return (name: name, image: image)
        }
    }

    public func getImage(name: String) throws -> Promise<UIImage> {
        if let cachedPromise = promiseCache.object(forKey: NSString(string: name)), cachedPromise.isPending {
            return cachedPromise
        }

        guard let url = URL(string: Consts.IMAGE_HOST + DPI.getValue(by: Int(UIScreen.main.scale)) + "/" + name) else {
            throw IconsCacheError.badHostURL
        }

        let request = URLRequest(url: url)

        if let cachedResponse = getCachedResponse(for: request) {
            if !isNeedCheckOnServer(cachedResponse: cachedResponse) {
                return getCachedPromiseOrCreate(forKey: name, cachedResponse: cachedResponse)
            } else {
                let checkRequest = makeModifiedRequest(url: url, lastResponse: cachedResponse.response)
                let promise = makeCheckUpdatePromise(checkRequest: checkRequest, for: request, cachedResponse: cachedResponse)
                return cachePromise(promise: promise, forKey: name)
            }
        } else {
            return cachePromise(promise: makeLoadPromise(request: request), forKey: name)
        }
    }

    // MARK: --

    fileprivate func isNeedCheckOnServer(cachedResponse: CachedURLResponse) -> Bool {
        if let userInfo = cachedResponse.userInfo, let checkedDate = userInfo["checkedDate"] as? TimeInterval, Date().timeIntervalSince1970 - checkedDate < Consts.ICONS_RELOAD_TIMEOUT {
            return false
        }
        return true
    }

    fileprivate func makeModifiedRequest(url: URL, lastResponse: URLResponse) -> URLRequest {
        var checkRequest = URLRequest(url: url)
        var lastModified: String = ""
        if let httpResponse = lastResponse as? HTTPURLResponse, let lastModifiedDate = httpResponse.allHeaderFields["Last-Modified"] as? String {
            lastModified = lastModifiedDate
        }
        checkRequest.addValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
        return checkRequest
    }

    // MARK: -- Image

    fileprivate func makeImage(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data, scale: UIScreen.main.scale) else {
            throw IconsCacheError.badImageData
        }
        guard let resized = image.circularImage(size: CGSize(width: Consts.ICONS_MAP_SIZE, height: Consts.ICONS_MAP_SIZE)) else {
            throw IconsCacheError.badResize
        }
        return resized
    }

    fileprivate func makeImagePromise(from data: Data) -> Promise<UIImage> {
        return Promise() { resolver in
            DispatchQueue.global().async { [unowned self] () in
                do {
                    resolver.fulfill(try self.makeImage(from: data))
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }

    fileprivate func makeLoadPromise(request: URLRequest) -> Promise<UIImage> {
        log("makeLoadPromise \(request)")
        return URLSession.shared.dataTask(.promise, with: request)
            .map { [unowned self] (input: (data: Data, response: URLResponse)) throws -> UIImage in
                self.cacheResponse(for: request, data: input.data, response: input.response)
                return try self.makeImage(from: input.data)
            }
    }

    fileprivate func makeCheckUpdatePromise(checkRequest: URLRequest, for request: URLRequest, cachedResponse: CachedURLResponse) -> Promise<UIImage> {
        return URLSession.shared.dataTask(.promise, with: checkRequest)
            .map { (input: (data: Data, response: URLResponse)) -> (needReload: Bool, data: Data, response: URLResponse) in
                guard let httpResponse = input.response as? HTTPURLResponse else {
                    throw IconsCacheError.badResponse
                }
                return (needReload: httpResponse.statusCode != 304, data: input.data, response: input.response)
            }.then { [unowned self]  (input: (needReload: Bool, data: Data, response: URLResponse)) -> Promise<UIImage> in
                let data = input.needReload ? input.data : cachedResponse.data
                let response = input.needReload ? input.response : cachedResponse.response

                self.cacheResponse(for: request, data: data, response: response)
                return self.makeImagePromise(from: data)
            }
    }

    // MARK: -- Cache

    fileprivate func getCachedPromise(forKey name: String) -> Promise<UIImage>? {
        return barrier.sync {
            promiseCache.object(forKey: NSString(string: name))
        }
    }

    fileprivate func getCachedPromiseOrCreate(forKey name: String, cachedResponse: CachedURLResponse) -> Promise<UIImage> {
        if let cachedPromise = getCachedPromise(forKey: name) {
            return cachedPromise
        } else {
            return cachePromise(promise: makeImagePromise(from: cachedResponse.data), forKey: name)
        }
    }

    fileprivate func getCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return barrier.sync {
            URLCache.shared.cachedResponse(for: request)
        }
    }

    fileprivate func cachePromise(promise: Promise<UIImage>, forKey name: String) -> Promise<UIImage> {
        barrier.sync(flags: .barrier) {
            promiseCache.setObject(promise, forKey: NSString(string: name))
        }
        return promise
    }

    fileprivate func cacheResponse(for request: URLRequest, data: Data, response: URLResponse) {
        barrier.sync(flags: .barrier) {
            let cached = CachedURLResponse(response: response, data: data, userInfo: ["checkedDate": Date().timeIntervalSince1970], storagePolicy: .allowed)
            URLCache.shared.storeCachedResponse(cached, for: request)
        }
    }

}
