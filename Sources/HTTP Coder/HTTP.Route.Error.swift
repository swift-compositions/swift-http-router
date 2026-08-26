public import HTTP

extension HTTP.Route {

    public enum Error: Swift.Error, Equatable, Sendable {

        /// The request does not address this branch. `OneOf` continues past this
        /// failure and only this failure.
        case noMatch

        /// The request addresses this branch but carries a value this branch
        /// cannot admit.
        case malformed

        /// The value cannot be printed back into a request.
        case unprintable
    }
}
