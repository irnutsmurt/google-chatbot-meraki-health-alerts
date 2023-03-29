import requests
import json

def send_to_google_chat(webhook_url, message):
    data = {
        'text': message
    }
    headers = {'Content-Type': 'application/json; charset=UTF-8'}

    response = requests.post(webhook_url, data=json.dumps(data), headers=headers)
    if response.status_code == 200:
        print("Message sent to Google Chat successfully.")
    else:
        print(f"Error sending message to Google Chat: {response.status_code}")
