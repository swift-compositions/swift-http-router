public import Call_Algebra
public import HTTP

extension HTTP {
    public protocol Responses<Domain, Content> {
        associatedtype Domain: Call_Algebra.Call.Domain
        associatedtype Content
        associatedtype Coverage
    }
}
