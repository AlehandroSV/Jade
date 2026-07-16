local M = {}

function M.compare(current_schema, desired_schema)
    local diff = {
        create_tables = {},
        drop_tables = {},
        add_columns = {},
        drop_columns = {},
        modify_columns = {},
    }

    local current_tables = {}
    for _, tbl in ipairs(current_schema.tables or {}) do
        current_tables[tbl.name] = tbl
    end

    local desired_tables = {}
    for _, tbl in ipairs(desired_schema.tables or {}) do
        desired_tables[tbl.name] = tbl
    end

    -- Find tables to create
    for name, tbl in pairs(desired_tables) do
        if not current_tables[name] then
            diff.create_tables[#diff.create_tables + 1] = tbl
        end
    end

    -- Find tables to drop
    for name, tbl in pairs(current_tables) do
        if not desired_tables[name] then
            diff.drop_tables[#diff.drop_tables + 1] = name
        end
    end

    -- Compare columns in existing tables
    for name, desired_tbl in pairs(desired_tables) do
        local current_tbl = current_tables[name]
        if current_tbl then
            local current_cols = {}
            for _, col in ipairs(current_tbl.columns or {}) do
                current_cols[col.name] = col
            end

            local desired_cols = {}
            for _, col in ipairs(desired_tbl.columns or {}) do
                desired_cols[col.name] = col
            end

            -- Find columns to add
            for col_name, col in pairs(desired_cols) do
                if not current_cols[col_name] then
                    diff.add_columns[#diff.add_columns + 1] = {
                        table = name,
                        column = col,
                    }
                end
            end

            -- Find columns to drop
            for col_name, col in pairs(current_cols) do
                if not desired_cols[col_name] then
                    diff.drop_columns[#diff.drop_columns + 1] = {
                        table = name,
                        column = col_name,
                    }
                end
            end

            -- Find columns to modify
            for col_name, desired_col in pairs(desired_cols) do
                local current_col = current_cols[col_name]
                if current_col then
                    if M.columnChanged(current_col, desired_col) then
                        diff.modify_columns[#diff.modify_columns + 1] = {
                            table = name,
                            column = desired_col,
                        }
                    end
                end
            end
        end
    end

    return diff
end

function M.columnChanged(current, desired)
    return current.type ~= desired.type
        or current.length ~= desired.length
        or current.nullable ~= desired.nullable
        or current.default ~= desired.default
end

function M.isEmpty(diff)
    return #diff.create_tables == 0
        and #diff.drop_tables == 0
        and #diff.add_columns == 0
        and #diff.drop_columns == 0
        and #diff.modify_columns == 0
end

function M.toString(diff)
    local lines = {}

    for _, tbl in ipairs(diff.create_tables) do
        lines[#lines + 1] = "CREATE TABLE " .. tbl.name
    end

    for _, name in ipairs(diff.drop_tables) do
        lines[#lines + 1] = "DROP TABLE " .. name
    end

    for _, change in ipairs(diff.add_columns) do
        lines[#lines + 1] = "ADD COLUMN " .. change.table .. "." .. change.column.name
    end

    for _, change in ipairs(diff.drop_columns) do
        lines[#lines + 1] = "DROP COLUMN " .. change.table .. "." .. change.column
    end

    for _, change in ipairs(diff.modify_columns) do
        lines[#lines + 1] = "MODIFY COLUMN " .. change.table .. "." .. change.column.name
    end

    return table.concat(lines, "\n")
end

return M
