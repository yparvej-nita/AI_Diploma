from astrapy import DataAPIClient
from astrapy.constants import VectorMetric
from astrapy.info import CollectionDefinition, CollectionVectorOptions

API_ENDPOINT = "API-Endpoint"
APPLICATION_TOKEN = "YourAppToken"

try:
    # Get an existing database
    client = DataAPIClient()
    database = client.get_database(
        API_ENDPOINT, token=APPLICATION_TOKEN
    )

    # Create a collection
    collection_definition = CollectionDefinition(
        vector=CollectionVectorOptions(
            dimension=1024, metric=VectorMetric.COSINE, source_model="nv-qa-4"
        ),
    )
    collection = database.create_collection(
        "collectionvec",
        definition=collection_definition,
    )
except Exception as e:
    print(f"An error occurred: {e}")
        