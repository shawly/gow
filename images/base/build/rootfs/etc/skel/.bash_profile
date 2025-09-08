# ~/.bash_profile: executed by bash for login shells.

# Source .bashrc if interactive
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Set PATH for user-local bin
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH
