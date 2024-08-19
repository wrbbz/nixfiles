YELLOW='\033[1;33m'
NC='\033[0m'
printf "%bExecution of custom script sudo -> doas substitution.\n" "${YELLOW}"
printf "This is the workaround for Telepresence.\n"
printf "If you are using it for something else - you are doing something wrong.\n"
printf "Use doas instead.\n"
printf "The script is placed at $(realpath "$0")%b\n\n" "${NC}"

if [ "$1" == "--non-interactive" ]
  then
    doas -n "${@:2}"
    exit 0
fi

doas "${@:1}"
