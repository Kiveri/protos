# protos

Центральный репозиторий [Protocol Buffers](https://protobuf.dev/)-контрактов и сгенерированного Go-кода для сервисов Kiveri.

## Структура

```
api/                    # Исходные .proto файлы (source of truth)
  sso/
    auth/auth.proto     # Публичный auth API (sso.auth.v1)
    admin/admin.proto   # Admin API управления пользователями (sso.admin.v1)
    app/app.proto       # Admin API управления приложениями (sso.app.v1)
gen/                    # Сгенерированный Go-код (коммитится, не редактировать вручную)
buf.yaml                # Правила Buf lint и breaking-change проверок
Makefile                # Генерация кода и локальные проверки
```

Пути импорта в `.proto` файлах задаются относительно каталога `api/`:

```protobuf
import "sso/auth/auth.proto";
```

## Требования

- Go 1.26+
- [protoc](https://grpc.io/docs/protoc-installation/) **35.1** (версия закреплена в `.protoc-version`; в CI — та же)
- [Buf CLI](https://buf.build/docs/installation/) (lint, format, breaking checks)

Установка Go-инструментов и protoc-плагинов:

```bash
make tools
```

Установка Buf (один раз):

```bash
go install github.com/bufbuild/buf/cmd/buf@latest
```

## Использование в других сервисах

Подключите модуль и импортируйте сгенерированные пакеты:

```bash
go get github.com/Kiveri/protos@v0.1.0
```

```go
import (
    ssoauthv1  "github.com/Kiveri/protos/gen/sso/auth/v1"
    ssoadminv1 "github.com/Kiveri/protos/gen/sso/admin/v1"
    ssoappv1   "github.com/Kiveri/protos/gen/sso/app/v1"
)
```

## Make targets

| Target | Описание |
|--------|----------|
| `make tools` | Установить закреплённые версии `protoc-gen-go` и `protoc-gen-go-grpc` |
| `make proto-gen` | Перегенерировать Go-код в `gen/` |
| `make proto-lint` | Запустить Buf lint (правила `STANDARD`) |
| `make proto-fmt` | Отформатировать все `.proto` файлы |
| `make proto-breaking` | Проверить breaking changes относительно `origin/master` |
| `make proto-check` | Перегенерировать и упасть, если `gen/` не совпадает с git |
| `make check` | Lint + proto-check + `go build ./...` |

Типичный workflow перед открытием PR:

```bash
make proto-fmt
make check
```

## Соглашения

- **Именование package:** `sso.<domain>.v1` (например, `sso.auth.v1`)
- **Go package:** `github.com/Kiveri/protos/gen/sso/<domain>/v1;<alias>`
- **Enum:** zero value с суффиксом `_UNSPECIFIED` (например, `USER_ROLE_UNSPECIFIED`)
- **Поля:** `snake_case`; **messages/services:** `PascalCase`
- **Breaking changes:** новая major-версия пакета (`v2`) и semver-тег

## Версионирование

Версии API помечаются по [SemVer](https://semver.org/):

- **Patch** — документация/комментарии, исправления без влияния на wire-формат
- **Minor** — обратно совместимые добавления (новые поля, RPC, значения enum)
- **Major** — breaking changes на уровне wire или JSON

История релизов — в [CHANGELOG.md](CHANGELOG.md).

## Настройка IDE

**GoLand:** Settings → Languages & Frameworks → Protocol Buffers → добавить `$PROJECT_DIR$/api` в import paths (или пометить `api/` как Resources Root).

**VS Code / Cursor:** `.vscode/settings.json` задаёт `--proto_path=api` для расширения proto3.
