public import Coder
public import Operation
public import Parser
public import Serializer

extension Operation._Application where Input: ~Copyable & Escapable {

    public struct Coder<Inner: Coder::Coder.`Protocol`>
    where
        Inner.Output: ~Copyable & Escapable,
        Inner.Output == Input
    {
        public let inner: Inner

        public init(_ inner: Inner) {
            self.inner = inner
        }
    }
}

extension Operation._Application.Coder: Parser.`Protocol`
where Input: ~Copyable & Escapable, Inner.Output: ~Copyable & Escapable {

    public typealias Input = Inner.Input

    public typealias Output = Operation._Application<Index, Inner.Output>

    public typealias Failure = Inner.Failure

    public borrowing func parse(_ input: inout Inner.Input) throws(Failure) -> Output {
        .init(try inner.parse(&input))
    }
}

extension Operation._Application.Coder: Serializer.`Protocol`
where Input: ~Copyable & Escapable, Inner.Output: ~Copyable & Escapable {

    public typealias Buffer = Inner.Buffer

    public borrowing func serialize(_ output: borrowing Output, into buffer: inout Buffer) throws(Failure) {
        try inner.serialize(output.input, into: &buffer)
    }
}

extension Operation._Application.Coder: Coder::Coder.`Protocol`
where Input: ~Copyable & Escapable, Inner.Output: ~Copyable & Escapable {}
