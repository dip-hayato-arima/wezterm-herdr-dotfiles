-- =============================================================================
-- WezTerm Configuration
-- =============================================================================
-- Installed at: ~/.config/wezterm/wezterm.lua
--
-- 前半: ghostty/config と同じ見た目・操作（各項目の上に対応する Ghostty の設定を書いた）
-- 後半: WezTerm にしか無い機能
--   4. 余白を少し広げる（Window の項）
--   2. 配色テーマを一覧から選んで切り替える（Ctrl+Cmd+T）
--   5. 上の帯の右側に配色名・バッテリー・日時を出す
--   6. タブ名にアイコンと Herdr のセッション名を出す
--   7. 起動時に Herdr のセッションを一覧から選ぶ／Ctrl+Cmd+S で別のセッションを新しいタブで開く
--      ／Ctrl+Cmd+N で今と同じセッションを新しいウィンドウで開く
-- WezTerm に同じ機能が無い Ghostty の設定は、このファイルの最後にまとめた。
-- =============================================================================

local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()

local HOME = os.getenv 'HOME'
local HERDR = HOME .. '/.local/bin/herdr'
local FONT_SIZE = 15
-- Ghostty: background-opacity = 0.85
local OPACITY = 0.85
local DEFAULT_SCHEME = 'Ghostty Black'

-- =============================================================================
-- Ghostty と同じにする設定
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Shell
-- -----------------------------------------------------------------------------
-- Ghostty: command = /bin/zsh
-- アカウントのログインシェルは bash なので、指定しないと WezTerm は bash を開く。
-- Ghostty と同じく、新しいタブ・ウィンドウ・分割は zsh のログインシェルにする。
config.default_prog = { '/bin/zsh', '-l' }

-- -----------------------------------------------------------------------------
-- Font
-- -----------------------------------------------------------------------------
-- Ghostty: font-family 未指定（JetBrains Mono）/ font-size = 14
-- Ghostty: font-thicken = true -> WezTerm に太らせる設定は無いので、太め（DemiBold）にして、少し大きい 15pt でポップな見た目にしている
config.font = wezterm.font_with_fallback {
  { family = 'JetBrains Mono', weight = 'DemiBold' },
  'Hiragino Sans',
}
config.font_size = FONT_SIZE
-- Ghostty: font-feature = +liga / +calt
config.harfbuzz_features = { 'liga=1', 'calt=1' }
-- 行間は Ghostty と同じ 1.0
config.line_height = 1.0
-- Ghostty は文字サイズを変えてもウィンドウの大きさを変えない
config.adjust_window_size_when_changing_font_size = false

-- -----------------------------------------------------------------------------
-- Colors（Ghostty の配色を「Ghostty Black」という名前の配色テーマにしておく）
-- -----------------------------------------------------------------------------
config.color_schemes = {
  [DEFAULT_SCHEME] = {
    -- Ghostty: background / foreground
    background = '#000000',
    foreground = '#e0e0e0',
    -- Ghostty: cursor-color / cursor-text
    cursor_bg = '#00ff00',
    cursor_fg = '#000000',
    cursor_border = '#00ff00',
    -- Ghostty: selection-background / selection-foreground
    selection_bg = '#3a3a5a',
    selection_fg = '#ffffff',
    -- Ghostty: palette = 0..7
    ansi = {
      '#1a1a1a', '#ff5555', '#50fa7b', '#f1fa8c',
      '#6eb6ff', '#ff79c6', '#8be9fd', '#f8f8f2',
    },
    -- Ghostty: palette = 8..15
    brights = {
      '#6272a4', '#ff6e6e', '#69ff94', '#ffffa5',
      '#89c0ff', '#ff92df', '#a4ffff', '#ffffff',
    },
  },
}
config.color_scheme = DEFAULT_SCHEME

-- Ghostty: bold-is-bright = true
config.bold_brightens_ansi_colors = 'BrightAndBold'

-- -----------------------------------------------------------------------------
-- Cursor
-- -----------------------------------------------------------------------------
-- Ghostty: cursor-style = block / cursor-style-blink = true
config.default_cursor_style = 'BlinkingBlock'
-- Ghostty の点滅（600ms でパッと切り替わる）に合わせる。WezTerm の既定はフェード
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- -----------------------------------------------------------------------------
-- Window
-- -----------------------------------------------------------------------------
-- Ghostty: background-opacity = 0.85 / background-blur-radius = 20
config.window_background_opacity = OPACITY
config.macos_window_background_blur = 20

-- 4. 余白（Ghostty: window-padding-x = 8 / window-padding-y = 8 から少し広げた）
config.window_padding = { left = 16, right = 16, top = 12, bottom = 12 }

-- Ghostty: macos-titlebar-style = transparent
-- 標準のタイトルバーを消し、信号機ボタンを背景と同じ色の帯（タブバー）に入れる
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

local function make_frame(bg)
  return {
    active_titlebar_bg = bg,
    inactive_titlebar_bg = bg,
    font = wezterm.font { family = 'JetBrains Mono', weight = 'DemiBold' },
    font_size = 12,
  }
end
config.window_frame = make_frame '#000000'

-- Ghostty: macos-non-native-fullscreen = true（透過を保つ）
config.native_macos_fullscreen_mode = false

-- Ghostty: macos-option-as-alt = true（左右どちらの Option も Alt として送る）
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Ghostty: unfocused-split-opacity = 0.9（フォーカスの無い分割を少し暗くする）
config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.9 }

-- Ghostty（macOS）は最後のウィンドウを閉じてもアプリを終了しない
config.quit_when_all_windows_are_closed = false

-- Ghostty の既定はベルの音を鳴らさない
config.audible_bell = 'Disabled'

-- -----------------------------------------------------------------------------
-- Scrollback & Mouse
-- -----------------------------------------------------------------------------
-- Ghostty: scrollback-limit = 10000000（Ghostty はバイト数で指定。WezTerm は行数なので 1 万行にする）
config.scrollback_lines = 10000

-- Ghostty: mouse-scroll-multiplier = 2
-- WezTerm に倍率の設定は無い。全画面アプリでホイールを矢印キーに変える量だけ既定の 3 から 2 倍にする
config.alternate_buffer_wheel_scroll_speed = 6

-- Ghostty: mouse-hide-while-typing = true
config.hide_mouse_cursor_when_typing = true

-- Ghostty: copy-on-select = clipboard
-- 選択したらクリップボードへコピー。リンクは Ghostty と同じく Cmd+クリックで開く
config.mouse_bindings = {
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'NONE', action = act.CompleteSelection 'Clipboard' },
  { event = { Up = { streak = 2, button = 'Left' } }, mods = 'NONE', action = act.CompleteSelection 'Clipboard' },
  { event = { Up = { streak = 3, button = 'Left' } }, mods = 'NONE', action = act.CompleteSelection 'Clipboard' },
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'SUPER', action = act.OpenLinkAtMouseCursor },
  { event = { Down = { streak = 1, button = 'Left' } }, mods = 'SUPER', action = act.Nop },
}

-- =============================================================================
-- WezTerm にしか無い機能
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2. 配色テーマの切り替え（Ctrl+Cmd+T で一覧。打ち込むと絞り込める）
-- -----------------------------------------------------------------------------
-- 一覧の先頭に Ghostty と同じ配色と、おすすめを ★ 付きで並べ、その下に内蔵の全テーマ（約 1,000）を並べる。
-- 選んだ配色は WezTerm を終了するまで続く（次に起動すると Ghostty Black に戻る）。
local FAVORITE_SCHEMES = {
  'Tokyo Night',
  'Catppuccin Mocha',
  'Kanagawa (Gogh)',
  'rose-pine',
  'Dracula (Official)',
  'Night Owl (Gogh)',
  'Synthwave (Gogh)',
  'Github Dark (Gogh)',
  'Everforest Dark (Gogh)',
  'Gruvbox Dark (Gogh)',
  'nord',
}

local function scheme_choices()
  local choices = { { id = DEFAULT_SCHEME, label = '★ ' .. DEFAULT_SCHEME .. '（Ghostty と同じ）' } }
  for _, name in ipairs(FAVORITE_SCHEMES) do
    table.insert(choices, { id = name, label = '★ ' .. name })
  end
  local all = {}
  for name in pairs(wezterm.get_builtin_color_schemes()) do
    table.insert(all, name)
  end
  table.sort(all)
  for _, name in ipairs(all) do
    table.insert(choices, { id = name, label = name })
  end
  return choices
end

local function apply_scheme(window, name)
  local overrides = window:get_config_overrides() or {}
  if name == DEFAULT_SCHEME then
    overrides.color_scheme = nil
    overrides.window_frame = nil
  else
    -- 上の帯も、選んだテーマの背景色に合わせる
    local scheme = wezterm.get_builtin_color_schemes()[name] or {}
    overrides.color_scheme = name
    overrides.window_frame = make_frame(scheme.background or '#000000')
  end
  window:set_config_overrides(overrides)
end

local pick_scheme = wezterm.action_callback(function(window, pane)
  window:perform_action(
    act.InputSelector {
      title = '配色テーマ',
      fuzzy = true,
      fuzzy_description = '配色テーマ（打ち込むと絞り込み / Enter で決定 / Esc でやめる）: ',
      choices = scheme_choices(),
      action = wezterm.action_callback(function(win, _, id)
        if id then
          apply_scheme(win, id)
        end
      end),
    },
    pane
  )
end)

-- -----------------------------------------------------------------------------
-- 6. タブ名: アイコン＋Herdr のセッション名（Herdr 以外はコマンド名）
-- -----------------------------------------------------------------------------
-- タブで動いている herdr の引数からセッション名を読む（引数なし = default）
local function herdr_session(pane_id)
  local pane = mux.get_pane(pane_id)
  if not pane then
    return nil
  end
  local info = pane:get_foreground_process_info()
  if not info or not info.argv then
    return nil
  end
  local argv = info.argv
  if not (argv[1] or ''):match 'herdr$' then
    return nil
  end
  for i, arg in ipairs(argv) do
    if arg == '--session' or arg == 'attach' then
      return argv[i + 1]
    end
  end
  return 'default'
end

local function tab_label(tab)
  local pane = tab.active_pane
  local session = herdr_session(pane.pane_id)
  if session then
    return wezterm.nerdfonts.md_layers_triple, session
  end
  local process = (pane.foreground_process_name or ''):match '[^/]+$' or ''
  if process == 'fzf' then
    return wezterm.nerdfonts.md_magnify, 'セッションを選択'
  elseif process == 'nvim' or process == 'vim' then
    return wezterm.nerdfonts.custom_vim, process
  elseif process == 'ssh' then
    return wezterm.nerdfonts.md_server, pane.title
  end
  return wezterm.nerdfonts.md_console, (process ~= '' and process) or pane.title
end

wezterm.on('format-tab-title', function(tab, _, _, cfg, hover, max_width)
  local palette = cfg.resolved_palette
  local icon, label = tab_label(tab)
  local text = string.format(' %s  %s ', icon, label)
  text = wezterm.truncate_right(text, max_width - 1) .. ' '

  local frame_bg = (cfg.window_frame and cfg.window_frame.active_titlebar_bg) or palette.background
  local bg, fg
  if tab.is_active then
    bg, fg = palette.ansi[5], palette.background
  elseif hover then
    bg, fg = palette.ansi[1], palette.foreground
  else
    bg, fg = frame_bg, palette.brights[1]
  end
  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = text },
  }
end)

-- -----------------------------------------------------------------------------
-- 5. 上の帯の右側: 配色名・バッテリー・日時
-- -----------------------------------------------------------------------------
local WEEKDAYS = { '日', '月', '火', '水', '木', '金', '土' }

local function battery_text()
  local info = wezterm.battery_info()[1]
  if not info then
    return nil
  end
  local percent = math.floor(info.state_of_charge * 100 + 0.5)
  local icon
  if info.state == 'Charging' then
    icon = wezterm.nerdfonts.md_battery_charging
  else
    local step = math.floor(percent / 10) * 10
    icon = (step >= 100 and wezterm.nerdfonts.md_battery)
      or wezterm.nerdfonts['md_battery_' .. math.max(step, 10)]
      or wezterm.nerdfonts.md_battery
  end
  return string.format('%s %d%%', icon, percent)
end

wezterm.on('update-status', function(window, _)
  local cfg = window:effective_config()
  local palette = cfg.resolved_palette
  local muted = palette.brights[1]
  local accent = palette.ansi[5]

  local now = os.date '*t'
  local items = {
    { wezterm.nerdfonts.md_palette, cfg.color_scheme or DEFAULT_SCHEME },
  }
  local battery = battery_text()
  if battery then
    table.insert(items, { '', battery })
  end
  table.insert(items, {
    wezterm.nerdfonts.md_calendar,
    string.format('%d/%d(%s)', now.month, now.day, WEEKDAYS[now.wday]),
  })
  table.insert(items, { wezterm.nerdfonts.md_clock_outline, os.date '%H:%M' })

  local cells = {}
  for i, item in ipairs(items) do
    if i > 1 then
      table.insert(cells, { Foreground = { Color = muted } })
      table.insert(cells, { Text = '  │  ' })
    end
    if item[1] ~= '' then
      table.insert(cells, { Foreground = { Color = accent } })
      table.insert(cells, { Text = item[1] .. ' ' })
    end
    table.insert(cells, { Foreground = { Color = palette.foreground } })
    table.insert(cells, { Text = item[2] })
  end
  table.insert(cells, { Text = '   ' })
  window:set_right_status(wezterm.format(cells))
end)

-- -----------------------------------------------------------------------------
-- 7. Herdr のセッションを選ぶ
-- -----------------------------------------------------------------------------
-- 起動時: 最初のウィンドウで herdr-session-picker.sh（fzf の一覧）を開く。
--   選ぶとそのセッションに入る。一覧に無い名前を打てば新しく作る。Esc で既定のセッション。
--   （Ghostty は今まで通り、既定のセッションをそのまま開く）
-- `wezterm start -- <command>` のように起動コマンドが渡されたときは、そちらに従う。
local PICKER = wezterm.config_dir .. '/herdr-session-picker.sh'
-- zsh -lc で herdr を起動する。WezTerm を Herdr のペインの中から起動したときに引き継ぐ
-- HERDR_* があると「入れ子」とみなされて起動しないので、消してから起動する
local HERDR_EXEC = [[unset -m 'HERDR_*'; exec "$0" "$@"]]

wezterm.on('gui-startup', function(cmd)
  local spawn = cmd or {}
  if not spawn.args then
    if #wezterm.glob(PICKER) > 0 then
      spawn.args = { '/bin/zsh', '-l', PICKER }
    else
      spawn.args = { '/bin/zsh', '-lc', HERDR_EXEC, HERDR }
    end
  end
  mux.spawn_window(spawn)
end)

-- セッション名から、herdr を起動する引数を作る（default は引数なし）
local function herdr_args(session)
  local args = { '/bin/zsh', '-lc', HERDR_EXEC, HERDR }
  if session ~= 'default' then
    table.insert(args, '--session')
    table.insert(args, session)
  end
  return args
end

-- Ctrl+Cmd+S: 動いているセッションを一覧から選び、WezTerm の新しいタブで開く
local function herdr_sessions()
  local ok, stdout = wezterm.run_child_process { HERDR, 'session', 'list' }
  local choices = {}
  if not ok then
    return choices
  end
  for line in stdout:gmatch '[^\n]+' do
    local name, status = line:match '^(%S+)%s+(%S+)'
    if name and name ~= 'name' then
      table.insert(choices, { id = name, label = string.format('%-20s %s', name, status) })
    end
  end
  return choices
end

local pick_session = wezterm.action_callback(function(window, pane)
  window:perform_action(
    act.InputSelector {
      title = 'Herdr のセッション',
      fuzzy = true,
      fuzzy_description = '新しいタブで開くセッション（打ち込むと絞り込み / Esc でやめる）: ',
      choices = herdr_sessions(),
      action = wezterm.action_callback(function(win, p, id)
        if id then
          win:perform_action(act.SpawnCommandInNewTab { args = herdr_args(id) }, p)
        end
      end),
    },
    pane
  )
end)

-- Ctrl+Cmd+N: 今のタブと同じ Herdr のセッションに、新しいウィンドウからもう 1 つの画面としてつなぐ。
-- Herdr は画面ごとに別のワークスペース・タブを表示できるので、同じセッションを 2 つの窓で並べて使える。
-- 今のタブが Herdr でないとき（zsh やセッションの一覧のとき）は、新しい窓でセッションの一覧を開く。
local open_session_in_new_window = wezterm.action_callback(function(window, pane)
  local session = herdr_session(pane:pane_id())
  local args
  if session then
    args = herdr_args(session)
  elseif #wezterm.glob(PICKER) > 0 then
    args = { '/bin/zsh', '-l', PICKER }
  else
    args = herdr_args 'default'
  end
  window:perform_action(act.SpawnCommandInNewWindow { args = args }, pane)
end)

-- =============================================================================
-- Keybindings
-- =============================================================================
-- 日本語入力中でも効くよう、文字キーは物理キーの位置で判定する
-- （Ghostty の cmd+KeyT / cmd+Digit1 と同じ考え方）。
-- 記号（+ = [ ] など）は JIS と US で位置が違うので、`mapped:` で入力される文字で判定する。
config.key_map_preference = 'Physical'

-- WezTerm 独自の既定ショートカット（Option+Enter で全画面、Ctrl+- で縮小 など）は
-- Claude Code や他のアプリへの入力を横取りするので全部外し、
-- Ghostty（macOS）の既定と ghostty/config の割り当てだけを下に並べる。
config.disable_default_key_bindings = true

-- Herdr の prefix（Ctrl+B = \x02）に続けて 1 文字送る
local function herdr(key)
  return act.SendString('\x02' .. key)
end

-- Ghostty: increase_font_size:1 / decrease_font_size:1 / reset_font_size
-- WezTerm の既定は 10% ずつ拡大縮小なので、Ghostty と同じ 1pt ずつにする
local function font_size_by(delta)
  return wezterm.action_callback(function(window, _)
    local overrides = window:get_config_overrides() or {}
    if delta == 0 then
      overrides.font_size = nil
    else
      overrides.font_size = (overrides.font_size or FONT_SIZE) + delta
    end
    window:set_config_overrides(overrides)
  end)
end

local keys = {
  -- ---- Claude Code: Shift+Enter で改行（Ghostty: shift+enter=text:\x1b\r）
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },

  -- ---- Herdr: タブ（Ghostty: cmd+KeyT / cmd+KeyW / cmd+shift+KeyW）
  { key = 't', mods = 'SUPER', action = herdr 'c' },
  { key = 'w', mods = 'SUPER', action = herdr 'x' },
  { key = 'w', mods = 'SUPER|SHIFT', action = herdr 'X' },

  -- ---- Herdr: 分割（Ghostty: cmd+KeyD / cmd+shift+KeyD）
  { key = 'd', mods = 'SUPER', action = herdr 'v' },
  { key = 'd', mods = 'SUPER|SHIFT', action = herdr '-' },

  -- ---- Herdr: 新しいワークスペース（Space）を作る（Ctrl+B → Shift+N と同じ）
  { key = 's', mods = 'SUPER|SHIFT', action = herdr 'N' },

  -- ---- Herdr: サイドバーの開閉（Ctrl+B → B と同じ）
  { key = 'b', mods = 'SUPER', action = herdr 'b' },

  -- ---- Herdr: ペインの移動（Ghostty: cmd+alt+KeyH/J/K/L）
  { key = 'h', mods = 'SUPER|ALT', action = herdr 'h' },
  { key = 'j', mods = 'SUPER|ALT', action = herdr 'j' },
  { key = 'k', mods = 'SUPER|ALT', action = herdr 'k' },
  { key = 'l', mods = 'SUPER|ALT', action = herdr 'l' },

  -- ---- Herdr: ペインの移動（Ghostty: cmd+left/down/up/right）
  { key = 'LeftArrow', mods = 'SUPER', action = herdr 'h' },
  { key = 'DownArrow', mods = 'SUPER', action = herdr 'j' },
  { key = 'UpArrow', mods = 'SUPER', action = herdr 'k' },
  { key = 'RightArrow', mods = 'SUPER', action = herdr 'l' },

  -- ---- Herdr: ワークスペース（Space）の移動（Cmd+Shift+↑ = 前、Cmd+Shift+↓ = 次）
  { key = 'UpArrow', mods = 'SUPER|SHIFT', action = herdr 'u' },
  { key = 'DownArrow', mods = 'SUPER|SHIFT', action = herdr 'd' },

  -- ---- WezTerm 自身の分割の移動（Ghostty: cmd+opt+arrows = goto_split）
  { key = 'LeftArrow', mods = 'SUPER|ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'SUPER|ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'SUPER|ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'SUPER|ALT', action = act.ActivatePaneDirection 'Down' },

  -- ---- 文字サイズ（Ghostty: cmd+plus / cmd+minus / cmd+0）
  { key = 'mapped:+', mods = 'SUPER', action = font_size_by(1) },
  { key = 'mapped:+', mods = 'SUPER|SHIFT', action = font_size_by(1) },
  { key = 'mapped:=', mods = 'SUPER', action = font_size_by(1) },
  { key = 'mapped:=', mods = 'SUPER|SHIFT', action = font_size_by(1) },
  { key = '-', mods = 'SUPER', action = font_size_by(-1) },
  { key = '0', mods = 'SUPER', action = font_size_by(0) },

  -- ---- 設定（Ghostty: cmd+shift+comma = reload_config / 既定の cmd+comma = open_config）
  { key = ',', mods = 'SUPER|SHIFT', action = act.ReloadConfiguration },
  {
    key = ',',
    mods = 'SUPER',
    action = wezterm.action_callback(function(_, _)
      wezterm.open_with(wezterm.config_file)
    end),
  },

  -- ---- WezTerm にしか無い機能
  -- 2. 配色テーマを一覧から選ぶ
  { key = 't', mods = 'SUPER|CTRL', action = pick_scheme },
  -- 7. Herdr のセッションを新しいタブで開く
  { key = 's', mods = 'SUPER|CTRL', action = pick_session },
  -- 7. 今と同じ Herdr のセッションを新しいウィンドウで開く
  { key = 'n', mods = 'SUPER|CTRL', action = open_session_in_new_window },

  -- ---- ここから下は Ghostty（macOS）の既定ショートカット
  -- コピー・貼り付け
  { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
  -- 画面とスクロールバックを消す（Ghostty: cmd+k = clear_screen）
  {
    key = 'k',
    mods = 'SUPER',
    action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    },
  },
  -- 検索（Ghostty: cmd+f）
  { key = 'f', mods = 'SUPER', action = act.Search 'CurrentSelectionOrEmptyString' },
  -- コマンドパレット（Ghostty: cmd+shift+p）
  { key = 'p', mods = 'SUPER|SHIFT', action = act.ActivateCommandPalette },
  -- ウィンドウ・アプリ
  { key = 'n', mods = 'SUPER', action = act.SpawnWindow },
  { key = 'q', mods = 'SUPER', action = act.QuitApplication },
  { key = 'h', mods = 'SUPER', action = act.HideApplication },
  { key = 'm', mods = 'SUPER', action = act.Hide },
  -- 全画面（Ghostty: cmd+enter / cmd+ctrl+f）
  { key = 'Enter', mods = 'SUPER', action = act.ToggleFullScreen },
  { key = 'f', mods = 'SUPER|CTRL', action = act.ToggleFullScreen },
  -- WezTerm 自身のタブの移動（Ghostty: cmd+shift+[ / ] / ctrl+tab）
  { key = 'mapped:[', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'mapped:]', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(1) },
  { key = 'mapped:{', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'mapped:}', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  -- WezTerm 自身の分割（Ghostty: cmd+[ / ] / cmd+shift+enter / cmd+ctrl+arrows）
  { key = 'mapped:[', mods = 'SUPER', action = act.ActivatePaneDirection 'Prev' },
  { key = 'mapped:]', mods = 'SUPER', action = act.ActivatePaneDirection 'Next' },
  { key = 'Enter', mods = 'SUPER|SHIFT', action = act.TogglePaneZoomState },
  { key = 'LeftArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'RightArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'UpArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'DownArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Down', 1 } },
  -- スクロール（Ghostty: cmd+home / end / pageup / pagedown）
  { key = 'Home', mods = 'SUPER', action = act.ScrollToTop },
  { key = 'End', mods = 'SUPER', action = act.ScrollToBottom },
  { key = 'PageUp', mods = 'SUPER', action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SUPER', action = act.ScrollByPage(1) },
  -- 行の編集（Ghostty: alt+left / alt+right = 単語移動、cmd+backspace = 行頭まで削除）
  { key = 'LeftArrow', mods = 'ALT', action = act.SendString '\x1bb' },
  { key = 'RightArrow', mods = 'ALT', action = act.SendString '\x1bf' },
  { key = 'Backspace', mods = 'SUPER', action = act.SendString '\x15' },
  -- インスペクタ（Ghostty: cmd+alt+i）
  { key = 'i', mods = 'SUPER|ALT', action = act.ShowDebugOverlay },
}

-- ---- Herdr: タブ N へ移動（Ghostty: cmd+Digit1..9）
for i = 1, 9 do
  table.insert(keys, { key = tostring(i), mods = 'SUPER', action = herdr(tostring(i)) })
end

config.keys = keys

-- -----------------------------------------------------------------------------
-- WezTerm に同じ機能が無いため再現していない Ghostty の設定
-- -----------------------------------------------------------------------------
-- quick terminal（global:ctrl+alt+t で画面の上から降りてくる）
--   WezTerm はアプリの外からのショートカットを受けられない
-- window-save-state = always（ウィンドウの位置・タブを復元）
--   中の作業は Herdr のセッション復元で戻る
-- window-padding-balance / minimum-contrast = 1.1
-- clipboard-paste-protection（危ない貼り付けの確認）
-- clipboard-read = allow（WezTerm は OSC 52 の読み取りに対応していない。書き込みは既定で可）
-- shell-integration-features = cursor,sudo,title
--   WezTerm のシェル統合は ~/.zshrc に書き足す方式なので、ここでは入れていない
-- clipboard-trim-trailing-spaces は WezTerm の既定（行末の空白を除いてコピー）と同じ

return config
