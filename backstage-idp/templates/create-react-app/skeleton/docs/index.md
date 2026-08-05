# ${{ values.name }}

${{ values.description }}

A React app on the platform's paved road. This page renders in the portal via
TechDocs — edit `docs/index.md` in the repo and it updates here.

## how it gets built and shipped

The app is a normal Vite + React project. What the platform adds:

1. `npm run build` produces static files — no Node process in production
2. The Dockerfile throws the build image away and copies those files onto
   nginx, so the running container is a web server and some HTML
3. CI pushes that image to GHCR on every commit to `main`
4. ArgoCD notices this repo has a `k8s/` folder and deploys it. Nobody
   registers anything

## why a frontend has metrics

Static files can't report on themselves, which is usually where frontends drop
off the observability map — no dashboard, no alerts, invisible until a user
complains.

There's a second container in the pod: `nginx-prometheus-exporter`. It reads
nginx's own request counters over localhost and republishes them in the format
Prometheus expects. The ServiceMonitor then renames `nginx_http_requests_total`
to `app_requests_total`, because that's the metric the platform's alert rules
and dashboards are written against.

The effect: this app gets the same `ServiceDown` alert and the same dashboard
shape as any backend service, without the platform needing to know it's a
frontend.

## local development

```bash
npm install
npm run dev      # http://localhost:8080, hot reload
```

To check what actually ships:

```bash
npm run build && npm run preview
```

## running it in the cluster

```bash
kubectl port-forward -n default svc/${{ values.name }} 8080:80
```

| | |
|---|---|
| http://localhost:8080/ | the app |
| http://localhost:8080/healthz | what the probes call |

The metrics live on the sidecar's port, not the app's:

```bash
kubectl port-forward -n default svc/${{ values.name }} 9113:9113
curl localhost:9113/metrics
```
