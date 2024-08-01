#Reverted commits into consideration

import requests
import re
import os
from bs4 import BeautifulSoup 
from dotenv import load_dotenv

load_dotenv()


# Retrieve the token from the environment variable
token = os.environ.get('BITBUCKET_TOKEN')
workspace = ""
repoSlug = ""


payload = {}

headers = {
  'Authorization': f'Bearer {token}'
}

def get_parser_args_matches(file_changes):
    parser_args = []
    pattern = "[+][ ]*parser.+"
    matches = re.findall(pattern, file_changes)
    for match in matches:
        if "parser.add_argument" in match:
            text = match.split("+        ")[-1]
            parser_args.append(f"<li>{text}</li>")
            
    return parser_args

def get_parser_arguments(pr_id):
    
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repoSlug}/pullrequests/{pr_id}/diff"

    response = requests.get(url, headers=headers, data=payload)
    changed_files = response.text.split("diff --git ")
    
    parser_args_html = ""
     
    for file_changes in changed_files:
        parser_args = get_parser_args_matches(file_changes)
        if file_changes != "" and len(parser_args) > 0:
            parser_args = get_parser_args_matches(file_changes)
            file_name = file_changes.split(" ")[0].split("/")[-1].split(".py")[0]
            header = f"<p><b>{file_name}</b>: {len(parser_args)} argument(s) were found</p>"
            
            parser_args_html +=  f"{header} <ul>{' '.join(parser_args)}</ul> <hr />"
    
    return parser_args_html


def get_pr_title(pr_id):
    try: 
        url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repoSlug}/pullrequests/{pr_id}/"

        response = requests.get(url, headers=headers, data={})
        print(response.json()["title"])
        title = response.json()["title"].split(":")
        res=f"<b>{title[0]}</b>: {title[1]}"
    except IndexError:
        res=f"{title[0]}"
    return res

def get_pr_id_from_el(text):
    pr_id_pattern = r"\((.*?)\)"
    pr_id = re.findall(pr_id_pattern, text)[0].split("#")[-1]
    return pr_id


def gen_link_from_text(link):
    return f"<a href='{link}'>{link.split('/')[-1]}</a>"

def gen_html(idx, p_text, link):
    if len(p_text.split(":")) > 1:
        parts = p_text.split(":")
        p_text = f"<b>{parts[0]}:</b>{parts[1]}"
    return f"<p>{idx}. {link} {p_text}</p>"


def extract_pull_request_details(pullRequestId: str) -> str:
    # Set your repository details
    workspace = "{workspace}"
    repoSlug = "geoaiprocessing" 

    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repoSlug}/pullrequests/{pullRequestId}"
    response = requests.get(url, headers=headers).json() 
    keywords = ["DEV", "PRODOPS", "GDM", "DIC"]
    text = response["summary"]["html"]

    soup = BeautifulSoup(text, 'html.parser')

    items = []
    parser_args = []
    count = 1
    for idx, el in enumerate(list(soup.ul)):
        if idx % 2 != 0 and el.find("a", href=True) is not None and el.text.startswith("\nRevert ") is False:
            link_full = el.find("a", href=True)['href']
            link_text = link_full.split('/')[-1]
            if link_text.split("-")[0] in keywords:
                link = gen_link_from_text(link_full)
                p_text = el.text.replace("         ", "").split("\n")[2].strip()
                items.append(gen_html(count, p_text, link))
                parser_args_pr_id = get_pr_id_from_el(el.text)
                p_arg_html = f"<p>{get_pr_title(parser_args_pr_id)}</p>" + get_parser_arguments(parser_args_pr_id)
                if "parser.add_argument" in p_arg_html:
                    parser_args.append(p_arg_html)
                    
                count += 1

    if parser_args:
        print(' GDM script update found')
        html_content = "Here are the latest deployments <br />" + " ".join(items) + "<br /> <br />"
        html_content +=  "<h2>These are the GDM Script Arguments</h2>" + "".join(parser_args)
    else:
        print('no GDM script updates found')
        html_content = "Here are the latest deployments <br />" + " ".join(items) + "<br /> <br />"

    # Writing HTML content to a file named 'prodops.html'
    with open('prodops.html', 'w') as file:
        file.write(html_content)
    
    return html_content

extract_pull_request_details("625")