public import Call_Algebra
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import RFC_9110
public import Serializer_Primitive

extension HTTP.Coder {
    public struct Leaf<
        Root: Call_Algebra.Call.Domain,
        Index: Call_Algebra.Call.Operation,
        Content,
        Value: Coder_Primitive.Coder.`Protocol`
    >
    where
        Value.Input == HTTP.Message.Response<Content>?,
        Value.Output == Swift.Result<
            Index.Output,
            Index.Failure
        >,
        Value.Buffer == HTTP.Message.Response<Content>?
    {
        private let value: Value

        public typealias Domain = Root
        public typealias Operation = Index
        public typealias Coverage = Index
        public typealias Input = HTTP.Message.Response<Content>?
        public typealias Output = Value.Output
        public typealias Buffer = HTTP.Message.Response<Content>?
        public typealias Failure = HTTP.Coder.Error
        public typealias Body = Never

        init(_ value: Value) {
            self.value = value
        }
    }
}

extension HTTP.Coder.Leaf {
    public borrowing func parse(
        _ input: inout Input
    ) throws(HTTP.Coder.Error) -> Output {
        do throws(Value.Failure) {
            return try value.parse(&input)
        } catch {
            throw .malformed
        }
    }

    public borrowing func serialize(
        _ output: Output,
        into buffer: inout Buffer
    ) throws(HTTP.Coder.Error) {
        do throws(Value.Failure) {
            try value.serialize(output, into: &buffer)
        } catch {
            throw .unprintable
        }
    }
}

extension HTTP.Coder.Leaf: Coder_Primitive.Coder.`Protocol` {}
extension HTTP.Coder.Leaf: HTTP.Responses {}

extension HTTP.Coder.Leaf: HTTP.Coding
where
    Root.Call: Call_Algebra.Call.Singleton,
    Index == Root.Call.Operation
{}
