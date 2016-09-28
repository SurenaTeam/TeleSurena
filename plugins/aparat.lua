local function run(msg, matches)
	if matches[1]:lower() == 'آپارات' or matches[1]:lower() == 'اپارات' then
		local url = http.request('http://www.aparat.com/etc/api/videoBySearch/text/'..URL.escape(matches[2]))
		local jdat = json:decode(url)

		local items = jdat.videobysearch
		text = 'نتیجه جستوجو در آپارات: \n'
		for i = 1, #items do
		text = text..'\n'..i..'- '..items[i].title..'  -  تعداد بازدید: '..items[i].visit_cnt..'\n    لینک: aparat.com/v/'..items[i].uid
		end
		text = text..''
		return text
	end
end

return {
   patterns = {
"^(آپارات) (.*)$",
"^(اپارات) (.*)$",
   },
   run = run
}
