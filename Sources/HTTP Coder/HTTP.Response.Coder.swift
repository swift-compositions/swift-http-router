public import HTTP

extension HTTP.Response {

    /// - Warning: This nest shadows the `Coder` primitive namespace. Inside it,
    ///   an unqualified `Coder` resolves here, and the primitive must be spelled
    ///   `Coder_Primitive.Coder`. The failure mode is a circular-reference
    ///   diagnostic that names neither type.
    public enum Coder {}
}
