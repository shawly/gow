# ~/.bashrc: executed by bash(1) for interactive non-login shells.

# If not running interactively, don’t do anything
[ -z "${PS1-}" ] && return

# ---- History ----
HISTSIZE=5000
HISTFILESIZE=10000
HISTTIMEFORMAT="%F %T "
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
# Save and reload history after each command
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# ---- Aliases ----
alias ll='ls -lh --color=auto'
alias la='ls -A --color=auto'
alias lla='ls -alh --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias df='df -h'
alias free='free -m'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ..; cd ..'
alias ....='cd ..; cd ..; cd ..'

# ---- Prompt (PS1) ----
if [[ ${EUID} == 0 ]] ; then
    PS1='\[\033[48;2;221;75;57;38;2;255;255;255m\] \$ \[\033[48;2;0;135;175;38;2;221;75;57m\]\[\033[48;2;0;135;175;38;2;255;255;255m\] \u@\h \[\033[48;2;83;85;85;38;2;0;135;175m\]\[\033[48;2;83;85;85;38;2;255;255;255m\] \w \[\033[49;38;2;83;85;85m\]\[\033[00m\] '
else
    PS1='\[\033[48;2;105;121;16;38;2;255;255;255m\] \$ \[\033[48;2;0;135;175;38;2;105;121;16m\]\[\033[48;2;0;135;175;38;2;255;255;255m\] \u@\h \[\033[48;2;83;85;85;38;2;0;135;175m\]\[\033[48;2;83;85;85;38;2;255;255;255m\] \w \[\033[49;38;2;83;85;85m\]\[\033[00m\] '
fi

# ---- Completion ----
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
