# sysadmin

Stack central de infraestrutura para um único host (docker compose) com:
- Observabilidade: Prometheus, Grafana, Loki, Promtail, node-exporter, cAdvisor

> **Nota**: Esta stack depende de uma stack de reverse proxy (Traefik) que deve estar rodando antes de iniciar esta stack.

## Serviços e suas funções

### Observabilidade - Métricas
- **Prometheus**: Sistema de monitoramento e alertas que coleta e armazena métricas de tempo de série. Scrape métricas de diversos serviços e exportadores.
- **Grafana**: Plataforma de visualização e análise que permite criar dashboards interativos para visualizar métricas do Prometheus e logs do Loki.
- **node-exporter**: Exportador Prometheus que coleta métricas do sistema operacional (CPU, memória, disco, rede) do host.
- **cAdvisor**: Exportador Prometheus que coleta métricas de uso de recursos (CPU, memória, I/O) dos containers Docker em execução.

### Observabilidade - Logs
- **Loki**: Sistema de agregação de logs projetado para ser altamente escalável e econômico. Armazena logs coletados pelo Promtail.
- **Promtail**: Agente de coleta de logs que monitora arquivos de log e envia os dados para o Loki. Configurado para coletar logs de containers Docker.

### Utilitários
- **whoami**: Serviço de teste/debug que retorna informações sobre requisições HTTP recebidas. Útil para validar configuração do Traefik.

## Como usar

1. **Certifique-se de que o Traefik está rodando:**
   - Esta stack depende do Traefik para expor os serviços via HTTPS
   - Inicie a stack do Traefik antes desta stack

2. **Copie `env.example` para `.env` e preencha:**
   - `DOMAIN_BASE`, `PROMETHEUS_DOMAIN`, `GRAFANA_DOMAIN`, `LOKI_DOMAIN`
   - `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD`
   - `MOUNT_POINT` (opcional, padrão: ./data)

3. **Garanta que a rede externa `traefik` exista:**
   - Normalmente criada pela stack do Traefik, mas se necessário: `docker network create traefik` (uma vez)

4. **Suba os serviços:**
   ```bash
   docker compose up -d
   ```
   Ou usando o Makefile:
   ```bash
   make up
   ```

## Conectar outras stacks
- Adicione seus serviços à rede externa `traefik` no compose/local onde eles vivem.
- Publique as portas de métricas necessárias (ex.: 9101-9105, 9187/9188, 15692) para que o Prometheus central possa scrapeá-las via `host.docker.internal`.
- Opcional: adicione labels Traefik nos serviços para expor via subdomínios.
- Para novos targets Prometheus, crie arquivos em `prometheus/targets/*.yml` (veja `docs/prometheus-targets.md` para detalhes).

## Serviços e portas
- **Prometheus**: Acesso via `${PROMETHEUS_DOMAIN}` (porta interna 9090, não exposta)
- **Grafana**: Acesso via `${GRAFANA_DOMAIN}` (porta interna 3000, não exposta)
- **Loki**: Acesso via `${LOKI_DOMAIN}` (porta interna 3100, não exposta)
- **node-exporter**: Porta interna 9100 (não exposta, apenas para Prometheus)
- **cAdvisor**: Porta interna 8080 (não exposta, apenas para Prometheus)
- **Promtail**: Sem portas expostas (envia logs para Loki via rede interna)
- **whoami** (opcional): Serviço de teste/debug acessível via `who.${DOMAIN_BASE}` (use `make debug` para ativar)

> **Nota**: Prometheus, Grafana e Loki não expõem portas diretamente para evitar conflitos com outras stacks. O acesso é feito exclusivamente via Traefik através dos subdomínios configurados.

## Segurança
- **Certificados SSL/TLS**: Gerenciados automaticamente pelo Traefik via Let's Encrypt com DNS challenge do Cloudflare
- **Redes Docker**: Serviços de observabilidade isolados na rede `observability`, expostos apenas via Traefik

## Dashboards
- Provisionamento via `grafana/dashboards` e datasources em `grafana/datasources`.
- Você pode adicionar dashboards JSON na pasta `grafana/dashboards` e eles serão automaticamente provisionados.

## Documentação Adicional
- `docs/loki-usage.md` - Como usar Loki para visualizar logs
- `docs/prometheus-targets.md` - Como adicionar novos targets ao Prometheus

## Comandos Úteis
- `make up` - Iniciar todos os serviços
- `make down` - Parar todos os serviços
- `make restart` - Reiniciar todos os serviços
- `make logs` - Ver logs de todos os serviços
- `make ps` - Listar containers em execução
- `make health-check` - Verificar saúde dos serviços
- `make open-grafana` - Abrir Grafana no navegador
- `make open-prometheus` - Abrir Prometheus no navegador
- `make open-loki` - Abrir Loki no navegador
- `make debug` - Iniciar com serviços de debug (whoami)

> **Nota**: O Traefik dashboard está na stack do reverse proxy. Acesse-o através da stack que gerencia o Traefik.