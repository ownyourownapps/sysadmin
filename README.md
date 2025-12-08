# sysadmin

Stack central de infraestrutura para um único host (docker compose) com:
- Reverse proxy Traefik + Cloudflared (DNS challenge Cloudflare)
- Observabilidade: Prometheus, Grafana, Loki, Promtail, node-exporter, cAdvisor

## Como usar
1) Copie `env.example` para `.env` e preencha:
   - `ACME_EMAIL`, `CF_DNS_API_TOKEN`, `CLOUDFLARE_TUNNEL_TOKEN`
   - `DOMAIN_BASE`, `TRAEFIK_DOMAIN`, `PROMETHEUS_DOMAIN`, `GRAFANA_DOMAIN`, `LOKI_DOMAIN`
   - `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD`
2) Garanta que a rede externa `traefik` exista: `docker network create traefik` (uma vez).
3) Suba: `docker compose up -d`.

## Conectar outras stacks (pmc/arrstack/homelab/nextcloud)
- Adicione seus serviços à rede externa `traefik` no compose/local onde eles vivem.
- Publique as portas de métricas necessárias (ex.: 9101-9105, 9187/9188, 15692) para que o Prometheus central possa scrapeá-las via `host.docker.internal`.
- Opcional: adicione labels Traefik nos serviços para expor via subdomínios.
- Para novos targets Prometheus, crie arquivos em `prometheus/targets/*.yml`.

## Serviços e portas
- Traefik: 80/443 (dashboard em `${TRAEFIK_DOMAIN}`)
- Prometheus: 9090 (`${PROMETHEUS_DOMAIN}`)
- Grafana: 3000 (`${GRAFANA_DOMAIN}`)
- Loki: 3100 (`${LOKI_DOMAIN}`)
- node-exporter: 9100
- cAdvisor: 8081

## Dashboards
- Provisionamento via `grafana/dashboards` e datasources em `grafana/datasources`.
- Inclui dashboard resumido `load-test-dashboard-summary.json`. Você pode adicionar mais arquivos na pasta.