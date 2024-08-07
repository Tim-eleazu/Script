from azure.storage.blob import BlobServiceClient
import os
import re
from collections import defaultdict

STORAGEACCOUNTURL = ""
STORAGEACCOUNTKEY = ""
CONTAINERNAME = "deployments"
LOCALFILENAME = os.getcwd()
RESULT_FILENAME = "intersection_results.html" 

os.makedirs(LOCALFILENAME, exist_ok=True)

# Create the BlobServiceClient object
blob_service_client_instance = BlobServiceClient(
    account_url=STORAGEACCOUNTURL, credential=STORAGEACCOUNTKEY)

# Create container client
container_client = blob_service_client_instance.get_container_client(CONTAINERNAME)

# List blobs in the container
blobs_list = container_client.list_blobs()

# Hold nodes for each software
installations = {
    'geoaiprocessing': set(),
    'geoaitools': set(),
    'geoalchemy': set()
}

# Regex patterns to identify the installations
patterns = {
    'geoaiprocessing': re.compile(r'Successfully installed geoaiprocessing\s+on\s+(\S+)'),
    'geoaitools': re.compile(r'Successfully installed geoaitools\s+on\s+(\S+)'),
    'geoalchemy': re.compile(r'Successfully installed geoalchemy\s+on\s+(\S+)')
}

for blob in blobs_list:
    if blob.name.endswith('.txt'):
        # Extract the folder name from the blob name
        folder_name = blob.name.split('_')[0]
        
        # Create a local folder for each text file
        local_folder_path = os.path.join(LOCALFILENAME, folder_name)
        os.makedirs(local_folder_path, exist_ok=True)
        
        # Define the local file path
        local_file_path = os.path.join(local_folder_path, blob.name)
        
        # Get blob client
        blob_client_instance = blob_service_client_instance.get_blob_client(
            container=CONTAINERNAME, blob=blob.name, snapshot=None)
        
        # Download the blob to a local file
        with open(local_file_path, "wb") as my_blob:
            blob_data = blob_client_instance.download_blob()
            my_blob.write(blob_data.readall())
        
        # Parse the file to find successful installations
        with open(local_file_path, "r") as file:
            content = file.read()
            for key, pattern in patterns.items():
                matches = pattern.findall(content)
                installations[key].update(matches)

# Debug 
print("Installations dictionary:")
for key, nodes in installations.items():
    print(f"{key}: {nodes}")

# Find the intersection of nodes where all three installations were successful
intersect_nodes = installations['geoaiprocessing'] & installations['geoaitools'] & installations['geoalchemy']

# Function to extract MU and NODE numbers for sorting
def extract_mu_node_order(node):
    mu_match = re.search(r'MU-(\d+)', node)
    node_match = re.search(r'NODE-(\d+)', node)
    if mu_match and node_match:
        mu_num = int(mu_match.group(1))
        node_num = int(node_match.group(1))
        return (mu_num, node_num)
    return (float('inf'), float('inf')) 

# Sort intersecting nodes by MU and NODE numbers
sorted_intersect_nodes = sorted(intersect_nodes, key=extract_mu_node_order)

# Group sorted nodes by MU-xx prefix
grouped_nodes = defaultdict(list)
for node in sorted_intersect_nodes:
    mu_prefix = re.search(r'(MU-\d+)', node).group(1)
    grouped_nodes[mu_prefix].append(node)

# Write the intersecting nodes to a result file in grouped and sorted order
result_file_path = os.path.join(LOCALFILENAME, RESULT_FILENAME)
with open(result_file_path, "w") as result_file:
    result_file.write("<html><body>\n")
    for mu_prefix in sorted(grouped_nodes.keys(), key=lambda x: int(x.split('-')[1])):
        result_file.write(f"<h3><b>{mu_prefix}</b></h3>\n")
        for node in grouped_nodes[mu_prefix]:
            result_file.write(f"<p>Geoaiecosystem was installed on {node}</p>\n")
    result_file.write("</body></html>\n")

print(f"Intersecting nodes have been written to '{result_file_path}'")