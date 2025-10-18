#!/bin/bash

#early exit
is_hdev_developer=$($CLI_PATH/common/is_member $USER hdev_developers)
is_sudo=$($CLI_PATH/common/is_sudo $USER)
if [ "$is_sudo" = "0" ] && [ "$is_hdev_developer" = "0" ]; then
    exit
fi

#check on sudo
#sudo_check $USER

#inputs (split the string into an array)
read -r -a flags_array <<< "$@"

#check on number of parameters
if [ "$#" -lt 2 ]; then
    update_help
    exit 1
elif [ "$2" = "--latest" ]; then
    if [ "$#" -gt 2 ]; then
    update_help
    exit 1
    fi
    #tag_name=$(gh release list -R "$HDEV_REPO" --limit 1 --json tagName --jq '.[0].tagName')
    tag_name=$(gh release list -R "$HDEV_REPO" -L 1 | awk '{print $1}')
    pullrq_id="none"
elif [ "$2" = "-n" ] || [ "$2" = "--number" ]; then
    word_check "$CLI_PATH" "-n" "--number" "${flags_array[@]}"
    pullrq_found=$word_found
    pullrq_id=$word_value

    #check on pullrq_id
    if [[ "$pullrq_found" == "1" && "$pullrq_id" == "" ]]; then
    update_help
    exit 1
    fi

    #check if PR exist
    exists_pr=$($CLI_PATH/common/gh_pr_check $GITHUB_CLI_PATH $HDEV_REPO $pullrq_id)
    if [ "$pullrq_found" = "1" ] && [ "$exists_pr" = "0" ]; then
    echo ""
    echo $CHECK_ON_PR_ERR_MSG
    $CLI_PATH/common/print_pr "$GITHUB_CLI_PATH" "$HDEV_REPO"
    exit 1
    fi
    tag_name="none"
elif [ "$2" = "-t" ] || [ "$2" = "--tag" ]; then
    word_check "$CLI_PATH" "-t" "--tag" "${flags_array[@]}"
    tag_found=$word_found
    tag_name=$word_value
    tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$HDEV_REPO" "$tag_name" "${flags_array[@]}"
    pullrq_id="none"
fi

#get update.sh
cd $UPDATES_PATH
git clone $REPO_URL > /dev/null 2>&1 #https://github.com/fpgasystems/hdev.git

#copy update
#sudo mv $UPDATES_PATH/$REPO_NAME/update.sh $HDEV_PATH/update
#sudo mv $UPDATES_PATH/$REPO_NAME/.update.sh $HDEV_PATH/.update
sudo $CLI_PATH/common/mv $UPDATES_PATH/$REPO_NAME/.update.sh $HDEV_PATH/.update
sudo $CLI_PATH/common/mv $UPDATES_PATH/$REPO_NAME/update.sh $HDEV_PATH/update

#remove temporal copy
rm -rf $UPDATES_PATH/$REPO_NAME

#run up to date update 
$HDEV_PATH/update --number $pullrq_id --tag $tag_name