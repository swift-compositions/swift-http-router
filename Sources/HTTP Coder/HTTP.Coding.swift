public import Call_Algebra
public import Coder_Primitive
public import HTTP
public import Parser_Primitive
public import RFC_9110
public import Serializer_Primitive

extension HTTP {
    public protocol Coding<Domain, Content>:
        HTTP.Responses,
        Coder_Primitive.Coder.`Protocol`
    where
        Self.Domain: Call_Algebra.Call.Domain,
        Self.Domain.Call: Call_Algebra.Call.Singleton,
        Operation == Self.Domain.Call.Operation,
        Input == HTTP.Message.Response<Content>?,
        Output == Swift.Result<
            Operation.Output,
            Operation.Failure
        >,
        Buffer == HTTP.Message.Response<Content>?,
        Failure == HTTP.Coder.Error,
        Coverage == Operation
    {
        associatedtype Operation: Call_Algebra.Call.Operation
    }
}
