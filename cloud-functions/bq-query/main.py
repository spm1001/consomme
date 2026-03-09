import json
import functions_framework
import google.auth
from google.cloud import bigquery

# Allowed project — prevents the function from being used to query arbitrary projects
ALLOWED_PROJECT = 'mit-consomme-test'
MAX_ROWS = 10000
MAX_BYTES_BILLED = 1 * 1024 * 1024 * 1024  # 1 GB safety limit

# Drive scope needed for external tables backed by Google Sheets
SCOPES = [
    'https://www.googleapis.com/auth/bigquery',
    'https://www.googleapis.com/auth/drive.readonly',
]


def get_client():
    """Gets a BigQuery client with Drive scope for Sheet-backed external tables."""
    credentials, project = google.auth.default(scopes=SCOPES)
    return bigquery.Client(project=ALLOWED_PROJECT, credentials=credentials)


@functions_framework.http
def execute_query(request):
    """HTTP Cloud Function to execute a BigQuery SQL query.

    Expected JSON payload:
        {
            "sql": "SELECT * FROM `mit-consomme-test.survey_data.ohid_survey_raw` LIMIT 10",
            "project": "mit-consomme-test"  // optional, must match ALLOWED_PROJECT
        }

    Returns:
        {
            "columns": ["col1", "col2"],
            "rows": [{"col1": "val1", "col2": "val2"}, ...],
            "totalRows": 10,
            "jobId": "job_abc123"
        }
    """
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    headers = {'Access-Control-Allow-Origin': '*'}

    request_json = request.get_json(silent=True)
    if not request_json:
        return (json.dumps({"error": "Invalid JSON payload."}), 400, headers)

    sql = request_json.get('sql', '').strip()
    project = request_json.get('project', ALLOWED_PROJECT)

    if not sql:
        return (json.dumps({"error": "Missing required field: 'sql'."}), 400, headers)

    if project != ALLOWED_PROJECT:
        return (json.dumps({"error": f"Project must be '{ALLOWED_PROJECT}'."}), 403, headers)

    try:
        client = get_client()

        job_config = bigquery.QueryJobConfig(
            maximum_bytes_billed=MAX_BYTES_BILLED,
        )

        query_job = client.query(sql, job_config=job_config)
        results = query_job.result(max_results=MAX_ROWS)

        columns = [field.name for field in results.schema]
        rows = []
        for row in results:
            rows.append({col: _serialize(row[col]) for col in columns})

        # Build a markdown table for Agent Builder (which strips dynamic JSON keys)
        # Cap to stay within Agent Builder's 8192 token output limit (~4 chars/token)
        MAX_DATA_CHARS = 1500
        md_lines = ["| " + " | ".join(columns) + " |"]
        md_lines.append("| " + " | ".join(["---"] * len(columns)) + " |")
        truncated = False
        for row in rows:
            line = "| " + " | ".join(str(row.get(c, "")) for c in columns) + " |"
            if sum(len(l) for l in md_lines) + len(line) + len(md_lines) > MAX_DATA_CHARS:
                truncated = True
                break
            md_lines.append(line)
        if truncated:
            shown = len(md_lines) - 2  # minus header + separator
            md_lines.append(f"| ... truncated ({shown} of {len(rows)} rows shown — add LIMIT or narrow WHERE to see all) |")
        data_table = "\n".join(md_lines)

        return (json.dumps({
            "columns": columns,
            "data": data_table,
            "totalRows": len(rows),
            "jobId": query_job.job_id,
        }), 200, headers)

    except Exception as e:
        import traceback
        traceback.print_exc()
        error_msg = str(e)
        # Surface BQ-specific error messages cleanly
        if hasattr(e, 'errors') and e.errors:
            error_msg = e.errors[0].get('message', str(e))
        return (json.dumps({"error": error_msg}), 400, headers)


def _serialize(value):
    """Convert BigQuery row values to JSON-serializable types."""
    if value is None:
        return None
    if isinstance(value, (int, float, str, bool)):
        return value
    if hasattr(value, 'isoformat'):
        return value.isoformat()
    if isinstance(value, bytes):
        return value.decode('utf-8', errors='replace')
    if isinstance(value, (list, tuple)):
        return [_serialize(v) for v in value]
    if isinstance(value, dict):
        return {k: _serialize(v) for k, v in value.items()}
    return str(value)
