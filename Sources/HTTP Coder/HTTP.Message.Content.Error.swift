public import HTTP
public import RFC_9110

extension HTTP.Message.Content {
    public enum Error: Swift.Error, Equatable {
        case missing
        case invalid
    }
}
