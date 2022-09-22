# lib-utils

Common utilities fonctions template for Youwol Helm charts.

To start using it, add it to your Helm chart dependencies :

```yaml
# file ./Chart.yaml
apiVersion: v2
name: mychart
version: 0.1.0
appVersion: 0.0.1

dependencies:
  - name: lib-utils
    version: 0.0.1
    repository: https://gitlab.com/api/v4/projects/15166395/packages/helm/stable/

```

## ```lib-utils.force-update```

Manage annotation ```youwol.com/force-update-marker```, which allow to force the update of an object by modifying the
marker.
Though currently the annotation’s value is an UUIDv4, it has no meaning by itself.

This template take a dictionary as its argument, with the following keys:

* ```root``` : the root object, for accessing ```.Release```, ```.Values```, etc. in subcharts
* ```kind``` : the kind of the object templated
* ```name``` : the name of the object templated

### Policy

Three policies can be used :

* ```install```: Default policy. Use value from deployed object if it bears the annotation or create the annotation.
* ```force```: Force generation of a new value for the annotation, even if the deployed object bears the annotation.
* ```keep ```: Use current marker if the object exists and bears the annotation, or do nothing.

The policy is specified :

* By default it will be ```install```
* For all objects in the release, using ```.Values.forceUpdatePolicy```.
* For each object, using ```.Values.forceUpdatePolicies.<name>``` where ```<name>``` is the object name

NB: Do note that on subsequent upgrade, a given release will keep policy previously specified.

### Examples

Here we want to ignore this mechanism for almost all objects in the release but force update of object ```updatedObject```.
Only ```updatedObject``` will bear a new value for the annotation, regardless its current metadata. All other deployed
objects will be untouched, should they bear the annotation or not.

```gotemplate
{{/* Far sake of brevity tow objects: 'updatedObject' will be updated, 'untouchedObject' will not */}}
---
{{- $name := "updatedObject" }}
  {{- $forceUpdateArgs := dict "root" . "name" $name "kind" "ConfigMap" }}
apiVersion: v1
kind: ConfigMap

metadata:
  name: {{ $name }}
  namespace: {{ .Release.Namespace }}
  annotations:
    {{- include "lib-utils.force-update" $forceUpdateArgs | indent 4 }}

data:
  foo: "toto"
---
{{- $name := "untouchedObject" }}
  {{- $forceUpdateArgs := dict "root" . "name" $name "kind" "ConfigMap" }}
apiVersion: v1
kind: ConfigMap

metadata:
  name: {{ $name }}
  namespace: {{ .Release.Namespace }}
  annotations:
    {{- include "lib-utils.force-update" $forceUpdateArgs | indent 4 }}

data:
  bar: "42"
```



#### Using ```values.yaml``` file

```values.yaml``` file :

```yaml
# file ./values.yaml
forceUpdatePolicy: "keep"
forceUpdatePolicies:
  updatedObject: force
```

Command line :

```shell
helm upgrade release .
```

#### Using Command line arguments

```shell
helm upgrade release . --set forceUpdatePolicy=keep --set forceUpdatePolicies.updatedObject=force
```

#### Using an external file

```/tmp/release.yaml``` file :

```yaml
# file /tmp/release.yaml
forceUpdatePolicy: "keep"
forceUpdatePolicies:
  updatedObject: force
```

Command line :

```shell
helm upgrade release . -f /tmp/release.yaml
```
