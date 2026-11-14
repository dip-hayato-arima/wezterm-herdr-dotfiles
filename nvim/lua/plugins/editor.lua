-- 編集を便利にするもの（検索・Git・ターミナル・括弧補完など）
return {
  -- ファイル名・文字列検索（VSCode の Ctrl+P / Ctrl+Shift+F 相当）
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope find_files hidden=true<cr>", desc = "ファイル検索" },
      { "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", desc = "ファイル検索" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "文字列検索" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "開いているファイル" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近開いたファイル" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = { file_ignore_patterns = { "node_modules/", "%.git/", "dist/", "coverage/" } },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- Git の差分表示
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      on_attach = function(buf)
        local gs = require("gitsigns")
        local map = function(l, r, d) vim.keymap.set("n", l, r, { buffer = buf, desc = d }) end
        map("]h", function() gs.nav_hunk("next") end, "次の変更箇所")
        map("[h", function() gs.nav_hunk("prev") end, "前の変更箇所")
        map("<leader>gp", gs.preview_hunk, "変更内容をプレビュー")
        map("<leader>gr", gs.reset_hunk, "変更を元に戻す")
      end,
    },
  },

  -- lazygit を Neovim 内で開く（lazygit が入っていれば <leader>gg）
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit",
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
  },

  -- 下部に開くターミナル（VSCode の Ctrl+` 相当）
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { { [[<C-\>]], desc = "ターミナル表示切替" } },
    opts = { open_mapping = [[<C-\>]], direction = "horizontal", size = 15 },
  },

  -- 括弧・クォートの自動補完
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- 囲み文字の追加・変更（ys / cs / ds）
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- エラー・警告の一覧（VSCode の「問題」パネル相当）
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = { { "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", desc = "問題の一覧" } },
  },
}
