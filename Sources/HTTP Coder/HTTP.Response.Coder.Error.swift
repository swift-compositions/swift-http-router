public import HTTP

extension HTTP.Response.Coder {

    public enum Error: Swift.Error, Equatable {

        /// The response does not address this branch. An alternation continues
        /// past this failure and only this failure.
        case noMatch

        /// The response addresses this branch but carries a payload this branch
        /// cannot admit.
        case malformed

        /// The value cannot be printed back into a response.
        case unprintable
    }
}
