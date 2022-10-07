# Nutanix Database Service Operator for Kubernetes
The NDB operator brings automated and simplified database administration, provisioning, and life-cycle management to Kubernetes.

---

## Getting Started
### Pre-requisites
1. NDB [installation](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Era-User-Guide-v2_4:top-era-installation-c.html).
2. A Kubernetes cluster.
3. Helm installed.
### Installation and Running on the cluster
Deploy the controller on the cluster:

```sh
helm repo add helm-test-manav https://manavrajvanshi-nx.github.io/helm/
```
```sh
helm install ndb-operator helm-test-manav/ndb-operator --version 0.0.1
```

### Using the Operator

1. Create the secrets that are to be used by the custom resource:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: your-ndb-secret
type: Opaque
stringData:
  username: username-for-ndb-server
  password: password-for-ndb-server
  ca_certificate: |
    -----BEGIN CERTIFICATE-----
    CA CERTIFICATE (ca_certificate is optional)
    -----END CERTIFICATE-----
---
apiVersion: v1
kind: Secret
metadata:
  name: your-db-secret
type: Opaque
stringData:
  password: password-for-the-database-instance
  ssh_public_key: SSH-PUBLIC-KEY

```

2. To create instances of custom resources (provision databases), edit the crd file with the NDB installation and database instance details and run:

```sh
kubectl apply -f CRD_FILE.yaml
```
3. To delete instances of custom resources (deprovision databases) run:

```sh
kubectl delete -f CRD_FILE.yaml
```
The CRD is described as follows:
```yaml
apiVersion: ndb.nutanix.com/v1alpha1
kind: Database
metadata:
  # This name that will be used within the kubernetes cluster
  name: db
spec:
  # NDB server specific details
  ndb:
    # Cluster id of the cluster where the Database has to be provisioned
    # Can be fetched from the GET /clusters endpoint
    clusterId: "Nutanix Cluster Id" 
    # Credentials secret name for NDB installation
    # data: username, password, 
    # stringData: ca_certificate
    credentialSecret: your-ndb-secret
    # The NDB Server
    server: https://[NDB IP]:8443/era/v0.9
    # Set to true to skip SSL verification, default: false.
    skipCertificateVerification: true
  # Database instance specific details (that is to be provisioned)
  databaseInstance:
    # The database instance name on NDB
    databaseInstanceName: "Database-Instance-Name"
    # Names of the databases on that instance
    databaseNames:
      - database_one
      - database_two
      - database_three
    # Credentials secret name for NDB installation
    # data: password, ssh_public_key
    credentialSecret: your-db-secret
    size: 10
    timezone: "UTC"
    type: postgres
```



## How it works

This project aims to follow the Kubernetes [Operator pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

It uses [Controllers](https://kubernetes.io/docs/concepts/architecture/controller/) 
which provides a reconcile function responsible for synchronizing resources until the desired state is reached on the cluster.

A custom resource of the kind Database is created by the reconciler, followed by a Service and an Endpoint that maps to the IP address of the database instance provisioned. Application pods/deployments can use this service to interact with the databases provisioned on NDB through the native Kubernetes service. 

Pods can specify an initContainer to wait for the service (and hence the database instance) to get created before they start up.
```yaml
  initContainers:
  - name: init-db
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup <<Database CR Name>>-svc.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for database service; sleep 2; done"]
```

## Contributing
See the [contributing docs](CONTRIBUTING.md).

## Support
### Community Plus

This code is developed in the open with input from the community through issues and PRs. A Nutanix engineering team serves as the maintainer. Documentation is available in the project repository.

Issues and enhancement requests can be submitted in the [Issues tab of this repository](https://github.com/nutanix-cloud-native/ndb-operator/issues). Please search for and review the existing open issues before submitting a new issue.

## License

Copyright 2021-2022 Nutanix, Inc.

The project is released under version 2.0 of the [Apache license](http://www.apache.org/licenses/LICENSE-2.0).
