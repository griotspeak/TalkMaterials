//: [Previous](@previous)

typealias Identifier = String

enum Error : Swift.Error {
    case undefinedValue(identifier: Identifier)
    case unboundVariable(Identifier)
    case mismatchedFunctionArguments(received: [String], expected: [String])
    case invalidZeroPredicate(Value)
    case applicationOfNonFunction(Value)
}

enum Term : ExpressibleByIntegerLiteral {
    case variable(Identifier)
    indirect case lambda(varName: Identifier, body: Term)
    indirect case application(Term, argument: Term)
    case integer(Int)
    indirect case add(Term, Term)
    indirect case ifIsZero(predicate: Term, then: Term, else: Term)

    static func + (lhs: Term, rhs: Term) -> Term {
        return .add(lhs, rhs)
    }

    init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

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

//    type Env = [(VarName, Value)]
struct Environment {
    var lookup: [Identifier:Value]

    init() {
        self.init(lookup: [:])
    }

    init(lookup: [Identifier:Value]) {
        self.lookup = lookup
    }

    public func setting(value: Value, for identifier: Identifier) -> Environment {
        var newLookup = lookup
        newLookup[identifier] = value
        return Environment(lookup: newLookup)
    }

    func evaluate(_ term: Term) throws -> Value {
        switch term {
        //        eval env (I n) = VI n
        case .integer(let value):
            return .integer(value)

        default:
            fatalError()
        }
    }
}

//: [Next](@next)
