import json
import uuid
import functions_framework
from google.oauth2 import service_account
import google.auth
from googleapiclient.discovery import build

# ITV Golden Template ID
TEMPLATE_PRESENTATION_ID = '1Dq3CFxCtIVBfGxKAOGRzczLuL1eJQXGCOl_i3D6b_sQ'

def get_credentials():
    """Gets Google API credentials from the runtime environment."""
    credentials, project = google.auth.default(
        scopes=[
            'https://www.googleapis.com/auth/presentations',
            'https://www.googleapis.com/auth/drive'
        ]
    )
    return credentials

@functions_framework.http
def generate_slide_deck(request):
    """HTTP Cloud Function to generate a slide deck from a JSON payload.
    
    Args:
        request (flask.Request): The request object.
        
    Expected JSON payload:
        {
            "title": "Main finding/title for the slide",
            "bullets": ["Point 1", "Point 2", "Point 3"]
        }
    """
    if request.method == 'OPTIONS':
        # Allows GET requests from any origin with the Content-Type
        # header and caches preflight response for an 3600s
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    # Set CORS headers for the main request
    headers = {
        'Access-Control-Allow-Origin': '*'
    }

    request_json = request.get_json(silent=True)
    if not request_json:
        return (json.dumps({"error": "Invalid JSON payload."}), 400, headers)
        
    title = request_json.get('title')
    bullets = request_json.get('bullets', [])
    
    if not title:
        return (json.dumps({"error": "Missing required field: 'title'."}), 400, headers)

    try:
        creds = get_credentials()
        drive_service = build('drive', 'v3', credentials=creds)
        slides_service = build('slides', 'v1', credentials=creds)

        # 1. Copy the Golden Template into the target folder
        copy_title = f"ITV Analysis: {title}"
        body = {
            'name': copy_title,
            'parents': ['1YQmH-q3Y1KhPJAa0kg_YHljQ4NahTJsY']
        }
        drive_response = drive_service.files().copy(
            fileId=TEMPLATE_PRESENTATION_ID, 
            body=body,
            supportsAllDrives=True
        ).execute()
        
        new_presentation_id = drive_response.get('id')

        # 2. Get the presentation to find the page elements
        presentation = slides_service.presentations().get(
            presentationId=new_presentation_id
        ).execute()
        
        # We assume we are editing the first slide
        slides = presentation.get('slides')
        if not slides:
             return (json.dumps({"error": "Template has no slides."}), 500, headers)
             
        first_slide = slides[0]
        page_elements = first_slide.get('pageElements', [])
        
        title_id = None
        body_id = None
        
        # Find the TITLE and BODY placeholders
        for element in page_elements:
            if 'shape' in element and 'placeholder' in element['shape']:
                ph_type = element['shape']['placeholder'].get('type')
                if ph_type in ['TITLE', 'CENTERED_TITLE']:
                    title_id = element['objectId']
                elif ph_type == 'BODY':
                    body_id = element['objectId']

        requests = []
        
        # 3. Inject Title
        if title_id:
            # Note: We skip deleteText because placeholders are empty by default in this template
            # and deleting text from an empty element throws a 400 error.
            requests.append({
                'insertText': {
                    'objectId': title_id,
                    'text': title,
                    'insertionIndex': 0
                }
            })

        # 4. Inject Bullets
        if body_id and bullets:
            # Format bullets into a single string with newlines
            bullet_text = '\n'.join(bullets)
            
            # Insert the text
            requests.append({
                'insertText': {
                    'objectId': body_id,
                    'text': bullet_text,
                    'insertionIndex': 0
                }
            })
            
            # Apply bullet styling to the whole block
            requests.append({
                'createParagraphBullets': {
                    'objectId': body_id,
                    'textRange': {'type': 'ALL'},
                    'bulletPreset': 'BULLET_DISC_CIRCLE_SQUARE'
                }
            })

        # 5. Execute the batch update
        if requests:
            slides_service.presentations().batchUpdate(
                presentationId=new_presentation_id,
                body={'requests': requests}
            ).execute()

        url = f"https://docs.google.com/presentation/d/{new_presentation_id}/edit"
        
        return (json.dumps({
            "message": "Slide deck generated successfully.",
            "url": url,
            "presentationId": new_presentation_id
        }), 200, headers)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return (json.dumps({"error": str(e)}), 500, headers)