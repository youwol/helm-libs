# helm-libs

Libraries collection for Helm charts development.

## lib-utils

Provide ```lib-utils.force-update``` template, for managing ```youwol.com/force-update-marker``` annotation.

More detail on how to use in the README.md of directory [lib-utils](./lib-utils)

## lib-configuration

Provide templates for managing ConfigMap and Secret, including managing annotations ```youwol.
com/force-update-marker``` and ```youwol.com/checksum```.

* ```lib-configuration.secret```: template a Kubernetes Secret, either generating or using provided values.
* ```lib-configuration.config-map```: template a Kubernetes ConfigMap from a Go dictionary.
* ```lib-configuration.duplicate-config-map```: duplicating existing Kubernetes ConfigMap across namespaces.
* ```lib-configuration.duplicate-secret```: duplicating existing Kubernetes Secret across namespaces.

More detail on these templates in the README.md of directory [lib-configuration](./lib-configuration)

## lib-backend

Provide templates for managing Helm Chart deploying Youwol backends.

More detail on these templates in the README.md of directory [lib-backend](./lib-backend)
