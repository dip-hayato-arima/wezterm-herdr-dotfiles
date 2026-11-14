# WezTerm + Herdr dotfiles

macOS 向けの [WezTerm](https://wezterm.org/) と [Herdr](https://herdr.dev/) の設定です。WezTerm を開くと Herdr のセッションを一覧から選んで入り、Cmd キーのショートカットで Herdr のタブ・分割・ワークスペースを操作します。

もとは Ghostty + Herdr で使っていた設定で、WezTerm でも同じ見た目・操作になるようにそろえています（配色、透過 0.85、ぼかし 20、キー割り当て）。新しいタブ・ウィンドウは zsh のログインシェルで開きます。

## 導入

Homebrew と Git を用意してから、次を実行します。

```sh
git clone https://github.com/dip-hayato-arima/wezterm-herdr-dotfiles.git
cd wezterm-herdr-dotfiles
brew bundle --file=Brewfile
./install.sh
```

WezTerm を再起動してください。`install.sh` は設定をシンボリックリンクで配置します。既存ファイルがあれば、同じディレクトリに `.backup.日時` を付けて退避します。再実行してもリンク済みの設定は変更しません。

## 設定の配置先

| リポジトリ | macOS の配置先 |
| --- | --- |
| `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| `wezterm/herdr-session-picker.sh` | `~/.config/wezterm/herdr-session-picker.sh` |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |

WezTerm からは `~/.local/bin/herdr` を起動します。`install.sh` はその場所に Herdr がなければ、インストール済みの `herdr` へのリンクを作ります。Herdr の設定を変えたら、Herdr の中で Ctrl+B → Shift+R を押すか、`herdr server reload-config` で再読み込みします。

Herdr のセッション、ログ、ソケット、リリース情報は端末ごとの実行データなので管理しません。設定にある `claude` / `codex` との連携を使う場合、それらの CLI は各 Mac に別途入れてください。

## 見た目

| 項目 | 設定 |
| --- | --- |
| 文字 | JetBrains Mono DemiBold 15pt（日本語は Hiragino Sans）。合字あり。行間 1.0 |
| 配色 | 黒背景の「Ghostty Black」。Ctrl+Cmd+T で約 1,000 種類から切り替えられる（WezTerm を終了すると戻る） |
| ウィンドウ | 背景の透過 0.85、ぼかし 20、余白は左右 16・上下 12 |
| タブ名 | アイコンと Herdr のセッション名（Herdr 以外はコマンド名） |
| 上の帯の右側 | 配色テーマ名・バッテリー・日付（曜日）・時刻 |

## ショートカット

### Herdr の操作（Ctrl+B に続けて 1 文字を送る）

| キー | 動き |
| --- | --- |
| Cmd+T | 新しい Herdr のタブ |
| Cmd+W / Cmd+Shift+W | ペインを閉じる / タブを閉じる |
| Cmd+D / Cmd+Shift+D | 左右に分割 / 上下に分割 |
| Cmd+矢印、Cmd+Option+H/J/K/L | 隣のペインへ移動 |
| Cmd+1〜9 | Herdr の N 番目のタブへ |
| Cmd+Shift+S | 新しいワークスペース（Space）を作る |
| Cmd+Shift+↑ / ↓ | 前・次のワークスペースへ移動（`herdr/config.toml` の `[keys]` で割り当て） |
| Cmd+B | サイドバー（Space・Agent の一覧）を開閉 |

### セッション

| キー | 動き |
| --- | --- |
| 起動時 | セッションの一覧が出る。Enter で入る／一覧に無い名前 + Enter で新しく作る／Esc で既定のセッション |
| Ctrl+Cmd+S | 別のセッションを一覧から選び、新しいタブで開く |
| Ctrl+Cmd+N | 今と同じセッションを新しいウィンドウで開く。窓ごとに別のワークスペース・タブを表示できる |

### WezTerm の操作

| キー | 動き |
| --- | --- |
| Cmd+C / Cmd+V | コピー / 貼り付け（選択するだけでもコピー） |
| Cmd+K | 画面と履歴を消す |
| Cmd+F | 検索 |
| Cmd+Shift+P | コマンドパレット |
| Cmd+N | 新しいウィンドウ（zsh） |
| Cmd+Enter、Ctrl+Cmd+F | 全画面 |
| Cmd+Shift+[ / ]、Ctrl+Tab | WezTerm のタブを移動 |
| Cmd+Option+矢印 | WezTerm のペインを移動 |
| Cmd+Ctrl+矢印 | WezTerm のペインの大きさを変える |
| Cmd+＋ / Cmd+− / Cmd+0 | 文字を 1pt 大きく / 小さく / 元に戻す |
| Cmd+, / Cmd+Shift+, | 設定ファイルを開く / 再読み込み |
| Shift+Enter | 改行を送る（Claude Code などで複数行入力） |
| Option+← / → | 単語単位で移動 |
| Cmd+Backspace | 行頭まで消す |

WezTerm 独自の既定ショートカットは、Claude Code などへの入力を横取りしないよう全部外しています。日本語入力中でも効くよう、文字キーは物理キーの位置で判定します。

## この環境で確認したバージョン

- WezTerm 20240203-110809-5046fc22
- Herdr 0.9.3

Homebrew は導入時に利用可能な版を入れるため、上記の版に固定はしていません。

## 参照

- [WezTerm の設定](https://wezterm.org/config/files.html)
- [Herdr の設定](https://herdr.dev/docs/configuration/)
- [Herdr の導入](https://herdr.dev/docs/install/)
