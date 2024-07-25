# Grafana Cluster

## Downloading

Command to clone the contents of the given repository branch and navigate to the folder

  ```bash
  git clone https://github.com/RybenLigst/DIPLOM.git
  cd grafana
  ```

## Запуск

Для запуску необхідно використовувати Docker Compose. Ви можете використовувати команду:

```shell
docker-compose -f ./docker-compose.grafana.yaml up -d
```

Or use the `grafana.sh' script for clustering:

```sh
./grafana.sh
```

## Project structure

- **docker-compose.grafana.yaml**: Docker Compose file for setting up and running services.
- **run.sh**: Script to start the cluster.
- **configs**: Directory with configuration files for Grafana and Prometheus.

## Configuration files

- **configs/alertmanager.yml**: Alertmanager configuration. Replace the token and chat ID according to the comments.
- **configs/grafana/dashboards**: Dashboard settings for Grafana.
 - **cadvisor.json**: Cadvisor panel for monitoring containers.
 - **node-exporter.json**: Node-Exporter panel for OS monitoring.
 - **providers.yml**: Data source for Grafana about panels.
- **configs/grafana/datasources/prometheus.yml**: Data source for Prometheus.
- **configs/prometheus**: Configurations for Prometheus.
 - **alert_rules.yml**: Configuration of alert triggers.
 - **prometheus.yml**: Configuration for Prometheus.
