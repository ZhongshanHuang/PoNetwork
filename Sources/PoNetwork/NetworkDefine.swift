public import Foundation
public import Alamofire

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias URLConvertible = Alamofire.URLConvertible
public typealias URLRequestConvertible = Alamofire.URLRequestConvertible
public typealias RequestHeaders = [String: String]
public typealias RequestParameters = [String: any Any & Sendable]
public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias RequestState = Alamofire.Request.State
public typealias ProgressHandler = (Progress) -> Void
public typealias MultipartFormData = Alamofire.MultipartFormData
public typealias NetworkError = Alamofire.AFError
public typealias ServerTrustManager = Alamofire.ServerTrustManager

public enum Uploadable: @unchecked Sendable {
    /// Upload from the provided `Data` value.
    case data(Data)
    /// Upload from the provided file `URL`
    case file(URL)
    /// Upload from the provided `InputStream`.
    case stream(InputStream)
    /// Upload from the provided `MultipartFormData`.
    case multipartFormData(MultipartFormData)
}

public typealias Destination = @Sendable (_ temporaryURL: URL, _ response: HTTPURLResponse) -> (destinationURL: URL, options: Alamofire.DownloadRequest.Options)

public typealias Session = Alamofire.Session

#if swift(>=6.2)
public typealias DecodableType = Decodable & SendableMetatype
#else
public typealias DecodableType = Decodable
#endif

