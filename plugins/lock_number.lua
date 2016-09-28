local function run(msg, matches)
    if is_momod(msg) then
        return
    end
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
            if data[tostring(msg.to.id)]['settings']['lock_number'] then
                lock_number = data[tostring(msg.to.id)]['settings']['lock_number']
            end
        end
    end
    local chat = get_receiver(msg)
    local user = "user#id"..msg.from.id
    if lock_number == "🔒" then
       delete_msg(msg.id, ok_cb, true)
    end
end

return {
	patterns = {
		"0(.+)$",
		"1(.+)$",
		"2(.+)$",
		"3(.+)$",
		"4(.+)$",
		"5(.+)$",
		"6(.+)$",
		"7(.+)$",
		"8(.+)$",
		"9(.+)$",
		"0$",
		"1$",
		"2$",
		"3$",
		"4$",
		"5$",
		"6$",
		"7$",
		"8$",
		"9$"
	},
	run = run
}

