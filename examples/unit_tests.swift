import Testing
@testable import AppModel

@Test("Person full name") 
func personFullName() {
    let person = Person(firstName: "Antoine", lastName: "van der Lee")
    #expect(person.fullName == "Antoine van der Lee")
}

@Test func fullName() throws {
    let person = Person(firstName: "Antoine", lastName: "van der Lee")
    // #require macro is used to unwrap an optional value and throw an error if it is nil
    let unwrappedPerson = try #require(person, "Person should be constructed successfully")
    #expect(unwrappedPerson.fullName == "Antoine van der Lee")
}

// Example of an async test
@Test @MainActor func foodTruckExists() async throws { ... }

// Reducing boilerplate code using Parameterized Tests
@Test(arguments: zip([Feature.userDefaultsEditor, .networkMonitor], [10, 5]))
func testLimitedFreeUsage(_ feature: Feature, tries: Int) {
    #expect(feature.isNumberOfTriesWithinFreeLimit(tries))
}


// When working with a large selection of test functions, it can be helpful to organize them into test suites.
// A test function can be added to a test suite in one of two ways:
// By placing it in a Swift type.
// By placing it in a Swift type and annotating that type with the @Suite attribute.
// The @Suite attribute isn’t required for the testing library to recognize that a type contains test functions, but adding it allows customization of a test suite’s appearance in the IDE and at the command line. If a trait such as tags(_:) or disabled(_:sourceLocation:) is applied to a test suite, it’s automatically inherited by the tests contained in the suite.
// In addition to containing test functions and any other members that a Swift type might contain, test suite types can also contain additional test suites nested within them. To add a nested test suite type, simply declare an additional type within the scope of the outer test suite type.
// By default, tests contained within a suite run in parallel with each other. For more information about test parallelization, see Running tests serially or in parallel.
@Suite("Food truck tests") struct FoodTruckTests {
  @Test func foodTruckExists() { ... }
}