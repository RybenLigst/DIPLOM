# Автоматизоване Розгортання Інфраструктури на AWS з Використанням Terraform та Kubernetes

## Огляд Проекту

Цей проект демонструє автоматизоване розгортання інфраструктури для веб-додатку, що складається з фронтенду, бекенду та бази даних, використовуючи сучасні DevOps технології. Проект забезпечує стабільність, масштабованість та ефективний моніторинг системи, а також впроваджує CI/CD процеси для безперервної інтеграції та доставки.

**Основні Компоненти:**

- **Інфраструктура як Код (IaC):** Terraform для управління ресурсами AWS.
- **Хмарна Платформа:** AWS (Amazon Web Services).
- **Оркестрація Контейнерів:** Kubernetes (EKS).
- **CI/CD Інструмент:** Jenkins для автоматизації процесів побудови та розгортання.
- **Моніторинг та Візуалізація:** Prometheus для збору метрик та Grafana для їх відображення.
- **База Даних:** PostgreSQL для зберігання даних додатку.

## Використані Технології та Інструменти

- **Terraform:** Для опису та управління інфраструктурою в AWS.
- **Kubernetes (EKS):** Для оркестрації контейнерів та забезпечення високої доступності додатків.
- **Prometheus та Grafana:** Для збору та візуалізації метрик системи та додатків.
- **Jenkins:** Для налаштування CI/CD пайплайнів.
- **Docker:** Для контейнеризації фронтенд та бекенд додатків.
- **PostgreSQL:** Розгортання та управління базою даних.

## Структура Проекту

.
├── backend-deployment.yaml
├── backend-service.yaml
├── database-deployment.yaml
├── database-password-secret.yaml
├── database-service.yaml
├── frontend-deployment.yaml
├── frontend-service.yaml
├── frontend-servicemonitor.yaml
├── infrastructure
│   ├── ec2.tf
│   ├── eks.tf
│   ├── main.tf
│   ├── network.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── variables.tf
├── jenkins01.sh
├── jenkinsfile
├── kubernetes
│   ├── backend_pod.yaml
│   ├── main.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   ├── tfplan
│   └── variables.tf
├── main.tf
├── modules
│   └── k8s
│       ├── main.tf
│       ├── terraform.tfstate
│       ├── terraform.tfstate.backup
│       └── variables.tf
├── sql-deployment.yaml
├── sql-service.yaml
├── terraform.tfstate
├── terraform.tfstate.backup
└── terraform.tfvars

5 directories, 35 files


## Налаштування та Розгортання

### Передумови

- **AWS Account:** Наявність облікового запису AWS з відповідними правами.
- **Terraform:** Встановлений Terraform (версія >= 1.0).
- **Helm:** Встановлений Helm (версія 3).
- **kubectl:** Налаштований `kubectl` для доступу до вашого EKS кластера.

### Крок 1: Налаштування Інфраструктури за Допомогою Terraform

1. **Перейдіть до каталогу інфраструктури:**

    ```bash
    cd infrastructure
    ```

2. **Ініціалізуйте Terraform:**

    ```bash
    terraform init
    ```

3. **Перевірте план розгортання:**

    ```bash
    terraform plan
    ```

4. **Застосуйте конфігурацію:**

    ```bash
    terraform apply
    ```

    Введіть `yes` для підтвердження.

### Крок 2: Розгортання Kubernetes Ресурсів

1. **Перейдіть до каталогу Kubernetes:**

    ```bash
    cd ../kubernetes
    ```

2. **Ініціалізуйте Terraform:**

    ```bash
    terraform init
    ```

3. **Перевірте план розгортання:**

    ```bash
    terraform plan
    ```

4. **Застосуйте конфігурацію:**

    ```bash
    terraform apply
    ```

    Введіть `yes` для підтвердження.

### Крок 3: Налаштування Моніторингу з Prometheus та Grafana

1. **Встановіть kube-prometheus-stack за допомогою Helm:**

    ```bash
    helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
    ```

2. **Перевірте статус встановлення:**

    ```bash
    helm status prometheus --namespace monitoring
    ```

3. **Отримайте пароль для Grafana:**

    ```bash
    kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```

4. **Налаштуйте доступ до Grafana:**

    Використайте port-forward для доступу до Grafana локально:

    ```bash
    kubectl port-forward --namespace monitoring svc/prometheus-grafana 3000:80
    ```

    Відкрийте [http://localhost:3000](http://localhost:3000) у браузері та увійдіть з логіном `admin` та отриманим паролем.

### Крок 4: Налаштування CI/CD з Jenkins

1. **Налаштуйте Jenkins для автоматичного побудови та розгортання Docker-образів:**
    - Створіть Jenkins пайплайн, який буде реагувати на зміни в репозиторії.
    - Налаштуйте кроки для побудови Docker-образу фронтенду та бекенду.
    - Додайте кроки для розгортання оновлених образів у Kubernetes кластері.

### Крок 5: Додавання Моніторингу для Фронтенду

1. **Додайте метрики до фронтенд-додатку:**
    - Використовуйте бібліотеку Prometheus client для вашої мови програмування (наприклад, `prom-client` для Node.js).
    - Додайте `/metrics` endpoint для збору метрик.

2. **ServiceMonitor для фронтенду:**

    Застосування:

    ```bash
    kubectl apply -f frontend-servicemonitor.yaml
    ```

3. **Створіть Dashboard у Grafana:**

    - Увійдіть до Grafana.
    - Натисніть `New Dashboard`.
    - Додайте нові панелі з PromQL-запитами для відображення метрик CPU, пам'яті та HTTP запитів фронтенду.
    - Збережіть Dashboard.

Приклади запитів: 

 - up{app="frontend"}
 - sum(rate(http_requests_total[5m])) by (status)
 - sum(rate(container_cpu_usage_seconds_total{pod=~"frontend-.*"}[5m])) by (pod)
 - sum(container_memory_usage_bytes{pod=~"frontend-.*"}) by (pod)
