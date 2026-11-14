-- Markdown / Mermaid の確認
return {
  -- エディタ内で Markdown を見やすく表示（見出し・表・チェックボックス等）
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "エディタ内表示の切替" },
    },
    opts = {},
  },

  -- ブラウザでプレビュー（Mermaid 図もここで描画される）
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_close = 0   -- 別ファイルに移ってもプレビューを閉じない
      vim.g.mkdp_theme = "dark"
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "ブラウザでプレビュー" },
    },
  },
}
