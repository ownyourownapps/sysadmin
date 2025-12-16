# Adding Prometheus Targets

Prometheus uses file-based service discovery to collect metrics from additional services.

## How It Works

The `prometheus/prometheus.yml` includes a job called `extra-targets` that reads YAML files from `prometheus/targets/` directory.

## Adding New Targets

1. Create a YAML file in `prometheus/targets/` directory:

```yaml
# prometheus/targets/my-service.yml
- targets:
    - 'host.docker.internal:9101'  # Service running on host
    - 'service-name:9102'           # Service in Docker network
  labels:
    job: 'my-service'
    environment: 'production'
```

2. Restart Prometheus to pick up changes:
   ```bash
   docker compose restart prometheus
   ```

3. Verify targets in Prometheus UI:
   - Go to Status → Targets
   - Look for your new job

## Target Formats

### Services on Host (outside Docker)
```yaml
- targets:
    - 'host.docker.internal:PORT'
  labels:
    job: 'service-name'
```

### Services in Docker Network
```yaml
- targets:
    - 'container-name:PORT'
  labels:
    job: 'service-name'
```

### Multiple Services
```yaml
- targets:
    - 'service1:9101'
    - 'service2:9102'
  labels:
    job: 'multi-service'
```

## Example: Adding wpp-infra Services

Create `prometheus/targets/wpp-infra.yml`:

```yaml
- targets:
    - 'host.docker.internal:9101'  # chaos-socket
    - 'host.docker.internal:9102'  # communicator
    - 'host.docker.internal:9103'  # command-processor
    - 'host.docker.internal:9104'  # data-processor
    - 'host.docker.internal:9105'  # retriever
  labels:
    job: 'wpp-apps'
    stack: 'pmc'
```

## Notes

- Prometheus automatically reloads config every 15 seconds
- Use `host.docker.internal` for services running on the host
- Use container names for services in the same Docker network
- Labels help organize and filter metrics in Grafana

