.PHONY: package
package: 
	helm package ./ndb-operator

.PHONY: index
index: package
	helm repo index .
