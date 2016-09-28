--An empty table for solving multiple kicking problem(thanks to @topkecleon )
kicktable = {}


local function run(msg, matches)
    if is_momod(msg) then
        return msg
    end
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
            if data[tostring(msg.to.id)]['settings']['lock_video'] then
                lock_video = data[tostring(msg.to.id)]['settings']['lock_video']
            end
        end
    end
    local chat = get_receiver(msg)
    local user = "user#id"..msg.from.id
    if lock_video == "🔒" then
        delete_msg(msg.id, ok_cb, true)
    end
end
 
return {
  patterns = {
  "%[(video)%]"
 },
  run = run
}
