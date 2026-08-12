from astrapy import DataAPIClient
API_ENDPOINT = ""
APPLICATION_TOKEN = ""

# Get an existing collection
client = DataAPIClient()
database = client.get_database(
    API_ENDPOINT, token=APPLICATION_TOKEN
)
collection = database.get_collection("collection1")

# Insert documents into the collection
result = collection.insert_many(
    [
        {
            "name": "Jane Doe",
            "age": 42,
        },
        {
            "nickname": "Bobby",
            "color": "blue",
            "foods": ["carrots", "chocolate"],
        },
    ]
)