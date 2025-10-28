#!/usr/bin/env bash
set -eu -o pipefail

CA_URL=https://step-certificates.default.svc.cluster.local
CA_ROOT_B64=$(kubectl get -o jsonpath="{.data['root_ca\.crt']}" configmaps/step-certificates-certs | step base64)
CA_PROVISIONER_NAME=magicloud@magicloud.lan
CA_PROVISIONER_KID=$(kubectl get -o jsonpath="{.data['ca\.json']}" configmaps/step-certificates-config | jq -r .authority.provisioners[0].key.kid)

kubectl apply -f - << EOF
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepClusterIssuer
metadata:
  name: step-issuer
spec:
  # The CA URL:
  url: $CA_URL
  # The base64 encoded version of the CA root certificate in PEM format:
  caBundle: $CA_ROOT_B64
  # The provisioner name, kid, and a reference to the provisioner password secret:
  provisioner:
    name: $CA_PROVISIONER_NAME
    kid: $CA_PROVISIONER_KID
    passwordRef:
      name: step-certificates-provisioner-password
      namespace: default
      key: password
---
EOF
