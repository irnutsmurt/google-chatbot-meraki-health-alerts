# Google Workspace Chatbot Meraki Health Alerts
Bot to pull down alerts from Meraki network devices using the meraki api to send to google workspace chat using Spaces Webhooks

Run the bash script meraki_google_chatbot_ installer.sh to be ran through the steps to automatically install this script. You will need your meraki api key, your networkid, and your googlechat webhook url. To find these, follow steps 2 - 5 of the manual install.

To manually install this bot follow, these steps
1. git clone repository (recommend placing in /opt/merakialerts)

2. On your Cisco Meraki, create an api key. https://documentation.meraki.com/General_Administration/Other_Topics/Cisco_Meraki_Dashboard_API

3. Generate a Google Chat Space Webhook. https://developers.google.com/chat/how-tos/webhooks

4. Get your Meraki organization ID. If you don't know this, login to your meraki web portal and then follow this link https://dashboard.meraki.com/api/v0/organizations

5. You'll need your network id next for your network that you want to monitor. Run this curl command replacing the org id and your api key you generated
curl -L --request GET \
--url https://api.meraki.com/api/v0/organizations/orgid here/networks \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--header 'X-Cisco-Meraki-API-Key: api key here'

6. Take your api key, your network id, and your google chat webhook url and place in the config.ini file in the approriate field. Please note, the webhook url will contain near the end a %. The script requires that you add an extra % to it. For example if the webhook url looks like this
```
https://chat.googleapis.com/v1/spaces/ABCDEonasRZyh/messages?key==AAAAAAAAAAABBBBBBCCCCC-DDDDDDEEEEEEEFFFFtoken=11GGGGGGGGGGHHHH34I-1IIIIIIIKKKKKKKLLL-MMM%3D
```

It should look like this in the config.ini
```
[google_chat]
https://chat.googleapis.com/v1/spaces/ABCDEonasRZyh/messages?key==AAAAAAAAAAABBBBBBCCCCC-DDDDDDEEEEEEEFFFFtoken=11GGGGGGGGGGHHHH34I-1IIIIIIIKKKKKKKLLL-MMM%%3D
```
7. run pip install requirements.txt to install dependencies

Edit the systemd service with what username you'll be using, what is the working directory the script is placed in, and replace the /opt/merakialerts/main.py to the file location of your script

Optionally, execute the create_service_account.sh by running sudo sh ./create_service_account.sh and use the meraki-alerts service account and follow the defaults

8. Place the systemd service in the /etc/systemd/system/meraki-alerts.service

9. run sudo systemctl daemon-relead

10. run the command sudo systemctl enable meraki-alerts.service

11. run the command sudo systemctl start meraki-alerts.service

12. Check if service is running by running sudo systemctl status meraki-alerts.service

