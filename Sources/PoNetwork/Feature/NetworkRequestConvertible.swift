import Foundation
import Alamofire

public protocol NetworkRequestConvertible {
    /// host，最后面不要以/结尾
    var baseURL: URL { get }
    /// 请求头
    var headers: [String: String]? { get }
    /// 请求方法
    var method: HTTPMethod { get }
    /// 路径
    var path: String? { get }
    /// 参数
    var parameters: [String: any Any & Sendable]? { get }
    /// 参数编码方式
    var parameterEncoding: any ParameterEncoding { get }
    /// 超时时间
    var timeoutInterval: TimeInterval? { get }
    /// 上传结构
    var uploadable: Uploadable? { get }
    
    /// 不要实现此方法
    func asRequest() -> DataRequest
}

/// 将参数组装成URLRequest
public extension NetworkRequestConvertible {
    var headers: [String: String]? { nil }
    var timeoutInterval: TimeInterval? { nil }
    var uploadable: Uploadable? { nil }
    
    func asRequest() -> DataRequest {
        var url = baseURL
        if let path, !path.isEmpty {
            url = baseURL.appendingPathComponent(path)
        }
        if let uploadable {
            return UploadRequest(urlConvertible: url, headers: headers, parameters: parameters, timeoutInterval: timeoutInterval, uploadable: uploadable)
        }
        let dataRequest = DataRequest(urlConvertible: url, method: method, headers: headers, parameters: parameters, parameterEncoding: parameterEncoding, timeoutInterval: timeoutInterval)
        return dataRequest
    }
}
