public import Byte
public import Checkpoint
public import HTTP

extension HTTP.Router {

    public typealias Request = HTTP.Message.Request<[Byte]>
}

extension HTTP.Message.Request: @retroactive Restorable where Content == [Byte] {

    public typealias Checkpoint = Self

    @inlinable
    public var checkpoint: Self {
        self
    }

    @inlinable
    public mutating func seek(to checkpoint: Self) {
        self = checkpoint
    }
}
