--This Plugin Writed By @ImanDaneshi
--Full Edit By @Navid_Quick
local function set_bot_photo(msg, success, result)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/bot.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    set_profile_photo(file, ok_cb, false)
    send_large_msg(receiver, 'عکس ربات عوض شد!', ok_cb, false)
    redis:del("bot:photo")
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'لطفا دوباره سعی کنید!', ok_cb, false)
  end
end

--فانکشن افزودن تاریخچه
local function logadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
	local GBan_log = 'GBan_log'
   	if not data[tostring(GBan_log)] then
		data[tostring(GBan_log)] = {}
		save_data(_config.moderation.data, data)
	end
	data[tostring(GBan_log)][tostring(msg.to.id)] = msg.to.peer_id
	save_data(_config.moderation.data, data)
	local text = 'تاریخچه گروه تنظیم شد!'
	reply_msg(msg.id,text,ok_cb,false)
	return
end

--فانکشن حذف تاریخچه
local function logrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	local GBan_log = 'GBan_log'
	if not data[tostring(GBan_log)] then
		data[tostring(GBan_log)] = nil
		save_data(_config.moderation.data, data)
	end
	data[tostring(GBan_log)][tostring(msg.to.id)] = nil
	save_data(_config.moderation.data, data)
	local text = 'تاریخچه گروه حذف شد!'
	reply_msg(msg.id,text,ok_cb,false)
	return
end


local function parsed_url(link)
  local parsed_link = URL.parse(link)
  local parsed_path = URL.parse_path(parsed_link.path)
  return parsed_path[2]
end

local function get_contact_list_callback (cb_extra, success, result)
  local text = " "
  for k,v in pairs(result) do
    if v.print_name and v.id and v.phone then
      text = text..string.gsub(v.print_name ,  "_" , " ").." ["..v.id.."] = "..v.phone.."\n"
    end
  end
  local file = io.open("contact_list.txt", "w")
  file:write(text)
  file:flush()
  file:close()
  send_document("user#id"..cb_extra.target,"contact_list.txt", ok_cb, false)--.txt فرمت
end

local function get_dialog_list_callback(cb_extra, success, result)
  local text = ""
  for k,v in pairsByKeys(result) do
    if v.peer then
      if v.peer.type == "chat" then
        text = text.."گروه{"..v.peer.title.."}["..v.peer.id.."]("..v.peer.members_num..")"
      else
        if v.peer.print_name and v.peer.id then
          text = text.."کاربر{"..v.peer.print_name.."}["..v.peer.id.."]"
        end
        if v.peer.username then
          text = text.."("..v.peer.username..")"
        end
        if v.peer.phone then
          text = text.."'"..v.peer.phone.."'"
        end
      end
    end
    if v.message then
      text = text..'\nآخرین پیام :\nآیدی گروه : '..v.message.id
      if v.message.text then
        text = text .. "\n متن پیام : "..v.message.text
      end
      if v.message.action then
        text = text.."\n"..serpent.block(v.message.action, {comment=false})
      end
      if v.message.from then
        if v.message.from.print_name then
          text = text.."\n از : \n"..string.gsub(v.message.from.print_name, "_"," ").."["..v.message.from.id.."]"
        end
        if v.message.from.username then
          text = text.."( "..v.message.from.username.." )"
        end
        if v.message.from.phone then
          text = text.."' "..v.message.from.phone.." '"
        end
      end
    end
    text = text.."\n\n"
  end
  local file = io.open("dialog_list.txt", "w")
  file:write(text)
  file:flush()
  file:close()
  send_document("user#id"..cb_extra.target,"dialog_list.txt", ok_cb, false)--.txt فرمت
end

local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  return false
end

local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function reload_plugins( )
	plugins = {}
  return load_plugins()
end

local function run(msg,matches)
    local receiver = get_receiver(msg)
    local group = msg.to.id
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if not is_admin1(msg) then
    	return 
    end
    if msg.media then
      	if msg.media.type == 'photo' and redis:get("bot:photo") then
      		if redis:get("bot:photo") == 'waiting' then
        		load_photo(msg.id, set_bot_photo, msg)
      		end
      	end
    end
    if matches[1] == "تنظیم عکس ربات" then
    	redis:set("bot:photo", "waiting")
    	return 'لطفا عکس ربات را ارسال کنید'
    end
    if matches[1] == "خواندن" then
    	if matches[2] == "روشن" then
    		redis:set("bot:markread", "on")
    		return "خواندن روشن شد."
    	end
    	if matches[2] == "خاموش" then
    		redis:del("bot:markread")
    		return "خواندن خاموش شد."
    	end
    	return
    end
    if matches[1] == "ارسال" then
    	local text = "شما یک پیام دریافت کردید از : "..(msg.from.username or msg.from.last_name).."\n\nپیام ارسالی : "..matches[3]
    	send_large_msg("user#id"..matches[2],text)
    	return "پیام شما ارسال شد"
    end
    
    if matches[1] == "بلاک" then
    	if is_admin2(matches[2]) then
    		return "شما نمی توانید ادمین ها را بلاک کنید"
    	end
    	block_user("user#id"..matches[2],ok_cb,false)
    	return "کاربر مورد نظر بلاک شد"
    end
    if matches[1] == "آنبلاک" then
    	unblock_user("user#id"..matches[2],ok_cb,false)
    	return "کاربر آنبلاک شد"
    end
    if matches[1] == "ورود به" then--ورود با لینک
    	local hash = parsed_url(matches[2])
    	import_chat_link(hash,ok_cb,false)
    end
    if matches[1] == "لیست مخاطبین" then
	    if not is_sudo(msg) then-- فقط سودو
    		return
    	end
      get_contact_list(get_contact_list_callback, {target = msg.from.id})
      return "لیست مخاطبین به پیوی شما ارسال شد"
    end
    if matches[1] == "حذف مخاطب" then
	    if not is_sudo(msg) then-- فقط سودو
    		return
    	end
      del_contact("user#id"..matches[2],ok_cb,false)
      return "کاربر "..matches[2].." از لیست مخاطبین حذف شد"
    end
    if matches[1] == "افزودن مخاطب" and is_sudo(msg) then
    phone = matches[2]
    first_name = matches[3]
    last_name = matches[4]
    add_contact(phone, first_name, last_name, ok_cb, false)
   return "کاربری با شماره +"..matches[2].." افزوده شد"
end
 if matches[1] == "ارسال مخاطب" and is_sudo(msg) then
    phone = matches[2]
    first_name = matches[3]
    last_name = matches[4]
    send_contact(get_receiver(msg), phone, first_name, last_name, ok_cb, false)
end
 if matches[1] == "مخاطب من" and is_sudo(msg) then
	if not msg.from.phone then
		return "شرمنده من شماره شما را ندارم"
    end
    phone = msg.from.phone
    first_name = (msg.from.first_name or msg.from.phone)
    last_name = (msg.from.last_name or msg.from.id)
    send_contact(get_receiver(msg), phone, first_name, last_name, ok_cb, false)
end

    if matches[1] == "لیست گفتگو" then
      get_dialog_list(get_dialog_list_callback, {target = msg.from.id})
      return "من لیست گفتگو را به پیوی شمار ارسال کردم"
    end
    if matches[1] == "درباره" then
      user_info("user#id"..matches[2],user_info_callback,{msg=msg})
    end
	if matches[1] == 'آپدیت آیدی' then
		local data = load_data(_config.moderation.data)
		local long_id = data[tostring(msg.to.id)]['long_id']
		if not long_id then
			data[tostring(msg.to.id)]['long_id'] = msg.to.peer_id 
			save_data(_config.moderation.data, data)
			return "آیدی آپدیت شد"
		end
	end
	if matches[1] == 'افزودن تاریخچه' and not matches[2] then
		if is_log_group(msg) then
			return "تاریخچه ای از قبل وجود دارد."
		end
		print("تاریخچه گروه "..msg.to.title.."("..msg.to.id..") افزوده شد.")
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] تاریخچه گروه را افزود.")
		logadd(msg)
	end
	if matches[1] == 'حذف تاریخچه' and not matches[2] then
		if not is_log_group(msg) then
			return "تاریخچه ای وجود ندارد."
		end
		print("تاریخچه گروه "..msg.to.title.."("..msg.to.id..") حذف شد")
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] تاریچه را حذف کرد.")
		logrem(msg)
	end
    return
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^(ارسال) (%d+) (.*)$",
	"^(ورود به) (.*)$",
	"^(انبلاک) (%d+)$",
	"^(بلاک) (%d+)$",
	"^(خواندن) (روشن)$",
	"^(خواندن) (خاموش)$",
	"^(تنظیم عکس ربات)$",
	"^(لیست مخاطبین)$",
	"^(لیست گفتگو)$",
	"^(حذف مخاطب) (%d+)$",
	"^(افزودن مخاطب) (.*) (.*) (.*)$", 
	"^(ارسال مخاطب) (.*) (.*) (.*)$",
	"^(مخاطب من)$",
	"^(راه اندازی مجدد)$",
	"^(آپدیت آیدی)$",
	"^(افزودن تاریخچه)$",
	"^(حذف تاریخچه)$",
	"%[(photo)%]",
  },
  run = run,
  pre_process = pre_process
}
--This Plugin Writed By @ImanDaneshi
--Full Edit By @Navid_Quick
