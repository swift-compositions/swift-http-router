public import HTTP

extension HTTP.Router {

    public enum Error: Swift.Error, Equatable {

        case mismatch

        case malformed

        case unprintable
    }
}
