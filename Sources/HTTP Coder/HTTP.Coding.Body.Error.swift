public import HTTP

extension HTTP.Coding.Body {

    public enum Error: Swift.Error, Equatable {
        case missing
        case invalid
    }
}
