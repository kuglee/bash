# If the shell is interactive and .bashrc exists, source .bashrc.
if [[ $- == *i* && -f ~/.bashrc ]]; then
    . ~/.bashrc
fi
