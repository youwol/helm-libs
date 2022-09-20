# lib-utils

Common utilies fonctions template for Youwol Helm charts.

## ```lib-utils.force-update```

Manage annotation ```youwol.com/force-update-marker```, which allow to force the update of an object by modifying the
marker.
Though currently the annotation’s value is an UUIDv4, it has no meaning by itself.

This template take a dictionary as its argument, with the following keys:

* ```root``` : the root object, for accessing ```.Release```, ```.Values```, etc. in subcharts
* ```king``` : the kind of the object templated
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

Here we want to ignore this mechanism for almost all objects in the release
but force update of object ```updatedObject```.
Only ```updatedObject``` will bear a new value for the annotation, regardless its current metadata. All other deployed 
objects will be untouched, should they bear the annotation or not.

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
