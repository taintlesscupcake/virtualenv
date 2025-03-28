# 환경 변수 설정
if [ -z "$ENV_HOME" ]; then
  export ENV_HOME="$HOME/.virtualenvs"
fi
export WORKON_HOME="$ENV_HOME/envs"

. "$ENV_HOME/check_for_update.sh"

mkenv() {
  if [ $# -ne 2 ]; then
    echo "Usage: mkenv <python_version> <env_name>"
    return 1
  fi

  if command -v mise &>/dev/null; then
    # mise 사용
    requested_version="$1"
    env_name="$2"

    if ! mise where python@"$requested_version" >/dev/null 2>&1; then
      echo -n "Python 버전 '$requested_version'이 mise에 없습니다. 설치하시겠습니까? (y/n) "
      read answer
      if [ "$answer" = "y" ]; then
        mise install python@"$requested_version"
      else
        echo "Python 설치가 취소되었습니다."
        return 1
      fi
    fi

    python_path=$(mise where python@"$requested_version")

    if [ -z "$python_path" ]; then
      echo "Python 버전 '$requested_version'의 경로를 찾을 수 없습니다."
      return 1
    fi

    virtualenv -p "$python_path/bin/python" "$WORKON_HOME/$env_name"
  else
    # mise가 없다면 기존 asdf 로직을 사용
    mkenv_asdf "$@"
  fi
}

mkenv_asdf() {
  if [ $# -ne 2 ]; then
    echo "Usage: mkenv <python_version> <env_name>"
    return 1
  fi

  installed_version="$1" # 기본값을 요청된 버전으로 설정

  python_path=$(asdf where python "$1")
  if [ "$python_path" = "Version not installed" ]; then
    dot_count=$(echo "$1" | awk -F"." '{print NF-1}')
    if [ "$dot_count" -le 1 ]; then
      echo -n "Python Version '$1' does not have a patch version. Do you want to install the latest patch version for $1? (y/n) "
      read answer
      if [ "$answer" = "y" ]; then
        asdf install python latest:$1
        # 설치된 최신 버전을 찾습니다.
        installed_version=$(asdf list python | sed 's/[* ]//g' | grep -E "^${1}\.[0-9]+$" | tail -n 1)
        echo "Python version selected: $installed_version"s
      else
        echo "Python install canceled."
        return 1
      fi
    else
      echo -n "Python Version '$1' is not installed. Do you want to install it? (y/n) "
      read answer
      if [ "$answer" = "y" ]; then
        asdf install python "$1"
        installed_version="$1"
      else
        echo "Python install canceled."
        return 1
      fi
    fi
  fi
  dot_count=$(echo "$installed_version" | awk -F"." '{print NF-1}')
  if [ "$dot_count" -le 1 ]; then
      echo -n "Python Version '$1' does not have a patch version. Do you want to use the latest patch version for $1? (y/n) "
      read answer
      if [ "$answer" = "y" ]; then
        # 설치된 최신 버전을 찾습니다.
        installed_version=$(asdf list python | sed 's/[* ]//g' | grep -E "^${1}\.[0-9]+$" | tail -n 1)
        echo "Python version selected: $installed_version"
      else
        echo "Python version selected: $installed_version"
      fi
    fi
  # 실제 설치된 버전을 사용하여 virtualenv를 생성합니다.
  virtualenv -p $(asdf where python "$installed_version")/bin/python "$WORKON_HOME"/"$2"
}

rmenv() {
  local force=0
  local env_name

  while getopts ":y" opt; do
    case ${opt} in
      y ) force=1 ;;
      \? ) echo "Invalid option: $OPTARG" 1>&2; return 1 ;;
    esac
  done
  shift $((OPTIND -1))

  if [ $# -ne 1 ]; then
    echo "Usage: rmenv [-y] <env_name>"
    return 1
  fi

  env_name="$1"

  if [ $force -eq 0 ]; then
    echo -n "Removing virtualenv ${env_name}. This action cannot be undone. Are you sure? (y/n) "
    read answer
    if [ "$answer" != "y" ]; then
      echo "Virtualenv removal canceled."
      return 1
    fi
  fi

  deactivate 2>/dev/null
  rm -rf "$WORKON_HOME/${env_name}"
  echo "Virtualenv ${env_name} successfully removed."
}

activate() {
  if [ $# -ne 1 ]; then
    echo "Usage: activate(act) <env_name>"
    return 1
  fi
  source "$WORKON_HOME/$1/bin/activate"
}

lsenv() {
  ls "$WORKON_HOME"
}

_activate_completions() {
  if [ -d "$WORKON_HOME" ]; then
    COMPREPLY=($(compgen -W "$(command ls -1 "$WORKON_HOME")" -- "${COMP_WORDS[COMP_CWORD]}"))
  fi
}

complete -F _activate_completions activate
complete -F _activate_completions rmenv

_mkenv_completions() {
  if [ "${COMP_CWORD}" -eq 1 ]; then
    if command -v mise &>/dev/null; then
      local versions=($(mise ls python | awk '{print $1}' 2>/dev/null))
    else
      local versions=($(asdf list python 2>/dev/null))
    fi
    COMPREPLY=($(compgen -W "${versions[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
  fi
}

complete -F _mkenv_completions mkenv

alias act=activate
alias deact=deactivate

setopt PROMPT_SUBST

show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV)) "
  fi
}

PS1='$(show_virtual_env)'$PS1
