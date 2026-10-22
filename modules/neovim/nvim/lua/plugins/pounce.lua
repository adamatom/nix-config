return {
  {
    'rlane/pounce.nvim',
    config = function()
      local pounce = require('pounce')
      local map = vim.keymap.set

      pounce.setup({
        -- Hop searched within the current window, so keep pounce scoped there.
        multi_window = false,
      })

      map({ 'n', 'x', 'o' }, 's', function()
        pounce.pounce()
      end, { desc = 'Pounce' })
    end,
  }
}
