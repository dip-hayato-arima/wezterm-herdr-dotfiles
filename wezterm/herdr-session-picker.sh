#!/bin/zsh
# WezTerm の起動時に、Herdr のセッションを一覧から選んで開く。
#   Enter                  : 選んだセッションに入る
#   一覧に無い名前 + Enter : その名前で新しいセッションを作る
#   Esc                    : 既定のセッション（Ghostty と同じ）に入る
# fzf が無いときや一覧が取れないときは、既定のセッションをそのまま開く。

herdr="$HOME/.local/bin/herdr"

# WezTerm を Herdr のペインの中から起動すると HERDR_* を引き継ぎ、
# Herdr が「入れ子」とみなして起動しない。この窓は新しい端末なので消しておく。
unset -m 'HERDR_*'
fzf=$(command -v fzf 2>/dev/null)
[ -z "$fzf" ] && [ -x "$HOME/.homebrew/bin/fzf" ] && fzf="$HOME/.homebrew/bin/fzf"
[ -z "$fzf" ] && [ -x /opt/homebrew/bin/fzf ] && fzf=/opt/homebrew/bin/fzf

open_session() {
  if [ "$1" = default ]; then
    "$herdr"
  else
    "$herdr" --session "$1"
  fi
  rc=$?
  if [ $rc -ne 0 ]; then
    printf '\nHerdr を開けませんでした（セッション: %s / 終了コード: %d）。zsh を開きます。\n' "$1" "$rc"
    exec /bin/zsh -l
  fi
  exit 0
}

list=$("$herdr" session list 2>/dev/null | awk 'NR > 1 {
  mark = ($2 == "running") ? "\033[32m●\033[0m" : "\033[90m○\033[0m"
  printf "%s\t%s %s\n", $1, mark, $2
}')

if [ -z "$fzf" ] || [ -z "$list" ]; then
  open_session default
fi

out=$(printf '%s\n' "$list" | "$fzf" \
  --ansi --reverse --no-multi --print-query \
  --delimiter='\t' --tabstop=22 \
  --prompt='herdr session > ' \
  --header=$'Enter: 開く ／ 新しい名前 + Enter: 作る ／ Esc: default\n' \
  --color='dark,bg+:#1a1a1a,hl:#6eb6ff,hl+:#89c0ff,pointer:#00ff00,prompt:#6eb6ff,header:#6272a4,info:#6272a4')
code=$?

query=$(printf '%s\n' "$out" | sed -n 1p)
picked=$(printf '%s\n' "$out" | sed -n 2p | cut -f1)

case $code in
  0) name=$picked ;;
  1) name=$query ;;   # 一覧に無い名前が打たれた
  *) name=default ;;  # Esc など
esac
[ -z "$name" ] && name=default

open_session "$name"
