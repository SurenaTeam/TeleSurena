--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "ابتدا من را در گروه مدیر کنید")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		            lock_arabic = '🔐',
		  lock_link = "🔒",
          flood = '🔒',
		  lock_spam = '🔒',
		  lock_sticker = '🔐',
		  public = '🔐',
		  lock_rtl = '🔐',
		  lock_tgservice = '🔒',
		  lock_contacts = '🔐',
          lock_photo = '🔐',
          lock_fosh = '🔐',
          lock_gif = '🔐',
          lock_chat = '🔐',
          lock_voice = '🔐',
          lock_tag = '🔐',
          lock_username = '🔐',
          lock_video = '🔐',
          lock_number = '🔐',
          lock_file = '🔐',
		  expiretime = 'null',
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
	  local text = 'سوپر گروه افزوده شد'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
	  local text = 'سوپرگروه حذف شد'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="👥 اطلاعات سوپرگروه : ["..result.title.."]\n\n"
local admin_num = "👤 تعداد مدیران : "..result.admins_count.."\n"
local user_num = "🗣 تعداد افراد : "..result.participants_count.."\n"
local kicked_num = "❌ تعداد افراد اخراج شده : "..result.kicked_count.."\n"
local channel_id = "🆔 آیدی سوپرگروه : "..result.peer_id.."\n"
if result.username then
	channel_username = "🔢 یوزرنیم : @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num..channel_id..channel_username
    send_large_msg(cb_extra.receiver, text)
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "🗣 افراد :  "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "🚫 افراد اخراج شده سوپرگروه : "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == '🔒' then
    return '🔒 لینک قفل شده بود 🔒'
  else
    data[tostring(target)]['settings']['lock_link'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 لینک قفل شد 🔒'
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == '🔐' then
    return '🔐 لینک باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_link'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 لینک باز شد 🔐'
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return "🚫 فقط صاحب و ... 🚫"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == '🔒' then
    return '🔒 اسپم قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_spam'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 اسپم قفل شد 🔒'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_unlock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_unlock == '🔐' then
    return '🔐 اسپم باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_spam'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 اسپم باز شد 🔐'
  end
end

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == '🔒' then
    return '🔐 فلود قفل بود 🔐'
  else
    data[tostring(target)]['settings']['flood'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 فلود قفل شد 🔒'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_unlock = data[tostring(target)]['settings']['flood']
  if group_flood_unlock == '🔐' then
    return '🔐 فلود باز بود 🔐'
  else
    data[tostring(target)]['settings']['flood'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 فلود باز شد 🔐'
  end
end

local function lock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_video_lock = data[tostring(target)]['settings']['lock_video']
  if group_video_lock == '🔒' then
    return '🔒 فیلم قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_video'] = '🔒'
    save_data(_config.moderation.data, data)
    return ' 🔒 فیلم قفل شد 🔒'
  end
end

 local function unlock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_video_unlock = data[tostring(target)]['settings']['lock_video']
  if group_video_unlock == '🔐' then
    return '🔐 فیلم باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_video'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 فیلم باز شد 🔐'
  end
end

local function lock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['lock_number']
  if group_number_lock == '🔒' then
    return '🔒 اعداد قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_number'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 اعداد قفل شد 🔒'
  end
end

 local function unlock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_unlock = data[tostring(target)]['settings']['lock_number']
  if group_number_unlock == '🔐' then
    return '🔐 اعداد باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_number'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 اعداد باز شد 🔐'
  end
end

local function lock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['lock_username']
  if group_username_lock == '🔒' then
    return '🔒 یوزرنیم قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_username'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 یوزرنیم قفل شد 🔒'
  end
end

local function unlock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_unlock = data[tostring(target)]['settings']['lock_username']
  if group_username_unlock == '🔐' then
    return '🔐 یوزرنیم باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_username'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 یوزرنیم باز شد  🔐'
  end
end

local function lock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['lock_tag']
  if group_tag_lock == '🔒' then
    return '🔒 تگ قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_tag'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 تگ قفل شد 🔒'  
  end
end

local function unlock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_unlock = data[tostring(target)]['settings']['lock_tag']
  if group_tag_unlock == '🔐' then
    return '🔐 تگ باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_tag'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 تگ باز شد  🔐'
  end
end

local function lock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_gif_lock = data[tostring(target)]['settings']['lock_gif']
  if group_gif_lock == '🔒' then
    return '🔒 گیف قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_gif'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 گیف قفل شد 🔒'
  end
end

  local function unlock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_gif_unlock = data[tostring(target)]['settings']['lock_gif']
  if group_gif_unlock == '🔐' then
    return '🔐 گیف باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_gif'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 گیف باز شد 🔐'
  end
end

local function lock_group_photo(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
  if group_photo_lock == '🔒' then
    return '🔒 عکس قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_photo'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 عکس قفل شد 🔒'
  end	
end

  local function unlock_group_photo(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_photo_unlock = data[tostring(target)]['settings']['lock_photo']
  if group_photo_unlock == '🔐' then
    return '🔐 عکس باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_photo'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 عکس باز شد 🔐'
  end
end

local function lock_group_voice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_voice_lock = data[tostring(target)]['settings']['lock_voice']
  if group_voice_lock == '🔒' then
    return '🔒 صدا (ویس) قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_voice'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 صدا (ویس) قفل شد 🔒'
  end
end
  
  local function unlock_group_voice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_voice_unlock = data[tostring(target)]['settings']['lock_voice']
  if group_voice_unlock == '🔐' then
    return '🔐 صدا (ویس) باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_voice'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 صدا (ویس) باز شد 🔐'
  end
end

local function lock_group_file(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_file_lock = data[tostring(target)]['settings']['lock_file']
  if group_file_lock == '🔒' then
    return '🔒 فایل قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_file'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 فایل قفل شد 🔒'
  end
end
  
  local function unlock_group_file(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_file_unlock = data[tostring(target)]['settings']['lock_file']
  if group_file_unlock == '🔐' then
    return '🔐 فایل باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_file'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 فایل باز شد 🔐'
  end
end

local function lock_group_chat(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_chat_lock = data[tostring(target)]['settings']['lock_chat']
  if group_chat_lock == '🔒' then
    return '🔒 چت قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_chat'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 چت قفل شد 🔒'
  end
end
  
  local function unlock_group_chat(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_chat_unlock = data[tostring(target)]['settings']['lock_chat']
  if group_chat_unlock == '🔐' then
    return '🔐 چت باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_chat'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔒 چت باز شد 🔒'
  end
end

local function lock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['lock_fosh']
  if group_fosh_lock == '🔒' then
    return '🔒 فحش قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_fosh'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 فحش قفل شد 🔒'
  end
end

local function unlock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_unlock = data[tostring(target)]['settings']['lock_fosh']
  if group_fosh_unlock == '🔐' then
    return '🔐 فحش باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_fosh'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 فحش باز شد 🔐'
  end
end

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == '🔒' then
    return '🔒 ورود و خروج قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 ورود و خروج قفل شد 🔒'
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_unlock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_unlock == '🔐' then
    return '🔐 ورود و خروج باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 ورود و خروج باز شد 🔐'
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == '🔒' then
    return '🔒 استیکر قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_sticker'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔐 استیکر قفل شد 🔐'
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_unlock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_unlock == '🔐' then
    return '🔐 استیکر باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_sticker'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 استیکر باز شد 🔐'
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == '🔒' then
    return '🔒 مخاطبین قفل بود 🔒'
  else
    data[tostring(target)]['settings']['lock_contacts'] = '🔒'
    save_data(_config.moderation.data, data)
    return '🔒 مخاطبین قفل شد 🔒'
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_unlock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_unlock == '🔐' then
    return '🔐 مخاطبین باز بود 🔐'
  else
    data[tostring(target)]['settings']['lock_contacts'] = '🔐'
    save_data(_config.moderation.data, data)
    return '🔐 مخاطبین باز شد 🔐'
  end
end
--End SuperGroup Locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'قوانین جدید ثبت شد'
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'هنوز هیچ قانونی ثبت نشده است'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = group_name..' قوانین :\n\n'..rules:gsub("/n", " ")
  return rules
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return "فقط مخصوص مدیران می باشد"
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'روشن' then
    return 'گروه در حال حاظر عمومی می باشد'
  else
    data[tostring(target)]['settings']['public'] = 'روشن'
    save_data(_config.moderation.data, data)
  end
  return 'گروه عمومی شد'
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'خاموش' then
    return 'گروه در حال حاظر عمومی نمی باشد'
  else
    data[tostring(target)]['settings']['public'] = 'خاموش'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    return 'گروه شخصی شد'
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = '🔐'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = '🔐'
		end
end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = '🔐'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_photo'] then
			data[tostring(target)]['settings']['lock_photo'] = '🔐'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_file'] then
			data[tostring(target)]['settings']['lock_file'] = '🔐'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_chat'] then
			data[tostring(target)]['settings']['lock_chat'] = '🔐'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_gif'] then
			data[tostring(target)]['settings']['lock_gif'] = '🔐'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_voice'] then
			data[tostring(target)]['settings']['lock_voice'] = '🔐'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_video'] then
			data[tostring(target)]['settings']['lock_video'] = '🔐'
		end
end
if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_fosh'] then
			data[tostring(target)]['settings']['lock_fosh'] = '🔐'
		end
end
 
 local Expiretime = "نامشخص"
    local now = tonumber(os.time())
    local rrredis = redis:hget ('expiretime', get_receiver(msg))
    if redis:hget ('expiretime', get_receiver(msg)) then
    
    Expiretime = math.floor((tonumber(rrredis) - tonumber(now)) / 86400) + 1
    end
	
  local settings = data[tostring(target)]['settings']
  local text = "⚙تنظیمات سوپرگروه⚙\n➖➖➖➖➖➖➖➖➖\n🖥 تنظیمات رسانه 🖥\n🏝 قفل گیف : "..settings.lock_gif.."\n🖼 قفل عکس : "..settings.lock_photo.."\n🎥 قفل فیلم : "..settings.lock_video.."\n🗣 قفل صدا (ویس) : "..settings.lock_voice.." \n🗂 قفل فایل : "..settings.lock_file.."\n➖➖➖➖➖➖➖➖➖\n👥 تنظیمات چت 👥\n🚫 قفل اسپم : "..settings.lock_spam.."\n🚫 حساسیت اسپم : "..NUM_MSG_MAX.."\n🚫 قفل حساسیت اسپم : "..settings.flood.."\n🤐 قفل چت : "..settings.lock_chat.."\n👥 قفل مخاطبین : "..settings.lock_contacts.."\n🔢 قفل اعداد : "..settings.lock_number.."\n🔞 قفل فحش : "..settings.lock_fosh.."\n📱 قفل ورود و خروج : "..settings.lock_tgservice.."\n➖➖➖➖➖➖➖➖➖\n👥 تنظیمات تبلیغات 👥\n⛓ قفل لینک : "..settings.lock_link.."\n⛓ قفل یوزرنیم : "..settings.lock_username.."\n⛓ قفل تگ : "..settings.lock_tag.."\n➖➖➖➖➖➖➖➖➖\n⏱مدت زمان گروه : "..Expiretime
  return text
end

local function set_expiretime(msg, data, target)
      if not is_sudo(msg) then
        return "شما ادمین ربات نیستید!"
      end
  local data_cat = 'expire'
  data[tostring(target)][data_cat] = expired
  save_data(_config.moderation.data, data)
  return 'تاریخ انقضای گروه به '..expired..' ست شد'
end

local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' در حال حاظر یک مدیر می باشد')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' یک مدیر نمی باشد')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, 'سوپرگروه اضافه نشده است')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' در حال حاظر یک مدیر می باشد')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' مدیر شد')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'گروه اضافه نشده است')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' یک مدیر نمی باشد')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' از مدیریت حذف شد')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'سوپرگروه اضافه نشده است'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return 'مدیری در گروه وجود ندارد'
  end
  local i = 1
  local message = '\nلیست مدیران گروه ' .. string.gsub(msg.to.print_name, '_', ' ') .. ' :\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "شما نمی توانید مدیران و سودو را اخراج کنید")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمی توانید مدیران دیگر را اخراج نمایید")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "شما نمی توانید مدیران و سودو را اخراج کنید")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمی توانید بقیه مدیران را اخراج کنید")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "setadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." مدیر شد"
		else
			text = "[ "..user_id.." ] مدیر شد"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "demoteadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "شما نمی توانید مدیران را بن گلوبالی کنید")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." از مدیریت برکنار شد"
		else
			text = "[ "..user_id.." ] از مدیریت برکنار شد"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] مدیر اصلی گروه شد"
			else
				text = "[ "..result.from.peer_id.." ] مدیر اصلی گروه شد"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "["..user_id.."] از لیست افراد بی صدا حذف شد")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] به لیست افراد بی صدا اضافه شد")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
		else
			text = "[ "..result.peer_id.." ] has been set as an admin"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "شما نمی توانید مدیران جهانی را حذف کنید")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." از مدیریت برکنار شد"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] از مدیریت برکنار شد"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "demoteadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "شما نمی توانید مدیر های جهانی را برکنار کنید")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." از مدیریت برکنار شد"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." از مدیریت برکنار شد"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] از لیست افراد بی صدا حذف شد")
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] به لیست افراد بی صدا اضافه شد")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'یوزر @'..member..' در این سوپرگروه نیست'
  else
    text = 'یوزر ['..memberid..'] در این سوپرگروه نیست'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "شما نمی توانید مدیران را اخراج کنید")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "شما نمی توانید بقیه مدیران را اخراج کنید")
      end
      if v.username then
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "setadmin" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] مدیر شد"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] مدیر شد"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = member_username.." ["..v.peer_id.."] مدیر اصلی گروه شد"
				else
					text = "["..v.peer_id.."] مدیر اصلی گروه شد"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
				text = "["..memberid.."] مدیر اصلی شد"
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'تصویر ذخیره شد', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'خطا لطفا مجددا سعی نمایید', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1] == 'تبدیل به سوپرگروه' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1] == 'تبدیل به سوپرگروه' then
			if not is_admin1(msg) then
				return
			end
			return "اینجا در حال حاظر یک سوپرگروه می باشد"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == 'افزودن گروه' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, 'این سوپرگروه در حال حاظر به لیست گروه های مدیریتی ربات اضافه شده است', ok_cb, false)
			end
			print("سوپرگروه "..msg.to.print_name.."("..msg.to.id..") اضافه شد")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1] == 'حذف گروه' and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
				return reply_msg(msg.id, 'سوپرگروه اضافه نشده است', ok_cb, false)
			end
			print("سوپرگروه "..msg.to.print_name.."("..msg.to.id..") از لیست سوپرگروهای مدیریتی ربات حذف شد")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "اطلاعات" then
			if not is_owner(msg) then
				return
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "لیست ادمین ها" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "صاحب گروه" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "مدیر اصلی وجود ندارد لطفا با سودو صحبت کنید"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			return "مدیر اصلی سوپرگروه : ["..group_owner..']'
		end

		if matches[1] == "لیست مدیران" then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "لیست ربات" and is_momod(msg) then
			member_type = 'Bots'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "who" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "لیست اخراج" and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'حذف' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == 'بلاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'بلاک' and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local	get_cmd = 'channel_block'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif msg.text:match("@[%a%d]") then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'ایدی' then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				return "🤖TeleSurena🤖\n➖➖➖➖➖➖➖➖➖➖➖\n👤درباره شما👤\n📝نام شما : " ..string.gsub(msg.from.print_name, "_", " ").. "\n📝ایدی شما : "..msg.from.id.."\n📝یوزرنیم شما : @"..(msg.from.username or '----').."\n➖➖➖➖➖➖➖➖➖➖➖\n👥درباره گروه👥\n📝نام سوپرگروه : " ..string.gsub(msg.to.print_name, "_", " ").. "\n📝ایدی سوپر گروه : "..msg.to.id.."\n➖➖➖➖➖➖➖➖➖➖➖\n📝@TeleSurenaCH📝"
            end
		end

		if matches[1] == 'خروج' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == 'ساخت لینک' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, '*خطا در دریافت لینک\nدلیل :  ساخته نشدن گروه توسط ربات\nلطفا لینک را ذخیره نمایید')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "لینک جدیدی ایجاد شد")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'تنظیم لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			return 'لطفا لینک جدید را برای ذخیره ارسال نمایید'
		end

		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return "لینک جدید ذخیره شد"
			end
		end

		if matches[1] == 'لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				return "ابتدا لینک جدیدی ایجاد یا ذخیره کنید"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			return "لینک گروه :\n"..group_link
		end

		if matches[1] == "دعوت" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'مشخصات' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'اخراج' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1] == 'افزودن مدیر گروه' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setadmin',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'افزودن مدیر گروه' and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'setadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local	get_cmd = 'setadmin'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'افزودن مدیر گروه' and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'setadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local	get_cmd = 'setadmin'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'حذف مدیر گروه' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'حذف مدیر گروه' and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'حذف مدیر گروه' and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'تنظیم صاحب گروه' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'تنظیم صاحب گروه' and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local	get_cmd = 'setowner'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'تنظیم صاحب گروه' and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'افزودن مدیر' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "فقط مدیران می توانند شخصی را مدیر کنند"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'افزودن مدیر' and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'افزودن مدیر' and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "اره"
		end
		if matches[1] == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "اره"
		end

		if matches[1] == 'حذف مدیر' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "فقط مدیران می توانند مدیری را اضافه کنند"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'حذف مدیر' and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "تنظیم نام" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "تنظیم درباره" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "درباره سوپرگروه ثبت شد"
		end

		if matches[1] == "تنظیم یوزرنیم" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "یوزرنیم سوپرگروه ذخیره شد")
				elseif success == 0 then
					send_large_msg(receiver, "خطا در تغییر یوزرنیم سوپرگروه\nیوزرنیم تکراری می باشد یا قابل تغییر نمی باشد")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		if matches[1]:lower() == 'تنظیم گروه نامحدود' and not matches[3] then
	local hash = 'usecommands:'..msg.from.id..':'..msg.to.id
    redis:incr(hash)
        expired = 'Unlimited'
        local target = msg.to.id
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group expire time to [unlimited]")
        return set_expiretime(msg, data, target)
    end
	if matches[1]:lower() == 'تنظیم مدت زمان' then
	local hash = 'usecommands:'..msg.from.id..':'..msg.to.id
    redis:incr(hash)
	  if tonumber(matches[2]) < 95 or tonumber(matches[2]) > 96 then
        return "اولین match باید بین 95 تا 96 باشد"
      end
	  if tonumber(matches[3]) < 01 or tonumber(matches[3]) > 12 then
        return "دومین match باید بین 01 تا 12 باشد"
      end
	  if tonumber(matches[4]) < 01 or tonumber(matches[4]) > 31 then
        return "سومین match باید بین 01 تا 31 باشد"
      end
	  
        expired = matches[2]..'.'..matches[3]..'.'..matches[4]
        local target = msg.to.id
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group expire time to ["..matches[2]/matches[3]/matches[4].."]")
        return set_expiretime(msg, data, target)
    end
	
		if matches[1] == 'تنظیم قوانین' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'تنظیم عکس' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return 'حالا لطفا عکس جدید سوپرگروه را ارسال نمایید'
		end

		if matches[1] == 'پاک کردن' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return "فقط مدیر اصلی می تواند تمام افراد را حذف کند"
			end
			if matches[2] == 'لیست مدیران' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return 'مدیری در این سوپرگروه وجود ندارد'
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return 'لیست مدیران حذف شد'
			end
			if matches[2] == 'قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return "قوانین ذخیره نشده است "
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return 'قوانین حذف شد'
			end
			if matches[2] == 'درباره' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return 'درباره ثبت نشده است'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return "درباره حذف شد"
			end
			if matches[2] == 'سایلنت' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return "لیست افراد بی صدا حذف شد"
			end
			if matches[2] == 'یوزرنیم' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "یوزرنیم سوپرگروه حذف شد")
					elseif success == 0 then
						send_large_msg(receiver, "خطا در حذف یوزرنیم سوپرگروه")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
		end
		
		if matches[1] == 'قفل' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'فروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fwd posting")
				return lock_group_fwd(msg, data, target)
			end
			if matches[2] == 'ریپلی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked reply posting")
				return lock_group_reply(msg, data, target)
			end
			if matches[2] == 'فایل' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked file posting ")
				return lock_group_file(msg, data, target)
			end
			if matches[2] == 'صدا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked voice posting ")
				return lock_group_voice(msg, data, target)
			end
			if matches[2] == 'ویس' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked voice posting ")
				return lock_group_voice(msg, data, target)
			end
			if matches[2] == 'فیلم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked video posting ")
				return lock_group_video(msg, data, target)
			end
			if matches[2] == 'گیف' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked gif posting ")
				return lock_group_gif(msg, data, target)
			end
			if matches[2] == 'جی ای اف' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked gif posting ")
				return lock_group_gif(msg, data, target)
			end
			if matches[2] == 'عکس' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked photo posting ")
				return lock_group_photo(msg, data, target)
			end
			if matches[2] == 'چت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked chat posting ")
				return lock_group_chat(msg, data, target)
			end
			if matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fosh posting ")
				return lock_group_fosh(msg, data, target)
			end
			if matches[2] == 'فحاشی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fosh posting ")
				return lock_group_fosh(msg, data, target)
			end
			if matches[2] == 'یوزرنیم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked username posting ")
				return lock_group_username(msg, data, target)
			end
			if matches[2] == '@' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked username posting ")
				return lock_group_username(msg, data, target)
			end
			if matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tag posting ")
				return lock_group_tag(msg, data, target)
			end
			if matches[2] == '#' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tag posting ")
				return lock_group_tag(msg, data, target)
			end
			if matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'اسپمینگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'فلودینگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'حساسیت اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'حساسیت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'ورود و خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tgservice actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'ورودوخروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tgservice actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == 'مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'مخاطبین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'شماره' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked number posting ")
				return lock_group_number(msg, data, target)
			end
			if matches[2] == 'اعداد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked number posting ")
				return lock_group_number(msg, data, target)
			end
			if matches[2] == 'فایل' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked file posting ")
				return lock_group_file(msg, data, target)
			end
		end

		if matches[1] == 'باز کردن' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'فروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fwd posting")
				return unlock_group_fwd(msg, data, target)
			end
			if matches[2] == 'ریپلی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked reply posting")
				return unlock_group_reply(msg, data, target)
			end
			if matches[2] == 'ریپلای' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked reply posting")
				return unlock_group_reply(msg, data, target)
			end
			if matches[2] == 'فایل' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked file posting ")
				return unlock_group_file(msg, data, target)
			end
			if matches[2] == 'صدا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked voice posting ")
				return unlock_group_voice(msg, data, target)
			end
			if matches[2] == 'ویس' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked voice posting ")
				return unlock_group_voice(msg, data, target)
			end
			if matches[2] == 'فیلم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked video posting ")
				return unlock_group_video(msg, data, target)
			end
			if matches[2] == 'گیف' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked gif posting ")
				return unlock_group_gif(msg, data, target)
			end
			if matches[2] == 'جی ای اف' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked gif posting ")
				return unlock_group_gif(msg, data, target)
			end
			if matches[2] == 'عکس' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked photo posting ")
				return unlock_group_photo(msg, data, target)
			end
			if matches[2] == 'چت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked chat posting ")
				return unlock_group_chat(msg, data, target)
			end
			if matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fosh posting ")
				return unlock_group_fosh(msg, data, target)
			end
			if matches[2] == 'فحاشی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fosh posting ")
				return unlock_group_fosh(msg, data, target)
			end
			if matches[2] == 'یوزرنیم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked username posting ")
				return unlock_group_username(msg, data, target)
			end
			if matches[2] == '@' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked username posting ")
				return unlock_group_username(msg, data, target)
			end
			if matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tag posting ")
				return unlock_group_tag(msg, data, target)
			end
			if matches[2] == '#' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tag posting ")
				return unlock_group_tag(msg, data, target)
			end
			if matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'اسپمینگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'فلودینگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'حساسیت اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'حساسیت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'ورود و خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'ورودوخروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'مخاطبین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'شماره' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked number posting ")
				return unlock_group_number(msg, data, target)
			end
			if matches[2] == 'اعداد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked number posting ")
				return unlock_group_number(msg, data, target)
			end
			if matches[2] == 'فایل' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked file posting ")
				return unlock_group_file(msg, data, target)
			end
		end

		if matches[1] == 'تنظیم حساسیت اسپم' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 5 or tonumber(matches[2]) > 20 then
				return "عدد انتخاب شده اشتباه است باید بین 5 تا 20 باشد"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return 'حساسیت اسپم تغییر یافت به : '..matches[2]
		end
		if matches[1] == 'عمومی' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'روشن' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == 'خاموش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == 'سایلنت رسانه' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "صوت بی صدا شد"
				else
					return "بی صدای صوت در سوپرگروه فعال است"
				end
			end
			if matches[2] == 'photo' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "تصویر بی صدا شد"
				else
					return "بی صدای تصاویر در سوپرگروه فعال است"
				end
			end
			if matches[2] == 'video' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "ویدیو بی صدا شد"
				else
					return "بی صدای ویدیو در سوپرگروه فعال است"
				end
			end
			if matches[2] == 'gifs' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "گیف بی صدا شد"
				else
					return "بی صدای گیف در حال حاظر فعال است"
				end
			end
			if matches[2] == 'documents' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "بی صدای اسناد فعال شد"
				else
					return "بی صدای اسناد در حال حاظر فعال است"
				end
			end
			if matches[2] == 'text' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "بی صدای متن فعال شد"
				else
					return "بی صدای متن در حال حاظر فعال است"
				end
			end
			if matches[2] == 'chat' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "چت قفل شد"
				else
					return "چت در حال حاظر قفل می باشد"
				end
			end
		end
		if matches[1] == 'حذف سایلنت رسانه' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "صوت با صدا شد"
				else
					return "صوت در حال حاظر با صدا است"
				end
			end
			if matches[2] == 'photo' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "تصویر با صدا شد"
				else
					return "تصویر در حال حاظر با صدا است"
				end
			end
			if matches[2] == 'video' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "ویدیو با صدا شد"
				else
					return "ویدیو در حال حاظر با صدا است"
				end
			end
			if matches[2] == 'gifs' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "گیف با صدا شد"
				else
					return "گیف در حال حاظر با صدا است"
				end
			end
			if matches[2] == 'documents' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "اسناد با صدا شد"
				else
					return "اسناد در حال حاظر با صدا است"
				end
			end
			if matches[2] == 'text' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return "متن با صدا شد"
				else
					return "متن در حال حاظر با صدا است"
				end
			end
			if matches[2] == 'chat' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "چت باز شد"
				else
					return "چت در حال حاظر باز می باشد"
				end
			end
		end


		if matches[1] == "سایلنت" and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "سایلنت" and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "از لیست افراد بی صدا حذف شد["..user_id.."]"
				elseif is_owner(msg) then
					mute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "به لیست افراد بی صدا اضافه شد["..user_id.."]"
				end
			elseif matches[1] == "سایلنت" and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1] == "لیست سایلنت رسانه" and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1] == "لیست سایلنت" and is_momod(msg) then
			local chat_id = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1] == 'تنظیمات' and is_momod(msg) then
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'قوانین' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1] == 'راهنما' and not is_owner(msg) then
			text = "فقط مخصوص مدیر اصلی می باشد"
			reply_msg(msg.id, text, ok_cb, false)
		end

		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == 'msg.to.peer_id' then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
    "^(افزودن گروه)$",
	"^(حذف گروه)$",
	--"^(move) (.*)$",
	"^(صاحب گروه)$",
	"^(لیست مدیران)$",
    "^(مسدود) (.*)",
	"^(مسدود)",
	"^(تبدیل به سوپرگروه)$",
	"^(ایدی)$",
	"^(ایدی) (.*)$",
	"^(آیدی)$",
	"^(آیدی) (.*)$",
	"^(خروج)$",
	"^(اخراج) (.*)$",
	"^(ساخت لینک)$",
	"^(لینک)$",
	"^(مشخصات) (.*)$",
	"^(افزودن مدیر گروه) (.*)$",
	"^(افزودن مدیر گروه)",
	"^(حذف مدیر گروه) (.*)$",
	"^(حذف مدیر گروه)",
	"^(تنظیم صاحب گروه) (.*)$",
	"^(تنظیم صاحب گروه)$",
	"^(افزودن مدیر) (.*)$",
	"^(افزودن مدیر)",
	"^(حذف مدیر) (.*)$",
	"^(حذف مدیر)",
	"^(تنظیم نام) (.*)$",
	"^(تنظیم قوانین) (.*)$",
	"^(تنظیم عکس)$",
	"^(تنظیم لینک)$",
	"^(حذف)$",
	"^(قفل) (.*)$",
	"^(باز کردن) (.*)$",
	--"^(سایلنت) ([^%s]+)$",
	--"^(حذف سایلنت) ([^%s]+)$",
	"^(لیست سایلنت)$",
	--"^(لیست رسانه های غیر مجاز)$",
	"^(سایلنت)$",
    "^(سایلنت) (.*)$",
	"^(عمومی) (.*)$",
	"^(تنظیمات)$",
	"^(قوانین)$",
	"^(تنظیم حساسیت اسپم) (%d+)$",
	"^(پاک کردن) (.*)$",
	"^(راهنما)$",
	"^(تنظیم گروه نامحدود)$",
    "^(تنظیم مدت زمان گروه) (.*) (.*) (.*)$",
    --"(mp) (.*)",
	--"(md) (.*)",
        "^(https://telegram.me/joinchat/%S+)$",
	"msg.to.peer_id",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
