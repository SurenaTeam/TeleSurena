do

local function create_group(msg)
        -- superuser and admins only (because sudo are always has privilege)
        if is_sudo(msg) or is_realm(msg) and is_admin(msg) then
                local group_creator = msg.from.print_name
                create_group_chat (group_creator, group_name, ok_cb, false)
                return ' گروهی به اسم [ '..string.gsub(group_name, '_', ' ')..' ] ساخته شد'
        end
end

local function create_realm(msg)
        -- superuser and admins only (because sudo are always has privilege)
        if is_sudo(msg) or is_realm(msg) and is_admin(msg) then
                local group_creator = msg.from.print_name
                create_group_chat (group_creator, group_name, ok_cb, false)
                return 'ریلمی به نام [ '..string.gsub(group_name, '_', ' ')..' ] ساخته شد'
        end
end


local function killchat(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.id, result.id)     
  end
end

local function killrealm(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.id, result.id)     
  end
end

local function get_group_type(msg)
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    if not data[tostring(msg.to.id)]['group_type'] then
     return 'گروه هیچ نقشی ندارد'
    end
     local group_type = data[tostring(msg.to.id)]['group_type']
     return group_type
  else 
     return 'نقشی برای گروه پیدا نشد'
  end 
end

local function callbackres(extra, success, result)
--vardump(result)
  local user = result.id
  local name = string.gsub(result.print_name, "_", " ")
  local chat = 'chat#id'..extra.chatid
  send_large_msg(chat, user..'\n'..name)
  return user
end

local function set_description(msg, data, target, about)
    if not is_admin(msg) then
        return "فقط برای ادمین ها !"
    end
    local data_cat = 'description'
        data[tostring(target)][data_cat] = about
        save_data(_config.moderation.data, data)
        return 'توضیحات گروه تغییر یافت به:\n'..about
end
 
local function set_rules(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین ها !"
    end
    local data_cat = 'rules'
        data[tostring(target)][data_cat] = rules
        save_data(_config.moderation.data, data)
        return 'قوانین گروه تغییر یافت به:\n'..rules
end
-- lock/unlock group name. bot automatically change group name when locked
local function lock_group_name(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین ها"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'yes' then
            return 'اسم گروه قفل بود'
        else
            data[tostring(target)]['settings']['lock_name'] = 'yes'
                save_data(_config.moderation.data, data)
                rename_chat('chat#id'..target, group_name_set, ok_cb, false)
        return 'اسم گروه قفل شد'
        end
end
 
local function unlock_group_name(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین ها"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'no' then
            return 'اسم گروه قفل نبود'
        else
            data[tostring(target)]['settings']['lock_name'] = 'no'
            save_data(_config.moderation.data, data)
        return 'اسم گروه آزاد شد'
        end
end
--lock/unlock group member. bot automatically kick new added user when locked
local function lock_group_member(msg, data, target)
    if not is_admin(msg) then
        return "فقط مخصوص ادمین ها"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'yes' then
            return 'ورود اعضا قفل بود'
        else
            data[tostring(target)]['settings']['lock_member'] = 'yes'
            save_data(_config.moderation.data, data)
        end
        return 'ورود اعضا قفل شد'
end
 
local function unlock_group_member(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین ها"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'no' then
            return 'ورود اعضا قفل نیست'
        else
            data[tostring(target)]['settings']['lock_member'] = 'no'
            save_data(_config.moderation.data, data)
        return 'ورود اعضا آزاد شد'
        end
end
 
--lock/unlock group photo. bot automatically keep group photo when locked
local function lock_group_photo(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین ها"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'yes' then
            return 'عکس گروه قفل بود'
        else
            data[tostring(target)]['settings']['set_photo'] = 'waiting'
            save_data(_config.moderation.data, data)
        end
        return 'لطفا عککس جدید را بفرستید'
end
 
local function unlock_group_photo(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'no' then
            return 'عکس گروه قفل نبود'
        else
            data[tostring(target)]['settings']['lock_photo'] = 'no'
            save_data(_config.moderation.data, data)
        return 'عکس گروه آزاد شد'
        end
end
 
local function lock_group_flood(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین ها"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'yes' then
            return 'اسپم در گروه قفل بود'
        else
            data[tostring(target)]['settings']['flood'] = 'yes'
            save_data(_config.moderation.data, data)
        return 'اسپم در گروه قفل شد'
        end
end
 
local function unlock_group_flood(msg, data, target)
    if not is_admin(msg) then
        return "فقط برای ادمین ها"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'no' then
            return 'اسپم در گروه قفل نبود'
        else
            data[tostring(target)]['settings']['flood'] = 'no'
            save_data(_config.moderation.data, data)
        return 'اسپم در گروه آزاد شد'
        end
end
-- show group settings
local function show_group_settings(msg, data, target)
    local data = load_data(_config.moderation.data, data)
    if not is_admin(msg) then
        return "فقط برای ادمین ها"
    end
  local settings = data[tostring(target)]['settings']
  local text = "تنظیمات گروه:\n💡قفل اسم گروه : "..settings.lock_name.."\n💡قفل عکس گروه : "..settings.lock_photo.."\n💡قفل تگ کردن در گروه : "..lock_tag.."\n💡قفل ورود اعضا : "..settings.lock_member.."\n💡قفل انگلیسی .. : "..lock_eng.."\n 💡محروم ترک کنندگان : "..lock_leave.."\n💡قفل فحش دادن : "..lock_badw.."\n💡قفل تبلیغات در گروه : "..lock_link.."\n💡قفل استیکر در گروه : "..lock_sticker.."\n💡حساسیت به اسپم : "..NUM_MSG_MAX.."\n💡حفاظت در برابر ربات ها : "..bots_protection--"\nPublic: "..public
  return text
end

local function returnids(cb_extra, success, result)
 
        local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.id
    local chatname = result.print_name
    local text = 'لیست کاربرای گروهه '..string.gsub(chatname,"_"," ")..' ('..result.id..'):'..'\n'..''
    for k,v in pairs(result.members) do
    	if v.print_name then
        	local username = ""
        	text = text .. "- " .. string.gsub(v.print_name,"_"," ") .. "  (" .. v.id .. ") \n"
        end
    end
    send_large_msg(receiver, text)
        local file = io.open("./groups/lists/"..result.id.."memberlist.txt", "w")
        file:write(text)
        file:flush()
        file:close()
end
 
local function returnidsfile(cb_extra, success, result)
    local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.id
    local chatname = result.print_name
    local text = 'لیست کاربرای گروهه '..string.gsub(chatname,"_"," ")..' ('..result.id..'):'..'\n'..''
    for k,v in pairs(result.members) do
    	if v.print_name then
        	local username = ""
        	text = text .. "- " .. string.gsub(v.print_name,"_"," ") .. "  (" .. v.id .. ") \n"
        end
    end
        local file = io.open("./groups/lists/"..result.id.."memberlist.txt", "w")
        file:write(text)
        file:flush()
        file:close()
        send_document("chat#id"..result.id,"./groups/lists/"..result.id.."memberlist.txt", ok_cb, false)
end
 
local function admin_promote(msg, admin_id)
        if not is_sudo(msg) then
        return "از دسترسی خارج است"
    end
        local admins = 'admins'
        if not data[tostring(admins)] then
                data[tostring(admins)] = {}
                save_data(_config.moderation.data, data)
        end
        if data[tostring(admins)][tostring(admin_id)] then
                return admin_name..' از قبل ادمین بود'
        end
        data[tostring(admins)][tostring(admin_id)] = admin_id
        save_data(_config.moderation.data, data)
        return admin_id..' به عنوان ادمین ارتقا یافت'
end

local function admin_demote(msg, admin_id)
    if not is_sudo(msg) then
        return "خارج از دسترسی!!"
    end
    local data = load_data(_config.moderation.data)
        local admins = 'admins'
        if not data[tostring(admins)] then
                data[tostring(admins)] = {}
                save_data(_config.moderation.data, data)
        end
        if not data[tostring(admins)][tostring(admin_id)] then
                return admin_id..' ادمین نیست'
        end
        data[tostring(admins)][tostring(admin_id)] = nil
        save_data(_config.moderation.data, data)
        return admin_id..' صلب درجه از ادمینی شد.'
end
 
local function admin_list(msg)
    local data = load_data(_config.moderation.data)
        local admins = 'admins'
        if not data[tostring(admins)] then
        data[tostring(admins)] = {}
        save_data(_config.moderation.data, data)
        end
        local message = 'لیست ادمینای ریلم:\n'
        for k,v in pairs(data[tostring(admins)]) do
                message = message .. '- (at)' .. v .. ' [' .. k .. '] ' ..'\n'
        end
        return message
end
 
local function groups_list(msg)
    local data = load_data(_config.moderation.data)
        local groups = 'groups'
        if not data[tostring(groups)] then
                return 'هیچ گروهی وجود نداردt'
        end
        local message = 'لیست گروه ها:\n'
        for k,v in pairs(data[tostring(groups)]) do
                local settings = data[tostring(v)]['settings']
                for m,n in pairs(settings) do
                        if m == 'set_name' then
                                name = n
                        end
                end
                local group_owner = "no link"
                if data[tostring(v)]['set_owner'] then
                        group_owner = tostring(data[tostring(v)]['set_owner'])
                end
                local group_link = "no link"
                if data[tostring(v)]['settings']['set_link'] then
			group_link = data[tostring(v)]['settings']['set_link']
		end

                message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
             
               
        end
        local file = io.open("./groups/lists/groups.txt", "w")
        file:write(message)
        file:flush()
        file:close()
        return message
       
end
local function realms_list(msg)
    local data = load_data(_config.moderation.data)
        local realms = 'realms'
        if not data[tostring(realms)] then
                return 'هیچ ریلمی وجود ندارد'
        end
        local message = 'لیست ریلم ها:\n'
        for k,v in pairs(data[tostring(realms)]) do
                local settings = data[tostring(v)]['settings']
                for m,n in pairs(settings) do
                        if m == 'set_name' then
                                name = n
                        end
                end
                local group_owner = "No owner"
                if data[tostring(v)]['admins_in'] then
                        group_owner = tostring(data[tostring(v)]['admins_in'])
		end
                local group_link = "No link"
                if data[tostring(v)]['settings']['set_link'] then
			group_link = data[tostring(v)]['settings']['set_link']
		end
                message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
        end
        local file = io.open("./groups/lists/realms.txt", "w")
        file:write(message)
        file:flush()
        file:close()
        return message
end
local function admin_user_promote(receiver, member_username, member_id)
        local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
                save_data(_config.moderation.data, data)
        end
        if data['admins'][tostring(member_id)] then
                return send_large_msg(receiver, member_username..' از قبل  ادمین بود')
        end
        data['admins'][tostring(member_id)] = member_username
        save_data(_config.moderation.data, data)
        return send_large_msg(receiver, '@'..member_username..' به عنوان ادمین ارتقا یافت')
end
 
local function admin_user_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
                save_data(_config.moderation.data, data)
        end
        if not data['admins'][tostring(member_id)] then
                return send_large_msg(receiver, member_username..' ادمین نیست')
        end
        data['admins'][tostring(member_id)] = nil
        save_data(_config.moderation.data, data)
        return send_large_msg(receiver, 'ادمینه  '..member_username..' صلب درجه شد')
end

 
local function username_id(cb_extra, success, result)
   local mod_cmd = cb_extra.mod_cmd
   local receiver = cb_extra.receiver
   local member = cb_extra.member
   local text = 'کاربری با ای دی @'..member..' در این گروه وجود ندارد.'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == member then
        member_username = member
        member_id = v.id
        if mod_cmd == 'افزودن مدیر ربات' then
            return admin_user_promote(receiver, member_username, member_id)
        elseif mod_cmd == 'حذف ادمین' then
            return admin_user_demote(receiver, member_username, member_id)
        end
      end
   end
   send_large_msg(receiver, text)
end

local function set_log_group(msg)
  if not is_admin(msg) then
    return 
  end
  local log_group = data[tostring(groups)][tostring(msg.to.id)]['log_group']
  if log_group == 'yes' then
    return 'تاریخچه گروه هم اکنون تنظیم شده است'
  else
    data[tostring(groups)][tostring(msg.to.id)]['log_group'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'تاریخچه گروه تنظیم شد'
  end
end

local function unset_log_group(msg)
  if not is_admin(msg) then
    return 
  end
  local log_group = data[tostring(groups)][tostring(msg.to.id)]['log_group']
  if log_group == 'no' then
    return 'از قبل تاریخچه غیر فعال بود'
  else
    data[tostring(groups)][tostring(msg.to.id)]['log_group'] = 'no'
    save_data(_config.moderation.data, data)
    return 'تاریخچه غیر فعال شد'
  end
end

local function help()
  local help_text = tostring(_config.help_text_realm)
  return help_text
end

function run(msg, matches)
    --vardump(msg)
   	local name_log = user_print_name(msg.from)
       if matches[1] == 'تاریخچه' and is_owner(msg) then
		savelog(msg.to.id, "تاریخچع توسط مدیر ساخته شد")
		send_document("chat#id"..msg.to.id,"./groups/"..msg.to.id.."log.txt", ok_cb, false)
        end

	if matches[1] == 'اعضا' and is_momod(msg) then
		local name = user_print_name(msg.from)
		savelog(msg.to.id, name.." ["..msg.from.id.."] درخواست لیست اعضا را کرد ")
		local receiver = get_receiver(msg)
		chat_info(receiver, returnidsfile, {receiver=receiver})
	end
	if matches[1] == 'لیست اعضا' and is_momod(msg) then
		local name = user_print_name(msg.from)
		savelog(msg.to.id, name.." ["..msg.from.id.."] درخواست لیست اعضا را در فرمت فایل کرد")
		local receiver = get_receiver(msg)
		chat_info(receiver, returnids, {receiver=receiver})
	end

    if matches[1] == 'ساخت گروه' and matches[2] then
        group_name = matches[2]
        group_type = 'group'
        return create_group(msg)
    end
    
    if not is_sudo(msg) or not is_admin(msg) and not is_realm(msg) then
		return  --Do nothing
	end

    if matches[1] == 'ساخت ریلم' and matches[2] then
        group_name = matches[2]
        group_type = 'realm'
        return create_realm(msg)
    end

    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	if matches[2] then if data[tostring(matches[2])] then
		local settings = data[tostring(matches[2])]['settings']
		if matches[1] == 'نصب توضیحات' and matches[2] then
			local target = matches[2]
		    local about = matches[3]
		    return set_description(msg, data, target, about)
		end
		if matches[1] == 'نصب قوانین' then
		    rules = matches[3]
			local target = matches[2]
		    return set_rules(msg, data, target)
		end
		if matches[1] == 'قفل' then --group lock *
			local target = matches[2]
		    if matches[3] == 'اسم' then
		        return lock_group_name(msg, data, target)
		    end
		    if matches[3] == 'ورود' then
		        return lock_group_member(msg, data, target)
		    end
		    if matches[3] == 'عکس' then
		        return lock_group_photo(msg, data, target)
		    end
		    if matches[3] == 'اسپم' then
		        return lock_group_flood(msg, data, target)
		    end
		end
		if matches[1] == 'باز کردن' then --group unlock *
			local target = matches[2]
		    if matches[3] == 'اسم' then
		        return unlock_group_name(msg, data, target)
		    end
		    if matches[3] == 'ورود' then
		        return unlock_group_member(msg, data, target)
		    end
		    if matches[3] == 'عکس' then
		    	return unlock_group_photo(msg, data, target)
		    end
		    if matches[3] == 'اسپم' then
		        return unlock_group_flood(msg, data, target)
		    end
		end
		if matches[1] == 'تنظیمات' and data[tostring(matches[2])]['settings'] then
			local target = matches[2]
		    return show_group_settings(msg, data, target)
		end

                if matches[1] == 'نصب اسم' and is_realm(msg) then
                    local new_name = string.gsub(matches[2], '_', ' ')
                    data[tostring(msg.to.id)]['settings']['set_name'] = new_name
                    save_data(_config.moderation.data, data)
                    local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
                    local to_rename = 'chat#id'..msg.to.id
                    rename_chat(to_rename, group_name_set, ok_cb, false)
                    savelog(msg.to.id, "ریلمه { "..msg.to.print_name.." }  اسمش عوض شد به [ "..new_name.." ] توسط "..name_log.." ["..msg.from.id.."]")
                end
		if matches[1] == 'نصب اسم' and is_admin(msg) then
		    local new_name = string.gsub(matches[3], '_', ' ')
		    data[tostring(matches[2])]['settings']['set_name'] = new_name
		    save_data(_config.moderation.data, data)
		    local group_name_set = data[tostring(matches[2])]['settings']['set_name']
		    local to_rename = 'chat#id'..matches[2]
		    rename_chat(to_rename, group_name_set, ok_cb, false)
                    savelog(msg.to.id, "گروهه { "..msg.to.print_name.." }  اسمش عوض شد به [ "..new_name.." ] توسط "..name_log.." ["..msg.from.id.."]")
		end

	    end 
        end
    	if matches[1] == 'راهنما' and is_realm(msg) then
      		savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /help")
     		return help()
    	end
              if matches[1] == 'تنظیم' then
                if matches[2] == 'تاریخچه گروه' then
                   savelog(msg.to.id, name_log.." ["..msg.from.id.."] تاریخچه را تنظیم کرد")
                  return set_log_group(msg)
                end
              end
                if matches[1] == 'حذف' and matches[2] == 'گروه' then
                  if not is_admin(msg) then
                     return nil
                  end
                  if is_realm(msg) then
                     local receiver = 'chat#id'..matches[3]
                     return modrem(msg),
                     print("در حال بستن گروهه: "..receiver),
                     chat_info(receiver, killchat, {receiver=receiver})
                  else
                     return 'خطا : گروهه '..matches[3]..' پیدا نشد' 
                    end
                 end
                if matches[1] == 'حذف' and matches[2] == 'ریلم' then
                  if not is_admin(msg) then
                     return nil
                  end
                  if is_realm(msg) then
                     local receiver = 'chat#id'..matches[3]
                     return realmrem(msg),
                     print("درحال حذف ریلمه : "..receiver),
                     chat_info(receiver, killrealm, {receiver=receiver})
                  else
                     return 'خطا : ریلمه  '..matches[3]..' پیدا نشد' 
                    end
                 end
		if matches[1] == 'chat_add_user' then
		    if not msg.service then
		        return ""
		    end
		    local user = 'user#id'..msg.action.user.id
		    local chat = 'chat#id'..msg.to.id
		    if not is_admin(msg) then
				chat_del_user(chat, user, ok_cb, true)
			end
		end
		if matches[1] == 'افزودن مدیر ربات' then
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("user "..admin_id.." has been promoted as admin")
				return admin_promote(msg, admin_id)
			else
			local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "افزودن مدیر ربات"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'حذف مدیر ربات' then
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("user "..admin_id.." has been demoted")
				return admin_demote(msg, admin_id)
			else
			local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "حذف مدیر ربات"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'نقش'then
                        local group_type = get_group_type(msg)
			return group_type
		end
		if matches[1] == 'لیست' and matches[2] == 'ادمین ها' then
			return admin_list(msg)
		end
		if matches[1] == 'لیست' and matches[2] == 'گروه ها' then
                  if msg.to.type == 'chat' then
			groups_list(msg)
		        send_document("chat#id"..msg.to.id, "./groups/lists/groups.txt", ok_cb, false)	
			return "لیست گروه ها ساخته شد " --group_list(msg)
                   elseif msg.to.type == 'user' then 
                        groups_list(msg)
		        send_document("user#id"..msg.from.id, "./groups/lists/groups.txt", ok_cb, false)	
			return "لیست گروه ها ساخته شد" --group_list(msg)
                  end
		end
		if matches[1] == 'لیست' and matches[2] == 'ریلم ها' then
                  if msg.to.type == 'chat' then
			realms_list(msg)
		        send_document("chat#id"..msg.to.id, "./groups/lists/realms.txt", ok_cb, false)	
			return "لیست ریلم ها ساخته شد" --realms_list(msg)
                   elseif msg.to.type == 'user' then 
                        realms_list(msg)
		        send_document("user#id"..msg.from.id, "./groups/lists/realms.txt", ok_cb, false)	
			return "لیست ریلم ها ساخته شد" --realms_list(msg)
                  end
		end
   		 if matches[1] == 'درمورد' and is_momod(msg) then 
      			local cbres_extra = {
        			chatid = msg.to.id
     			}
      			local username = matches[2]
      			local username = username:gsub("@","")
      			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /res "..username)
      			return res_user(username,  callbackres, cbres_extra)
    end
end



return {
  patterns = {
    "^(ساخت گروه) (.*)$",
    "^(ساخت ریلم) (.*)$",
    "^(نصب توضیحات) (%d+) (.*)$",
    "^(نصب قوانین) (%d+) (.*)$",
    "^(نصب اسم) (.*)$",
    "^(نصب اسم) (%d+) (.*)$",
    "^(نصب اسم) (%d+) (.*)$",
        "^(قفل) (%d+) (.*)$",
    "^(باز کردن) (%d+) (.*)$",
    "^(تنظیمات) (%d+)$",
        "^(لیست اعضا)$",
        "^(اعضا)$",
        "^(نقش)$",
    "^(حذف) (گروه) (%d+)$",
    "^(حذف) (ریلم) (%d+)$",
    "^(افزودن مدیر ربات) (.*)$", -- sudoers only
    "^(حذف مدیر ربات) (.*)$", -- sudoers only
    "^(لیست) (.*)$",
        "^(تاریخچه)$",
        "^(راهنما)$",
        "^!!tgservice (.+)$", 
  },
  run = run
}
end
