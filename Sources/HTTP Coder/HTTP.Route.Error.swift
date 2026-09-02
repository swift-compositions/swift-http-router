public import HTTP
public import RFC_9110

extension HTTP.Route {

    public enum Error: Swift.Error, Equatable {

        case mismatch

        case malformed

        case unprintable
    }
}
