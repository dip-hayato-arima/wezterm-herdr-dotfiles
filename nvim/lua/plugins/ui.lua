-- 見た目まわり（配色・ツリー・タブ・ステータスバー）

-- 配色パレット：Ghostty の純黒背景を活かし、アクセントはネオン系で揃える
local c = {
  black = "#000000",
  tab_off = "#0a0a0f", -- 非アクティブなタブの背景（ほぼ黒）
  tab_on = "#15151f",  -- アクティブなタブの背景
  dim = "#565f89",
  text = "#ffffff",
  blue = "#7aa2f7",
  purple = "#bb9af7",
  pink = "#f7768e",
  green = "#9ece6a",
  yellow = "#e0af68",
  cyan = "#7dcfff",
  orange = "#ff9e64",
}

-- タブの状態ごとの背景（"" = 非アクティブ / _visible = 別ウィンドウで表示中 / _selected = 選択中）
local states = {
  { suffix = "", bg = c.tab_off },
  { suffix = "_visible", bg = c.tab_off },
  { suffix = "_selected", bg = c.tab_on },
}

-- bufferline の色指定を組み立てる（タブ列の背景は NONE にして Ghostty の透過を通す）
local function bufferline_highlights()
  local h = {
    fill = { bg = "NONE" },
    background = { fg = c.dim, bg = c.tab_off },
    buffer_visible = { fg = "#7982a9", bg = c.tab_off },
    buffer_selected = { fg = c.text, bg = c.tab_on, bold = true, italic = false, sp = c.purple },
    tab = { fg = c.dim, bg = c.tab_off },
    tab_selected = { fg = c.black, bg = c.purple, bold = true },
    tab_separator = { fg = c.tab_off, bg = c.tab_off },
    tab_separator_selected = { fg = c.purple, bg = c.purple },
    tab_close = { fg = c.pink, bg = "NONE" },
    indicator_visible = { fg = c.tab_off, bg = c.tab_off },
    indicator_selected = { fg = c.purple, bg = c.tab_on, sp = c.purple },
    offset_separator = { fg = c.dim, bg = "NONE" },
    trunc_marker = { fg = c.dim, bg = "NONE" },
  }

  -- sp は選択中タブの下線の色（指定しないと既定の黒になる）
  for _, s in ipairs(states) do
    local on = s.suffix == "_selected"
    local sp = on and c.purple or nil
    h["numbers" .. s.suffix] = { fg = c.cyan, bg = s.bg, sp = sp }
    h["modified" .. s.suffix] = { fg = c.orange, bg = s.bg, sp = sp }
    h["duplicate" .. s.suffix] = { fg = c.dim, bg = s.bg, italic = true, sp = sp }
    h["close_button" .. s.suffix] = { fg = on and c.pink or c.dim, bg = s.bg, sp = sp }
    h["separator" .. s.suffix] = { fg = on and c.purple or "#1c1c28", bg = s.bg, sp = sp }
    h["pick" .. s.suffix] = { fg = c.pink, bg = s.bg, bold = true, italic = true, sp = sp }
    h["diagnostic" .. s.suffix] = { fg = c.pink, bg = s.bg, sp = sp }
  end

  -- 診断（エラー・警告・情報・ヒント）の色
  local diag = { error = c.pink, warning = c.yellow, info = c.cyan, hint = c.green }
  for kind, color in pairs(diag) do
    for _, s in ipairs(states) do
      local sp = s.suffix == "_selected" and c.purple or nil
      h[kind .. s.suffix] = { fg = color, bg = s.bg, sp = sp }
      h[kind .. "_diagnostic" .. s.suffix] = { fg = color, bg = s.bg, sp = sp }
    end
  end

  return h
end

return {
  -- VSCode 風カラースキーム（背景は透過、グレーの面は深い黒に寄せる）
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      require("vscode").setup({
        transparent = true, -- Normal の背景を NONE にして、Ghostty の背景（純黒・透過）をそのまま見せる
        color_overrides = {
          vscCursorDarkDark = "#0d0d0d", -- カーソル行・ツリーの選択行
          vscPopupBack = "#050505",      -- 補完・ホバーなどのポップアップ
          vscLeftDark = "#050505",
          vscLeftMid = "#151515",
          vscTabCurrent = "#000000",
          vscTabOther = "#0a0a0a",
          vscTabOutside = "#000000",
          vscPopupHighlightGray = "#151515",
          vscSplitDark = "#262626",      -- ウィンドウの区切り線
          vscContext = "#232323",        -- インデントのガイド線
          vscFoldBackground = "#0a121a",
        },
      })
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- ファイルツリー（右側に表示）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    keys = {
      { "<C-b>", "<cmd>Neotree toggle right<cr>", desc = "ファイルツリー表示切替" },
      { "<leader>e", "<cmd>Neotree focus right<cr>", desc = "ファイルツリーにフォーカス" },
    },
    opts = {
      close_if_last_window = true,
      window = { position = "right", width = 35 },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = false, never_show = { ".git", ".DS_Store" } },
        hijack_netrw_behavior = "open_current",
      },
    },
  },

  -- 上部のタブ（開いているファイル）：カラフルに
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- 「EXPLORER」の見出しをアクセント色の帯にする（カラースキーム再読込でも消えないよう都度定義）
      local function explorer_hl()
        vim.api.nvim_set_hl(0, "BufferLineExplorer", { fg = c.black, bg = c.purple, bold = true })
      end
      explorer_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = explorer_hl })

      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or (level:match("warning") and " " or " ")
            return " " .. icon .. count
          end,
          themable = false,          -- vscode.nvim が先に定義した BufferLine* を、こちらの指定で上書きする
          color_icons = true,        -- ファイル種別のアイコンを言語ごとの色で表示
          modified_icon = "●",
          separator_style = "thin",  -- slant は背景透過と相性が悪いので thin
          indicator = { style = "underline" },
          show_buffer_close_icons = true,
          offsets = {
            {
              filetype = "neo-tree",
              text = "  EXPLORER",
              highlight = "BufferLineExplorer",
              text_align = "center",
              separator = true,
            },
          },
        },
        highlights = bufferline_highlights(),
      })
    end,
  },

  -- 下部のステータスバー
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "vscode", globalstatus = true } },
  },

  -- インデントのガイド線
  { "saghen/blink.indent", opts = {} },

  -- キーを押しかけたときに候補を表示（Space を押して待つと一覧が出る）
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "検索" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "コード" },
        { "<leader>m", group = "Markdown" },
      },
    },
  },

  -- 通知・コマンドラインの見た目を整える
  { "j-hui/fidget.nvim", opts = {} },
}
