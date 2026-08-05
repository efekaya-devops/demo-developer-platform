# demo-developer-platform

The code behind the [demo.efekaya.io](https://demo.efekaya.io) walkthrough — a full
Internal Developer Platform, split across four repos and combined here (with
their original commit history intact) so it's browsable in one place.

- **[backstage-idp](backstage-idp/)** — the portal side of the platform. Two golden
  paths create running apps — a backend service and a React frontend — and the
  rest request infrastructure: Crossplane claims on the Azure side, Terraform
  module calls for AWS and GCP.
- **[idp-gitops](idp-gitops/)** — the runtime side: a local kind cluster, ArgoCD,
  monitoring, Crossplane, and the discovery rules that deploy new services
  without anyone editing this repo by hand.
- **[crossplane-modules](crossplane-modules/)** — Azure blueprints for Crossplane:
  XRDs + Compositions, no platform wiring around them. Meant to be read, not
  necessarily run — each module shows a different pattern you run into once
  you go past the trivial stuff.
- **[terraform-modules](terraform-modules/)** — infra modules for the demo. Local
  (free) and cloud versions of the same thing, so swapping `source =` is
  basically the whole migration.

Each folder keeps its own README and its own git history (merged in via
`git subtree`, not squashed) — start there for the details on running any one
piece standalone.
