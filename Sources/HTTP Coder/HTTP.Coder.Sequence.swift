public import Call_Algebra
public import HTTP

extension HTTP.Coder {
    public struct Sequence<
        Root: Call_Algebra.Call.Domain,
        First: HTTP.Responses,
        Second: HTTP.Responses
    >
    where
        First.Domain == Root,
        Second.Domain == Root,
        First.Content == Second.Content
    {
        public let first: First
        public let second: Second

        public init(_ first: First, _ second: Second) {
            self.first = first
            self.second = second
        }
    }
}

extension HTTP.Coder.Sequence: HTTP.Responses {
    public typealias Domain = Root
    public typealias Content = First.Content
    public typealias Coverage = Call_Algebra.Call.Coverage<
        First.Coverage,
        Second.Coverage
    >
}
