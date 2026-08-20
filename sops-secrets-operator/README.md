# sops-secrets-operator

Watches `SopsSecret` CRDs cluster-wide and decrypts them into real
`Secret` resources. This is what lets `*.sops.yaml` files (e.g.
`torklink/templates/discord-bot-token.sops.yaml`) be committed to this
repo safely -- only the `data`/`stringData` values are encrypted
(see `.sops.yaml` at the repo root, `encrypted_regex`), everything
else stays a normal readable/diffable manifest.

## The one thing that can't live in git

The operator decrypts using an [age](https://github.com/FiloSottile/age)
private key, which by definition must never be committed. It lives only
as a Kubernetes Secret:

```
kubectl -n sops create secret generic sops-age-key-file --from-file=key=<path-to-age-private-key>
```

A copy of that private key is stored in Bitwarden. **If the cluster is
ever rebuilt from scratch**, recreate the `sops` namespace + the secret
above from the Bitwarden copy *before* (or right after) this Application
syncs -- until that secret exists, every `SopsSecret` in the cluster
will sit in a decryption-failure loop, harmless but inert.

Public key (safe to share, only encrypts): `age1h4azg8f0prh7rezk5s7zj7glg2w2y64ze6gfrzrq8mrcxz8sjqus2ycwcn`

## Adding a new encrypted secret

```
sops --encrypt --age age1h4azg8f0prh7rezk5s7zj7glg2w2y64ze6gfrzrq8mrcxz8sjqus2ycwcn \
  --encrypted-regex '^(data|stringData)$' --input-type yaml --output-type yaml \
  my-secret.plain.yaml > path/to/chart/templates/my-secret.sops.yaml
```

where `my-secret.plain.yaml` is a normal `SopsSecret` manifest (see
`torklink/templates/discord-bot-token.sops.yaml` for the shape). Never
commit the `.plain.yaml` source.
