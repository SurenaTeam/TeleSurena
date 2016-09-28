function reload_plugins( ) 
  plugins = {} 
  load_plugins() 
end 
   function run(msg, matches) 
    if tonumber (msg.from.id) == 239832443 then--expample 198794027  
       if matches[1]:lower() == "افزودن سودو" then 
          table.insert(_config.sudo_users, tonumber(matches[2])) 
      print(matches[2]..' سودو شد') 
     save_config() 
     reload_plugins(true) 
      return matches[2]..' سودو شد' 
   elseif matches[1]:lower() == "حذف سودو" then 
      table.remove(_config.sudo_users, tonumber(matches[2])) 
      print(matches[2]..' از لیست سودو ها حذف شد') 
     save_config() 
     reload_plugins(true) 
      return matches[2]..' از لیست سودو ها حذف شد' 
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
