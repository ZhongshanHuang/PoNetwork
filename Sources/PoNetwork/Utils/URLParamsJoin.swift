public import Foundation
import Alamofire

public struct URLParamsJoin {
    
    public static func url(_ url: URL, add params: [String: Any]) -> URL {
        if params.isEmpty { return url }
        
        let newURLStr: String
        if url.query != nil {
            newURLStr = url.absoluteString + "&" + query(params)
        } else {
            newURLStr = url.absoluteString + "?" + query(params)
        }
        return URL(string: newURLStr) ?? url
    }
    
    public static func urlStr(_ urlStr: String, add params: [String: Any]) -> String {
        if params.isEmpty { return urlStr }
        guard let url = URL(string: urlStr) else { return urlStr }
        
        let newURLStr: String
        if url.query != nil {
            newURLStr = url.absoluteString + "&" + query(params)
        } else {
            newURLStr = url.absoluteString + "?" + query(params)
        }
        return newURLStr
    }

    
    public static func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        let enCoding = URLEncoding.default
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += enCoding.queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
}


