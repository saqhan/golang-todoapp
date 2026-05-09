include .env
export

env-up:
	@docker compose up -d todoapp-postgres
	@echo "PostgreSQL запущен"
	@echo "Подключение: postgresql://test_user:test_password@localhost:5432/test_db"

env-down:
	@docker compose down todoapp-postgres

env-logs:
	@docker compose logs -f

env-ps:
	@docker compose ps

env-cleanup:
	@read -p "clean all volume files? [y/n]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres && \
		rm -rf out/pgdata && \
		echo "✅ files cleaned"; \
	else \
		echo "❌ cleaned cancel"; \
	fi

migrate-create:
	@if [ -z $(seq) ]; then \
		echo "Error: seq variable is not set"; \
		exit 1; \
	fi
	docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

test-target:
	@echo "value: $(var)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z $(action) ]; then \
		echo "Отсутствует экшен"; \
		exit 1; \
	fi
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder