import requests
import json
from pprint import pprint as pp
import time
import os
import argparse

token = os.environ["BITBUCKET_AUTH_TOKEN"]

headers = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/json",
    "Content-Type": "application/json"
}

workspace = "enersoftinc"

def trigger_pipeline(repo_slug, branch, trailer):
    pattern = {
        "geoaiprocessing": f"GeoAIProcessing-{trailer}",
        "geoalchemy": f"GeoAlchemy-{trailer}",
        "geoaitools": f"GeoAITools-{trailer}"
    }[repo_slug]
    
    repository_uri = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/pipelines/"
    body = {
        "target": {
            "ref_type": "branch",
            "type": "pipeline_ref_target",
            "ref_name": branch,
            "selector": {
                "type": "custom",
                "pattern": pattern
            }
        }
    }
    response = requests.post(repository_uri, headers=headers, data=json.dumps(body))
    print(response.request.url)
    print(response.request.body)
    response.raise_for_status()
    return response.json()["uuid"]

def check_pipeline_status(repo_slug, pipeline_uuid):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/pipelines/{pipeline_uuid}/steps"
    response = requests.request("GET", url, headers=headers, data={})
    steps = response.json()["values"]
    return steps

def print_logs(repo_slug, pipeline_uuid, step_uuid, step_name):
    print("pipeline uuid is " + pipeline_uuid)
    print("step uuid is " + step_uuid)
    headers['Accept'] = '*/*'
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/pipelines/{pipeline_uuid}/steps/{step_uuid}/log"
    response = requests.request("GET", url, headers=headers, data={})
    print(f"******LOGS for {step_name} BELOW***********")
    print(response.text)
    print("***************************")

def print_steps(repo_slug, pipeline_uuid, steps):
    for step in steps:
        print_logs(repo_slug, pipeline_uuid, step["uuid"], step["name"])
        print("*********")
        print(step["uuid"])
        print(step["name"])
        print(step["state"])
        print("*********")

def main(repo_slug, branch, trailer):
    uuid = trigger_pipeline(repo_slug, branch, trailer)
    print(uuid)
    while True:
        time.sleep(60)
        steps = check_pipeline_status(repo_slug, uuid)
        try:
            all_steps_completed = all(step["state"]["result"]["name"] in ["SUCCESSFUL", "FAILED", "STOPPED", "NOT_RUN"] for step in steps)
            if all_steps_completed:
                print_steps(repo_slug, uuid, steps)
                results = [step["state"]["result"]["name"] for step in steps]
                if "FAILED" in results or "STOPPED" in results:
                    print(f"Pipeline {repo_slug} did not succeed. Exiting.")
                    return "FAILED"
                return "SUCCESSFUL"
            print("Checking again.....")
        except KeyError:
            continue

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Trigger and monitor Bitbucket pipeline.')
    parser.add_argument('-Trailer', required=True, help='Trailer name')
    parser.add_argument('-Repository', required=True, help='Repository name')
    parser.add_argument('-Branch', required=True, help='Branch name')
    args = parser.parse_args()

    repo_slug = args.Repository.lower()
    print("repo_slug", repo_slug)
    if repo_slug == "entirepipeline":
        repo_sequence = ["geoaiprocessing", "geoaitools", "geoalchemy"]
    else:
        repo_sequence = [repo_slug]

    for repo in repo_sequence:
        print("Repo is " + repo)
        print("Branch is " + args.Branch)
        print("Trailer is " + args.Trailer)
        result = main(repo, args.Branch, args.Trailer)
        if result in ["FAILED", "STOPPED"]:
            print("The process should have stopped here....")
            break

    print("*********************************") 
    print("***************This is the end of the script******************")
    print("*********************************")


