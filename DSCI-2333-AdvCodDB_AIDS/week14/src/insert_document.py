from astrapy import DataAPIClient
API_ENDPOINT = "https://1033fe26-1e46-4c5a-9dba-7eb987b8ea93-us-east-2.apps.astra.datastax.com"
APPLICATION_TOKEN = "AstraCS:HDTWhqOfCIBaDDKmOhSzErAU:a988ad29b66203fad11808e6b6429d377cb0bfd94be89286957e112c2bbc5e33"

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