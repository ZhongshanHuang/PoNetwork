import Foundation
import Alamofire

protocol NetworkURLRequestConvertible: URLRequestConvertible {
    /// host，最后面不要以/结尾
    var baseURL: URL { get }
    /// 请求头
    var headers: [String: String]? { get }
    /// 请求方法
    var method: HTTPMethod { get }
    /// 路径
    var path: String { get }
    /// 参数
    var params: [String: any Any & Sendable]? { get }
    /// 参数编码方式
    var parameterEncoding: any ParameterEncoding { get }
}

/// 将参数组装成URLRequest
extension NetworkURLRequestConvertible {
    
    var baseURL: URL { baseURL }
    
    var headers: [String: String]? {
        nil
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = baseURL
        if !path.isEmpty {
            url = baseURL.appendingPathComponent(path)
        }
        var request = URLRequest(url: url)
        request.method = method
        request.allHTTPHeaderFields = headers
        request = try parameterEncoding.encode(request, with: params)
        return request
    }
}
