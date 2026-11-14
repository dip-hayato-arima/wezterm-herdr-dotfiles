-- 言語機能（構文ハイライト・補完・定義ジャンプ・エラー表示・整形）
return {
  -- 構文ハイライト（Tree-sitter）
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local langs = {
        "lua", "vim", "vimdoc", "bash", "json", "yaml", "toml",
        "javascript", "typescript", "tsx", "html", "css",
        "markdown", "markdown_inline", "mermaid", "prisma",
        "dockerfile", "terraform", "hcl", "sql", "diff", "gitcommit",
      }
      require("nvim-treesitter").install(langs)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- 言語サーバーのインストーラ（:Mason で一覧を開ける）
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls", "ts_ls", "eslint", "jsonls", "yamlls",
        "html", "cssls", "prismals", "marksman", "bashls", "terraformls",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })
      vim.diagnostic.config({ virtual_text = true, severity_sort = true, float = { border = "rounded" } })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(l, r, d) vim.keymap.set("n", l, r, { buffer = ev.buf, desc = d }) end
          map("gd", vim.lsp.buf.definition, "定義へジャンプ")
          map("gr", "<cmd>Telescope lsp_references<cr>", "参照一覧")
          map("K", vim.lsp.buf.hover, "型・ドキュメント表示")
          map("<F2>", vim.lsp.buf.rename, "名前の変更")
          map("<leader>ca", vim.lsp.buf.code_action, "クイックフィックス")
          map("<leader>cd", vim.diagnostic.open_float, "この行のエラー詳細")
        end,
      })
    end,
  },

  -- 入力補完
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "enter" },  -- Enter で確定、Tab / Shift+Tab で候補移動
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },

  -- 保存時の自動整形（プロジェクトの prettier / eslint 設定を使う）
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      { "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end, desc = "整形" },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" }, typescript = { "prettier" },
        javascriptreact = { "prettier" }, typescriptreact = { "prettier" },
        json = { "prettier" }, yaml = { "prettier" }, css = { "prettier" },
        html = { "prettier" }, markdown = { "prettier" },
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
    },
  },
}
