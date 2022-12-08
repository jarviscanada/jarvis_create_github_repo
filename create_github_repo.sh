#!/bin/bash

github_token=$1
csv_file=$2

REPO_PREFIX="jarvis_data_eng_"
USER_NAME="jarviscanada"

repos_json=$(curl -s --location --request GET 'https://api.github.com/user/repos' --header "Authorization: token ${github_token}")

check_http_status() {
    http_response=$1
    expected_status=$2
    action=$3
    status=$(echo "$1" | head -1 | awk '{print $2}' | xargs)
    echo "${1} ${2} ${3}"
}

create_github_repo() {
    username=$1
    repo_name=${REPO_PREFIX}${username}
    collaborator=$2

    echo ">>>>processing $repo_name"

    #create repo
    sleep 1
    http_response=$(curl -i -s --location --request POST 'https://api.github.com/user/repos' \
        --header "Authorization: token ${github_token}" \
        --header 'Content-Type: application/json' \
        --data-raw '{
	"name": "'${repo_name}'"
}')
    # check_http_status "${http_response}" 201 "create repo"

    #add collaborator
    sleep 1
    http_response=$(curl -i -s --location --request PUT "https://api.github.com/repos/${USER_NAME}/${repo_name}/collaborators/${collaborator}" \
        --header "Authorization: token ${github_token}")
    # check_http_status "${http_response}" 201 "add collaborator"

    #stop watching
    sleep 1
    http_response=$(curl -i -s --location --request DELETE 'https://api.github.com/repos/'${USER_NAME}'/'${repo_name}'/subscription' \
        --header 'Authorization: token '${github_token}'')
    # check_http_status "${http_response}" 204 "stop watching"

    echo ">>>>Finish $repo_name"
    echo ""
}

parse_row() {
    row=$1
    echo $row | awk -F',' '{print $1 " " $2}'
}

for row in $(cat $csv_file); do
    create_github_repo $(parse_row ${row})
done
exit 0
