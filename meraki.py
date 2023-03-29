import requests

def get_health_alerts(api_key, network_id):
    url = f'https://api.meraki.com/api/v1/networks/{network_id}/health/alerts'
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Cisco-Meraki-API-Key': api_key
    }

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error getting health alerts: {response.status_code}")
        return None
