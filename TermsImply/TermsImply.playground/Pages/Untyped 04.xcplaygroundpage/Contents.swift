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

        case .ifIsZero(let predicate, let thenTerm, let elseTerm):
            let v1 = try evaluate(predicate)
            switch v1 {
            case .integer(0):
                return try evaluate(thenTerm)
            case .integer:
                return try evaluate(elseTerm)
            case .closure:
                throw Error.invalidZeroPredicate(v1)
            }

        case .lambda(let name, let argument):
            return .closure { (v) -> Value in
                try self.setting(value: v, for: name).evaluate(argument)
            }

        case .application(let e1, let argument):
            return try evaluateApplication(body: e1, argument: argument)
        }
    }

    private func evaluateApplication(body: Term, argument: Term) throws -> Value {
        let v1 = try evaluate(body)
        let v2 = try evaluate(argument)
        switch v1 {
        case .integer:
            throw Error.applicationOfNonFunction(v1)
        case .closure(let closure):
            return try closure(v2)
        }
    }

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


//eval env0 (L "x" (IFZ (V "x") (I 1) ((V "x") :+ (I 2))) ‘A‘ (I 10))
let example: Term = .application(.lambda(varName: "x", body: .ifIsZero(predicate: .variable("x"), then: 1, else: .variable("x") + 2)), argument: 10)

let environment = Environment()
let x: Identifier = "x"
let vx: Term = .variable("x")
let term1: Term = .lambda(varName: x, body: .ifIsZero(predicate: vx, then: 1, else: vx + 2))


do {
    try environment.evaluate(example)
} catch let error {
    print(error)
}

do {
    try environment.evaluate(term1)
    try environment.evaluate(.application(term1, argument: 2))
    try environment.evaluate(.application(term1, argument: 0))
    try environment.evaluate(.application(term1, argument: vx))
} catch let error {
    print(error)
}





//: [Next](@next)
