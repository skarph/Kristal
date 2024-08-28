local jsonb    = require 'json-beautify'
local util     = require 'utility'

print("BUILDING CUSTOM DOCS!")
print('ok?', ws and vm and guide and getDesc and getLabel and jsonb and util and markdown and true)

export.makeDocObject['type'] = function(source, obj, has_seen)
    if export.makeDocObject['variable'](source, obj, has_seen) == false then
        return false
    end
    obj.fields = {}
    vm.getSimpleClassFields(ws.rootUri, source, vm.ANY, function (next_source, mark, discardParentFields)
        if discardParentFields then return nil end

        if next_source.type == 'doc.field'
        or next_source.type == 'setfield'
        or next_source.type == 'setmethod'
        or next_source.type == 'tableindex'
        then
            table.insert(obj.fields, export.documentObject(next_source, has_seen))
        end
    end)
    table.sort(obj.fields, export.sortDoc)
end

export.serializeAndExport = function (docs, outputDir)
    local jsonPath = outputDir .. '/doc.json'

    --export to json
    local old_jsonb_supportSparseArray = jsonb.supportSparseArray
    jsonb.supportSparseArray = true
    local jsonOk, jsonErr = util.saveFile(jsonPath, jsonb.beautify(docs))
    jsonb.supportSparseArray = old_jsonb_supportSparseArray

    --error checking save file
    if( not (jsonOk) ) then
        return false, {jsonPath}, {jsonErr}
    end

    return true, {jsonPath}
end

--[[local old_init = export.makeDocObject['INIT']
export.makeDocObject['INIT'] = function(source, has_seen)
    local result = old_init(source, has_seen)
    result.snoopingas = true --inejectionsar wtest :)))
    return result
end]]

--[[
function export.gatherGlobals(context)
    local all_globals = vm.getAllGlobals()
    local globals = {}
    for _, g in pairs(all_globals) do
        local guri = guide.getUri(g)
        print(guri)
        if not (guri:find(METAPATH)) then
            table.insert(globals, g)
        else
            print("not", guri)
        end
    end
    return globals
end
--]]
--[[
---Add config settings to JSON output.
---@param results table
local function makeMetadata(results)
    return {META = {
        blaclist = export.blacklist,
        commit = getCommit(fs.absolute(fs.path(DOC)):string()),
        count = #results,
        format = 'LuaLS | skarphtest',
        root = fs.absolute(fs.path(DOC)):string(),
        time = "KEEP_SHA"--os.time(os.date("!*t")),
    }}
end

"docScriptPath": "/luadoc_meta/.buildDocs.lua"

]]