import Foundation

struct CutOperation: Equatable {

    let timestamp: Date
    let fileCount: Int?

    init(timestamp: Date = Date(), fileCount: Int? = nil) {
        self.timestamp = timestamp
        self.fileCount = fileCount
    }

    var isRecent: Bool {
        Date().timeIntervalSince(timestamp) < 300 // 5 minutes
    }
}

enum CutState: Equatable {
    case inactive
    case active(CutOperation)

    var isActive: Bool {
        if case .active = self {
            return true
        }
        return false
    }

    var operation: CutOperation? {
        if case .active(let operation) = self {
            return operation
        }
        return nil
    }
}
