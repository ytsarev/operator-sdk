#!/usr/bin/env bash

#############################
# Make sure that test/test-framework is updated according to the current source code
#############################

set -ex

source hack/lib/test_lib.sh

# Go inside of the mock data test project
cd test/test-framework

# Ensure test-framework is up-to-date with current Go project dependencies.
echo "$(../../build/operator-sdk print-deps)" > go.mod
sed -i".bak" -E -e "s|github.com/operator-framework/operator-sdk[[:blank:]]+master||g" go.mod; rm -f go.mod.bak
echo -e "\nreplace github.com/operator-framework/operator-sdk => ../../" >> go.mod
go mod edit -require "github.com/operator-framework/operator-sdk@v0.0.0"
go build ./...
go mod tidy

# Run gen commands
../../build/operator-sdk generate k8s
# TODO(camilamacedo86): remove this when the openapi gen be set to false and it no longer is generated
# The following file is gen by openapi but it has not been committed in order to allow we clone and call the test locally in any path.
trap_add 'rm pkg/apis/cache/v1alpha1/zz_generated.openapi.go' EXIT
../../build/operator-sdk generate openapi
