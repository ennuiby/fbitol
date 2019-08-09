script_name('FBI Helper')
script_version('0.1')
script_author('Chase_Yanetto')

require 'lib.moonloader'

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
    local fpath = os.getenv('TEMP') .. '\\ftulsupd.json'
    downloadUrlToFile('https://raw.githubusercontent.com/ennuiby/fbitol/master/ftulsupd.json', fpath, function(id, status, p1, p2)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            local f = io.open(fpath, 'r')
            if f then
                local info = decodeJson(f:read('*a'))
                updatelink = info.updateurl
                updlist1 = info.updlist
                ttt = updlist1
			    if info and info.latest then
                    if tonumber(thisScript().version) < tonumber(info.latest) then
                        ftext('Обнаружено обновление {0C2265}FBI Helper{ffffff}. Для обновления нажмите кнопку в окошке.')
                        lua_thread.create(goupdate)
                    else
                        print('Обновлений скрипта не обнаружено. Приятной игры.')
                        update = false
				    end
                end
            else
                print("Проверка обновления прошка неуспешно. Запускаю старую версию.")
            end
        elseif status == 64 then
            print("Проверка обновления прошка неуспешно. Запускаю старую версию.")
            update = false
        end
    end)
end


function goupdate()
    ftext('Началось скачивание обновления. Скрипт перезагрузится через пару секунд.', -1)
    wait(300)
    downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23)
        if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
            thisScript():reload()
        elseif status1 == 64 then
            ftext("Скачивание обновления прошло не успешно. Запускаю старую версию")
        end
    end)
end
