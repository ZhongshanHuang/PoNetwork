public import Foundation
public import Alamofire

public final class BaseDataResponse<T: Decodable>: BaseEmptyDataResponse {
    public var data: T?
    
    private enum CodingKeys: CodingKey {
        case data
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent(T.self, forKey: .data)
        try super.init(from: decoder)
    }
    
    override func generateErrorBySelf() -> NetworkError {
        if data == nil {
            let innerError = NSError(domain: "poNetwork", code: self.code ?? 0, userInfo: [NSLocalizedDescriptionKey: msg ?? "base response data null"])
            return NetworkError.responseValidationFailed(reason: .customValidationFailed(error: innerError))
        }
        return super.generateErrorBySelf()
    }
    
}

public class BaseEmptyDataResponse: Decodable {
    public var code: Int?
    public var msg: String?
    
    func generateErrorBySelf() -> NetworkError {
        let innerError = NSError(domain: "poNetwork", code: self.code ?? 0, userInfo: [NSLocalizedDescriptionKey: msg ?? "base response business check error"])
        return NetworkError.responseValidationFailed(reason: .customValidationFailed(error: innerError))
    }
}

