public import Byte
public import Coder
public import HTTP

extension HTTP.Body.Coder {

    public protocol `Protocol`<Output, Failure>: Coding
    where Input == [Byte], Buffer == [Byte], Output: Copyable {

        static var contentType: HTTP.MediaType { get }

        func decode(_ input: inout [Byte], as mediaType: HTTP.MediaType) throws(Failure) -> Output

        func encode(_ output: Output, into buffer: inout [Byte]) throws(Failure) -> HTTP.MediaType
    }
}

extension HTTP.Body.Coder.`Protocol` {

    @inlinable
    public func decode(_ input: inout [Byte], as mediaType: HTTP.MediaType) throws(Failure) -> Output {
        try parse(&input)
    }

    @inlinable
    public func encode(_ output: Output, into buffer: inout [Byte]) throws(Failure) -> HTTP.MediaType {
        try serialize(output, into: &buffer)
        return Self.contentType
    }
}
