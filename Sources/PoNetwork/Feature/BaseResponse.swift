import Foundation
import Alamofire

final class BaseDataResponse<T: Decodable>: BaseEmptyDataResponse {
    var data: T?
    
    private enum CodingKeys: CodingKey {
        case data
    }
    
    required init(from decoder: any Decoder) throws {
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

class BaseEmptyDataResponse: Decodable {
    var code: Int?
    var msg: String?
    
    func generateErrorBySelf() -> NetworkError {
        let innerError = NSError(domain: "poNetwork", code: self.code ?? 0, userInfo: [NSLocalizedDescriptionKey: msg ?? "base response business check error"])
        return NetworkError.responseValidationFailed(reason: .customValidationFailed(error: innerError))
    }
}

