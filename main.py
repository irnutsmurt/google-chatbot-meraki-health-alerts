import configparser
import json
import re
import time
from meraki import get_health_alerts
from googlechat import send_to_google_chat

def read_previous_alerts(file_name):
    try:
        with open(file_name, 'r') as file:
            return file.read().splitlines()
    except FileNotFoundError:
        return []

def store_previous_alerts(file_name, alerts):
    with open(file_name, 'w') as file:
        for alert in alerts:
            file.write(f"{alert}\n")

def format_alert(alert):
    scope_devices = ', '.join([f"{device['name']} ({device['productType']}) - {device['url']}" for device in alert['scope']['devices']])
    scope_applications = ', '.join(alert['scope']['applications'])
    scope_peers = ', '.join(alert['scope']['peers'])

    message = f"*Category*: {alert['category']}\n" \
              f"*Type*: {alert['type']}\n" \
              f"*Severity*: {alert.get('severity', 'N/A')}\n" \
              f"*Devices*: {scope_devices}\n" \
              f"*Applications*: {scope_applications}\n" \
              f"*Peers*: {scope_peers}\n"
    return message

def main():
    config = configparser.ConfigParser()
    config.read('config.ini')

    meraki_api_key = config.get('meraki', 'api_key')
    meraki_network_id = config.get('meraki', 'network_id')
    google_chat_webhook_url = config.get('google_chat', 'webhook_url')

    previous_alerts = read_previous_alerts('previous_alerts.txt')

    health_alerts = get_health_alerts(meraki_api_key, meraki_network_id)
    if health_alerts:
        for alert in health_alerts:
            message = format_alert(alert)
            message_pattern = re.compile(re.escape(message), re.MULTILINE)

            # Check for duplicates
            if not any(message_pattern.search(prev_alert) for prev_alert in previous_alerts):
                send_to_google_chat(google_chat_webhook_url, message)
                previous_alerts.append(message)

        store_previous_alerts('previous_alerts.txt', previous_alerts)

if __name__ == '__main__':
    while True:
        main()
        time.sleep(60)  # Sleep for 60 seconds (1 minute)