# Changelog

Здесь документируются все значимые изменения Protocol Buffer API этого проекта.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/),
проект следует [Semantic Versioning](https://semver.org/lang/ru/).

## [Unreleased]

### Добавлено

- Buf lint/format/breaking checks, CI pipeline, `tools.go` и документация проекта.

### Изменено

- Переименован gRPC-сервис `AuthAdmin` → `AuthAdminService` для соответствия правилам Buf `STANDARD`.

### Добавлено (начальные API)

- Определения SSO API: `sso.auth.v1`, `sso.admin.v1`, `sso.app.v1`.

## [0.1.0] - 2026-07-26

### Добавлено

- Первая опубликованная версия protobuf-контрактов для домена Kiveri SSO.

[Unreleased]: https://github.com/Kiveri/protos/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Kiveri/protos/releases/tag/v0.1.0
