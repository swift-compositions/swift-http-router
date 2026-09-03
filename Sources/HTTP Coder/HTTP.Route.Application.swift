public import Coder
public import HTTP
public import Operation
public import Parser
public import RFC_9110
public import Serializer

extension HTTP.Route {

    public struct Application<Index: Operation.Symbol, Inner: Coder.`Protocol`>
    where
        Index.Input: ~Copyable & Escapable,
        Inner.Output: ~Copyable & Escapable,
        Inner.Output == Index.Input,
        Inner.Failure == HTTP.Route.Error
    {
        public let inner: Inner

        public init(_ inner: Inner) {
            self.inner = inner
        }
    }
}

extension HTTP.Route.Application: Parser.`Protocol`
where Index.Input: ~Copyable & Escapable, Inner.Output: ~Copyable & Escapable {

    public typealias Input = Inner.Input

    public typealias Output = Operation.Application<Index>

    public typealias Failure = HTTP.Route.Error

    public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
        .init(try inner.parse(&input))
    }
}

extension HTTP.Route.Application: Serializer.`Protocol`
where Index.Input: ~Copyable & Escapable, Inner.Output: ~Copyable & Escapable {

    public typealias Buffer = Inner.Buffer

    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        try inner.serialize(output.input, into: &buffer)
    }
}

extension HTTP.Route.Application: Coder.`Protocol`
where Index.Input: ~Copyable & Escapable, Inner.Output: ~Copyable & Escapable {}
