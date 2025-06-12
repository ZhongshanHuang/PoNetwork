import Foundation
import Alamofire

// MARK: - Request
public class Request: URLRequestConvertible, @unchecked Sendable {
    public let urlConvertible: any URLConvertible
    public let method: HTTPMethod
    public let headers: RequestHeaders?
    public let parameters: RequestParameters?
    public let parameterEncoding: any ParameterEncoding
    public let timeoutInterval: TimeInterval?
    public private(set) var sendCount: UInt = 0
    public var task: URLSessionTask? {
        innerRequest?.task
    }
    public var state: RequestState {
        innerRequest?.state ?? .initialized
    }
    public var uploadProgressHandler: (handler: ProgressHandler, queue: DispatchQueue)?
    public var downloadProgressHandler: (handler: ProgressHandler, queue: DispatchQueue)?
    
    weak var innerRequest: Alamofire.Request? {
        didSet {
            if innerRequest != nil {
                sendCount += 1
                if concurrentTaskCancel {
                    cancel()
                }
            }
        }
    }
    private var concurrentTaskCancel = false
    
    public init(urlConvertible: any URLConvertible, method: HTTPMethod = .get, headers: RequestHeaders? = nil, parameters: Parameters? = nil, parameterEncoding: any ParameterEncoding = URLEncoding.default, timeoutInterval: TimeInterval? = nil) {
        self.urlConvertible = urlConvertible
        self.method = method
        self.headers = headers
        self.parameters = parameters
        self.parameterEncoding = parameterEncoding
        self.timeoutInterval = timeoutInterval
    }
    
    func cancel() {
        concurrentTaskCancel = true
        innerRequest?.cancel()
    }
    
    func suspend() {
        innerRequest?.suspend()
    }
    
    func resume() {
        innerRequest?.resume()
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try urlConvertible.asURL()
        var request = URLRequest(url: url)
        request.method = method
        request.allHTTPHeaderFields = headers
        if let timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        if let parameters {
            request = try parameterEncoding.encode(request, with: parameters)
        }
        return request
    }
    
}

// MARK: - DataRequest
public class DataRequest: Request, @unchecked Sendable {
    var innerDataRequest: Alamofire.DataRequest? { innerRequest as? Alamofire.DataRequest }
    
    func newRequest(with host: String) throws -> DataRequest {
        let oldURL = try urlConvertible.asURL()
        guard var components = URLComponents(url: oldURL, resolvingAgainstBaseURL: false) else { throw AFError.invalidURL(url: oldURL) }
        components.host = host
        let newRequest = DataRequest(urlConvertible: components, method: method, headers: headers, parameters: parameters, parameterEncoding: parameterEncoding, timeoutInterval: timeoutInterval)
        return newRequest
    }
    
}

// MARK: - UploadRequest
public final class UploadRequest: DataRequest, @unchecked Sendable {
    public let uploadable: Uploadable
    var innerUploadRequest: Alamofire.UploadRequest? { innerRequest as? Alamofire.UploadRequest }
    
    /// UploadRequest的Parameters会被拼接到url里
    public init(urlConvertible: any URLConvertible, headers: RequestHeaders? = nil, parameters: Parameters? = nil, timeoutInterval: TimeInterval? = nil, uploadable: Uploadable) {
        self.uploadable = uploadable
        super.init(urlConvertible: urlConvertible, method: .post, headers: headers, parameters: parameters, timeoutInterval: timeoutInterval)
    }
    
    /// UploadRequest的Parameters会被拼接到url里
    public init(urlConvertible: any URLConvertible, headers: RequestHeaders? = nil, parameters: Parameters? = nil, timeoutInterval: TimeInterval? = nil, multipartFormData: @escaping (MultipartFormData) -> Void) {
        let formData = MultipartFormData(fileManager: FileManager.default)
        multipartFormData(formData)
        self.uploadable = .multipartFormData(formData)
        super.init(urlConvertible: urlConvertible, method: .post, headers: headers, parameters: parameters, timeoutInterval: timeoutInterval)
    }
    
    public override func asURLRequest() throws -> URLRequest {
        var url = try urlConvertible.asURL()
        if let parameters {
            url = URLParamsJoin.url(url, add: parameters)
        }
        var request = URLRequest(url: url)
        request.method = method
        request.allHTTPHeaderFields = headers
        if let timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        return request
    }
    
    override func newRequest(with host: String) throws -> UploadRequest {
        let oldURL = try urlConvertible.asURL()
        guard var components = URLComponents(url: oldURL, resolvingAgainstBaseURL: false) else { throw AFError.invalidURL(url: oldURL) }
        components.host = host
        let newRequest = UploadRequest(urlConvertible: components, headers: headers, parameters: parameters, timeoutInterval: timeoutInterval, uploadable: uploadable)
        return newRequest
    }
    
}

// MARK: - DownloadRequest
public final class DownloadRequest: Request, @unchecked Sendable {
    public let destination: Destination
    var innerDownloadRequest: Alamofire.DownloadRequest? { innerRequest as? Alamofire.DownloadRequest }
    
    public init(urlConvertible: any URLConvertible, method: HTTPMethod = .get, headers: RequestHeaders? = nil, parameters: Parameters? = nil, parameterEncoding: any ParameterEncoding = URLEncoding.default, timeoutInterval: TimeInterval? = nil, destination: @escaping Destination) {
        self.destination = destination
        super.init(urlConvertible: urlConvertible, method: method, headers: headers, parameters: parameters, parameterEncoding: parameterEncoding, timeoutInterval: timeoutInterval)
    }
    
}
