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

local old_export_documentObject = export.documentObject
function export.documentObject(source, has_seen)
    if type(source) == 'table' and source.getSets then
        for _, set in ipairs(source:getSets(ws.rootUri)) do
            local ok, uri = pcall(guide.getUri, set)
            if not ok then
                return nil
            end
            --remove uri root (and prefix)
            local local_file_uri = uri
            local i, j = local_file_uri:find(DOC)
            if not j then
                return nil
            end
        end
    end
    return old_export_documentObject(source, has_seen)
end