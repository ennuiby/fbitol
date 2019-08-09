script_name('FBI Helper')
script_version('0.2')
script_author('Chase_Yanetto')

require 'lib.moonloader'

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
	autoupdate("https://raw.githubusercontent.com/ennuiby/fbitol/master/ftulsupd.json", '['..string.upper(thisScript().name)..']: ', "")
	sampRegisterChatCommand('onp', onp)
	sampRegisterChatCommand('mpr', mpr)
	sampRegisterChatCommand('sh', sh)
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

function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((prefix..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end)
  while update ~= false do wait(100) end
end
