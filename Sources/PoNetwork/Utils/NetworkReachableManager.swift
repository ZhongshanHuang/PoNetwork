public import Foundation
public import Alamofire
import CoreTelephony

public final class NetworkReachableManager: @unchecked Sendable {
    
    public static let networkStatusChangeNotification = Notification.Name("NetworkReachableManager.networkStatusChangeNotification")
    private let networkManager = NetworkReachabilityManager(host: "www.baidu.com")!
    
    public private(set) var lastStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    
    public var status: NetworkReachabilityManager.NetworkReachabilityStatus {
        networkManager.status
    }
    
    public var isReachable: Bool {
        networkManager.isReachable
    }
    
    public var isReachableOnCellular: Bool {
        networkManager.isReachableOnCellular
    }
    
    public var isReachableOnEthernetOrWiFi: Bool {
        networkManager.isReachableOnEthernetOrWiFi
    }
    
    public static let shared = NetworkReachableManager()
    private init() {}
    
    func startMonitoring() {
        networkManager.startListening { [weak self] status in
            NotificationCenter.default.post(name: NetworkReachableManager.networkStatusChangeNotification, object: nil)
            self?.lastStatus = status
        }
    }
    
    private lazy var shareTelephoneInfo = CTTelephonyNetworkInfo()
    var currentReachabilityStatus: String {
        if isReachableOnEthernetOrWiFi {
            return "WIFI"
        } else {
            var res = ""
            if let currentRadioAccessTechnology = shareTelephoneInfo.serviceCurrentRadioAccessTechnology?.first(where: { (key: String, value: String) in
                value.hasPrefix("CTRadioAccessTechnology")
            })?.value {
                if currentRadioAccessTechnology == CTRadioAccessTechnologyLTE {
                    res = "4G";
                } else if currentRadioAccessTechnology == CTRadioAccessTechnologyEdge || currentRadioAccessTechnology == CTRadioAccessTechnologyGPRS {
                    res = "2G";
                } else if #available(iOS 14.2, *) {//NOTO：如果编译有问题，请升级XCode，保证XCode所带的iOS SDK最新来支持该feature.此处踩过坑，Apple自己说从14.0开始支持使用该API，但是iPhone12以下的设备在iOS14.0会崩溃
                    if currentRadioAccessTechnology == CTRadioAccessTechnologyNRNSA || currentRadioAccessTechnology == CTRadioAccessTechnologyNR {
                        res = "5G";
                    }
                }
                
                if res.isEmpty {
                    res = "3G";
                }
            } else {
                res = "2G/3G/4G/5G"
            }
            return res
        }
    }
    
}

 
