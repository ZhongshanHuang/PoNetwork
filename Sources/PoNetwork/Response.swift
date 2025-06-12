import Foundation
import Alamofire

public protocol Response {
    var request: URLRequest? { get }
    var response: HTTPURLResponse? { get }
    var metrics: URLSessionTaskMetrics? { get }
}

extension DataResponse: Response {}
extension DownloadResponse: Response {}

public typealias RawDataResponse = DataResponse<Data?, NetworkError>
public typealias DecodedDataResponse<Value> = DataResponse<Value, NetworkError>

public struct DataResponse<Success, Failure: Error>: @unchecked Sendable {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public var statusCode: Int? { response?.statusCode }
    public let metrics: URLSessionTaskMetrics?
    public let data: Data?
    
    public let result: Result<Success, Failure>
    public var value: Success? { result.success ?? nil }
    public var error: Failure? { result.failure }
    
    public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, metrics: URLSessionTaskMetrics? = nil, result: Result<Success, Failure>) {
        self.request = request
        self.response = response
        self.data = data
        self.metrics = metrics
        self.result = result
    }
    
}

extension DataResponse where Failure == NetworkError {
    public func replaceFailure(with error: Failure) -> DataResponse<Success, Failure> {
        DataResponse<Success, Failure>(request: request, response: response, data: data, metrics: metrics, result: .failure(error))
    }
}

extension RawDataResponse {
    public func decode<T: Decodable>(of type: T.Type = T.self, decoder: JSONDecoder = JSONDecoder()) -> DataResponse<T, Failure> {
        guard error == nil else {
            return DataResponse<T, Failure>(request: request, response: response, data: data, metrics: metrics, result: .failure(error!))
        }

        guard let data, !data.isEmpty else {
            return DataResponse<T, Failure>(request: request, response: response, data: data, metrics: metrics, result: .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)))
        }
        do {
            let model = try decoder.decode(type, from: data)
            return DataResponse<T, Failure>(request: request, response: response, data: data, metrics: metrics, result: .success(model))
        } catch {
            return DataResponse<T, Failure>(request: request, response: response, data: data, metrics: metrics, result: .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))))
        }
    }
    
}

public struct DownloadResponse: Sendable {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public var statusCode: Int? { response?.statusCode }
    public let metrics: URLSessionTaskMetrics?
    public var fileURL: URL?
    public let result: Result<URL?, NetworkError>
    public var value: URL? { result.success ?? nil }
    public var error: NetworkError? { result.failure }
    
    public init(request: URLRequest?, response: HTTPURLResponse?, fileURL: URL?, metrics: URLSessionTaskMetrics? = nil, result: Result<URL?, NetworkError>) {
        self.request = request
        self.response = response
        self.fileURL = fileURL
        self.metrics = metrics
        self.result = result
    }
}
