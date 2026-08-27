public import Call_Algebra
public import HTTP

extension HTTP {
    public protocol Respondable: Call_Algebra.Call.Domain {
        associatedtype Response: HTTP.Responses
        where Response.Domain == Self

        @HTTP.Coder.Builder<Self>
        static var response: Response { get }
    }
}
