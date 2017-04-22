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
        case .integer(let value):
            return .integer(value)

        case .variable(let identifier):
            if let value = lookup[identifier] {
                return value
            } else {
                throw Error.unboundVariable(identifier)
            }

        case .add(let lhs, let rhs):
            return try evaluateAdd(lhs: lhs, rhs: rhs)
        default:
            fatalError()
        }
    }

    // eval env (e1 :+ e2) =
    //     let v1 = eval env e1
    //         v2 = eval env e2
    //     in case (v1,v2) of
    //        (VI n1, VI n2) -> VI (n1+n2)
    //        vs     -> error $
    //                  "Trying to add non-integers: " ++ show vs
    private func evaluateAdd(lhs: Term, rhs: Term) throws -> Value {
        let left = try evaluate(lhs)
        let right = try evaluate(rhs)
        switch (left, right) {
        case (.integer(let leftValue), .integer(let rightValue)):
            return .integer(leftValue + rightValue)
        case (.integer, _), (.closure, _):
            throw Error.mismatchedFunctionArguments(received: [String(describing: left), String(describing: right)], expected: ["Int", "Int"])
        }
    }
}

//: [Next](@next)
