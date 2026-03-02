<!-- Downloaded from: https://engineering.verygood.ventures/development/testing/testing_best_practices/llms.txt -->
<!-- Source: Testing Best Practices -->

# Testing Best Practices

These are some tips for writing the most effective and maintainable tests possible.

## Name tests descriptively

Don't be afraid of being verbose in your tests. Make sure everything is readable, which can make it easier to maintain over time.

Good ✅:
```dart
testWidgets('renders $YourView', (tester) async {});
testWidgets('renders $YourView for $YourState', (tester) async {});
test('given an [input] is returning the [output] expected', () async {});
blocTest<YourBloc, RecipeGeneratorState>('emits $StateA if ...',);
```

Bad ❗️:
```dart
testWidgets('renders', (tester) async {});
test('works', () async {});
blocTest<YourBloc, RecipeGeneratorState>('emits',);
```

## Tests should be named as natural sentences

Tests should be organized so they read as natural sentences when combined with their group names. The top-level group should be the class or entity being tested, and nested groups should represent specific methods or behaviors.

Good ✅:
```dart
group(ShoppingCart, () {
  group('addItem', () {
    test('increases item count', () {
      // ShoppingCart addItem increases item count
    });

    test('updates total price', () {
      // ShoppingCart addItem updates total price
    });
  });

  group('calculateTotal', () {
    test('returns sum of all item prices', () {
      // ShoppingCart calculateTotal returns sum of all item prices
    });

    test('returns zero when cart is empty', () {
      // ShoppingCart calculateTotal returns zero when cart is empty
    });
  });
});
```

Bad ❗️:
```dart
void main() {
   test('Validate calculateTotal returns total when cart is empty', () {
    // No need for "Validate" as it's implied a test is validating a behavior
   });

  test('ShoppingCart addItem increases item count', () {
    // No grouping structure - harder to organize and read
  });

  test('returns zero', () {
    // Missing context - what class and method is this testing?
  });

  group('total tests', () {
    test('works correctly', () {
      // Too vague and doesn't read naturally
    });
  });
}
```

## Use string expression with types

If you're referencing a type within a test description, use a [string expression](https://dart.dev/language/built-in-types#string) to ease renaming the type:

Good ✅:
```dart
testWidgets('renders $YourView', (tester) async {});
```

Bad ❗️:
```dart
testWidgets('renders YourView', (tester) async {});
```

If your [test](https://pub.dev/documentation/test/latest/test/test.html) or [group](https://pub.dev/documentation/test/latest/test/group.html) description only contains a type, consider omitting the string expression:

Good ✅:
```dart
group(YourView, () {});
```

Bad ❗️:
```dart
group('$YourView', () {});
```

## Keep test setup inside a group

When running tests through the `very_good` CLI's optimization, all test files become a single file.

If test setup methods are outside of a group, those setups may cause side effects and make tests fail due to issues that wouldn't happen when running without the optimization.

In order to avoid such issues, refrain from adding `setUp` and `setUpAll` (as well as `tearDown` and `tearDownAll`) methods outside a group:

Good ✅:
```dart
void main() {
  group(UserRepository, () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = _MockApiClient();
      // mock api client methods...
    });

    // Tests...
  });
}
```

Bad ❗️:
```dart
void main() {
  late ApiClient apiClient;

  setUp(() {
    apiClient = _MockApiClient();
    // mock api client methods...
  });

  group(UserRepository, () {
    // Tests...
  });
}
```

## Use private mocks

Developers may reuse mocks across different test files. This could lead to undesired behaviors in tests. For example, if you change the default values of a mock in one class, it could effect your test results in another. In order to avoid this, it is better to create private mocks for each test file.

Good ✅:
```dart
class _MockYourClass extends Mock implements YourClass {}
```

Bad ❗️:
```dart
class MockYourClass extends Mock implements YourClass {}
```

:::tip
The analyzer will warn you about unused private mocks (but not if they're public!) if the [`unused_element` diagnostic message](https://dart.dev/tools/diagnostic-messages?utm_source=dartdev&utm_medium=redir&utm_id=diagcode&utm_content=unused_element#unused_element) is not suppressed.
:::

:::tip
If you have the [Bloc VS Code extension](https://github.com/felangel/bloc/tree/master/extensions/vscode) installed, you can use the [`_mock` snippet](https://github.com/felangel/bloc/tree/master/extensions/vscode#bloc) to quickly create a private mock.
:::

## Use keys carefully

Although keys can be an easy way to look for a widget while testing, they tend to be harder to maintain, especially if we use hard-coded keys. Instead, we recommend finding a widget by its type.

Good ✅:
```dart
expect(find.byType(HomePage), findsOneWidget);
```

Bad ❗️:
```dart
expect(find.byKey(Key('homePageKey')), findsOneWidget);
```

## Shared mutable objects should be initialized per test

We should ensure that shared mutable objects are initialized per test. This avoids the possibility of tests affecting each other, which can lead to flaky tests due to unexpected failures during test parallelization or random ordering.

Good ✅:
```dart
void main() {
  group(_MySubject, () {
    late _MySubjectDependency myDependency;

    setUp(() {
      myDependency = _MySubjectDependency();
    });

    test('value starts at 0', () {
      // This test no longer assumes the order tests are run.
      final subject = _MySubject(myDependency);
      expect(subject.value, equals(0));
    });

    test('value can be increased', () {
      final subject = _MySubject(myDependency);

      subject.increase();

      expect(subject.value, equals(1));
    });
  });
}
```

Bad ❗️:
```dart
class _MySubjectDependency {
  var value = 0;
}

class _MySubject {
  // Although the constructor is constant, it is mutable.
  const _MySubject(this._dependency);

  final _MySubjectDependency _dependency;

  get value => _dependency.value;

  void increase() => _dependency.value++;
}

void main() {
  group(_MySubject, () {
    final _MySubjectDependency myDependency = _MySubjectDependency();

    test('value starts at 0', () {
      // This test assumes the order tests are run.
      final subject = _MySubject(myDependency);
      expect(subject.value, equals(0));
    });

    test('value can be increased', () {
      final subject = _MySubject(myDependency);

      subject.increase();

      expect(subject.value, equals(1));
    });
  });
}
```

## Do not share state between tests

Tests should not share state between them to ensure they remain independent, reliable, and predictable.

When tests share state (such as relying on static members), the order that tests are executed in can cause inconsistent results. Implicitly sharing state between tests means that tests no longer exist in isolation and are influenced by each other. As a result, it can be difficult to identify the root cause of test failures.

Good ✅:
```dart
class _Counter {
  int value = 0;
  void increment() => value++;
  void decrement() => value--;
}

void main() {
  group(_Counter, () {
    late _Counter counter;

    setUp(() => counter = _Counter());

    test('increment', () {
      counter.increment();
      expect(counter.value, 1);
    });

    test('decrement', () {
      counter.decrement();
      expect(counter.value, -1);
    });
  });
}
```

Bad ❗️:
```dart
class _Counter {
  int value = 0;
  void increment() => value++;
  void decrement() => value--;
}

void main() {
  group(_Counter, () {
    final _Counter counter = _Counter();

    test('increment', () {
      counter.increment();
      expect(counter.value, 1);
    });

    test('decrement', () {
      counter.decrement();
      // The expectation only succeeds when the previous test executes first.
      expect(counter.value, 0);
    });
  });
}
```

## Use random test ordering

Running tests in an arbitrary (random) order is a crucial practice to identify and eliminate flaky tests, specially during continuous integration.

Flaky tests are those that pass or fail inconsistently without changes to the codebase, often due to unintended dependencies between tests.

By running tests in random order, these hidden dependencies are more likely to be exposed, as any reliance on the order of test execution becomes clear when tests fail unexpectedly.

This practice ensures that tests do not share state or rely on the side effects of previous tests, leading to a more robust and reliable test suite. Overall, the tests become easier to trust and reduce debugging time caused by intermittent test failures.

Good ✅:
```sh # Randomize test ordering using the --test-randomize-ordering-seed
option flutter test --test-randomize-ordering-seed random dart test
--test-randomize-ordering-seed random very_good test
--test-randomize-ordering-seed random ```

## Avoid using magic strings to tag tests

When [tagging tests](https://github.com/dart-lang/test/blob/master/pkgs/test/doc/configuration.md#configuring-tags), avoid using magic strings. Instead, use constants to tag tests. This helps to avoid typos and makes it easier to refactor.

Good ✅:
```dart
testWidgets(
  'render matches golden file',
  tags: TestTag.golden,
  (WidgetTester tester) async {
    // ...
  },
);
```

Bad ❗️:
```dart
testWidgets(
  'render matches golden file',
  tags: 'golden',
  (WidgetTester tester) async {
    // ...
  },
);
```

:::caution

[Dart 2.17](https://dart.dev/guides/whats-new#may-11-2022-2-17-release) introduced [enhanced enumerations](https://dart.dev/language/enums)
and [Dart 3.3](https://dart.dev/guides/whats-new#february-15-2024-3-3-release) introduced [extension types](https://dart.dev/language/extension-types). These could be used to declare the tags within arguments, however you will not be able to use the tags within the [`@Tags` annotation](https://pub.dev/documentation/test/latest/test/Tags-class.html).

Instead, define an abstract class to hold your tags:

```dart
/// Defined tags for tests.
///
/// Use these tags to group tests and run them separately.
///
/// Tags are defined within the `dart_test.yaml` file.
///
/// See also:
///
/// * [Dart Test Configuration documentation](https://github.com/dart-lang/test/blob/master/pkgs/test/doc/configuration.md)
abstract class TestTag {
  /// Tests that compare golden files.
  static const golden = 'golden';
}
```

:::