import os
import argparse
from glob import iglob
from azure.storage.blob import BlobServiceClient, ContentSettings
from datetime import datetime

BUILD_NUMBER = os.environ.get("BITBUCKET_BUILD_NUMBER")
REPO_SLUG = os.environ.get("BITBUCKET_REPO_SLUG")
DISCOVERY_CONN_STRING = os.environ.get("DISCOVERY_CONN_STRING")

def get_timestamp():
    return datetime.now().strftime("%Y%m%d-%H%M%S")

def upload_reports(pattern):
    files_to_upload = iglob(pattern)
    blob_service_client = BlobServiceClient.from_connection_string(DISCOVERY_CONN_STRING)
    container_client = blob_service_client.get_container_client("bitbucket")
    for file in files_to_upload:
        blob_name = f"{REPO_SLUG}/Build#{BUILD_NUMBER}/{file}"
        print(f"{blob_name=}")
        print(f"{file=}")
        with open(file, "rb") as data:
            container_client.upload_blob(
                name=blob_name,
                data=data,
                content_settings=ContentSettings(content_type="application/json"),
                overwrite=True
            )

def upload_builds(pattern):
    files_to_upload = iglob(pattern)
    blob_service_client = BlobServiceClient.from_connection_string(DISCOVERY_CONN_STRING)
    container_client = blob_service_client.get_container_client("products")
    for file in files_to_upload:
        true_filename = file.split("\\")[-1]
        blob_name = f"{REPO_SLUG}/{true_filename}"
        print(f"{blob_name=}")
        print(f"{file=}")

        if (true_filename.endswith(".tar.gz")):
            content_settings=ContentSettings(content_type="application/gzip")
        elif (true_filename.endswith(".whl")):
            content_settings=ContentSettings(content_type="application/octet-stream")
        else:
            content_settings=ContentSettings()

        with open(file, "rb") as data:
            container_client.upload_blob(
                name=blob_name,
                data=data,
                content_settings=content_settings,
                overwrite=True
            )


if __name__ == "__main__": # "*report.json"
    parser = argparse.ArgumentParser(
        description="Uploads files to Discovery Depot."
    )
    verbosity_group = parser.add_mutually_exclusive_group()
    verbosity_group.add_argument("-v", "--verbose", action="count", default=0)
    verbosity_group.add_argument("-q", "--quiet", action="store_true")
    required = parser.add_argument_group("Required arguments")
    optional = parser.add_argument_group("Optional arguments")
    required.add_argument(
        "-t",
        "--type",
        dest="type",
        choices=["reports", "build"],
        type=str,
        required=True,
        help="Choose a type of artifact to upload to Discovery",
    )
    required.add_argument(
        "-p",
        "--pattern",
        dest="pattern",
        required=True,
        help="Glob pattern, to find and upload files to Discovery",
    )
    args = parser.parse_args()
    if (args.type == "reports"):
        upload_reports(args.pattern)
    elif (args.type == "build"):
        upload_builds(args.pattern)
