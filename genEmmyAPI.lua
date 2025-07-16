local time = os.clock()

print("Requiring love_api")

local api = require('love_api')

local function safeDesc(src, prefix)
    prefix = prefix or ""
    return "--- " .. string.gsub(src, "\n", "\n" .. prefix .. "--- ")
end

local function stripNewlines(src)
    return string.gsub(src, "\n", " ")
end

local function genReturns(variant)
    local returns = variant.returns
    local s = ""
    local num = 0
    if returns and #returns > 0 then
        num = #returns
        for i, ret in ipairs(returns) do
            if i == 1 then
                s = ret.type
            else
                s = s .. ', ' .. ret.type
            end
        end
    else
        s = "void"
    end
    return s, num
end

local function genFunction(moduleName, fun, static)
    local code = safeDesc(fun.description) .. "\n"
    local argList = ''

    for vIdx, variant in ipairs(fun.variants) do
        -- args
        local arguments = variant.arguments
        if arguments and #arguments > 0 then
            if vIdx == 1 then
                for argIdx, argument in ipairs(arguments) do
                    if argIdx == 1 then
                        argList = argument.name
                    else
                        argList = argList .. ', ' .. argument.name
                    end

                    local type = argument.type
                    local description = argument.description

                    if (argument.default) then
                        type = type .. "?"
                        description = description .. " (Defaults to " .. argument.default .. ".)"
                    end
                    code = code .. '---@param ' .. argument.name .. ' ' .. type .. ' # ' .. description .. '\n'
                end
            else
                code = code .. '---@overload fun('
                for argIdx, argument in ipairs(arguments) do
                    if argIdx == 1 then
                        code = code .. argument.name .. ':' .. argument.type
                        if (argument.default) then
                            code = code .. '?'
                        end
                    else
                        code = code .. ', '
                        code = code .. argument.name .. ':' .. argument.type
                        if (argument.default) then
                            code = code .. '?'
                        end
                    end
                end
                code = code .. '):' .. genReturns(variant)
                code = code .. '\n'
            end
        end

        if vIdx == 1 then
            local type, num = genReturns(variant)
            if num > 0 then
                code = code .. '---@return ' .. type .. '\n'
            end
        end
    end

    local dot = static and '.' or ':'
    code = code .. "function " .. moduleName .. dot .. fun.name .. "(" .. argList .. ") end\n\n"
    return code
end

local function genType(name, type)
    local code = "---@class " .. type.name
    if type.supertypes then
        code = code .. ' : ' .. table.concat(type.supertypes, ", ")
    end
    code = code .. '\n'
    code = code .. safeDesc(type.description) .. '\n'
    code = code .. 'local ' .. name .. ' = {}\n'
    -- functions
    if type.functions then
        for i, fun in ipairs(type.functions) do
            code = code .. genFunction(name, fun, false)
        end
    end

    return code
end

local function genEnum(enum)
    -- These'll have to actually be aliases, since LOVE isn't going to expose these or anything.

    local code = safeDesc(enum.description) .. '\n'
    code = code .. '---@alias ' .. enum.name .. '\n'
    for i, const in ipairs(enum.constants) do
        code = code .. '---| "' .. const.name .. '" -- ' .. stripNewlines(const.description) .. '\n'
    end
    code = code .. '\n'
    return code
end

local function genModule(name, api)
    print("Generating module " .. name)
    local f = assert(io.open("api/" .. name .. ".lua", 'w'))
    f:write("---@meta\n")
    f:write("---@namespace love\n\n")

    if api.description then
        f:write(safeDesc(api.description) .. '\n')
    end

    f:write(name .. " = {}\n\n")

    -- types
    if api.types then
        for i, type in ipairs(api.types) do
            f:write('--region ' .. type.name .. '\n')
            f:write(genType(type.name, type))
            f:write('--endregion ' .. type.name .. '\n')
        end
    end

    -- enums
    if api.enums then
        for i, enum in ipairs(api.enums) do
            f:write(genEnum(enum))
        end
    end

    -- modules
    if api.modules then
        for i, m in ipairs(api.modules) do
            f:write("---@type " .. name .. '.' .. m.name .. '\n')
            f:write(name .. "." .. m.name .. ' = nil\n\n')
            genModule(name .. '.' .. m.name, m)
        end
    end

    -- functions
    for i, fun in ipairs(api.functions) do
        f:write(genFunction(name, fun, true))
    end

    -- Add newline at the end of the file
    f:close()
end

genModule('love', api)

local completed = os.clock() - time
print("--------")
print('Completed in ' .. (completed * 1000) .. 'ms.')
