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

  requested_version="$1"
  env_name="$2"

  if command -v mise &>/dev/null; then
    # mise 사용
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
  else
    # mise 없으면 asdf 사용
    if ! asdf where python "$requested_version" >/dev/null 2>&1; then
      echo -n "Python 버전 '$requested_version'이 asdf에 없습니다. 설치하시겠습니까? (y/n) "
      read answer
      if [ "$answer" = "y" ]; then
        asdf install python "$requested_version"
      else
        echo "Python 설치가 취소되었습니다."
        return 1
      fi
    fi

    python_path=$(asdf where python "$requested_version")
  fi

  if [ -z "$python_path" ]; then
    echo "Python 버전 '$requested_version'의 경로를 찾을 수 없습니다."
    return 1
  fi

  virtualenv -p "$python_path/bin/python" "$WORKON_HOME/$env_name"
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
