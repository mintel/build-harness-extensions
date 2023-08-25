#!/bin/bash

tftools=" ../../modules/satoshi/tf-tool-versions"
k8stools="../../modules/satoshi/k8s-tool-versions"

cat $tftools $k8stools > .tool-versions