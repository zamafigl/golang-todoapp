include .env
export 

export PROJECT_ROOT=$(shell pwd)
env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@read -p "Очистить данные окружения? (yes/no) " ans; \
	if [ "$$ans" = "yes" ]; then \
		docker compose down todoapp-postgres && \
		rm -rf out/pgdata &&\
		echo "Данные окружения очищены."; \
	else \
		echo "Очистка данных окружения отменена."; \
	fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Отстуствует необходимый параметр seq. Используйте: make migrate-create seq=<номер миграции>"; \
		exit 1; \
	fi 
	docker compose run --rm todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"
migrate-action:
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@todoapp-postgres:5432/$(POSTGRES_DB)?sslmode=disable \
		$(action)
migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder