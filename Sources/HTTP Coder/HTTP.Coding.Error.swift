public import HTTP

extension HTTP.Coding {

    public enum Error: Swift.Error, Equatable {

        case request

        case response
    }
}
