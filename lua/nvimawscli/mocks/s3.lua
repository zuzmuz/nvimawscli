
---
local M = {}

---
function M.list_buckets(on_result)
    on_result(vim.json.encode {'bucket1', 'bucket2'}, nil)
end

function M.list_bucket_objects(bucket_name, on_result)
    on_result(vim.json.encode {
        NextToken = 'whhhahahahah',
        Contents = {
            { Key = 'lessons/first/hi.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'lessons/first/bye.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'lessons/second/hi.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'lessons/second/bye.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'lessons/second/welcome.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'lessons/second/back.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/first/hi.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/first/bye.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/first/again.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/second/hi.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/second/bye.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/second/last_time.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/third/hi.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/third/bye.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'album_art/third/lie.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'xml/first/hi.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'xml/first/bye.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'xml/first/beautiful.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'xml/first/world.png', Size = '0', LastModiefied = 'Yesterday' },
            { Key = 'xml/first/it_was_nice.png', Size = '0', LastModiefied = 'Yesterday' },
        }
    }, nil)
end

return M
