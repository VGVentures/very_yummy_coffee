# Custom Dockerfile for Dart Frog — see https://dart-frog.dev/advanced/custom-dockerfile/
#
# This API depends on ../shared/very_yummy_coffee_models. Build from the monorepo root:
#   docker build -f api/Dockerfile -t very-yummy-coffee-api .
#
# Run: docker run -i -t -p 8080:8080 very-yummy-coffee-api
#
# Official Dart image: https://hub.docker.com/_/dart
# Pin to match monorepo SDK constraints (e.g. very_yummy_coffee_models ^3.11.0).
FROM dart:3.11 AS build

# Layout matches pubspec path dependency: api at /app, shared at /shared/...
COPY shared/very_yummy_coffee_models /shared/very_yummy_coffee_models
COPY api /app

WORKDIR /app

# Resolve app dependencies.
RUN dart pub get

# Generate a production build.
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# AOT-compile from the bundled build output (path deps live under .dart_frog_path_dependencies).
WORKDIR /app/build
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Minimal runtime image from AOT binary and Dart runtime files from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/build/bin/server /app/bin/
COPY --from=build /app/build/fixtures/ /app/fixtures/

# Server loads `fixtures/menu.json` relative to the process working directory.
WORKDIR /app

EXPOSE 8080

# Uncomment if you add static assets to the Dart Frog project.
# COPY --from=build /app/build/public /public/

CMD ["/app/bin/server"]
