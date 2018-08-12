function table.find_remove_one(tbl, elem)
    for i, e in ipairs(tbl) do
        if e == elem then 
            table.remove(tbl, i)
            return true
        end
    end
    return false
end

function table.find_index(tbl, elem)
    for i, e in ipairs(tbl) do
        if e == elem then return i end
    end
    return nil
end

function table.clear(tbl)
    for i = 1, #tbl do
        tbl[i] = nil
    end
end

function table.insert_many(tbl, ...)
    for _, v in ipairs({...}) do
        tbl[#tbl + 1] = v
    end
end

function drawHighlight(fixture, body)
    local shape = fixture:getShape()
    if shape:typeOf("CircleShape") then
        local cx, cy = body:getWorldPoints(shape:getPoint())
        love.graphics.circle("line", cx, cy, shape:getRadius())
    elseif shape:typeOf("PolygonShape") then
        love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
    else
        love.graphics.line(body:getWorldPoints(shape:getPoints()))
    end
end
function computeSunkVertices(polygonVertices, yb)
    local vertices = {}
    local x1, y1, x2, y2
    x2 = polygonVertices[#polygonVertices - 1]
    y2 = polygonVertices[#polygonVertices]
    for i=1, #polygonVertices do
        if i % 2 == 1 then
            x1 = x2
            x2 = polygonVertices[i]
        elseif i % 2 == 0 then
            y1 = y2
            y2 = polygonVertices[i]
            if y1 > yb and y2 > yb then
                table.insert_many(vertices, x2, y2)
            elseif y1 < yb and y2 > yb then
                local xb = x1 + (yb - y1) / (y2 - y1) * (x2 - x1)
                table.insert_many(vertices, xb, yb, x2, y2)
            elseif y1 > yb and y2 < yb then
                local xb = x2 + (yb - y2) / (y1 - y2) * (x1 - x2)
                table.insert_many(vertices, xb, yb)
            end
        end
    end
    if #vertices < 6 then return nil end
    return vertices
end

function computeCentroid(vertices)
    local cx, cy = 0, 0
    local area = 0
    local x1, y1, x2, y2
    x2 = vertices[#vertices - 1]
    y2 = vertices[#vertices]
    for i=1, #vertices do
        if i % 2 == 1 then
            x1 = x2
            x2 = vertices[i]
        elseif i % 2 == 0 then
            y1 = y2
            y2 = vertices[i]
            local cross = x1 * y2 - x2 * y1
            cx = cx + (x1 + x2) * cross
            cy = cy + (y1 + y2) * cross
            area = area + cross
        end
    end
    area = area / 2
    cx = cx / (6 * area)
    cy = cy / (6 * area)
    return cx, cy, area
end


