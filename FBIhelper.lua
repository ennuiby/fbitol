script_name('FBI Helper')
script_version("0.2")
script_author('Chase_Yanetto')

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local dlstatus = require('moonloader').download_status
local sampev = require 'lib.samp.events'
local check = false
local check1 = false

local color = 0x0C2265

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
	update()
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

function update()
  local fpath = os.getenv('TEMP') .. '\\ftulsupd.json' -- куда будет качаться наш файлик для сравнения версии
  downloadUrlToFile('https://raw.githubusercontent.com/ennuiby/fbitol/master/ftulsupd.json', fpath, function(id, status, p1, p2) -- ссылку на ваш гитхаб где есть строчки которые я ввёл в теме или любой другой сайт
    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
    local f = io.open(fpath, 'r') -- открывает файл
    if f then
      local info = decodeJson(f:read('*a')) -- читает
      updatelink = info.updateurl
      if info and info.latest then
        version = tonumber(info.latest) -- переводит версию в число
        if version > tonumber(thisScript().version) then -- если версия больше чем версия установленная то...
          lua_thread.create(goupdate) -- апдейт
        else -- если меньше, то
          update = false -- не даём обновиться
          sampAddChatMessage(('[Testing]: У вас и так последняя версия! Обновление отменено'), color)
        end
      end
    end
  end
end)
end
--скачивание актуальной версии
function goupdate()
sampAddChatMessage(('[Testing]: Обнаружено обновление. AutoReload может конфликтовать. Обновляюсь...'), color)
sampAddChatMessage(('[Testing]: Текущая версия: '..thisScript().version..". Новая версия: "..version), color)
wait(300)
downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- качает ваш файлик с latest version
  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
  sampAddChatMessage(('[Testing]: Обновление завершено!'), color)
  thisScript():reload()
end
end)
end
