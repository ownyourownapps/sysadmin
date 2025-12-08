# Respostas às Dúvidas

## Docker Compose - Portas Expostas

### Por que expor portas se estamos usando Traefik?

**Resposta curta:** Para serviços internos (Prometheus, Grafana, Loki), você pode remover as portas expostas se quiser acessar APENAS via Traefik. Mas há casos onde faz sentido manter:

1. **Prometheus (9090)**: 
   - Se você quiser acessar diretamente para debug/testes: mantenha
   - Se quiser APENAS via Traefik: remova
   - **Recomendação**: Manter para debug, mas adicionar labels Traefik também

2. **Grafana (3000)**:
   - Mesma lógica do Prometheus
   - **Recomendação**: Manter para acesso direto em caso de problemas com Traefik

3. **Node-exporter (9100)**:
   - **NÃO precisa expor** - é apenas para o Prometheus interno
   - Prometheus acessa via rede Docker (`node-exporter:9100`)

4. **cAdvisor (8081)**:
   - **NÃO precisa expor** - é apenas para o Prometheus interno
   - Prometheus acessa via rede Docker (`cadvisor:8080`)

5. **Loki (3100)**:
   - Se quiser acessar via Traefik: remova a porta
   - Se quiser acesso direto: mantenha
   - **Recomendação**: Remover, usar apenas via Traefik

6. **Promtail**:
   - **NÃO precisa expor nada** - ele só envia logs para Loki via rede interna

## Volumes

### `prometheus_data:/prometheus`
- **O que é**: Volume persistente onde o Prometheus armazena os dados de séries temporais (TSDB)
- **Quem escreve**: O próprio Prometheus escreve aqui
- **Por que**: Para persistir métricas entre reinicializações do container

### `./prometheus/targets:/etc/prometheus/targets`
- **O que é**: Diretório montado para arquivos de service discovery
- **Para que serve**: Permite adicionar novos targets do Prometheus sem recriar o container
- **Como usar**: Crie arquivos YAML em `./prometheus/targets/` com targets adicionais

### `grafana_data:/var/lib/grafana`
- **O que é**: Volume persistente do Grafana
- **O que contém**: Dashboards criados na UI, datasources configurados manualmente, usuários, etc.
- **Por que**: Para não perder configurações entre reinicializações

### `./grafana/dashboards/dashboard.yml`
- **O que é**: Arquivo de provisionamento do Grafana
- **Para que serve**: Diz ao Grafana onde procurar dashboards JSON e como carregá-los automaticamente
- **Como funciona**: Grafana lê este arquivo na inicialização e carrega os dashboards da pasta especificada

## Configurações

### `extra_hosts: host.docker.internal:host-gateway`
- **O que é**: Permite que containers acessem serviços rodando no host (fora do Docker)
- **Como funciona**: Cria um alias DNS `host.docker.internal` que aponta para o gateway do host
- **Por que usar**: Para o Prometheus coletar métricas de serviços que rodam no host (ex: RabbitMQ na porta 15692 do host)

### `GF_INSTALL_PLUGINS`
- **O que é**: Lista de plugins do Grafana para instalar automaticamente
- **Exemplo**: `"grafana-piechart-panel,grafana-clock-panel"`
- **Vazio**: Não instala plugins extras (padrão)

## Prometheus

### Job `extra-targets` com `file_sd_configs`
- **Para que serve**: Service Discovery via arquivos
- **Como usar**: Crie arquivos YAML em `./prometheus/targets/` com formato:
  ```yaml
  - targets:
      - 'servico1:porta'
      - 'servico2:porta'
    labels:
      job: 'meu-job'
  ```
- **Vantagem**: Adiciona novos targets sem recriar o container Prometheus

## Promtail

### O que é o "patch" no final do arquivo?
- **Resposta**: Isso parece ser um artefato de edição. O arquivo deveria terminar após a linha 26 (pipeline_stages). O texto "*** End Patch" não é válido em YAML e deve ser removido.

## Middlewares Traefik

### `secure-headers`
- Adiciona headers de segurança HTTP (XSS protection, content-type nosniff, frame deny, HSTS, etc.)
- **Recomendação**: Usar em todos os serviços expostos publicamente

### `ip-allowlist`
- Restringe acesso por IP
- **Configuração atual**: Permite apenas localhost e redes privadas (192.168.0.0/16, 10.0.0.0/8)
- **Recomendação**: Usar em serviços sensíveis (Grafana, Prometheus)

## Serviços Whoami

### São úteis?
- **Sim, para testes e debug**:
  - Verificar se o Traefik está roteando corretamente
  - Testar middlewares
  - Validar certificados SSL
- **Recomendação**: Manter como opcional (usar profiles ou comentar quando não precisar)

