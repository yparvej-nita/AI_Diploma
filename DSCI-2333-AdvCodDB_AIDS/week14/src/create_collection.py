from astrapy import DataAPIClient

API_ENDPOINT = "API-Endpoint"
APPLICATION_TOKEN = "YourAppToken"
# Get a database
client = DataAPIClient()
database = client.get_database(
    API_ENDPOINT, token=APPLICATION_TOKEN
)

try:
    # Check if the collection already exists
    if "collection-1" in database.list_collection_names():
        print("Collection 'collection-1' already exists.")
    else:
        # Create a collection
        collection = database.create_collection("collection1")
        print("Collection 'collection-1' created successfully.")
except Exception as e:
    print(f"An error occurred: {e}")
    