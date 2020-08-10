import Foundation
import Alamofire

final class MockURLProtocol: URLProtocol {
    
    enum ResponseType {
        case error(Error)
        case success(HTTPURLResponse)
        case successWithData(DefaultDataResponse)
        case errorWithData(DefaultDataResponse)
    }
    
    static var responseType: ResponseType!
    
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    private(set) var activeTask: URLSessionTask?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    override func startLoading() {
        activeTask = session.dataTask(with: request.urlRequest!)
        activeTask?.cancel()
    }
    
    override func stopLoading() {
        activeTask?.cancel()
    }
}

// MARK: - URLSessionDataDelegate
extension MockURLProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        switch MockURLProtocol.responseType {
            case .error(let error)?:
                client?.urlProtocol(self, didFailWithError: error)
            case .success(let response)?:
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            case .successWithData(let responseData)?:
                client?.urlProtocol(self, didLoad: responseData.data!)
            case .errorWithData(let responseData)?:
                client?.urlProtocol(self, didFailWithError: responseData.error!)
            default:
                print("Not implemented")
                break
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
}

extension MockURLProtocol {
    
    enum MockError: Error {
        case none
    }
    
    static func responseWithFailure() {
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.error(MockError.none)
    }
    
    static func responseWithStatusCode(code: Int) {
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.success(HTTPURLResponse(url: URL(string: "http://any.com")!, statusCode: code, httpVersion: nil, headerFields: nil)!)
    }
    
    static func responseWithData(data: Data) {
        let hTTPURLResponse = HTTPURLResponse(url: URL(string: "http://any.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let defaultDataResponse = DefaultDataResponse(request: URLRequest.init(url: URL(string: "http://any.com")!), response: hTTPURLResponse, data: data, error: nil)
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.successWithData(defaultDataResponse)
    }
    
    static func responseWithDataError() {
        let hTTPURLResponse = HTTPURLResponse(url: URL(string: "http://any.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let defaultDataResponse = DefaultDataResponse(request: URLRequest.init(url: URL(string: "http://any.com")!), response: hTTPURLResponse, data: nil, error: MockError.none)
        MockURLProtocol.responseType = MockURLProtocol.ResponseType.errorWithData(defaultDataResponse)
    }
}
