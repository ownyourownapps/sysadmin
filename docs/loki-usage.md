# Using Loki for Logs

Loki is integrated and working. Docker container logs are automatically collected by Promtail and sent to Loki.

## Access Logs in Grafana

1. Access Grafana via Traefik: `https://${GRAFANA_DOMAIN}`
2. Go to **Explore** (compass icon)
3. Select **Loki** datasource
4. Use queries like:
   - `{container="container-name"}` - Logs from specific container
   - `{service="service-name"}` - Logs from specific service (if labeled)
   - `{level="error"}` - Only error logs
   - `{container="name"} |= "error"` - Search for "error" in container logs

## Configuration

- **Loki:** Service in `docker-compose.yml`
- **Promtail:** Service in `docker-compose.yml` - collects logs from Docker
- **Datasource:** Auto-configured in `grafana/datasources/loki.yml`

## Promtail Configuration

Promtail is configured to collect logs from:
- All containers in the `sysadmin` compose project
- You can extend it to collect from other projects by updating `promtail/promtail-config.yml`

## Troubleshooting

If logs don't appear:

1. Check if services are running:
   ```bash
   docker compose ps loki promtail
   ```

2. Check Promtail logs:
   ```bash
   docker compose logs promtail
   ```

3. Verify datasource in Grafana:
   - Configuration → Data Sources → Loki
   - Test the connection

4. Check Promtail configuration:
   ```bash
   docker compose exec promtail cat /etc/promtail/config.yml
   ```

