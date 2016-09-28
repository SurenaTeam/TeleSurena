local function run(msg, matches)
if msg.to.type == 'channel' then
    if is_owner(msg) then
        return
    end
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
            if data[tostring(msg.to.id)]['settings']['lock_link'] then
                lock_link = data[tostring(msg.to.id)]['settings']['lock_link']
            end
        end
    end
    local chat = get_receiver(msg)
    local user = "user#id"..msg.from.id
    if lock_link == "🔒" and not is_momod(msg) then
		delete_msg(msg.id,ok_cb,false)
    end
end
end
return {patterns = {
    "http//:",
    "https://",
    "https://telegram.me",
    "http://telegram.me",
}, run = run}
