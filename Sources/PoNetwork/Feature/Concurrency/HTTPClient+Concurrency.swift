public import Foundation

extension HTTPClient {
    
    // MARK: - Data
    public func send(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil) -> sending DataTask<Data?> {
        let request = requestConvertible.asRequest()
        return send(request, decisionPiple: decisionPiple)
    }
    
    public func send(_ request: DataRequest, decisionPiple: [any Decision]? = nil) -> sending DataTask<Data?> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return DataTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
    public func send<T: DecodableType>(_ requestConvertible: any NetworkRequestConvertible, decisionPiple: [any Decision]? = nil, decodableType: T.Type) -> sending DataTask<T> {
        let request = requestConvertible.asRequest()
        return send(request, decisionPiple: decisionPiple, decodableType: decodableType)
    }
    
    public func send<T: DecodableType>(_ request: DataRequest, decisionPiple: [any Decision]? = nil, decodableType: T.Type) -> sending DataTask<T> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple, decodableType: decodableType) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return DataTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
    // MARK: - Upload
    public func send(_ request: UploadRequest, decisionPiple: [any Decision]? = nil) -> sending UploadTask<Data?> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return UploadTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
    public func send<T: DecodableType>(_ request: UploadRequest, decisionPiple: [any Decision]? = nil, decodableType: T.Type) -> sending UploadTask<T> {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request, decisionPiple: decisionPiple, decodableType: decodableType) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return UploadTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
    // MARK: - Download
    public func send(_ request: DownloadRequest) -> sending DownloadTask {
        let task = Task {
            await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    send(request) { response in
                        continuation.resume(returning: response)
                    }
                }
            } onCancel: {
                request.cancel()
            }
        }
        return DownloadTask(request: request, task: task, shouldAutomaticallyCancel: true)
    }
    
}
