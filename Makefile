COMPOSE=docker compose -f srcs/docker-compose.yml

up:
	$(COMPOSE) up -d --build
down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

re:
	$(COMPOSE) down -v
	$(COMPOSE) up -d --build

ps:
	$(COMPOSE) ps

.PHONY: up down logs ps re