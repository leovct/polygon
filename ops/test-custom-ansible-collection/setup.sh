#!/bin/bash
# Script that sets up the ansible inventory for provisioning GCP compute instances given a project id and a filter.

# Check if both arguments are provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <project_id> <filter>"
    echo "For example: $0 prj-polygonlabs-devtools-dev name:my-super-instance"
    exit 1
fi

# Check if either argument is empty
PROJECT=$1
FILTER=$2
if [[ -z "$PROJECT" || -z "$FILTER" ]]; then
    echo "Both project id and filter must be specified."
    exit 1
fi

# Set up the inventory.
echo Setting up the inventory for GCP...
echo PROJECT=$PROJECT
echo FILTER=$FILTER
rm -f ./inventory/gcp-instances.json ./inventory/gcp-inventory.json
gcloud compute instances list --project=$PROJECT --filter=$FILTER --format=json > ./inventory/gcp-instances.json
jq -f ./inventory/gcp-inventory-filter.jq ./inventory/gcp-instances.json > ./inventory/gcp-inventory.json
echo; echo New inventory:
cat ./inventory/gcp-inventory.json
echo; echo Done!
