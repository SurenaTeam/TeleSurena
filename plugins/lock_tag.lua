local function run(msg, matches)
if msg.to.type == 'channel' then
    if is_owner(msg) then
        return
    end
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
            if data[tostring(msg.to.id)]['settings']['lock_tag'] then
                lock_tag = data[tostring(msg.to.id)]['settings']['lock_tag']
            end
        end
    end
    local chat = get_receiver(msg)
    local user = "user#id"..msg.from.id
    if lock_tag == "🔒" and not is_momod(msg) then
		delete_msg(msg.id,ok_cb,false)
    end
end
end
return {patterns = {
    "#",
}, run = run}
