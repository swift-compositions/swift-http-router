public import HTTP

extension HTTP.Message.Content {
    public enum Error: Swift.Error, Equatable {
        case missing
        case invalid
    }
}
