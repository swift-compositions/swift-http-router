public import HTTP

extension HTTP.Message {
    public enum Error: Swift.Error, Equatable {
        case mismatch
        case malformed
        case unprintable
    }
}
