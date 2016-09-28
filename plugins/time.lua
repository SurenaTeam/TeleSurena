function run(msg, matches)
local url , res = http.request('http://api.gpmod.ir/time/')
if res ~= 200 then return "No connection" end
local jdat = json:decode(url)
local text = '🤖TeleSurena🤖\n➖➖➖➖➖➖➖➖➖➖➖➖➖\n🕕زمان : '..jdat.FAtime..' \n📅امروز : '..jdat.FAdate..'\n➖➖➖➖➖➖➖➖➖➖➖➖➖\n🕕 '..jdat.ENtime..'\n📅 '..jdat.ENdate.. '\n➖➖➖➖➖➖➖➖➖➖➖➖➖\n📝@TeleSurenaCH📝'
return text
end
return {
  patterns = {
  "^زمان$",
  "^ساعت$"
  }, 
run = run 
}