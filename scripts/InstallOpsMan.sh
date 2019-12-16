#!/bin/bash

set -eu

pushd ./downloads > /dev/null
    pivnet login --api-token $PIVNET_TOKEN
    pivnet download-product-files --product-slug='elastic-runtime' --release-version='2.9.0-build.113' --product-file-id=494978
    unzip terraforming-azure-0.55.0.zip
    cd ./pivotal-cf-terraforming-azure-2c4d2d4/terraforming-pks
    terraform init
popd > /dev/null
