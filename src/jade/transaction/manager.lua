local M = {}

local Transaction = require("jade.transaction")

function M.run(driver, fn)
    local tx = Transaction.new(driver)
    tx:start()

    local ok, err = pcall(fn, tx)

    if ok then
        tx:commit()
        return true
    else
        tx:rollback()
        error(err)
    end
end

return M
