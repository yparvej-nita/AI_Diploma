from astrapy import DataAPIClient

# Initialize the client
client = DataAPIClient()
db = client.get_database(
  "https://1033fe26-1e46-4c5a-9dba-7eb987b8ea93-us-east-2.apps.astra.datastax.com",
  token="YOUR_TOKEN"
)

print(f"Connected to Astra DB: {db.list_collection_names()}")