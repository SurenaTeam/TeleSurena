do

local function run(msg, matches)
  if not is_sudo(msg) then
    return "شما دسترسی ارسال فایل به سرور را ندارید\nSudo : @CRUEL"
  end
  local receiver = get_receiver(msg)
  if matches[1] == 'dl' then
    
    local file = matches[3]
    
    if matches[2] == 'sticker' and not matches[4] then
      send_document(receiver, "./media/"..file..".webp", ok_cb, false)
    end
  
    if matches[2] == 'files' then
      local extension = matches[4]
      send_document(receiver, "./media/"..file..'.'..extension, ok_cb, false)
    end
    
    if matches[2] == 'file' then
      send_document(receiver, "./"..file, ok_cb, false)
    end

    if matches[2] == 'manual' and is_admin(msg) then
      local ruta = matches[3]
      local document = matches[4]
      send_document(receiver, "./"..ruta.."/"..document, ok_cb, false)
    end
  
  end
  
  if matches[1] == 'extensions' then
    return 'یافت نشد'
  end
  
  if matches[1] == 'list' and matches[2] == 'files' then
    return 'لیستی یافت نشد'
    --send_document(receiver, "./media/files/files.txt", ok_cb, false)
  end
end

return {
  description = "Kicking ourself (bot) from unmanaged groups.",
  usage = {
    "!list files : Envía un archivo con los nombres de todo lo que se puede enviar",
    "!extensions : Envía un mensaje con las extensiones para cada tipo de archivo permitidas",
    "!dl sticker <nombre del sticker> : Envía ese sticker del servidor",
    "!dl file <nombre del archivo> <extension del archivo> : Envía ese archivo del servidor",
    "!dl plugin <Nombre del plugin> : Envía ese archivo del servidor",
    "!dl manual <Ruta de archivo> <Nombre del plugin> : Envía un archivo desde el directorio TeleSeed",
  },
  patterns = {
  "^(dl) (.*) (.*) (.*)$",
  "^(dl) (.*) (.*)$",
  "^(dl) (.*)$",
  "^(list) (files)$",
  "^(extensions)$"
  },
  run = run
}
end
