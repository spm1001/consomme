#!/usr/bin/env bash
# Deploys the BigQuery Query Cloud Function

set -euo pipefail

PROJECT_ID="mit-consomme-test"
REGION="europe-west2"
FUNCTION_NAME="execute-bq-query"

echo "Deploying $FUNCTION_NAME to $PROJECT_ID..."

gcloud functions deploy $FUNCTION_NAME \
    --gen2 \
    --runtime=python311 \
    --region=$REGION \
    --project=$PROJECT_ID \
    --source=. \
    --entry-point=execute_query \
    --trigger-http \
    --no-allow-unauthenticated \
    --memory=256MB \
    --timeout=120s

echo "Done."
echo ""
echo "Grant the Dialogflow Service Agent invoker access:"
echo "  gcloud functions add-invoker-policy-binding $FUNCTION_NAME \\"
echo "    --region=$REGION --project=$PROJECT_ID \\"
echo "    --member='serviceAccount:service-904029233381@gcp-sa-dialogflow.iam.gserviceaccount.com'"
