-- VSCode ライクな Neovim 設定（左: コード / 右: ファイルツリー）
-- プラグインは lua/plugins/*.lua に用途別に分けている

-- 基本設定 ---------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1        -- 標準のファイラ(netrw)を無効化し neo-tree に任せる
vim.g.loaded_netrwPlugin = 1

-- クリップボード：コピー用ツールが無い Linux（EC2 など）では、ターミナル経由（OSC 52）で
-- 手元のクリップボードへコピーする。貼り付けは Neovim 内のレジスタから行う。mac は従来どおり
if vim.fn.has("mac") == 0 and vim.fn.executable("xclip") == 0
  and vim.fn.executable("xsel") == 0 and vim.fn.executable("wl-copy") == 0 then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52 (copy only)",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

local opt = vim.opt
opt.number = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 5
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true
opt.conceallevel = 2          -- Markdown の装飾記号を隠して見やすくする
opt.fillchars = { eob = " " } -- 行末以降の「~」を消す（透過背景に残って見えるため）

-- プラグインマネージャ lazy.nvim の自動インストール ---------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "plugins" } }, {
  install = { colorscheme = { "vscode" } },
  change_detection = { notify = false },
})

-- 起動時にファイルツリーを右側に開き、フォーカスはコード側に戻す -----------
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- ディレクトリを引数に起動したときは hijack_netrw に任せる
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      return
    end
    vim.cmd("Neotree show right")
  end,
})

-- 便利キーマップ ---------------------------------------------------------
local map = vim.keymap.set
map("n", "<C-s>", "<cmd>w<cr>", { desc = "保存" })
map("i", "<C-s>", "<Esc><cmd>w<cr>a", { desc = "保存" })
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "次のタブ" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "前のタブ" })
map("n", "<leader>w", "<cmd>bdelete<cr>", { desc = "タブを閉じる" })
-- 左右のウィンドウ移動は Cmd+Shift+←/→。Ghostty は ESC[1;10D / ESC[1;10C で送り、herdr も
-- そのまま通す（実測済み）。Neovim はこれを <S-D-Left> / <S-D-Right> として受け取る。
-- 上下は Cmd+Shift+↑/↓ が Ghostty 標準（プロンプトへジャンプ）に取られるため Ctrl+J/K のまま
map("n", "<S-D-Left>", "<C-w>h", { desc = "左のウィンドウへ（Cmd+Shift+←）" })
map("n", "<S-D-Right>", "<C-w>l", { desc = "右のウィンドウへ（Cmd+Shift+→）" })
map("n", "<C-j>", "<C-w>j", { desc = "下のウィンドウへ" })
map("n", "<C-k>", "<C-w>k", { desc = "上のウィンドウへ" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "検索ハイライトを消す" })
map("v", "<", "<gv", { desc = "インデントを減らす" })
map("v", ">", ">gv", { desc = "インデントを増やす" })
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "ターミナルからノーマルモードへ" })
