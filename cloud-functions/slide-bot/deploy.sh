#!/usr/bin/env bash
# Deploys the Slide Generator Cloud Function

set -euo pipefail

PROJECT_ID="mit-consomme-test"
REGION="europe-west2"
FUNCTION_NAME="generate-slide-deck"

echo "Deploying $FUNCTION_NAME to $PROJECT_ID..."

gcloud functions deploy $FUNCTION_NAME \
    --gen2 \
    --runtime=python311 \
    --region=$REGION \
    --project=$PROJECT_ID \
    --source=. \
    --entry-point=generate_slide_deck \
    --trigger-http \
    --allow-unauthenticated

echo "Done."
