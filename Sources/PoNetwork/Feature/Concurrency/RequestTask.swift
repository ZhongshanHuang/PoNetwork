public import Foundation

public struct DataTask<Value> : Sendable {
    /// `DataResponse` produced by the `DataRequest` and its response handler.
    public var response: DataResponse<Value, NetworkError> {
        get async {
            if shouldAutomaticallyCancel {
                return await withTaskCancellationHandler {
                    await task.value
                } onCancel: {
                    cancel()
                }
            } else {
                return await task.value
            }
        }
    }

    /// `Result` of any response serialization performed for the `response`.
    public var result: Result<Value, NetworkError> {
        get async { await response.result }
    }

    /// `Value` returned by the `response`.
    public var value: Value {
        get async throws {
            try await result.get()
        }
    }

    private let request: DataRequest
    private let task: Task<DataResponse<Value, NetworkError>, Never>
    private let shouldAutomaticallyCancel: Bool

    init(request: DataRequest, task: Task<DataResponse<Value, NetworkError>, Never>, shouldAutomaticallyCancel: Bool) {
        self.request = request
        self.task = task
        self.shouldAutomaticallyCancel = shouldAutomaticallyCancel
    }

    /// Cancel the underlying `DataRequest` and `Task`.
    public func cancel() {
        task.cancel()
    }

    /// Resume the underlying `DataRequest`.
    public func resume() {
        request.resume()
    }

    /// Suspend the underlying `DataRequest`.
    public func suspend() {
        request.suspend()
    }
}

public struct UploadTask<Value>: Sendable {
    /// `DataResponse` produced by the `DataRequest` and its response handler.
    public var response: DataResponse<Value, NetworkError> {
        get async {
            if shouldAutomaticallyCancel {
                return await withTaskCancellationHandler {
                    await task.value
                } onCancel: {
                    cancel()
                }
            } else {
                return await task.value
            }
        }
    }

    /// `Result` of any response serialization performed for the `response`.
    public var result: Result<Value, NetworkError> {
        get async { await response.result }
    }

    /// `Value` returned by the `response`.
    public var value: Value {
        get async throws {
            try await result.get()
        }
    }

    private let request: UploadRequest
    private let task: Task<DataResponse<Value, NetworkError>, Never>
    private let shouldAutomaticallyCancel: Bool

    init(request: UploadRequest, task: Task<DataResponse<Value, NetworkError>, Never>, shouldAutomaticallyCancel: Bool) {
        self.request = request
        self.task = task
        self.shouldAutomaticallyCancel = shouldAutomaticallyCancel
    }

    /// Cancel the underlying `DataRequest` and `Task`.
    public func cancel() {
        task.cancel()
    }

    /// Resume the underlying `DataRequest`.
    public func resume() {
        request.resume()
    }

    /// Suspend the underlying `DataRequest`.
    public func suspend() {
        request.suspend()
    }
}

public struct DownloadTask: Sendable {
    /// `DownloadResponse` produced by the `DownloadRequest` and its response handler.
    public var response: DownloadResponse {
        get async {
            if shouldAutomaticallyCancel {
                return await withTaskCancellationHandler {
                    await task.value
                } onCancel: {
                    cancel()
                }
            } else {
                return await task.value
            }
        }
    }

    /// `Result` of any response serialization performed for the `response`.
    public var result: Result<URL?, NetworkError> {
        get async { await response.result }
    }

    /// `Value` returned by the `response`.
    public var value: URL? {
        get async throws {
            try await result.get()
        }
    }

    private let task: Task<DownloadResponse, Never>
    private let request: DownloadRequest
    private let shouldAutomaticallyCancel: Bool

    init(request: DownloadRequest, task: Task<DownloadResponse, Never>, shouldAutomaticallyCancel: Bool) {
        self.request = request
        self.task = task
        self.shouldAutomaticallyCancel = shouldAutomaticallyCancel
    }

    /// Cancel the underlying `DownloadRequest` and `Task`.
    public func cancel() {
        task.cancel()
    }

    /// Resume the underlying `DownloadRequest`.
    public func resume() {
        request.resume()
    }

    /// Suspend the underlying `DownloadRequest`.
    public func suspend() {
        request.suspend()
    }
}
