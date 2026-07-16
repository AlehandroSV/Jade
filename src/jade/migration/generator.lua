local M = {}

function M.generateCreateTable(table_name, columns)
    local lines = {}
    lines[#lines + 1] = '    Jade.createTable("' .. table_name .. '", {'

    for name, col in pairs(columns) do
        local parts = {}
        parts[#parts + 1] = '        ' .. name .. ' = Jade.' .. col.type .. '()'

        if col._primary_key then
            parts[#parts + 1] = ':primaryKey()'
        end
        if col._unique then
            parts[#parts + 1] = ':unique()'
        end
        if not col._nullable then
            parts[#parts + 1] = ':notNull()'
        end
        if col._default ~= nil and col._default ~= "CURRENT_TIMESTAMP" then
            parts[#parts + 1] = ':default(' .. tostring(col._default) .. ')'
        elseif col._default == "CURRENT_TIMESTAMP" then
            parts[#parts + 1] = ':defaultNow()'
        end
        if col.length and col.type == "string" then
            -- Length is already in the constructor
        end

        lines[#lines + 1] = table.concat(parts)
    end

    lines[#lines + 1] = "    })"

    return table.concat(lines, "\n")
end

function M.generateDropTable(table_name)
    return '    Jade.dropTable("' .. table_name .. '")'
end

function M.generateAddColumn(table_name, column_name, column)
    local type_str = column.type
    if column.length then
        type_str = type_str .. "(" .. column.length .. ")"
    end

    local parts = {}
    parts[#parts + 1] = '    Jade.addColumn("' .. table_name .. '", "' .. column_name .. '", Jade.' .. column.type
    if column.length then
        parts[#parts + 1] = "(" .. column.length .. ")"
    end
    parts[#parts + 1] = '())'

    return table.concat(parts)
end

function M.generateDropColumn(table_name, column_name)
    return '    Jade.dropColumn("' .. table_name .. '", "' .. column_name .. '")'
end

function M.generateMigration(name, diff)
    local up_lines = {}
    local down_lines = {}

    -- Create tables
    for _, tbl in ipairs(diff.create_tables) do
        up_lines[#up_lines + 1] = M.generateCreateTable(tbl.name, tbl.columns)
        down_lines[#down_lines + 1] = M.generateDropTable(tbl.name)
    end

    -- Drop tables
    for _, table_name in ipairs(diff.drop_tables) do
        up_lines[#up_lines + 1] = M.generateDropTable(table_name)
        -- Note: we can't easily reverse this without knowing the schema
        down_lines[#down_lines + 1] = '-- TODO: recreate table ' .. table_name
    end

    -- Add columns
    for _, change in ipairs(diff.add_columns) do
        up_lines[#up_lines + 1] = M.generateAddColumn(change.table, change.column.name, change.column)
        down_lines[#down_lines + 1] = M.generateDropColumn(change.table, change.column.name)
    end

    -- Drop columns
    for _, change in ipairs(diff.drop_columns) do
        up_lines[#up_lines + 1] = M.generateDropColumn(change.table, change.column)
        -- Note: we can't easily reverse this without knowing the column definition
        down_lines[#down_lines + 1] = '-- TODO: recreate column ' .. change.table .. '.' .. change.column
    end

    -- Modify columns (simplified - just drop and re-add)
    for _, change in ipairs(diff.modify_columns) do
        up_lines[#up_lines + 1] = '-- TODO: modify column ' .. change.table .. '.' .. change.column.name
        down_lines[#down_lines + 1] = '-- TODO: modify column ' .. change.table .. '.' .. change.column.name
    end

    local up_content = table.concat(up_lines, "\n\n")
    local down_content = table.concat(down_lines, "\n\n")

    return up_content, down_content
end

return M
