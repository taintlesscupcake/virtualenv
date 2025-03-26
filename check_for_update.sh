#!/bin/bash

(
    cd "$ENV_HOME" || exit 1

    git fetch

    current_branch=$(git rev-parse --abbrev-ref HEAD)

    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse origin/"$current_branch")

    if [ "$local_commit" = "$remote_commit" ]; then
        exit 0
    else
        echo "There are updates available for your repository."
        echo -n "Would you like to update now? (y/N): "
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Updating your local repository..."
            git pull origin "$current_branch"
            echo "Update completed."
        else
            echo "Update canceled."
        fi
    fi
)
