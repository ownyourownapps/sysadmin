# sysadmin

Stack central de infraestrutura para um único host (docker compose) com:
- Reverse proxy Traefik + Cloudflared (DNS challenge Cloudflare)
- Observabilidade: Prometheus, Grafana, Loki, Promtail, node-exporter, cAdvisor

## Como usar
1) Copie `env.example` para `.env` e preencha:
   - `ACME_EMAIL`, `CF_DNS_API_TOKEN`, `CLOUDFLARE_TUNNEL_TOKEN`
   - `DOMAIN_BASE`, `TRAEFIK_DOMAIN`, `PROMETHEUS_DOMAIN`, `GRAFANA_DOMAIN`, `LOKI_DOMAIN`
   - `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD`
   - `IP_ALLOWLIST` (opcional, padrão: localhost + redes privadas)
2) Garanta que a rede externa `traefik` exista: `docker network create traefik` (uma vez).
3) Suba: `docker compose up -d` ou `make up`.

## Conectar outras stacks (pmc/arrstack/homelab/nextcloud)
- Adicione seus serviços à rede externa `traefik` no compose/local onde eles vivem.
- Publique as portas de métricas necessárias (ex.: 9101-9105, 9187/9188, 15692) para que o Prometheus central possa scrapeá-las via `host.docker.internal`.
- Opcional: adicione labels Traefik nos serviços para expor via subdomínios.
- Para novos targets Prometheus, crie arquivos em `prometheus/targets/*.yml`.

## Serviços e portas
- **Traefik**: 80/443 (dashboard em `${TRAEFIK_DOMAIN}`)
- **Prometheus**: Acesso via `${PROMETHEUS_DOMAIN}` (porta interna 9090, não exposta)
- **Grafana**: Acesso via `${GRAFANA_DOMAIN}` (porta interna 3000, não exposta)
- **Loki**: Acesso via `${LOKI_DOMAIN}` (porta interna 3100, não exposta)
- **node-exporter**: Porta interna 9100 (não exposta, apenas para Prometheus)
- **cAdvisor**: Porta interna 8080 (não exposta, apenas para Prometheus)
- **Promtail**: Sem portas expostas (envia logs para Loki via rede interna)

> **Nota**: Prometheus, Grafana e Loki não expõem portas diretamente para evitar conflitos com outras stacks. O acesso é feito exclusivamente via Traefik através dos subdomínios configurados.

## Dashboards
- Provisionamento via `grafana/dashboards` e datasources em `grafana/datasources`.
- Inclui dashboard resumido `load-test-dashboard-summary.json`. Você pode adicionar mais arquivos na pasta.

## Documentação Adicional
- `docs/loki-usage.md` - Como usar Loki para visualizar logs
- `docs/prometheus-targets.md` - Como adicionar novos targets ao Prometheus
- `QUESTIONS_ANSWERS.md` - Respostas a dúvidas comuns sobre configuração

## Comandos Úteis
- `make up` - Iniciar todos os serviços
- `make down` - Parar todos os serviços
- `make restart` - Reiniciar todos os serviços
- `make logs` - Ver logs de todos os serviços
- `make ps` - Listar containers em execução
- `make health-check` - Verificar saúde dos serviços
- `make open-traefik` - Abrir Traefik dashboard no navegador
- `make open-grafana` - Abrir Grafana no navegador
- `make open-prometheus` - Abrir Prometheus no navegador
- `make open-loki` - Abrir Loki no navegador
- `make debug` - Iniciar com serviços de debug (whoami)