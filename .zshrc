
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="amuse"
plugins=(
  git
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh
eval "$(rbenv init - zsh)"

# Java環境設定（macOSネイティブ対応）
export JAVA_HOME=$(/usr/libexec/java_home -v21)
export PATH="$JAVA_HOME/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

# xcode
# alias start='open my-dear.xcworkspace'
alias xdd='echo "Deleting Xcode DerivedData..."; rm -rf ~/Library/Developer/Xcode/DerivedData && echo "✅ Done!"'

# Codex prompt editor (Ctrl+G) uses VISUAL, then EDITOR
export EDITOR="code -w"
export VISUAL="$EDITOR"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# カスタムコマンド
xstart() {
  local workspace project

  workspace=( *.xcworkspace(N) )
  project=( *.xcodeproj(N) )

  if (( ${#workspace[@]} > 0 )); then
    open "$workspace[1]"
  elif (( ${#project[@]} > 0 )); then
    open "$project[1]"
  else
    echo "❌ No Xcode project found"
    return 1
  fi
}