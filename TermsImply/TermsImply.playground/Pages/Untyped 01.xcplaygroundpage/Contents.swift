//: [Previous](@previous)

typealias Identifier = String

enum Term {
    case variable(Identifier)
    indirect case lambda(varName: Identifier, body: Term)
    indirect case application(Term, argument: Term)
    case integer(Int)
    indirect case add(Term, Term)
    indirect case ifIsZero(predicate: Term, then: Term, else: Term)

    static func + (lhs: Term, rhs: Term) -> Term {
        return .add(lhs, rhs)
    }
}

//    data Value = VI Int | VC (Value -> Value)
//    instance Show Value where
//        show (VI n) = "VI " ++ show n
//        show (VC _) = "<function>"
enum Value : ExpressibleByIntegerLiteral, CustomStringConvertible {
    typealias RawClosure = (Value) throws -> Value
    case integer(Int)
    case closure(RawClosure)

    init(integerLiteral value: Int) {
        self = .integer(value)
    }

    var description: String {
        switch self {
        case .integer(let value):
            return value.description
        case .closure:
            return "(Closure)"
        }
    }
}

//: [Next](@next)
