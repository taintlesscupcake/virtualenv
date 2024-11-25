#!/bin/bash

cd $ENV_HOME

# 원격 저장소에서 최신 정보를 가져옵니다
git fetch

# 현재 체크아웃된 브랜치 확인
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 원격 브랜치와 로컬 브랜치의 최신 커밋 비교
local_commit=$(git rev-parse HEAD)
remote_commit=$(git rev-parse origin/$current_branch)

if [ "$local_commit" = "$remote_commit" ]; then
    cd ~
    return 0
else
    echo "There are updates available for your repository."
    echo -n "Would you like to update now? (y/N): "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Updating your local repository..."
        git pull origin $current_branch
        echo "Update completed."
    else
        echo "Update canceled."
    fi
fi

cd ~