MODULE     := github.com/Kiveri/protos
PROTO_DIR  := api
PROTO_FILES := $(shell find $(PROTO_DIR) -name '*.proto' | sort)
BUF        := $(shell command -v buf 2>/dev/null)

# Pin plugin versions to match go.mod dependencies.
PROTOC_VERSION             := 35.1
PROTOC_GEN_GO_VERSION      := v1.36.11
PROTOC_GEN_GO_GRPC_VERSION := v1.6.2

export PATH := $(PATH):$(shell go env GOPATH)/bin

.PHONY: tools proto-gen proto-lint proto-fmt proto-breaking proto-check check

tools:
	@echo "==> [tools] Installing protoc plugins..."
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION)
	@echo "==> [tools] Done. Ensure protoc is installed: https://grpc.io/docs/protoc-installation/"

proto-gen: tools
	@echo "==> [proto-gen] Generating Go code from .proto files..."
	@protoc -I $(PROTO_DIR) \
		--go_out=. --go_opt=module=$(MODULE) \
		--go-grpc_out=. --go-grpc_opt=module=$(MODULE) \
		$(PROTO_FILES)
	@echo "==> [proto-gen] Done."

proto-lint:
ifndef BUF
	$(error buf is not installed; install: go install github.com/bufbuild/buf/cmd/buf@latest)
endif
	@echo "==> [proto-lint] Linting .proto files..."
	@buf lint
	@echo "==> [proto-lint] Done."

proto-fmt:
ifndef BUF
	$(error buf is not installed; install: go install github.com/bufbuild/buf/cmd/buf@latest)
endif
	@echo "==> [proto-fmt] Formatting .proto files..."
	@buf format -w
	@echo "==> [proto-fmt] Done."

proto-breaking:
ifndef BUF
	$(error buf is not installed; install: go install github.com/bufbuild/buf/cmd/buf@latest)
endif
	@echo "==> [proto-breaking] Checking for breaking changes against origin/master..."
	@if ! git ls-tree -r --name-only origin/master -- 'api/' 2>/dev/null | grep -q '\.proto$$'; then \
		echo "==> [proto-breaking] Skipping: no .proto files on origin/master"; \
	else \
		buf breaking --against ".git#commit=$$(git rev-parse origin/master)"; \
	fi
	@echo "==> [proto-breaking] Done."

proto-check: proto-gen
	@echo "==> [proto-check] Verifying gen/ is up to date..."
	@DIFF=$$(git diff gen/ | grep -E '^[+-]' | grep -Ev '^(\+\+\+|---)' | grep -Ev 'protoc[[:space:]]+v[0-9]'); \
	if [ -n "$$DIFF" ]; then \
		echo "$$DIFF"; \
		echo "gen/ is out of date; run 'make proto-gen' and commit"; \
		exit 1; \
	fi
	@echo "==> [proto-check] Done."

check: proto-lint proto-check
	@echo "==> [check] Building generated packages..."
	@go build ./...
	@echo "==> [check] All checks passed."
