local function run(msg)
    local data = load_data(_config.moderation.data)
     if data[tostring(msg.to.id)]['settings']['lock_tgservice'] == '🔒' then
        delete_msg(msg.id, ok_cb, true)
        return 
    end
end

return {
patterns = {
      "^!!tgservice (.*)$",
}, 
run = run
}
