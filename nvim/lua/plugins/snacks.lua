-- Foreground of the Normal highlight, used as the stroke color for drawings.
local function ink_fg()
  local fg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
  if not fg then
    return vim.o.background == "light" and "#000000" or "#ffffff"
  end
  return string.format("#%06x", fg)
end

return {
  {
    "folke/snacks.nvim",
    -- snacks is already pulled in by claudecode.nvim; this spec just enables
    -- the inline-image module. lazy.nvim merges opts for the same plugin.
    lazy = false,
    priority = 1000,
    opts = {
      image = {
        enabled = true,
        -- Render images inline in markdown/files and on hover. Requires a
        -- terminal with a graphics protocol (kitty here) + ImageMagick.
        doc = {
          enabled = true,
          inline = true,
          float = true,
        },
        -- Obsidian links (e.g. Ink drawings) are relative to the vault root,
        -- not the note's folder. Fall back to the nearest dir with .obsidian/.
        resolve = function(file, src)
          if src:find("^%w%w+://") or src:sub(1, 1) == "/" then
            return nil
          end
          local vault = vim.fs.root(file, ".obsidian")
          if vault and vim.uv.fs_stat(vault .. "/" .. src) then
            return vault .. "/" .. src
          end
        end,
        -- Ink strokes are black on transparent; recolor them to the theme's
        -- foreground and keep the transparency so the editor bg shows through.
        convert = {
          magick = {
            vector = function()
              return {
                "-background", "none", "-density", 192, "{src}[{page}]",
                "-colorspace", "sRGB", "-channel", "RGB", "-fill", ink_fg(), "-colorize", 100, "+channel",
              }
            end,
          },
        },
      },
    },
    init = function()
      -- Converted PNGs are cached by source path only, so key the cache dir on
      -- the stroke color: switching themes then re-renders instead of reusing.
      vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        callback = function()
          Snacks.image.config.cache = vim.fn.stdpath("cache") .. "/snacks/image/" .. ink_fg():sub(2)
        end,
      })
    end,
  },
}
