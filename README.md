# elasticsearch-kibana-opentelemetry

Proof of concept on an helm-based Elasticsearch-Kibana-Opentelemetry kubernetes apps

## Development

Deploy EKS cluster using terraform. Run from within `terraform` folder.

```sh
$ cd terraform
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

Get cluster kubeconfig file;

```sh
$ aws eks update-kubeconfig --region us-east-1 --name citi-eks-observability --kubeconfig kubeconfig
```

Deploy helm-chart - Run from within `helm` folder.

```sh
$ export KUBECONFIG="../terraform/kubeconfig"
$ kubectl create ns citi-observability
$ alias k="kubectl -n citi-observability"

$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm repo update
$ helm search repo -l bitnami/elasticsearch | head

$ helm install elasticsearch \
  -f bitnami-es-values.yaml \
  --set sysctlImage.enabled=true \
  --set data.persistence.size=16Gi \
  --set coordinating.service.type=LoadBalancer \
  --set global.kibanaEnabled=true \
  --render-subchart-notes \
  --version 19.17.2 \
  -n citi-observability \
  bitnami/elasticsearch

# View Elasticsearch
## HTTP
$ kubectl port-forward --namespace citi-observability svc/elasticsearch 9201:9200
$ curl http://127.0.0.1:9200/

## HTTPS
$ kubectl port-forward --namespace citi-observability svc/elasticsearch 9300:9300
$ curl https://127.0.0.1:9300/

# View Kibana
$ kubectl port-forward --namespace citi-observability svc/elasticsearch-kibana 8080:5601
$ curl https://127.0.0.1:8080/

$ helm uninstall elasticsearch \
  -n citi-observability \
  bitnami/elasticsearch
```