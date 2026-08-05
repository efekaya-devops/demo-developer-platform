# ${{ values.name }}

${{ values.description }}

| | |
|---|---|
| **CI/CD** | GitHub Actions builds + pushes `ghcr.io/<owner>/<repo>` on every push to `main` |
| **Deploy** | ArgoCD auto-discovers this repo (it has a `k8s/` folder) and syncs it |
| **Observability** | `/metrics` scraped via ServiceMonitor; dashboard auto-appears in Grafana |
| **Docs** | `docs/` renders in the portal via TechDocs |

## seeing it run

The service is a ClusterIP — it has no public address, which is deliberate.
Forward a port to reach it:

```bash
kubectl port-forward -n default svc/${{ values.name }} 8080:80
```

Then:

| | |
|---|---|
| http://localhost:8080/ | the app itself |
| http://localhost:8080/healthz | what the liveness and readiness probes call |
| http://localhost:8080/metrics | what Prometheus scrapes |

If the port's taken, change the left-hand number — `18080:80` works the same.

Want the graph to show something? Generate some traffic:

```bash
for i in $(seq 1 300); do curl -s -o /dev/null localhost:8080/; done
```

Then open the `${{ values.name }}` dashboard in Grafana (http://localhost:3001).
Nobody created that dashboard — `k8s/dashboard.yaml` ships the JSON as a
ConfigMap and Grafana's sidecar loads anything labelled `grafana_dashboard=1`.

## running it locally instead

```bash
npm install
npm start          # http://localhost:8080
```

## where things are

```
server.js          the app
k8s/               deployment, service, servicemonitor, grafana dashboard
docs/              techdocs sources, rendered in the portal
catalog-info.yaml  what registers this service in the catalog
```
