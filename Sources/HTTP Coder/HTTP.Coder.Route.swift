public import Call_Algebra
public import HTTP

extension HTTP.Coder {
    public struct Route<
        Root: Call_Algebra.Call.Domain,
        Identifier,
        Child: HTTP.Responses
    >
    where
        Child.Domain: HTTP.Respondable,
        Child == Child.Domain.Response
    {
        public let child: Child

        public init(
            _: KeyPath<
                Root.Call.Branches,
                Call_Algebra.Call.Branch<
                    Root.Call,
                    Child.Domain.Call,
                    Identifier
                >
            >,
            child: () -> Child
        ) {
            self.child = child()
        }
    }
}

extension HTTP.Coder.Route: HTTP.Responses {
    public typealias Domain = Root
    public typealias Content = Child.Content
    public typealias Coverage = Identifier
}
