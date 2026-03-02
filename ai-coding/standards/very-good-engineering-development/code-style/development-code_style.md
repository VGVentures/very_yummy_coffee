<!-- Downloaded from: https://engineering.verygood.ventures/development/code_style/llms.txt -->
<!-- Source: Code Style -->

# Code Style

In general, the best guides for code style are the [Effective Dart](https://dart.dev/effective-dart) guidelines and the linter rules set up in [very_good_analysis](https://pub.dev/packages/very_good_analysis). However, there are certain practices we've learned outside of these two places that will make code more maintainable.

## Record Types

Among other things, the release of Dart 3.0 introduced [record types](https://dart.dev/language/records), a way to store two different but related pieces of data without creating a separate data class. When using record types, be sure to choose expressive names for positional values.

Bad ❗️:
```dart
Future<(String, String)> getUserNameAndEmail() async => _someApiFetchMethod();

final userData = await getUserNameAndEmail();

// a bunch of other code...

if (userData.$1.isValid) {
  // do stuff
}
```

The above example will compile, but it is not immediately obvious what value `userData.$1` refers to here. The name of the function gives the reader the impression that the second value in the record is the email, but it is not clear. Particularly in a large codebase, where there could be more processing in between the call to `getUserNameAndEmail()` and the check on `userData.$1`, reviewers will not be able to tell immediately what is going on here.

Good ✅:
```dart
Future<(String, String)> getUserNameAndEmail() async => _someApiFetchMethod();

final (username, email) = await getUserNameAndEmail();

// a bunch of other code...

if (email.isValid) {
  // do stuff
}
```

Now, we are expressly naming the values that we are getting from our record type. Any reviewer or future maintainer of this code will know what value is being validated.

:::tip
While this is our recommended practice for dealing with record types, you might want to consider whether you actually need a record type. Particularly in larger projects where you are using values across multiple files, dedicated data models may be easier to read and maintain.
:::

## Prefer Widgets to Methods

We prefer creating widgets over creating methods that return `Widget`.

Bad ❗️:
```dart
  class ParentWidget extends StatelessWidget {
    const ParentWidget({super.key});

    \@override
    Widget build(BuildContext context) {
      return _buildChildWidget(context);
    }

    Widget _buildChildWidget(BuildContext context) {
      return const Text('Hello World!');
    }
  }
  ```

Good ✅:
```dart
  class ParentWidget extends StatelessWidget {
    const ParentWidget({super.key});

    \@override
    Widget build(BuildContext context) {
      return ChildWidget();
    }
  }

  class ChildWidget extends StatelessWidget {
    const ChildWidget({super.key});

    \@override
    Widget build(BuildContext context) {
      return const Text('Hello World!');
    }
  }
  ```

We prefer this for a few reasons:

1. It avoids coding errors caused by passing around the wrong `BuildContext`. Flutter manages the `BuildContext` via the widget tree, which is more reliable.

2. The widgets are added to the widget tree, which allows for more potentially efficient rendering and enables inspecting them in the debug tools.

3. Widgets are easier to test as they can be tested in isolation. They don't required building the `ParentWidget` to test the `ChildWidget`.

For more details, check out the following video:

<iframe
  style="width: 100%; height: 480px;"
  src="https://www.youtube.com/embed/IOyq-eTRhvo?si=pr_2yp_tr94EJztF"
  title="YouTube video player"
  frameborder="0"
  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
  referrerpolicy="strict-origin-when-cross-origin"
  allowfullscreen
></iframe>

## Prefer `EdgeInsets.symmetric` and `EdgeInsets.only` over `EdgeInsets.fromLTRB`

When specifying padding or insets, avoid using `EdgeInsets.fromLTRB`. The positional arguments make it easy to mix up which value applies to which side.

Bad ❗️:
```dart
Padding(
  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
  child: child,
)
```

Good ✅:
```dart
Padding(
  padding: const EdgeInsets.only(top: 16, bottom: 8),
  child: child,
)
```

When all horizontal or vertical values are the same, prefer `EdgeInsets.symmetric` for brevity.

Bad ❗️:
```dart
Padding(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
  child: child,
)
```

Good ✅:
```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: child,
)
```

## Prefer `async`/`await` over `.then`

When working with `Future`s, prefer `async`/`await` over `.then`. The `async`/`await` syntax is easier to read, debug, and test.

Bad ❗️:
```dart
Future<void> fetchAndSaveUser() {
  return getUser().then((user) {
    return saveUser(user);
  });
}
```

Good ✅:
```dart
Future<void> fetchAndSaveUser() async {
  final user = await getUser();
  await saveUser(user);
}
```

`async`/`await` also makes error handling more straightforward — standard `try`/`catch` blocks work as expected, whereas `.then` requires chaining `.catchError`, which has its own subtle behaviors.