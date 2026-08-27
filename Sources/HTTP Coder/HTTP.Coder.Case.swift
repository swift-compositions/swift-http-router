public import Call_Algebra
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import RFC_9110
public import Serializer_Primitive

extension HTTP.Coder {
    public struct Case<
        Root: Call_Algebra.Call.Domain,
        Index: Call_Algebra.Call.Operation,
        Content,
        Value: Coder_Primitive.Coder.`Protocol`
    >
    where
        Value.Input == HTTP.Message.Response<Content>?,
        Value.Output == Swift.Result<Index.Output, Index.Failure>,
        Value.Buffer == HTTP.Message.Response<Content>?
    {
        private let value: Value

        public init(
            _: KeyPath<
                Root.Call.Branches,
                Call_Algebra.Call.Branch<
                    Root.Call,
                    Index.Input,
                    Index
                >
            >,
            _ value: Value
        ) {
            self.value = value
        }
    }
}

extension HTTP.Coder.Case: HTTP.Responses {
    public typealias Domain = Root
    public typealias Coverage = Index
}
