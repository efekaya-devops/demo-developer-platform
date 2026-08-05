# crossplane-modules

Azure blueprints for Crossplane - XRDs + Compositions, no platform wiring
around them. Meant to be read, not necessarily run - each module shows a
different pattern you run into once you go past the trivial stuff.

| Module | Pattern it shows |
|---|---|
| `resourcegroup` | the basics - one claim field, one azure resource |
| `storage` | bring-your-own-resource-group (deploy into something that already exists) |
| `keyvault` | same shape as storage, second example so the pattern sticks |
| `virtualnetwork` | composing multiple resources off one claim + wiring them together (`matchControllerRef`) |
| `database` | conditional resources with go-templating (patch-and-transform can't do "create this only if X") |
| `webappplatform` | the "flagship" one - four resources, real world shape |

## the external-name thing

Worth calling out because it'll cost you a debugging afternoon otherwise:
pin `crossplane.io/external-name` yourself from a field you control, don't
let the provider fill it in after create. If a create is slow/async and
something interrupts before the write-back lands, external-name stays empty,
the next reconcile tries to create the resource AGAIN, and Crossplane trips
a safety lock that blocks not just create but *delete* too. Seen it happen on
a function app, took a while to figure out.


## running the checks

```bash
scripts/validate-render.sh
```

Renders every module against its example claim in `examples/`. Needs the
crossplane CLI + docker running. Catches typos and bad field paths, doesn't
catch "will azure actually accept this" - for that you need a real cluster.

## packaging

`crossplane.yaml` at the root makes this installable as one Configuration
package if you want to `crossplane xpkg build` the whole thing. Not required
for just reading the code though.

Other repos in the platform: [backstage-idp](https://github.com/efekaya-devops/backstage-idp) ·
[idp-gitops](https://github.com/efekaya-devops/idp-gitops) · [terraform-modules](https://github.com/efekaya-devops/terraform-modules) ·

