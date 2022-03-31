#!/usr/bin/env bash
#
# Prompts user for the relative path to dashboards directory.
# To avoid this prompt, set LOCAL_DASHBOARD_DIRECTORY when you run make.
shopt -s globstar
PS3="Enter number of selection: "
select dir in **/dashboards/ "Other (enter manually)"; do
    if [[ $dir == "Other (enter manually)" ]]
    then
        read -erp "Enter relative path to dashboards directory: " dir
    fi
    echo -n "$dir"
    break
done
