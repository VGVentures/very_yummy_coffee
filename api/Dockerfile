# Official Dart image: https://hub.docker.com/_/dart
FROM dart:stable AS build

WORKDIR /app

# Resolve dependencies.
COPY pubspec.* ./
RUN dart pub get

# Copy source and build.
COPY . .
RUN dart pub global activate dart_frog_cli
RUN dart_frog build

# Compile to a native executable.
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Minimal runtime image.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/build/bin/server /app/bin/server

# Fixture data is read from the working directory at startup.
COPY --from=build /app/fixtures/ /app/fixtures/

EXPOSE 8080
CMD ["/app/bin/server"]
