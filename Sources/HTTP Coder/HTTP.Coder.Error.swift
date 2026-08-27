public import HTTP

extension HTTP.Coder {
    public enum Error: Swift.Error, Equatable {
        case mismatch
        case malformed
        case unprintable
    }
}
