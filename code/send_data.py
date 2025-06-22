import time
import requests
from pymongo import MongoClient

# MongoDB connection configuration
host = "host"
port = "port"
username = "username"
password = "password"
database_name = "database_name"
collection_name = "collection_name"

# Establish MongoDB connection
client = MongoClient(f"mongodb://{username}:{password}@{host}:{port}/?authSource=admin")
db = client[database_name]
collection = db[collection_name]

# ThingSpeak API configuration
api_key_t = "api_key_t"  # API key for temperature channel
url_t = "url_t"          # URL for temperature channel
api_key_h = "api_key_h"  # API key for humidity channel
url_h = "url_h"          # URL for humidity channel

latest_id = None  # Tracks the latest _id processed from MongoDB

# Send data to ThingSpeak channel
def send_data_to_channel(url, api_key, data):
    data['api_key'] = api_key  # Add API key to payload
    response = requests.get(url, params=data)
    if response.status_code == 200:
        print("Data uploaded successfully:", data)
    else:
        print("Upload failed with status code:", response.status_code)

try:
    while True:
        # Query MongoDB for new records
        query = {} if latest_id is None else {"_id": {"$gt": latest_id}}
        result = collection.find(query).sort("_id", -1).limit(1)

        for item in result:
            # Build payloads for temperature and humidity
            temp_payload = {}
            humi_payload = {}

            # Process temperature data for 8 sensors
            for i in range(1, 9):
                temp_value = item.get(f"Temp_N1_ID{i}", 0) / 100  # Retrieve and convert temperature value
                temp_payload[f"field{i}"] = temp_value  # Add to temperature payload

            # Process humidity data for 8 sensors
            for j in range(1, 9):
                humi_value = item.get(f"Humi_N1_ID{j}", 0) / 100  # Retrieve and convert humidity value
                humi_payload[f"field{j}"] = humi_value  # Add to humidity payload

            # Send data to respective ThingSpeak channels
            send_data_to_channel(url_t, api_key_t, temp_payload)
            send_data_to_channel(url_h, api_key_h, humi_payload)

            # Update the latest processed _id
            latest_id = item["_id"]

        # Fetch data every 90 seconds
        time.sleep(90)

except KeyboardInterrupt:
    print("Program interrupted")
finally:
    client.close()  # Ensure MongoDB connection is closed