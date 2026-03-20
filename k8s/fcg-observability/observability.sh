echo ">>> Instalação será iniciada..."
echo ""

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add zabbix-community https://zabbix-community.github.io/helm-zabbix
helm repo update

# PROMETHEUS + GRAFANA

helm install kube-stack prometheus-community/kube-prometheus-stack \
  --namespace observability \
  --set grafana.enabled=true \
  --set grafana.adminUser=admin \
  --set grafana.adminPassword=admin123 \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=ClusterIP \
  --set grafana.sidecar.datasources.enabled=true


# LOKI (logs)


helm install loki grafana/loki \
  --namespace observability \
  --set loki.auth_enabled=false \
  --set loki.storage.type=filesystem \
  --set singleBinary.replicas=1


# TEMPO (traces)


helm install tempo grafana/tempo \
  --namespace observability \
  --set tempo.receivers.otlp.protocols.grpc.endpoint=0.0.0.0:4317 \
  --set tempo.receivers.otlp.protocols.http.endpoint=0.0.0.0:4318 \
  --set service.type=ClusterIP


# ZABBIX + POSTGRESQL

helm install zabbix zabbix-community/zabbix \
  --namespace observability \
  --set zabbixServer.enabled=true \
  --set zabbixWeb.enabled=true \
  --set zabbixWeb.service.type=LoadBalancer \
  --set postgresql.enabled=true \
  --set postgresql.auth.password=zabbix_pass \
  --set postgresql.auth.username=zabbix \
  --set postgresql.auth.database=zabbix \
  --set zabbixProxy.enabled=false


kubectl rollout status deployment -n observability


echo ">>> Instalação concluída! Pegando endereços de acesso..."
echo ""
echo "--- Grafana ---"
kubectl get service -n observability | grep grafana
echo "Usuário: admin | Senha: admin123"
echo "--- Zabbix ---"
kubectl get service -n observability | grep zabbix-web
echo "Usuário: Admin | Senha: zabbix"
