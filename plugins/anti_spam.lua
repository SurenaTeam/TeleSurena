--این پلاگین توسط : @ImanDaneshi
--سپاس فراوان از @MohammadArak
kicktable = {}

do

local TIME_CHECK = 2
local function pre_process(msg)
  if msg.service then
    return msg
  end
  if msg.from.id == our_id then
    return msg
  end

  if msg.from.type == 'user' then
    local hash = 'user:'..msg.from.id
    print('Saving user', hash)
    if msg.from.print_name then
      redis:hset(hash, 'print_name', msg.from.print_name)
    end
    if msg.from.first_name then
      redis:hset(hash, 'first_name', msg.from.first_name)
    end
    if msg.from.last_name then
      redis:hset(hash, 'last_name', msg.from.last_name)
    end
  end

  if msg.to.type == 'chat' then
    local hash = 'chat:'..msg.to.id..':users'
    redis:sadd(hash, msg.from.id)
  end

  if msg.to.type == 'channel' then
    local hash = 'channel:'..msg.to.id..':users'
    redis:sadd(hash, msg.from.id)
  end
  
  if msg.to.type == 'user' then
    local hash = 'PM:'..msg.from.id
    redis:sadd(hash, msg.from.id)
  end

  local hash = 'msgs:'..msg.from.id..':'..msg.to.id
  redis:incr(hash)

  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['settings']['flood'] == 'no' then
      return msg
    end
  end

  if msg.from.type == 'user' then
    local hash = 'user:'..msg.from.id..':msgs'
    local msgs = tonumber(redis:get(hash) or 0)
    local data = load_data(_config.moderation.data)
    local NUM_MSG_MAX = 5
    if data[tostring(msg.to.id)] then
      if data[tostring(msg.to.id)]['settings']['flood_msg_max'] then
        NUM_MSG_MAX = tonumber(data[tostring(msg.to.id)]['settings']['flood_msg_max'])
      end
    end
    local max_msg = NUM_MSG_MAX * 1
    if msgs > max_msg then
	  local user = msg.from.id
	  local chat = msg.to.id
	  local whitelist = "whitelist"
	  local is_whitelisted = redis:sismember(whitelist, user)
      if is_momod(msg) then 
        return msg
      end
	  if is_whitelisted == true then
		return msg
	  end
	  local receiver = get_receiver(msg)
	  if msg.to.type == 'user' then
		local max_msg = 7 * 1
		print(msgs)
		if msgs >= max_msg then
			print("Pass2")
			send_large_msg("user#id"..msg.from.id, "یوزر ["..msg.from.id.."] به دلیل اسپم بلاک شد")
			savelog(msg.from.id.." PM", "یوزر ["..msg.from.id.."] به دلیل اسپم بلاک شد")
			block_user("user#id"..msg.from.id,ok_cb,false)
		end
      end
	  if kicktable[user] == true then
		return
	  end
	  delete_msg(msg.id, ok_cb, false)
	  kick_user(user, chat)
	  local username = msg.from.username
	  local print_name = user_print_name(msg.from):gsub("‮", "")
	  local name_log = print_name:gsub("_", "")
	  if msg.to.type == 'chat' or msg.to.type == 'channel' then
		if username then
			savelog(msg.to.id, name_log.." @"..username.." ["..msg.from.id.."] kicked for #spam")
			send_large_msg(receiver , "یوزر @"..username.."["..msg.from.id.."] به دلیل اسپم از گروه اخراج شد")
		else
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked for #spam")
			send_large_msg(receiver , "یوزر "..name_log.."["..msg.from.id.."] به دلیل اسپم از گروه اخراج شد")
		end
	  end

      local gbanspam = 'gban:spam'..msg.from.id
      redis:incr(gbanspam)
      local gbanspam = 'gban:spam'..msg.from.id
      local gbanspamonredis = redis:get(gbanspam)
      if gbanspamonredis then
        if tonumber(gbanspamonredis) ==  4 and not is_owner(msg) then
          banall_user(msg.from.id)
          local gbanspam = 'gban:spam'..msg.from.id
          redis:set(gbanspam, 0)
          if msg.from.username ~= nil then
            username = msg.from.username
		  else 
			username = "---"
          end
          local print_name = user_print_name(msg.from):gsub("‮", "")
		  local name = print_name:gsub("_", "")
          send_large_msg("chat#id"..msg.to.id, "یوزر [ "..name.." ]"..msg.from.id.." به دلیل اسپم بن گلوبالی شد")
		  send_large_msg("channel#id"..msg.to.id, "یوزر [ "..name.." ]"..msg.from.id.." به دلیل اسپم بن گلوبالی شد")
          local GBan_log = 'GBan_log'
		  local GBan_log =  data[tostring(GBan_log)]
		  for k,v in pairs(GBan_log) do
			log_SuperGroup = v
			gban_text = "یوزر [ "..name.." ] ( @"..username.." )"..msg.from.id.." از ( "..msg.to.print_name.." ) [ "..msg.to.id.." ] به دلیل اسپم بن گلوبالی شد"
			send_large_msg(log_SuperGroup, gban_text)
		  end
        end
      end
      kicktable[user] = true
      msg = nil
    end
    redis:setex(hash, TIME_CHECK, msgs+1)
  end
  return msg
end

local function cron()
	kicktable = {}
end

return {
  patterns = {},
  cron = cron,
  pre_process = pre_process
}
end
--این پلاگین توسط : @ImanDaneshi
--سپاس فراوان از @MohammadArak
