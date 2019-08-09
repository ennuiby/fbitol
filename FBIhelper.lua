script_name('FBI Helper')
script_version('0.2')
script_author('Chase_Yanetto')

require 'lib.moonloader'
local copas = require "copas"
local chttp = require "copas.http"

local dlstatus = require('moonloader').download_status
local sampev = require 'lib.samp.events'
local check = false
local check1 = false

local nick = ''

ctag = " FBI Tools {ffffff}| "

function ftext(message)
    sampAddChatMessage(ctag..message, 0x0C2265)
end

function sampev.onServerMessage(color, text)
	if check then
		if color == -65366 and text:find('%[Телефон%] .+: .+') then
			local nick, text = text:match('%[Телефон%]%s(.*):%s(.*)')
			lua_thread.create(function()
				wait(100)
				sampSendChat('/r [Прослушка телефона]: "'..text..'"')
			end)
		end
	end
	if check1 then
		if text:find('%- .+: .+') then
		local nick1, text = text:match('%- (.+): (.+)')
			if nick == nick1 then
				lua_thread.create(function()
					wait(400)
					sampSendChat("/r [Мини-передатчик]: "..text.."")
				end)
			end
		end
	end
end

function main()
    while not isSampAvailable() do wait(0) end
	sampRegisterChatCommand('onp', onp)
	sampRegisterChatCommand('mpr', mpr)
	sampRegisterChatCommand('sh', sh)
	updateScript()
	wait(-1)
end

function mpr(pam)
    pID = tonumber(pam)
	if check1 then
		if pID ~= nil then
			if sampIsPlayerConnected(pID) then
				nick = sampGetPlayerNickname(pID)
				ftext('Новый ник записан в буфер обмена скрипта.')
			else
				ftext('Игрок не подключен к серверу.')
			end
		else
			ftext("Используйте: /mpr [ID]", -1)
			return
		end
	else
		ftext('Вы не активировали мини-передатчик: /onp 1')
    end
end

function onp(pam)
	if pam == "" or pam < "0" and pam ~= "1" or pam == nil then
        ftext("Введите: /onp [Тип]", -1)
        ftext("0 - Выключить автопрослушку. 1 - Включить автопрослушку.", -1)
		check = false
		check1 = false
	elseif pam == "0" then
		check = false
		check1 = false
		ftext("Вы выключили автопрослушку.", -1)
	elseif pam == "1" then
		check = true
		check1 = true
		ftext("Вы включили автопрослушку.")
	else
		ftext("Вы ввели неверный тип.")
		check = false
		check1 = false
	end
end

function sh(pam)
    if #pam ~= 0 then
        sampSendChat(string.format('/r [Мини-передатчик]: *шепотом* %s ', pam))
    else
        ftext('Введите /sh [текст]')
		ftext('Текст шепотом: /sh [Текст]')
    end
end

function updateScript()
	httpRequest("https://raw.githubusercontent.com/ennuiby/fbitol/master/ftulsupd.json", nil, function(response)
		if response ~= nil then
			response = decodeJson(response)
			if response["version"] ~= nil and response["url"] ~= nil then
				if response["version"] ~= thisScript().version then
					sampAddChatMessage("New script version found!", 0xFFFFFF)
					sampAddChatMessage("Current version: "..thisScript().version, 0xFFFFFF)
					sampAddChatMessage("New version: "..response["version"], 0xFFFFFF)
					sampAddChatMessage("Start updating...", 0xFFFFFF)
					httpRequest(response["url"], nil, function(downloadedFile, err)
						if downloadedFile ~= nil then
							lua_thread.create(function()
								local pathToNewVersion = thisScript().directory.."/"..thisScript().name.."_"..reposponse["version"]..".lua";
								local file = io.open(pathToNewVersion, "w")
								if file ~= nil then
									file:write(downloadedFile)
									file:close()
									
									sampAddChatMessage("New version downloaded to: "..pathToNewVersion, 0xFFFFFF)
								else
									sampAddChatMessage("Cannot edit script!", 0xFFFFFF)
								
									enabled = true
								end
							end)
						else
							sampAddChatMessage("Script updating error: "..err, 0xFFFFFF)
							
							enabled = true
						end
					end)
				else
					enabled = true
				end
			else
				enabled = true
			end
		else
			enabled = true
		end
	end)
end

function switchCopasStatus()
    if not copas.running then
        copas.running = true
        lua_thread.create(function()
            wait(0)
            while not copas.finished() do
                local ok, err = copas.step(0)
                if ok == nil then error(err) end
                wait(0)
            end
            copas.running = false
        end)
    end
end

function httpRequest(request, body, handler) -- Author: FYP
	switchCopasStatus()
    if handler then
        return copas.addthread(function(r, b, h)
            copas.setErrorHandler(function(err) h(nil, err) end)
            h(chttp.request(r, b))
        end, request, body, handler)
    else
        local results
        local thread = copas.addthread(function(r, b)
            copas.setErrorHandler(function(err) results = {nil, err} end)
            results = table.pack(chttp.request(r, b))
        end, request, body)
        while coroutine.status(thread) ~= 'dead' do wait(0) end
        return table.unpack(results)
    end
end

function char_to_hex(str) --Author: ShuffleBoy
  return string.format("%%%02X", string.byte(str))
end

function url_encode(str) --Author: ShuffleBoy
  local str = string.gsub(str, "\\", "\\")
  local str = string.gsub(str, "([^%w])", char_to_hex)
  return str
end

function http_build_query(query) --Author: ShuffleBoy
  local buff=""
  for k, v in pairs(query) do
    buff = buff.. string.format("%s=%s&", k, url_encode(v))
  end
  local buff = string.reverse(string.gsub(string.reverse(buff), "&", "", 1))
  return buff
end

function dump(o) -- From internet
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function search(search_table, search_column, search_value) --Поиск в таблице заданного значения в заданном столбце
	for key, value in ipairs(search_table) do
		if value[search_column] == search_value then
			return key;
		end
	end
					
	return nil
end
