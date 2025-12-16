.PHONY: help up down restart logs ps health-check open-traefik open-grafana open-prometheus open-loki

# Default target
help:
	@echo "Sysadmin Stack - Available commands:"
	@echo ""
	@echo "  make up              - Start all services"
	@echo "  make down            - Stop all services"
	@echo "  make restart         - Restart all services"
	@echo "  make logs            - Show logs from all services"
	@echo "  make ps              - Show running containers"
	@echo "  make health-check    - Check service health"
	@echo ""
	@echo "  make open-traefik    - Open Traefik dashboard"
	@echo "  make open-grafana    - Open Grafana dashboard"
	@echo "  make open-prometheus - Open Prometheus UI"
	@echo "  make open-loki       - Open Loki UI"
	@echo ""
	@echo "  make debug           - Start with debug services (whoami)"

# Docker Compose commands
up:
	@docker compose up -d
	@echo "✅ Services started!"
	@echo ""
	@make ps

down:
	@docker compose down
	@echo "✅ Services stopped!"

restart:
	@docker compose restart
	@echo "✅ Services restarted!"

logs:
	@docker compose logs -f

ps:
	@docker compose ps

# Health Check
health-check:
	@echo "Checking service health..."
	@echo ""
	@echo "Container Status:"
	@docker compose ps
	@echo ""
	@echo "Testing endpoints (if accessible via Traefik):"
	@echo "  Note: Services are accessed via Traefik domains (check .env for domains)"
	@echo ""
	@echo "Service URLs (from .env):"
	@echo "  Traefik:    https://$$(grep TRAEFIK_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'traefik.example.com')"
	@echo "  Grafana:    https://$$(grep GRAFANA_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'grafana.example.com')"
	@echo "  Prometheus: https://$$(grep PROMETHEUS_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'prometheus.example.com')"
	@echo "  Loki:       https://$$(grep LOKI_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'loki.example.com')"

# UI Access (via Traefik domains)
open-traefik:
	@DOMAIN=$$(grep TRAEFIK_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'traefik.example.com'); \
	echo "Opening Traefik at https://$$DOMAIN"; \
	which xdg-open > /dev/null 2>&1 && xdg-open https://$$DOMAIN || \
	which open > /dev/null 2>&1 && open https://$$DOMAIN || \
	echo "Please open https://$$DOMAIN in your browser"

open-grafana:
	@DOMAIN=$$(grep GRAFANA_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'grafana.example.com'); \
	echo "Opening Grafana at https://$$DOMAIN"; \
	which xdg-open > /dev/null 2>&1 && xdg-open https://$$DOMAIN || \
	which open > /dev/null 2>&1 && open https://$$DOMAIN || \
	echo "Please open https://$$DOMAIN in your browser"

open-prometheus:
	@DOMAIN=$$(grep PROMETHEUS_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'prometheus.example.com'); \
	echo "Opening Prometheus at https://$$DOMAIN"; \
	which xdg-open > /dev/null 2>&1 && xdg-open https://$$DOMAIN || \
	which open > /dev/null 2>&1 && open https://$$DOMAIN || \
	echo "Please open https://$$DOMAIN in your browser"

open-loki:
	@DOMAIN=$$(grep LOKI_DOMAIN .env 2>/dev/null | cut -d'=' -f2 || echo 'loki.example.com'); \
	echo "Opening Loki at https://$$DOMAIN"; \
	which xdg-open > /dev/null 2>&1 && xdg-open https://$$DOMAIN || \
	which open > /dev/null 2>&1 && open https://$$DOMAIN || \
	echo "Please open https://$$DOMAIN in your browser"

# Debug mode (includes whoami services)
debug:
	@docker compose --profile debug up -d
	@echo "✅ Services started with debug profile (whoami enabled)!"

