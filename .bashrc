################################################################################
# => General
################################################################################
bind 'TAB: menu-complete'
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set colored-completion-prefix'
bind 'set editing-mode vi'
export CLICOLOR=1


################################################################################
# => History
################################################################################
HISTSIZE=10000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignorespace:ignoredups
shopt -s histappend
PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"


################################################################################
# => Prompt
################################################################################
# Themes
# normal color, insert color, user color, foreground color
xcodeColors=(8 208 248 255)
solarizedColors=(12 3 11 255)


isViModeOn() {
  set -o | grep -E "^vi\s*on"
}

viModeString() {
  local text=$1
  local modeColor=$2
  local userColor=$3
  local foregroundColor=$4

  printf '%s' \
    "\1\e[1;38;5;"$foregroundColor"m\e[48;5;"$modeColor"m\2 " \
    "$text" \
    " \1\e[0m\2\1\e[38;5;"$modeColor"m\e[48;5;"$userColor"m\2\1\e[0m\2"
}

setViModeStrings() {
  local normalText=$1
  local normalColor=$2
  local insertText=$3
  local insertColor=$4
  local userColor=$5
  local foregroundColor=$6

  bind "set vi-cmd-mode-string \
    $(viModeString "$normalText" $normalColor $userColor $foregroundColor)"
  bind "set vi-ins-mode-string \
    $(viModeString "$insertText" $insertColor $userColor $foregroundColor)"
}

userPrompt() {
  local userColor=$1
  local foregroundColor=$2

  printf '%s' \
    "\[\e[38;5;"$foregroundColor"m\]\[\e[48;5;"$userColor"m\]" \
    " \u \[$(tput sgr0)\]" \
    "\[\e[38;5;"$userColor"m\]\[$(tput sgr0)\]"
}

setPrompt() {
  local normalColor=$1
  local insertColor=$2
  local userColor=$3
  local foregroundColor=$4

  if [ "${BASH_VERSINFO:-0}" -ge 4 ]; then
    if [[ $(isViModeOn) != "" ]]; then
      bind "set show-mode-in-prompt on"

      setViModeStrings \
        "NORMAL" \
        $normalColor \
        "INSERT" \
        $insertColor \
        $userColor \
        $foregroundColor
    fi

    title='echo -ne "\e]0;$(basename ${PWD/#$HOME/~})\007"'
    PROMPT_COMMAND="$PROMPT_COMMAND$title"
  fi

  PS1=$(userPrompt $userColor $foregroundColor)
}

setPrompt "${xcodeColors[@]}"


################################################################################
# => Commands
################################################################################
# cd to the path of the front Finder window
cdf() {
  target=$(osascript -e '
    tell application "Finder"
      if (count of Finder windows) > 0 then
        get POSIX path of (target of front Finder window as text)
      end if
    end tell'
  )

  if [ "$target" != "" ]; then
    pushd "$target" > /dev/null
    pwd
  else
    echo 'No Finder window found' >&2
  fi
}


################################################################################
# => Aliases
################################################################################
# Directory stack
alias pushdd="pushd \$PWD > /dev/null"
alias cd='pushdd;cd'
alias popdd='popd >/dev/null'
alias cd.='popdd'
alias cd..='popdd;popdd'
alias cd...='popdd;popdd;popdd'
alias cd....='popdd;popdd;popdd;popdd'
alias .cd='popd -n +0'
alias ..cd='popd -n +0;popd -n +0;popd -n +0;popd -n +0;popd -n +0;popd -n +0; \
  popd -n +0;popd -n +0;popd -n +0;popd -n +0'

# cd
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Other
alias vim='nvim'
alias grep='grep --color -Iinr'
alias youtube-dl-video="youtube-dl \
  -f 'bestvideo[ext=mp4][width<=1920][height<=1080]+bestaudio[ext=m4a]' \
  -o '%(title)s.%(ext)s'"
alias youtube-dl-video4k="youtube-dl \
  -f 'bestvideo[width>1920][height>1080]+bestaudio[ext=m4a]' \
  -o '%(title)s.%(ext)s'"
alias youtube-dl-video480="youtube-dl \
  -f 'bestvideo[ext=mp4][width<=640][height<=480]+bestaudio[ext=m4a]' \
  -o '%(title)s.%(ext)s'"
alias youtube-dl-audio="youtube-dl --extract-audio --audio-format m4a \
  --audio-quality 0 -o '%(title)s.%(ext)s'"
alias reloadprefs="killall -u $(whoami) cfprefsd"


################################################################################
# => Keybindings
################################################################################
bind -m vi-insert "\C-l":clear-screen
