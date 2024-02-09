#!/bin/bash

# https://itsmetommy.com/2020/06/10/kubernetes-install-bitnami-elasticsearch-kibana-using-helm/

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo -l bitnami/elasticsearch | head

# Install
wget https://raw.githubusercontent.com/bitnami/charts/master/bitnami/elasticsearch/values.yaml

helm upgrade elasticsearch \
  -f bitnami-es-values.yaml \
  --set sysctlImage.enabled=true \
  --set data.persistence.size=16Gi \
  --set coordinating.service.type=LoadBalancer \
  --set global.kibanaEnabled=true \
  --version 19.17.2 \
  -n citi-observability \
  bitnami/elasticsearch

kubectl port-forward --namespace citi-observability svc/elasticsearch 9200:9200

kubectl port-forward --namespace citi-observability svc/elasticsearch-kibana 5601:5601

curl http://127.0.0.1:9200/
curl http://127.0.0.1:5601/

helm template elasticsearch \
  -f bitnami-es-values.yaml \
  --set sysctlImage.enabled=true \
  --set data.persistence.size=16Gi \
  --set coordinating.service.type=LoadBalancer \
  --set global.kibanaEnabled=true \
  --version 19.17.2 \
  -n cti-svcs-cdso-gdk-169643 \
  --output-dir citi-observability \
  bitnami/elasticsearch 