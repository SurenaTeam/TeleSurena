local function reload_plugins()
  plugins = {}
  load_plugins()
end
function is_botowner(msg)
  local var = false
  local admins = {232006008,239832443}
  for k,v in pairs(admins) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end
local function is_sudouser( id )
  for k,v in pairs(_config.sudo_users) do
    if id == v then
      return k
    end
  end
 -- If not found
  return false
  end
local function run(msg, matches)
  if is_botowner(msg) then
    local user = tonumber(matches[2])
    if is_sudouser(user) then
      return "Already is Sudo"
    else
      if matches[1]:lower() == "افزودن سودو" then
        table.insert(_config.sudo_users, user)
        print(matches[2]..' سودو شد!')
        save_config()
        reload_plugins(true)
        return matches[2]..' سودو شد!'
      elseif matches[1]:lower() == "حذف سودو" then
        table.remove(_config.sudo_users, user)
        print(matches[2]..' از لیست سودو ها حذف شد!')
        save_config()
        reload_plugins(true)
        return matches[2]..' از لیست سودو ها حذف شد!'
      end
    end
  end
end
return {
patterns = {
"^(افزودن سودو) (%d+)$",
"^(حذف سودو) (%d+)$"
  },
  run = run
}
