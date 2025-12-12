#!/usr/bin/env python3
#
# Copyright Marc 2024
#
#This script is designed to process a csv file and trace requirement links
#
import csv
import argparse
import requests
import os

# Gitlab API Base
GITLAB_DOMAIN = "mydomain.url.uk"
GITLAB_API_URL = f"https://{GITLAB_DOMAIN}/api/v4"
API_TOKEN = "~/.ssh/my_api_token"
PER_PAGE = 100

description = '''
Process a CSV file and update GitLab issues.

Function does x y z
'''
# Function to parse command-line arguments
def parse_arguments():
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('-f', '--file', default='vv.csv', help='Input CSV file (default: vv.csv)')
    parser.add_argument('-o', '--output', default='vv-update.csv', help='Output CSV file (default: vv-update.csv)')
    parser.add_argument('-p', '--project', default='396', help='GitLab project ID (default: 396)')
    parser.add_argument('-t', '--token', default=os.path.expanduser('~/.ssh/gitlab_pac'), help='GitLab token file (default: ~/.ssh/gitlab_pac)')
    return parser.parse_args()

# Function to load GitLab token from file
def load_gitlab_token(token_file):
    with open(token_file, 'r') as file:
        return file.read().strip()


def Debug(message):
    if args.debug:
        print("[DEBUG]",message)

def check_file(file_path):
    if not os/path.exists(file_path):
        print(f"Error: The file '{file_path}' does not exist.")
        return False
    else:
        return True

# Function to search for issues on GitLab based on project and search string
def get_all_items(url):
    """Generic Fetch items for a GitLab url, with pagination and limits."""
    all_items = []
    page = 1

    while True:
        params = {"page": page, "per_page": PER_PAGE}
        response = requests.get(url, headers=HEADERS, params=params, timeout=20)
        response.raise_for_status()

        if response.status_code == 200:
            data = response.json()

            if isinstance(data, list):
                Debug("Response is a list")
                all_items.extend(data)
            elif:
                Debug("Response is a dict"):
                all_items.append(data)

            next_page = response.headers.get('X-Next-Page')
            if not next_page:
                break
            page = int(next_page)

        elif response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 10))
            Debug(f"Rate limit exceeded. Retrying after {retry_after} seconds....")
            time.sleep(retry_after)
        else:
            print(f"Failed to retrieve date: {response.status_code}")

    return all_items if all_items else ""


# Main function to process CSV
def process_csv(input_file, output_file, all_issues):
    with open(input_file, mode='r', newline='', encoding='utf-8', errors='replace') as infile, \
         open(output_file, mode='w', newline='', encoding='utf-8') as outfile:
        
        # Skip the first row (non header)
        first_row = infile.readline()
        outfile.write)first_row)

        # Use DictReader to handle column names
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames  # Capture the field names for output
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()  # Write the header to the output file

        for row in reader:

            Debug(f"Row {row_num:<5}: ", end="", flush=True)

            uid = (row["DOORS UID"] or "").strip()
            object_type = (row["Object Type"] or "").strip().upper()
            company_responsible = (row["Company Responsible"] or "").strip().upper()

            search_string = f"{object_type[:3]}-{uid}"
            Debug(f" {search_string:<10} ", end="", flush=True)

            # If Object Type is not "MOP" or "REQ", skip GitLab search and write row as-is
            if not object_type.startswith(('MOP', 'REQ')):
                writer.writerow(row)
                continue

            if not ocompany_responsible.startswith(('COMPANY:')):
                writer.writerow(row)
                continue

            # Search for GitLab issues that match the search string
            matching_issues = [issue for issue in all_issues if issue['title'].startswith(search_string)]
            if len(matching_issues) == 1:

                for issue in matching_issues:

                    all_links = get_all_items(f"{GITLAB_API_URL}/projects/{args.project}/issues/{issue['iid']}/links")
                    if len(all_links) == 0:
                        Debug("Warning: No links")
                    elif len(all_links) == 1:
                        Debug("1 link added")
                    elif len(all_links) > 1:
                        Debug(f" > {len(all_links)} links added")

                    row["User Stories"] += " | ".join([f"Link{i + 1}: {each_link['title']}|{each_link['web_url']} - {each_link['labels']}\n"
                                              for i, each_link in enumerate(all_links)])

            else:
                Debug(f" > [{len(matching_issues)}] matches")

            # Write the updated row to the output CSV file
            writer.writerow(row)

# Entry point
if __name__ == "__main__":
    args = parse_arguments()
    access_toekn = load_gitlab_token(args.token)
    HEADERS = {"Authorization": "Bearer " + access_token} if access_token else None

    if not check_file(args.token):
        exit(1)
    if not check_file(args.file):
        exit(2)

    print(f"Caching issues for project [{str(args.project)}]")

    issues_url = f"{GITLAB_API_URL}/projects/{args.project}/issues"
    all_issues = get_all_items(issues_url)

    process_csv(args.file, args.output, args.project, gitlab_token)
    Debug("")
