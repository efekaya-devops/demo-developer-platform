# ${{ values.name }}

${{ values.description }}

| | |
|---|---|
| **Stack** | Vite + React, built to static files, served by nginx |
| **CI/CD** | GitHub Actions builds + pushes `ghcr.io/<owner>/<repo>` on every push to `main` |
| **Deploy** | ArgoCD auto-discovers this repo (it has a `k8s/` folder) and syncs it |
| **Observability** | nginx exporter sidecar → Prometheus; dashboard auto-appears in Grafana |
| **Docs** | `docs/` renders in the portal via TechDocs |

## local development

```bash
npm install
npm run dev        # http://localhost:8080, hot reload
```

`npm run build && npm run preview` shows you what actually ships — the static
bundle, not the dev server.

## seeing it run in the cluster

The service is a ClusterIP — it has no public address, which is deliberate.
Forward a port to reach it:

```bash
kubectl port-forward -n default svc/${{ values.name }} 8080:80
```

Then:

| | |
|---|---|
| http://localhost:8080/ | the app |
| http://localhost:8080/healthz | what the liveness and readiness probes call |

If the port's taken, change the left-hand number — `18080:80` works the same.

Metrics come from the sidecar, on its own port:

```bash
kubectl port-forward -n default svc/${{ values.name }} 9113:9113
curl localhost:9113/metrics
```

Want the graph to show something? Generate some traffic:

```bash
for i in $(seq 1 300); do curl -s -o /dev/null localhost:8080/; done
```

Then open the `${{ values.name }}` dashboard in Grafana (http://localhost:3001).
Nobody created it — `k8s/dashboard.yaml` ships the JSON as a ConfigMap and
Grafana's sidecar loads anything labelled `grafana_dashboard=1`.

## how a bag of static files ends up with metrics

Frontends usually fall off the observability map: there's no process to
instrument, so there's no dashboard and no alerts, and the app is invisible
until someone complains.

The pod runs a second container, `nginx-prometheus-exporter`, which reads
nginx's request counters over localhost and republishes them for Prometheus.
The ServiceMonitor renames `nginx_http_requests_total` to `app_requests_total`,
which is the metric the platform's alert rules are written against — so this
app inherits `ServiceDown` and the rest without the platform knowing or caring
that it's a frontend.

## where things are

```
src/               the React app - replace this with yours
nginx.conf         SPA routing, /healthz, and the stub_status the sidecar reads
Dockerfile         multi-stage: build with node, ship on nginx
k8s/               deployment (app + metrics sidecar), service, servicemonitor, dashboard
docs/              techdocs sources, rendered in the portal
catalog-info.yaml  what registers this app in the catalog
```
