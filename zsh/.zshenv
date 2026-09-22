export EDITOR="nvim"
export VISUAL="gedit"
export MANPAGER="nvim +Man!"

if [ -d "$HOME/.local/share/android-sdk" ]; then
    export ANDROID_SDK_ROOT="$HOME/.local/share/android-sdk"
fi
