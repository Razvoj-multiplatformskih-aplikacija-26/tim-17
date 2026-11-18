FROM dart:3.13.5 AS build
WORKDIR /workspace
COPY <<EOF pubspec.yaml
name: jobly_server_image
environment:
  sdk: ^3.13.0
workspace:
  - packages/domain
  - packages/api_contract
  - packages/api_mapping
  - packages/use_cases
  - apps/server
EOF
COPY pubspec.lock ./
COPY packages/domain packages/domain
COPY packages/api_contract packages/api_contract
COPY packages/api_mapping packages/api_mapping
COPY packages/use_cases packages/use_cases
COPY apps/server apps/server
RUN dart pub get
RUN dart compile exe apps/server/bin/server.dart -o /server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /server /app/server
WORKDIR /app
ENV HOST=0.0.0.0
USER 65532:65532
EXPOSE 8080
CMD ["/app/server"]
