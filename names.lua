require 'helpers'

-- Reading names

function findFiles(dir, match)
    local files = {}
    local p = io.popen('find "' .. dir .. '" -type f')
    for file in p:lines() do
        if string.match(file, match) then
            table.insert(files, file)
        end
    end
    return files
end

base_dir = 'names'
ext = 'txt'

origin_filenames = findFiles(base_dir, '.' .. ext)
origin_counts = {}
origin_weights = {}

function trimFilename(s)
    return s:split('/')[2]:split('%.')[1]
end

origins = map(origin_filenames, trimFilename)

all_names = {}
all_chars = {}
n_chars = 0
max_count = 1000

for oi = 1, #origins do 
    local origin = origins[oi]
    local origin_names = {}
    local li = 0

    for line in io.lines(base_dir .. '/' .. origin .. '.' .. ext) do
        li = li + 1
        if li > 1 then
            local name = line
            local name_length = 0
            for char in string.gfind(name, "([%z\1-\127\194-\244][\128-\191]*)") do
                if not all_chars[char] then
                    n_chars = n_chars + 1
                    all_chars[char] = n_chars
                end
                name_length = name_length + 1
            end
            if name_length > 1 then
                table.insert(origin_names, {oi, name})
            end
        end
    end

    origin_counts[oi] = li

    if origin_counts[oi] >= max_count then
        for ni = 1, max_count do
            table.insert(all_names, randomChoice(origin_names))
        end
    else
        for ni = 1, origin_counts[oi] do
            table.insert(all_names, origin_names[ni])
        end
        if max_count > origin_counts[oi] then
            for ni = 1, (max_count - origin_counts[oi]) do
                table.insert(all_names, randomChoice(origin_names))
            end
        end
    end
end

for oi = 1, #origins do 
    origin_weights[oi] = (#all_names - origin_counts[oi]) / #all_names
end

all_chars.n_chars = n_chars
torch.save('all_chars.t7', all_chars)
torch.save('origins.t7', origins)

