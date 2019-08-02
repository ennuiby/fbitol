script_name("FBI Tools")
script_authors("Thomas Lawson, Sesh Jefferson, Chase_Yanetto")
script_version(3.3)

require 'lib.moonloader'
require 'lib.sampfuncs'

local lsg, sf               = pcall(require, 'sampfuncs')
local lkey, key             = pcall(require, 'vkeys')
local lsampev, sp           = pcall(require, 'lib.samp.events')
local lsphere, Sphere       = pcall(require, 'Sphere')
local lrkeys, rkeys         = pcall(require, 'rkeys')
local limadd, imadd         = pcall(require, 'imgui_addons')
local bNotf, notf 			= pcall(import, "imgui_notf.lua")
local dlstatus              = require('moonloader').download_status
local limgui, imgui         = pcall(require, 'imgui')
local lrequests, requests   = pcall(require, 'requests')
local wm                    = require 'lib.windows.message'
local gk                    = require 'game.keys'
local encoding              = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local cfg =
{
    main = {
        posX = 1596,
        posY = 916,
        widehud = 320,
        male = true,
        wanted = false,
        clear = false,
        hud = false,
        tar = 'тэг',
        parol = 'пароль',
        parolb = false,
        tarb = false,
        clistb = false,
        spzamen = false,
        clist = 0,
        offptrl = false,
        offwntd = false,
        tchat = false,
        autocar = false,
        strobs = true,
        megaf = true,
        autobp = false
    },
    commands = {
        cput = true,
        ceject = true,
        deject = true,
        ftazer = true,
        zaderjka = 1400,
        ticket = true,
        kmdctime = true
    },
    autobp = {
        deagle = true,
        dvadeagle = true,
        shot = true,
        dvashot = true,
        smg = true,
        dvasmg = true,
        m4 = true,
        dvam4 = true,
        rifle = true,
        dvarifle = true,
        armour = true,
        spec = true
    }
}

if limgui then 
    mainw           = imgui.ImBool(false)
    setwindows      = imgui.ImBool(false)
    shpwindow       = imgui.ImBool(false)
    ykwindow        = imgui.ImBool(false)
    fpwindow        = imgui.ImBool(false)
    akwindow        = imgui.ImBool(false)
    pozivn          = imgui.ImBool(false)
    updwindows      = imgui.ImBool(false)
    bMainWindow     = imgui.ImBool(false)
    bindkey         = imgui.ImBool(false)
    cmdwind         = imgui.ImBool(false)
    memw            = imgui.ImBool(false)
    sInputEdit      = imgui.ImBuffer(256)
    bIsEnterEdit    = imgui.ImBool(false)
    piew            = imgui.ImBool(false)
    imegaf          = imgui.ImBool(false)
    bindname        = imgui.ImBuffer(256)
    bindtext        = imgui.ImBuffer(10240)
end

function ftext(text)
    sampAddChatMessage((' %s | {ffffff}%s'):format(script.this.name, text),0x0C2265)
end

local config_keys = {
    oopda = { v = {key.VK_F12}},
    oopnet = { v = {key.VK_F11}},
    tazerkey = { v = {key.VK_X}},
    fastmenukey = { v = {key.VK_F2}},
    megafkey = { v = {18,77}},
    dkldkey = { v = {18,80}},
    cuffkey = { v = {}},
    followkey = { v = {}},
    cputkey = { v = {}},
    cejectkey = { v = {}},
    takekey = { v = {}},
    arrestkey = { v = {}},
    uncuffkey = { v = {}},
    dejectkey = { v = {}},
    sirenkey = { v = {}}
}

local mcheckb = false
local stazer = false
local rabden = false
local frak = -1
local rang = -1
local wfrac = nil
local warnst = false
local changetextpos = false
local opyatstat = false
local gmegafhandle = nil
local gmegafid = -1
local targetid = -1
local smsid = -1
local smstoid = -1
local mcid = -1
local vixodid = {}
local ooplistt = {}
local tLastKeys = {}
local departament = {}
local radio = {}
local sms = {}
local wanted = {}
local incar = {}
local suz = {}
local show = 1
local autoBP = 1
local checkstat = false
local fileb = getWorkingDirectory() .. "\\config\\fbitools.bind"
local tMembers = {}
local Player = {}
local tBindList = {}
local fthelp = {
    {
        cmd = '/ft',
        desc = 'Открыть меню скрипта',
        use = '/ft'
    },
    {
        cmd = '/st',
        desc = 'Попросить игрока заглушить свое Т/С через мегафон [/m]',
        use = '/st [id]'
    },
    {
        cmd = '/oop',
        desc = 'Написать в волну департамента об ООП',
        use = '/oop [id]'
    },
    {
        cmd = '/warn',
        desc = 'Предупредить игрока в волну департамента о нарушении подачи в розыск',
        use = '/warn [id]'
    },
    {
        cmd = '/su',
        desc = 'Выдать розыск через диалог',
        use = '/su [id]'
    },
    {
        cmd = '/ssu',
        desc = 'Выдать розыск через серверную команду',
        use = '/ssu [id] [кол-во звезд] [причина]'
    },
    {
        cmd = '/cput',
        desc = 'РП отыгровка посадки преступника в автомобиль/мото',
        use = '/cput [id] [сиденье(не обязательно)]'
    },
    {
        cmd = '/ceject',
        desc = 'РП отыгровка высадки преступника из автомобиля/мото',
        use = '/ceject [id]'
    },
    {
        cmd = '/deject',
        desc = 'РП отыгровка вытаскивания преступника из автомобиля/мото',
        use = '/deject [id]'
    },
    {
        cmd = '/ms',
        desc = 'РП отыгровка взятия маскировки',
        use = '/ms [тип]'
    },
    {
        cmd = '/keys',
        desc = "РП отыгровка сравнения ключей от КПЗ",
        use = '/keys'
    },
    {
        cmd = '/rh',
        desc = "Запросить патрульный экипаж в текущий квадрат",
        use = "/rh [департамент(1 - LSPD, 2 - SFPD, 3 - LVPD)]"
    },
    {
        cmd = '/tazer',
        desc = "РП тазер",
        use = '/tazer'
    },
    {
        cmd = "/gr",
        desc = "Написать в волну департамента о пересечении юрисдикции",
        use = "/gr [департамент(1 - LSPD, 2 - SFPD, 3 - LVPD)] [причина]"
    },
    {
        cmd = '/df',
        desc = "Открыть диалог с разминированием бомб",
        use = '/df'
    },
    {
        cmd = '/dmb',
        desc = 'Открыть /members в диалоге',
        use = '/dmb'
    },
    {
        cmd = '/ar',
        desc = 'Попросить разрешение на въезд на военную территорию в волну департамента',
        use = '/ar [армия(1 - LVA, 2 - SFA)]'
    },
    {
        cmd = '/pr',
        desc = 'Правила миранды',
        use = '/pr'
    },
    {
        cmd = '/kmdc',
        desc = 'По РП пробить игрока в КПК',
        use = '/kmdc [id]'
    },
    {
        cmd = '/ftazer',
        desc = 'РП отыгровка /ftazer',
        use = '/ftazer [тип]'
    },
    {
        cmd = '/fvz',
        desc = 'Вызвать игрока в офис ФБР со старшими',
        use = '/fvz [id]'
    },
    {
        cmd = '/fbd',
        desc = 'Запросить причину изменения БД по волне департамента',
        use = '/fbd [id]'
    },
    {
        cmd = '/blg',
        desc = 'Выразить благодарность по волне департамента',
        use = "/blg [id] [фракция] [причина]"
    },
    {
        cmd = '/yk',
        desc = "Открыть шпору УК (Текст шпоры можно изменить в файле moonloader/fbitools/yk.txt)",
        use = "/yk"
    },
    {
        cmd = '/ak',
        desc = "Открыть шпору АК (Текст шпоры можно изменить в файле moonloader/fbitools/ak.txt)",
        use = "/ak"
    },
    {
        cmd = '/fp',
        desc = "Открыть шпору ФП (Текст шпоры можно изменить в файле moonloader/fbitools/fp.txt)",
        use = "/fp"
    },
    {
        cmd = '/shp',
        desc = "Открыть шпору (Текст шпоры можно изменить в файле moonloader/fbitools/shp.txt)",
        use = "/shp"
    },
    {
        cmd = '/fyk',
        desc = 'Поиск по шпоре УК',
        use = '/fyk [текст]'
    },
    {
        cmd = '/fak',
        desc = 'Поиск по шпоре АК',
        use = '/fak [текст]'
    },
    {
        cmd = '/ffp',
        desc = 'Поиск по шпоре ФП',
        use = '/ffp [текст]'
    },
    {
        cmd = '/fshp',
        desc = 'Поиск по шпоре',
        use = '/fshp [текст]'
    },
    {
        cmd = '/fst',
        desc = 'Изменить время',
        use = '/fst [время]'
    },
    {
        cmd = '/fsw',
        desc = 'Изменить погоду',
        use = '/fsw [погода]'
    },
    {
        cmd = '/cc',
        desc = 'Очистить чат',
        use = '/cc'
    },
    {
        cmd = '/dkld',
        desc = 'Сделать доклад',
        use = '/dkld'
    },
    {
        cmd = '/mcheck',
        desc = 'Пробить по /mdc всех на расстоянии 200 метров',
        use = '/mcheck'
    },
    {
        cmd = '/megaf',
        desc = 'Мегафон с автоотпределением авто',
        use = '/megaf'
    },
    {
        cmd = '/rlog',
        desc = 'Открыть лог 25 последних сообщений в рацию',
        use = '/rlog'
    },
    {
        cmd = '/dlog',
        desc = 'Открыть лог 25 последних сообщений в департамент',
        use = '/dlog'
    },
    {
        cmd = '/sulog',
        desc = 'Открыть лог 25 последних выдачи розыска',
        use = '/sulog'
    },
    {
        cmd = '/smslog',
        desc = 'Открыть лог 25 последних SMS',
        use = '/smslog'
    },
    {
        cmd = '/z',
        desc = 'Выдать розыск по заготовленым статьям',
        use = '/z [id] [параметр(не обязательно)]'
    },
    {
        cmd = '/rt',
        desc = 'Сообщение в рацию без тэга',
        use = '/rt [текст]'
    },
    {
        cmd = '/ooplist',
        desc = 'Список ООП',
        use = '/ooplist [id(не обязательно)]'
    },
    {
        cmd = '/fkv',
        desc = 'Поставить метку на квадрат на карте',
        use = '/fkv [квадрат]'
    },
    {
        cmd = '/fnr',
        desc = 'Созвать сотрудников на работу',
        use = '/fnr'
    }
}
local tEditData = {
	id = -1,
	inputActive = false
}
local quitReason = {
    [1] = 'Выход',
    [2] = 'Кик/Бан',
    [0] = 'Краш/Вылет'
}
local sut = [[
Нанесение телесных повреждений - 2 года
Вооруженное нападение на гражданских - 3 года
Вооруженное нападение на гос - 6 лет, запрет на адвоката
Хулиганство - 1 год
Неадекватное поведение - 1 год
Попрошайничество - 1 год
Оскорбление - 2 года
Угон транспортного средства - 2 года
Неподчинение сотрудникам ПО - 1 год
Уход от сотрудников ПО - 2 года
Побег с места заключения - 6 лет
Ношение оружия без лицензии - 1 год и штраф в размере 2000$.
Изготовление нелегального оружия - 3 года и изъятие
Приобретение нелегального оружия - 3 года и изъятие
Продажа нелегального оружия - 3 года и изъятие
Хранение наркотиков - 3 года и изъятие
Хранение материалов - 3 года и изъятие
Употребление наркотиков - 3 года и изъятие
Порча чужого имущества - 1 год и штраф в размере 5000$
Уничтожение чужого имущества - 4 года и штраф в размере 15000$
Проникновение на охр. территорию - 2 года
Проникновение на част. территорию - 1 год
Вымогательство - 2 года
Угрозы - 1 год
Провокации - 2 года
Мошенничество - 2 года
Предложение интимных услуг - 1 год
Изнасилование гражданина - 3 год
Укрывательство преступлений - 2 года
Использование фальшивых документов - 1 год
Клевета на гос. лицо - 1 год
Клевета на гос. организации - 2 года
Ношение военной формы - 2 года, форма подлежит изъятию.
Покупка ключей от камеры - 6 лет
Предложение взятки - 2 года
Совершение теракта - 6 лет, лишение всех лицензий
Неуплата штрафа - 2 года
Игнорирование спец. сирен - 1 год
Превышение полномочий адвоката - 3 года
Похищение гос. сотрудника - 4 года
Чистосердечное признание - 1 год
Наезд на пешехода - 2 года
Уход с места ДТП - 3 года
Ограбление - 3 года
ООП - 6 лет
Уход - 6 лет
]]

local shpt = [[
Пока что вы не настроили шпору.
Что бы вставить сюда свой текст вам нужно выполнить ряд дейтсвий:
1. Открыть папку fbitools которая находится в папке moonloader
2. Открыть файл shp.txt любым блокнотом
3. Изменить текст в нем на какой вам нужен
4. Сохранить файл
]]

function sampGetStreamedPlayers()
	local t = {}
	for i = 0, sampGetMaxPlayerId(false) do
		if sampIsPlayerConnected(i) then
			local result, sped = sampGetCharHandleBySampPlayerId(i)
			if result then
				if doesCharExist(sped) then
					table.insert(t, i)
                end
			end
		end
    end
	return t
end

function sirenk()
    if isCharInAnyCar(PLAYER_PED) then
        local car = storeCarCharIsInNoSave(PLAYER_PED)
        switchCarSiren(car, not isCarSirenOn(car))
    end
end

function getClosestPlayerId()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist and sampGetFraktionBySkin(i) ~= 'Полиция' and sampGetFraktionBySkin(i) ~= 'FBI' then
                minDist = dist
                closestId = i
            end
        end
    end
    return closestId
end
function getClosestPlayerIDinCar()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    local veh = storeCarCharIsInNoSave(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist and sampGetFraktionBySkin(i) ~= 'Полиция' and sampGetFraktionBySkin(i) ~= 'FBI' and isCharInAnyCar(pedID) then
                if storeCarCharIsInNoSave(pedID) == veh then
                    minDist = dist
                    closestId = i
                end
            end
        end
    end
    return closestId
end

function getClosestPlayerIDinCarD()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 999 do
        local streamed, pedID = sampGetCharHandleBySampPlayerId(i)
        if streamed then
            local xi, yi, zi = getCharCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist and sampGetFraktionBySkin(i) ~= 'Полиция' and sampGetFraktionBySkin(i) ~= 'FBI' and isCharInAnyCar(pedID) then
                minDist = dist
                closestId = i
            end
        end
    end
    return closestId
end

function cuffk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me %s руки преступника и %s наручники', cfg.main.male and 'заломал' or 'заломала', cfg.main.male and 'достал' or 'достала'))
                wait(1400)
                sampSendChat('/cuff '..targetid)
                gmegafhandle = ped
                gmegafid = targetid
                gmegaflvl = sampGetPlayerScore(targetid)
                gmegaffrak = sampGetFraktionBySkin(targetid)
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if closeid ~= -1 then 
            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
            if doesCharExist(closehandle) then
                lua_thread.create(function()
                    sampSendChat(string.format('/me %s руки преступника и %s наручники', cfg.main.male and 'заломал' or 'заломала', cfg.main.male and 'достал' or 'достала'))
                    wait(1400)
                    sampSendChat('/cuff '..closeid)
                    gmegafhandle = closehandle
                    gmegafid = closeid
                    gmegaflvl = sampGetPlayerScore(closeid)
                    gmegaffrak = sampGetFraktionBySkin(closeid)
                end)
            end
        end
    end
end

function uncuffk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        local result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me %s наручники с преступника', cfg.main.male and 'снял' or 'сняла'))
                wait(1400)
                sampSendChat('/uncuff '..targetid)
                gmegafhandle = nil
                gmegafid = -1
                gmegaflvl = nil
                gmegaffrak = nil
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if sampIsPlayerConnected(closeid) then
            if closeid ~= -1 then
                local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
                if doesCharExist(closehandle) then
                    lua_thread.create(function()
                        sampSendChat(string.format('/me %s наручники с преступника', cfg.main.male and 'снял' or 'сняла'))
                        wait(1400)
                        sampSendChat('/uncuff '..closeid)
                        gmegafhandle = nil
                        gmegafid = -1
                        gmegaflvl = nil
                        gmegaffrak = nil
                    end)
                end
            end
        end
    end
end

function followk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me %s один из концов наручников к себе, после чего %s за собой преступника', cfg.main.male and 'пристегнул' or 'пристегнула', cfg.main.male and 'повел' or 'повела'))
                wait(1400)
                sampSendChat('/follow '..targetid)
                gmegafhandle = ped
                gmegafid = targetid
                gmegaflvl = sampGetPlayerScore(targetid)
                gmegaffrak = sampGetFraktionBySkin(targetid)
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if closeid ~= -1 then 
            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
            if doesCharExist(closehandle) then
                lua_thread.create(function()
                    sampSendChat(string.format('/me %s один из концов наручников к себе, после чего %s за собой преступника', cfg.main.male and 'пристегнул' or 'пристегнула', cfg.main.male and 'повел' or 'повела'))
                    wait(1400)
                    sampSendChat('/follow '..closeid)
                    gmegafhandle = closehandle
                    gmegafid = closeid
                    gmegaflvl = sampGetPlayerScore(closeid)
                    gmegaffrak = sampGetFraktionBySkin(closeid)
                end)
            end
        end
    end
end

function cputk()
    local closeid = getClosestPlayerId()
    if closeid ~= -1 then
        local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
        if doesCharExist(closehandle) then
            lua_thread.create(function()
                if isCharOnAnyBike(PLAYER_PED) then
                    sampSendChat(string.format("/me %s преступника на сиденье мотоцикла", cfg.main.male and 'посадил' or 'посадила'))
                    wait(1400)
                    sampSendChat("/cput "..closeid.." 1", -1)
                else
                    sampSendChat(string.format("/me %s дверь автомобиля и %s туда преступника", cfg.main.male and 'открыл' or 'открыла', cfg.main.male and 'затолкнул' or 'затолкнула'))
                    wait(1400)
                    sampSendChat("/cput "..closeid.." "..getFreeSeat(), -1)
                end
                gmegafhandle = closehandle
                gmegafid = closeid
                gmegaflvl = sampGetPlayerScore(closeid)
                gmegaffrak = sampGetFraktionBySkin(closeid)
            end)
        end
    end
end

function cejectk()
    if isCharInAnyCar(PLAYER_PED) then
        local closestId = getClosestPlayerIDinCar()
        if closestId ~= -1 then
            local result, closehandle = sampGetCharHandleBySampPlayerId(closestId)
            lua_thread.create(function()
                if isCharOnAnyBike(PLAYER_PED) then
                    sampSendChat(string.format("/me %s преступника с мотоцикла", cfg.main.male and 'высадил' or 'высадила'))
                    wait(1400)
                    sampSendChat("/ceject "..closestId, -1)
                else
                    sampSendChat(string.format("/me %s дверь автомобиля и %s преступника", cfg.main.male and 'открыл' or 'открыл', cfg.main.male and 'высадил' or 'высадила'))
                    wait(1400)
                    sampSendChat("/ceject "..closestId)
                end
                gmegafhandle = closehandle
                gmegafid = closestId
                gmegaflvl = sampGetPlayerScore(closestId)
                gmegaffrak = sampGetFraktionBySkin(closestId)
            end)
        end
    end
end

function takek()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me надев перчатки, %s руками по торсу', cfg.main.male and 'провел' or 'провела'))
                wait(1400)
                sampSendChat('/take '..targetid)
                gmegafhandle = ped
                gmegafid = targetid
                gmegaflvl = sampGetPlayerScore(targetid)
                gmegaffrak = sampGetFraktionBySkin(targetid)
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if closeid ~= -1 then 
            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
            if doesCharExist(closehandle) then
                lua_thread.create(function()
                    sampSendChat(string.format('/me надев перчатки, %s руками по торсу', cfg.main.male and 'провел' or 'провела'))
                    wait(cfg.commands.zaderjka)
                    sampSendChat('/take '..closeid)
                    gmegafhandle = closehandle
                    gmegafid = closeid
                    gmegaflvl = sampGetPlayerScore(closeid)
                    gmegaffrak = sampGetFraktionBySkin(closeid)
                end)
            end
        end
    end
end

function arrestk()
    local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if valid then
        result, targetid = sampGetPlayerIdByCharHandle(ped)
        if result then
            lua_thread.create(function()
                sampSendChat(string.format('/me %s камеру', cfg.main.male and 'открыл' or 'открыла'))
                wait(cfg.commands.zaderjka)
                sampSendChat(string.format('/me %s преступника в камеру', cfg.main.male and 'провел' or 'провела'))
                wait(cfg.commands.zaderjka)
                sampSendChat('/arrest '..targetid)
                wait(cfg.commands.zaderjka)
                sampSendChat(string.format('/me %s камеру', cfg.main.male and 'закрыл' or 'закрыла'))
                gmegafhandle = nil
                gmegafid = -1
                gmegaflvl = nil
                gmegaffrak = nil
            end)
        end
    else
        local closeid = getClosestPlayerId()
        if closeid ~= -1 then 
            local result, closehandle = sampGetCharHandleBySampPlayerId(closeid)
            if doesCharExist(closehandle) then
                lua_thread.create(function()
                    sampSendChat(string.format('/me %s камеру', cfg.main.male and 'открыл' or 'открыла'))
                    wait(cfg.commands.zaderjka)
                    sampSendChat(string.format('/me %s преступника в камеру', cfg.main.male and 'провел' or 'провела'))
                    wait(cfg.commands.zaderjka)
                    sampSendChat('/arrest '..closeid)
                    wait(cfg.commands.zaderjka)
                    sampSendChat(string.format('/me %s камеру', cfg.main.male and 'закрыл' or 'закрыла'))
                    gmegafhandle = nil
                    gmegafid = -1
                    gmegaflvl = nil
                    gmegaffrak = nil
                end)
            end
        end
    end
end

function dejectk()
    local closestId = getClosestPlayerIDinCarD()
    if closestId ~= -1 then
        local result, closehandle = sampGetCharHandleBySampPlayerId(closestId)
        if result then
            lua_thread.create(function()
                if isCharInFlyingVehicle(closehandle) then
                    sampSendChat(string.format("/me %s дверь вертолёта и %s преступника", cfg.main.male and 'открыл' or 'открыла', cfg.main.male and 'вытащил' or 'вытащила'))
                    wait(1400)
                    sampSendChat("/deject "..closestId)
                elseif isCharInModel(closehandle, 481) or isCharInModel(closehandle, 510) then
                    sampSendChat(string.format("/me скинул преступника с велосипеда", cfg.main.male and 'скинул' or 'скинула'))
                    wait(1400)
                    sampSendChat("/deject "..closestId)
                elseif isCharInModel(closehandle, 462) then
                    sampSendChat(string.format("/me %s преступника со скутера", cfg.main.male and 'скинул' or 'скинула'))
                    wait(1400)
                    sampSendChat("/deject "..closestId)
                elseif isCharOnAnyBike(closehandle) then
                    sampSendChat(string.format("/me %s преступника с мотоцикла", cfg.main.male and 'скинул' or 'скинула'))
                    wait(1400)
                    sampSendChat("/deject "..closestId)
                elseif isCharInAnyCar(closehandle) then
                    sampSendChat(string.format("/me %s окно и %s преступника из машины", cfg.main.male and 'разбил' or 'разбила', cfg.main.male and 'вытолкнул' or 'вытолкнула'))
                    wait(1400)
                    sampSendChat("/deject "..closestId)
                end
            end)
        end
    end
end

function sampGetFraktionBySkin(id)
    local t = 'Гражданский'
    if sampIsPlayerConnected(id) then
        local result, ped = sampGetCharHandleBySampPlayerId(id)
        if result then
            local skin = getCharModel(ped)
            if skin == 102 or skin == 103 or skin == 104 or skin == 195 or skin == 21 then t = 'Ballas Gang' end
            if skin == 105 or skin == 106 or skin == 107 or skin == 269 or skin == 270 or skin == 271 or skin == 86 or skin == 149 or skin == 297 then t = 'Grove Gang' end
            if skin == 108 or skin == 109 or skin == 110 or skin == 190 or skin == 47 then t = 'Vagos Gang' end
            if skin == 114 or skin == 115 or skin == 116 or skin == 48 or skin == 44 or skin == 41 or skin == 292 then t = 'Aztec Gang' end
            if skin == 173 or skin == 174 or skin == 175 or skin == 193 or skin == 226 or skin == 30 or skin == 119 then t = 'Rifa Gang' end
            if skin == 191 or skin == 252 or skin == 287 or skin == 61 or skin == 179 or skin == 255 then t = 'Army' end
            if skin == 57 or skin == 98 or skin == 147 or skin == 150 or skin == 187 or skin == 216 then t = 'Мэрия' end
            if skin == 59 or skin == 172 or skin == 189 or skin == 240 then t = 'Автошкола' end
            if skin == 201 or skin == 247 or skin == 248 or skin == 254 or skin == 248 or skin == 298 then t = 'Байкеры' end
            if skin == 272 or skin == 112 or skin == 125 or skin == 214 or skin == 111  or skin == 126 then t = 'Русская мафия' end
            if skin == 113 or skin == 124 or skin == 214 or skin == 223 then t = 'La Cosa Nostra' end
            if skin == 120 or skin == 123 or skin == 169 or skin == 186 then t = 'Yakuza' end
            if skin == 211 or skin == 217 or skin == 250 or skin == 261 then t = 'News' end
            if skin == 70 or skin == 219 or skin == 274 or skin == 275 or skin == 276 or skin == 70 then t = 'Медики' end
            if skin == 286 or skin == 141 or skin == 163 or skin == 164 or skin == 165 or skin == 166 then t = 'FBI' end
            if skin == 280 or skin == 265 or skin == 266 or skin == 267 or skin == 281 or skin == 282 or skin == 288 or skin == 284 or skin == 285 or skin == 304 or skin == 305 or skin == 306 or skin == 307 or skin == 309 or skin == 283 or skin == 303 then t = 'Полиция' end
        end
    end
    return t
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function getMaskList(forma)
	local mask = {
		['гражданского'] = 0,
		['полицейского'] = 1,
		['военного'] = 2,
		['лаборатория'] = 3,
		['медика'] = 3,
		['сотрудника мэрии'] = 4,
		['работника автошколы'] = 5,
		['работника новостей'] = 6,
		['ЧОП LCN'] = 7,
		['ЧОП Yakuza'] = 8,
		['ЧОП Russian Mafia'] = 9,
		['БК Rifa'] = 10,
		['БК Grove'] = 11,
		['БК Ballas'] = 12,
		['БК Vagos'] = 13,
		['БК Aztec'] = 14,
		['байкеров'] = 15
	}
	return mask[forma]
end

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function submenus_show(menu, caption, select_button, close_button, back_button)
    select_button, close_button, back_button = select_button or '»', close_button or 'x', back_button or '«'
    prev_menus = {}
    function display(menu, id, caption)
        local string_list = {}
        for i, v in ipairs(menu) do
            table.insert(string_list, type(v.submenu) == 'table' and v.title .. ' »' or v.title)
        end
        sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button, (#prev_menus > 0) and back_button or close_button, sf.DIALOG_STYLE_LIST)
        repeat
            wait(0)
            local result, button, list = sampHasDialogRespond(id)
            if result then
                if button == 1 and list ~= -1 then
                    local item = menu[list + 1]
                    if type(item.submenu) == 'table' then
                        table.insert(prev_menus, {menu = menu, caption = caption})
                        if type(item.onclick) == 'function' then
                            item.onclick(menu, list + 1, item.submenu)
                        end
                        return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
                    elseif type(item.onclick) == 'function' then
                        local result = item.onclick(menu, list + 1)
                        if not result then return result end
                        return display(menu, id, caption)
                    end
                else
                    if #prev_menus > 0 then
                        local prev_menu = prev_menus[#prev_menus]
                        prev_menus[#prev_menus] = nil
                        return display(prev_menu.menu, id - 1, prev_menu.caption)
                    end
                    return false
                end
            end
        until result
    end
    return display(menu, 31337, caption or menu.title)
end

local dfmenu = {
    {
        title = 'Бомба с часовым механизмом',
        onclick = function()
            sampSendChat(("/me %s саперный набор"):format(cfg.main.male and 'достал' or 'достала'))
            wait(3500)
            sampSendChat(("/me %s саперный набор"):format(cfg.main.male and 'открыл' or 'открыла'))
            wait(3500)
            sampSendChat(("/me %s взрывное устройство"):format(cfg.main.male and 'осмотрел' or 'осмотрела'))
            wait(3500)
            sampSendChat(("/do %s тип взрывного устройства. Бомба с часовым механизмом."):format(cfg.main.male and 'Определил' or 'Определила'))
            wait(3500)
            sampSendChat(("/do %s три провода выходящих с механизма."):format(cfg.main.male and 'Увидел' or 'Увидела'))
            wait(3500)
            sampSendChat(("/me %s нож из саперного набора"):format(cfg.main.male and 'достал' or 'достала'))
            wait(3500)
            sampSendChat(("/me аккуратно %s первый провод"):format(cfg.main.male and 'зачистил' or 'зачистила'))
            wait(3500)
            sampSendChat(("/try %s отвертку с индикатором и %s край отвертки к оголённом проводу"):format(cfg.main.male and 'достал' or 'достала', cfg.main.male and 'прислонил' or 'прислонила'))
        end
    },
    {
        title = 'Бомба с часовым механизмом если {63c600}[Удачно]',
        onclick = function()
            sampSendChat(("/me %s проводок"):format(cfg.main.male and 'перерезал' or 'перерезала'))
            wait(3500)
            sampSendChat(("/me %s к устройству"):format(cfg.main.male and 'прислушался' or 'прислушалась'))
            wait(3500)
            sampSendChat("/do Механизм перестал издавать тикающие звуки.")
            wait(3500)
            sampSendChat("/do Бомба обезврежена.")
            wait(3500)
            sampSendChat(("/me %s инструменты обратно в саперный набор"):format(cfg.main.male and 'сложил' or 'сложила'))
            wait(3500)
            sampSendChat(("/me %s бронированный кейс и аккуратно %s туда бомбу"):format(cfg.main.male and 'достал' or 'достала', cfg.main.male and 'сложил' or 'сложила'))
        end
    },
    {
        title = 'Бомба с часовым механизмом если {bf0000}[Неудачно]',
        onclick = function()
            sampSendChat(("/me аккуратно %s второй провод"):format(cfg.main.male and 'зачистил' or 'зачистила'))
            wait(3500)
            sampSendChat(("/me %s проводок"):format(cfg.main.male and 'перерезал' or 'перерезала'))
            wait(3500)
            sampSendChat(("/me %s к устройству"):format(cfg.main.male and 'прислушался' or 'прислушалась'))
            wait(3500)
            sampSendChat("/do Механизм перестал издавать тикающие звуки.")
            wait(3500)
            sampSendChat("/do Бомба обезврежена.")
            wait(3500)
            sampSendChat(("/me %s инструменты обратно в саперный набор"):format(cfg.main.male and 'сложил' or 'сложила'))
            wait(3500)
            sampSendChat(("/me %s бронированный кейс и аккуратно %s туда бомбу"):format(cfg.main.male and 'достал' or 'достала', cfg.main.male and 'сложил' or 'сложила'))
        end
    },
    {
        title = 'Бомба с дистанционным управлением',
        onclick = function()
            sampSendChat(("/me %s саперный набор"):format(cfg.main.male and 'достал' or 'достала'))
            wait(3500)
            sampSendChat(("/me %s саперный набор"):format(cfg.main.male and 'открыл' or 'открыла'))
            wait(3500)
            sampSendChat(("/me %s взрывное устройство"):format(cfg.main.male and 'осмотрел' or 'осмотрела'))
            wait(3500)
            sampSendChat(("/do %s тип взрывного устройства. Бомба с дистанционным управлением."):format(cfg.main.male and 'Определил' or 'Определила'))
            wait(3500)
            sampSendChat(("/do %s два шурупа на блоке с механизмом."):format(cfg.main.male and 'Увидел' or 'Увидела'))
            wait(3500)
            sampSendChat(("/me %s отвертку из саперного набора"):format(cfg.main.male and 'достал' or 'достала'))
            wait(3500)
            sampSendChat("/me аккуратно выкручивает шуруп")
            wait(3500)
            sampSendChat(("/me %s крышку блока и %s антенну"):format(cfg.main.male and 'отодвинул' or 'отодвинула', cfg.main.male and 'увидел' or 'увидела'))
            wait(3500)
            sampSendChat(("/do %s красный мигающий индикатор."):format(cfg.main.male and 'Увидел' or 'Увидела'))
            wait(3500)
            sampSendChat(("/me %s путь микросхемы от антенны к детонатору"):format(cfg.main.male and 'просмотрел' or 'просмотрела'))
            wait(3500)
            sampSendChat(("/me %s два провода"):format(cfg.main.male and 'Увидел' or 'Увидела'))
            wait(3500)
            sampSendChat(("/try %s первый провод. Индикатор перестал мигать."):format(cfg.main.male and 'перерезал' or 'перерезала'))
        end
    },
    {
        title = 'Бомба с дистанционным управлением если {63c600}[Удачно]',
        onclick = function()
            sampSendChat("/do Бомба обезврежена.")
            wait(3500)
            sampSendChat(("/me %s инструменты обратно в саперный набор"):format(cfg.main.male and 'сложил' or 'сложила'))
            wait(3500)
            sampSendChat(("/me %s бронированный кейс и аккуратно %s туда бомбу"):format(cfg.main.male and 'достал' or 'достала', cfg.main.male and 'сложил' or 'сложила'))
        end
    },
    {
        title = 'Бомба с дистанционным управлением если {bf0000}[Неудачно]',
        onclick = function()
            sampSendChat(("/me %s второй провод"):format(cfg.main.male and 'перерезал' or 'перерезала'))
            wait(3500)
            sampSendChat("/do Индикатор перестал мигать.")
            wait(3500)
            sampSendChat("/do Бомба обезврежена.")
            wait(3500)
            sampSendChat(("/me %s инструменты обратно в саперный набор"):format(cfg.main.male and 'сложил' or 'сложила'))
            wait(3500)
            sampSendChat(("/me %s бронированный кейс и аккуратно %s туда бомбу"):format(cfg.main.male and 'достал' or 'достала', cfg.main.male and 'сложил' or 'сложила'))
        end
    },
    {
        title = 'Бомба с активационным кодом',
        onclick = function()
            sampSendChat(("/me %s саперный набор"):format(cfg.main.male and 'достал' or 'достала'))
            wait(3500)
            sampSendChat(("/me %s саперный набор"):format(cfg.main.male and 'открыл' or 'открыла'))
            wait(3500)
            sampSendChat(("/me %s взрывное устройство"):format(cfg.main.male and 'осмотрел' or 'осмотрела'))
            wait(3500)
            sampSendChat(("/do %s тип взрывного устройства. Бомба с активационным кодом."):format(cfg.main.male and 'Определил' or 'Определила'))
            wait(3500)
            sampSendChat(("/me %s из саперного набора прибор для подбора кода"):format(cfg.main.male and 'достал' or 'достала'))
            wait(3500)
            sampSendChat(("/me %s прибор к бомбе"):format(cfg.main.male and 'подключил' or 'подключила'))
            wait(3500)
            sampSendChat("/do На приборе высветилось: Ожидание получения пароля.")
            wait(3500)
            sampSendChat("/do На приборе высветилось: Пароль 5326.")
            wait(3500)
            sampSendChat(("/try %s полученный пароль. Экран бомбы выключился"):format(cfg.main.male and 'ввёл' or 'ввёла'))
        end
    },
    {
        title = 'Бомба с активационным кодом если {63c600}[Удачно]',
        onclick = function()
            sampSendChat("/do Бомба обезврежена.")
            wait(3500)
            sampSendChat(("/me %s инструменты обратно в саперный набор"):format(cfg.main.male and 'сложил' or 'сложила'))
            wait(3500)
            sampSendChat(("/me %s бронированный кейс и аккуратно %s туда бомбу"):format(cfg.main.male and 'достал' or 'достала', cfg.main.male and 'сложил' or 'сложила'))
        end
    },
    {
        title = 'Бомба с активационным кодом если {bf0000}[Неудачно]',
        onclick = function()
            sampSendChat(("/me перезагрузила прибор"):format(cfg.main.male and 'перезагрузил' or 'перезагрузила'))
            wait(3500)
            sampSendChat("/do На приборе высветилось: Ожидание получения пароля.")
            wait(3500)
            sampSendChat("/do На приборе высветилось: Пароль 3789.")
            wait(3500)
            sampSendChat(("/me %s полученный пароль"):format(cfg.main.male and 'ввёл' or 'ввёла'))
            wait(3500)
            sampSendChat("/Экран бомбы выключился")
            wait(3500)
            sampSendChat("/do Бомба обезврежена.")
            wait(3500)
            sampSendChat(("/me %s инструменты обратно в саперный набор"):format(cfg.main.male and 'сложил' or 'сложила'))
            wait(3500)
            sampSendChat(("/me %s бронированный кейс и аккуратно %s туда бомбу"):format(cfg.main.male and 'достал' or 'достала', cfg.main.male and 'сложил' or 'сложила'))
        end
    }
}

local fcmenu =
{
  {
    title = 'Теракты',
    submenu =
    {
      {
        title = '{00BFFF}« Мэрия »'
      },
      {
        title = '{00BFFF}Захват мэрии без заложников — {ff0000}100.000$'
      },
      {
        title = '{00BFFF}Захват мэрии c заложниками — {ff0000}150.000$'
      },
      {
        title = '{9A9593}« Офис ФБР »'
      },
      {
        title = '{9A9593}Захват офиса федерального бюро без заложников — {ff0000}100.000$'
      },
      {
        title = '{9A9593}Захват офиса федерального бюро c заложниками — {ff0000}150.000$'
      },
      {
        title = '{0080FF}« Участок SFPD »'
      },
      {
        title = '{0080FF}Захват участка SAPD без заложников — {ff0000}100.000$'
      },
      {
        title = '{0080FF}Захват участка SAPD c заложниками — {ff0000}150.000$'
      },
      {
        title = '{BF4040}« Больница »'
      },
      {
        title = '{BF4040}Захват больницы без заложников — {ff0000}75.000$'
      },
      {
        title = '{BF4040}Захват больницы с заложниками — {ff0000}100.000$'
      },
      {
        title = '{00BFFF}« Автошкола »'
      },
      {
        title = '{00BFFF}Захват автошколы без заложников — {ff0000}50.000$'
      },
      {
        title = '{00BFFF}Захват автошколы с заложниками — {ff0000}75.000$'
      },
      {
        title = '{40BFBF}« CМИ »'
      },
      {
        title = '{40BFBF}Захват СМИ без заложников — {ff0000}50.000$'
      },
      {
        title = '{40BFBF}Захват СМИ с заложниками — {ff0000}75.000$'
      },
      {
        title = '« Остальное »'
      },
      {
        title = 'Захват развлекательных/рабочих заведений без заложников — {ff0000}50.000$'
      },
      {
        title = 'Захват развлекательных/рабочих заведений с заложниками — {ff0000}75.000$'
      }
    }
  },
  {
    title = 'Похищения',
    submenu =
    {
      {
        title = 'Мэрия',
        submenu =
        {
          {
            title = '{0040BF}Мэр{ffffff} [6] - {ff0000}100.000$'
          },
          {
            title = '{0040BF}Зам.Мэра{ffffff} [5] - {ff0000}80.000$'
          },
          {
            title = '{0040BF}Начальник охраны{ffffff} [4] - {ff0000}60.000$'
          },
          {
            title = '{0040BF}Охранник{ffffff} [3] - {ff0000}40.000$'
          },
          {
            title = '{0040BF}Адвокат{ffffff} [2] - {ff0000}30.000$'
          },
          {
            title = '{0040BF}Секретарь{ffffff} [1] - {ff0000}20.000$'
          }
        }
      },
      {
        title = 'ФБР',
        submenu =
        {
          {
            title = '{9A9593}Директор{ffffff} [10] - {ff0000}100.000$'
          },
          {
            title = '{9A9593}Зам.Директора{FFFFFF} [9] - {ff0000}80.000$'
          },
          {
            title = '{9A9593}Инспектор{ffffff} [8] - {ff0000}70.000$'
          },
          {
            title = '{9A9593}Глава CID{ffffff} [7] - {ff0000}60.000$'
          },
          {
            title = '{9A9593}Глава DEA{ffffff} [6] - {ff0000}50.000$'
          },
          {
            title = '{9A9593}Агент CID{ffffff} [5] - {ff0000}40.000$'
          },
          {
            title = '{9A9593}Агент DEA{ffffff} [4] - {ff0000}30.000$'
          },
          {
            title = '{9A9593}Мл.Агент{ffffff} [3] - {ff0000}25.000$'
          },
          {
            title = '{9A9593}Дежурный{ffffff} [2] - {ff0000}20.000$'
          },
          {
            title = '{9A9593}Стажер{ffffff} [1] - {ff0000}15.000$'
          }
        }
      },
      {
        title = 'Полиция',
        submenu =
        {
          {
            title = '{0000FF}Шериф{ffffff} [14] - {ff0000}80.000$'
          },
          {
            title = '{0000FF}Полковник{ffffff} [13] - {ff0000}70.000$'
          },
          {
            title = '{0000FF}Подполковник{ffffff} [12] - {ff0000}65.000$'
          },
          {
            title = '{0000FF}Майор{ffffff} [11] - {ff0000}60.000$'
          },
          {
            title = '{0000FF}Капитан{ffffff} [10] - {ff0000}55.000$'
          },
          {
            title = '{0000FF}Ст.Лейтенант{ffffff} [9] - {ff0000}50.000$'
          },
          {
            title = '{0000FF}Лейтенант{ffffff} [8] - {ff0000}45.000$'
          },
          {
            title = '{0000FF}Мл.Лейтенант{ffffff} [7] - {ff0000}40.000$'
          },
          {
            title = '{0000FF}Ст.Прапорщик{ffffff} [6] - {ff0000}35.000$'
          },
          {
            title = '{0000FF}Прапорщик{ffffff} [5] - {ff0000}30.000$'
          },
          {
            title = '{0000FF}Сержант{ffffff} [4] - {ff0000}25.000$'
          },
          {
            title = '{0000FF}Мл.Сержант{ffffff} [3] - {ff0000}20.000$'
          },
          {
            title = '{0000FF}Офицер{ffffff} [2] - {ff0000}15.000$'
          },
          {
            title = '{0000FF}Кадет{ffffff} [1] - {ff0000}10.000$'
          }
        }
      },
      {
        title = 'Армия',
        submenu =
        {
          {
            title = '{008040}Генерал{ffffff} [15] - {ff0000}80.000$'
          },
          {
            title = '{008040}Полковник{ffffff} [14] - {ff0000}75.000$'
          },
          {
            title = '{008040}Подполковник{ffffff} [13] - {ff0000}70.000$'
          },
          {
            title = '{008040}Майор{ffffff} [12] - {ff0000}65.000$'
          },
          {
            title = '{008040}Капитан{ffffff} [11] - {ff0000}60.000$'
          },
          {
            title = '{008040}Ст.Лейтенант{ffffff} [10] - {ff0000}55.000$'
          },
          {
            title = '{008040}Лейтенант{ffffff} [9] - {ff0000}50.000$'
          },
          {
            title = '{008040}Мл.Лейтенант{ffffff} [8] - {ff0000}45.000$'
          },
          {
            title = '{008040}Прапорщик{ffffff} [7] - {ff0000}40.000$'
          },
          {
            title = '{008040}Старшина{ffffff} [6] - {ff0000}35.000$'
          },
          {
            title = '{008040}Ст.сержант{ffffff} [5] - {ff0000}30.000$'
          },
          {
            title = '{008040}Сержант{ffffff} [4] - {ff0000}25.000$'
          },
          {
            title = '{008040}Мл.Сержант{ffffff} [3] - {ff0000}20.000$'
          },
          {
            title = '{008040}Ефрейтор{ffffff} [2] - {ff0000}15.000$'
          },
          {
            title = '{008040}Рядовой{ffffff} [1] - {ff0000}10.000$'
          }
        }
      },
      {
        title = 'Медики',
        submenu =
        {
          {
            title = '{BF4040}Глав.Врач{ffffff} [10] - {ff0000}80.000$'
          },
          {
            title = '{BF4040}Зам.Глав.Врача{ffffff} [9] - {ff0000}75.000$'
          },
          {
            title = '{BF4040}Хирург{ffffff} [8] - {ff0000}70.000$'
          },
          {
            title = '{BF4040}Психолог{ffffff} [7] - {ff0000}60.000$'
          },
          {
            title = '{BF4040}Доктор{ffffff} [6] - {ff0000}40.000$'
          },
          {
            title = '{BF4040}Нарколог{ffffff} [5] - {ff0000}35.000$'
          },
          {
            title = '{BF4040}Спасатель{ffffff} [4] - {ff0000}30.000$'
          },
          {
            title = '{BF4040}Мед.Брат{ffffff} [3] - {ff0000}25.000$'
          },
          {
            title = '{BF4040}Санитар{ffffff} [2] - {ff0000}20.000$'
          },
          {
            title = '{BF4040}Интерн{ffffff} [1] - {ff0000}15.000$'
          }
        }
      },
      {
        title = 'Автошкола',
        submenu =
        {
          {
            title = '{40BFFF}Управляющий{ffffff} [10] - {ff0000}80.000$'
          },
          {
            title = '{40BFFF}Директор{ffffff} [9] - {ff0000}75.000$'
          },
          {
            title = '{40BFFF}Ст.Менеджер{ffffff} [8] - {ff0000}70.000$'
          },
          {
            title = '{40BFFF}Мл.Менеджер{ffffff} [7] - {ff0000}60.000$'
          },
          {
            title = '{40BFFF}Координатор{ffffff} [6] - {ff0000}55.000$'
          },
          {
            title = '{40BFFF}Инструктор{FFFFFF} [5] - {ff0000}50.000$'
          },
          {
            title = '{40BFFF}Мл.Инструктор{ffffff} [4] - {ff0000}45.000$'
          },
          {
            title = '{40BFFF}Экзаменатор{ffffff} [3] - {ff0000}30.000$'
          },
          {
            title = '{40BFFF}Консультант{ffffff} [2] - {ff0000}25.000$'
          },
          {
            title = '{40BFFF}Стажер{ffffff} [1] - {ff0000}20.000$'
          }
        }
      },
      {
        title = 'Новости',
        submenu =
        {
          {
            title = '{FFFF80}Генеральный директор{ffffff} [10] - {ff0000}70.000$'
          },
          {
            title = '{FFFF80}Програмный директор{ffffff} [9] - {ff0000}60.000$'
          },
          {
            title = '{FFFF80}Технический директор{ffffff} [8] - {ff0000}55.000$'
          },
          {
            title = '{FFFF80}Главный редактор{ffffff} [7] - {ff0000}50.000$'
          },
          {
            title = '{FFFF80}Редактор{ffffff} [6] - {ff0000}45.000$'
          },
          {
            title = '{FFFF80}Ведущий{ffffff} [5] - {ff0000}40.000$'
          },
          {
            title = '{FFFF80}Репортер{ffffff} [4] - {ff0000}30.000$'
          },
          {
            title = '{FFFF80}Звукорежиссер{ffffff} [3] - {ff0000}25.000$'
          },
          {
            title = '{FFFF80}Звукооператор{ffffff} [2] - {ff0000}20.000$'
          },
          {
            title = '{FFFF80}Стажер{ffffff} [1] - {ff0000}15.000$'
          }
        }
      }
    }
  }
}

local fthmenu = {
    {
        title = '{ffffff}» Запросить поддержку в текущий квадрат',
        onclick = function()
            if cfg.main.tarb then
                sampSendChat(string.format('/r [%s]: Нужна поддержка в квадрат %s', cfg.main.tar, kvadrat()))
            else
                sampSendChat(string.format('/r Нужна поддержка в квадрат %s', kvadrat()))
            end
        end
    },
    {
        title = '{ffffff}» Запросить эвакуацию в текущий квадрат',
        onclick = function()
            sampShowDialog(1401, '{0C2265}FBI Tools {ffffff}| Эвакуация', '{ffffff}Введите: кол-во мест\nПример: 3 места', 'Отправить', 'Отмена', 1)
        end
    },
    {
        title = '{ffffff}» Цены выкупа',
        onclick = function()
            submenus_show(fcmenu, '{0C2265}FBI Tools {ffffff}| Цены выкупа')
        end
    }
}


function getweaponname(weapon)
    local names = {
    [0] = "Fist",
    [1] = "Brass Knuckles",
    [2] = "Golf Club",
    [3] = "Nightstick",
    [4] = "Knife",
    [5] = "Baseball Bat",
    [6] = "Shovel",
    [7] = "Pool Cue",
    [8] = "Katana",
    [9] = "Chainsaw",
    [10] = "Purple Dildo",
    [11] = "Dildo",
    [12] = "Vibrator",
    [13] = "Silver Vibrator",
    [14] = "Flowers",
    [15] = "Cane",
    [16] = "Grenade",
    [17] = "Tear Gas",
    [18] = "Molotov Cocktail",
    [22] = "9mm",
    [23] = "Silenced 9mm",
    [24] = "Desert Eagle",
    [25] = "Shotgun",
    [26] = "Sawnoff Shotgun",
    [27] = "Combat Shotgun",
    [28] = "Micro SMG/Uzi",
    [29] = "MP5",
    [30] = "AK-47",
    [31] = "M4",
    [32] = "Tec-9",
    [33] = "Country Rifle",
    [34] = "Sniper Rifle",
    [35] = "RPG",
    [36] = "HS Rocket",
    [37] = "Flamethrower",
    [38] = "Minigun",
    [39] = "Satchel Charge",
    [40] = "Detonator",
    [41] = "Spraycan",
    [42] = "Fire Extinguisher",
    [43] = "Camera",
    [44] = "Night Vis Goggles",
    [45] = "Thermal Goggles",
    [46] = "Parachute" }
    return names[weapon]
end

function naparnik()
    local v = {}
    if isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        for i = 0, 999 do
            if sampIsPlayerConnected(i) then
                local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
                if doesCharExist(ichar) then
                    if isCharInAnyCar(ichar) then
                        local iveh = storeCarCharIsInNoSave(ichar)
                        if veh == iveh then
                            if sampGetFraktionBySkin(i) == 'Полиция' or sampGetFraktionBySkin(i) == 'FBI' then
                                local inick, ifam = sampGetPlayerNickname(i):match('(.+)_(.+)')
                                if inick and ifam then
                                    table.insert(v, string.format('%s.%s', inick:sub(1,1), ifam))
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        local myposx, myposy, myposz = getCharCoordinates(PLAYER_PED)
        for i = 0, 999 do
            if sampIsPlayerConnected(i) then
                local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
                if doesCharExist(ichar) then
                    local ix, iy, iz = getCharCoordinates(ichar)
                    if getDistanceBetweenCoords3d(myposx, myposy, myposz, ix, iy, iz) <= 30 then
                        if sampGetFraktionBySkin(i) == 'Полиция' or sampGetFraktionBySkin(i) == 'FBI' then
                            local inick, ifam = sampGetPlayerNickname(i):match('(.+)_(.+)')
                            if inick and ifam then
                                table.insert(v, string.format('%s.%s', inick:sub(1,1), ifam))
                            end
                        end
                    end
                end
            end
        end
    end
    if #v == 0 then
        return 'Напарников нет.'
    elseif #v == 1 then
        return 'Напарник: '..table.concat(v, ', ').. '.'
    elseif #v >=2 then
        return 'Напарники: '..table.concat(v, ', ').. '.'
    end
end

function onHotKey(id, keys)
    lua_thread.create(function()
        local sKeys = tostring(table.concat(keys, " "))
        for k, v in pairs(tBindList) do
            if sKeys == tostring(table.concat(v.v, " ")) then
                local tostr = tostring(v.text)
                if tostr:len() > 0 then
                    for line in tostr:gmatch('[^\r\n]+') do
                        if line:match("^{wait%:%d+}$") then
                            wait(line:match("^%{wait%:(%d+)}$"))
                        elseif line:match("^{screen}$") then
                            screen()
                        else
                            local bIsEnter = string.match(line, "^{noe}(.+)") ~= nil
                            local bIsF6 = string.match(line, "^{f6}(.+)") ~= nil
                            if not bIsEnter then
                                if bIsF6 then
                                    sampProcessChatInput(line:gsub("{f6}", ""):gsub('{myid}', select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('{kv}', kvadrat()):gsub('{targetid}', targetid):gsub('{targetrpnick}', sampGetPlayerNicknameForBinder(targetid):gsub('_', ' ')):gsub('{naparnik}', naparnik()):gsub('{myrpnick}', sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' ')):gsub('{smsid}', smsid):gsub('{smstoid}', smstoid):gsub('{rang}', rang):gsub('{frak}', frak):gsub('{megafid}', gmegafid):gsub("{dl}", mcid))
                                else
                                    sampSendChat(line:gsub('{myid}', select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('{kv}', kvadrat()):gsub('{targetid}', targetid):gsub('{targetrpnick}', sampGetPlayerNicknameForBinder(targetid):gsub('_', ' ')):gsub('{naparnik}', naparnik()):gsub('{myrpnick}', sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' ')):gsub('{smsid}', smsid):gsub('{smstoid}', smstoid):gsub('{rang}', rang):gsub('{frak}', frak):gsub('{megafid}', gmegafid):gsub("{dl}", mcid))
                                end
                            else
                                sampSetChatInputText(line:gsub("{noe}", ""):gsub('{myid}', select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('{kv}', kvadrat()):gsub('{targetid}', targetid):gsub('{targetrpnick}', sampGetPlayerNicknameForBinder(targetid):gsub('_', ' ')):gsub('{naparnik}', naparnik()):gsub('{myrpnick}', sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' ')):gsub('{smsid}', smsid):gsub('{smstoid}', smstoid):gsub('{rang}', rang):gsub('{frak}', frak):gsub('{megafid}', gmegafid):gsub("{dl}", mcid))
                                sampSetChatInputEnabled(true)
                            end
                        end
                    end
                end
            end
        end
    end)
end
function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end

function kvadrat1(param)
    local KV = {
        ["А"] = 1,
        ["Б"] = 2,
        ["В"] = 3,
        ["Г"] = 4,
        ["Д"] = 5,
        ["Ж"] = 6,
        ["З"] = 7,
        ["И"] = 8,
        ["К"] = 9,
        ["Л"] = 10,
        ["М"] = 11,
        ["Н"] = 12,
        ["О"] = 13,
        ["П"] = 14,
        ["Р"] = 15,
        ["С"] = 16,
        ["Т"] = 17,
        ["У"] = 18,
        ["Ф"] = 19,
        ["Х"] = 20,
        ["Ц"] = 21,
        ["Ч"] = 22,
        ["Ш"] = 23,
        ["Я"] = 24,
        ["а"] = 1,
        ["б"] = 2,
        ["в"] = 3,
        ["г"] = 4,
        ["д"] = 5,
        ["ж"] = 6,
        ["з"] = 7,
        ["и"] = 8,
        ["к"] = 9,
        ["л"] = 10,
        ["м"] = 11,
        ["н"] = 12,
        ["о"] = 13,
        ["п"] = 14,
        ["р"] = 15,
        ["с"] = 16,
        ["т"] = 17,
        ["у"] = 18,
        ["ф"] = 19,
        ["х"] = 20,
        ["ц"] = 21,
        ["ч"] = 22,
        ["ш"] = 23,
        ["я"] = 24,
    }
    return KV[param]
end

function saveData(table, path)
	if doesFileExist(path) then os.remove(path) end
    local sfa = io.open(path, "w")
    if sfa then
        sfa:write(encodeJson(table))
        sfa:close()
    end
end

function getFreeSeat()
    seat = 3
    if isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        for i = 1, 3 do
            if isCarPassengerSeatFree(veh, i) then
                seat = i
            end
        end
    end
    return seat
end

function getNameSphere(id)
    local names =
    {
      [1] = 'АВ',
      [2] = 'АШ',
      [3] = 'СФа',
      [4] = 'В',
      [5] = 'А',
      [6] = 'СФн',
      [7] = 'Тоннель',
      [8] = 'Мэрия',
      [9] = 'Хот-Доги',
      [10] = 'Больница ЛС',
      [11] = 'АВ',
      [12] = 'Мост',
      [13] = 'Перекресток',
      [14] = 'Развилка',
      [15] = 'В',
      [16] = 'А',
      [17] = 'В',
      [18] = 'С',
      [19] = 'КПП',
      [20] = 'Порт ЛС',
      [21] = 'Опасный район',
      [32] = 'КПП',
      [33] = 'D',
      [34] = 'Холл Мэрии',
      [35] = 'Авторынок'
    }
    return names[id]
end

function longtoshort(long)
    local short =
    {
      ['Армия ЛВ'] = 'LVa',
      ['Армия СФ'] = 'SFa',
      ['ФБР'] = 'FBI'
    }
    return short[long]
end
local osnova = {
	{
		title = 'Лаборатория',
		onclick = function()
			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			sampSendChat(("/r %s в сотрудника лаборатории."):format(cfg.main.male and 'Переоделся' or 'Переоделась'))
	        wait(1400)
	        sampSendChat("/rb "..myid)
		end
	},
	{
		title = 'Гражданский',
		onclick = function()
			mstype = 'гражданского'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Полиция',
		onclick = function()
			mstype = 'полицейского'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Армия',
		onclick = function()
			mstype = 'военного'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'МЧС',
		onclick = function()
			mstype = 'медика'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Мэрия',
		onclick = function()
			mstype = 'сотрудника мэрии'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Автошкола',
		onclick = function()
			mstype = 'работника автошколы'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Новости',
		onclick = function()
			mstype = 'работника новостей'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'LCN',
		ocnlick = function()
			mstype = 'ЧПО LCN'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Yakuza',
		onclick = function()
			mstype = 'ЧОП Yakuza'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Russian Mafia',
		onclick = function()
			mstype = 'ЧОП Russian Mafia'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Rifa',
		onclick = function()
			mstype = 'БК Rifa'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Grove',
		onclick = function()
			mstype = 'БК Grove'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Ballas',
		onclick = function()
			mstype = 'БК Ballas'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Vagos',
		onclick = function()
			mstype = 'БК Vagos'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Aztec',
		onclick = function()
			mstype = 'БК Aztec'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	},
	{
		title = 'Байкеры',
		onclick = function()
			mstype = 'байкеров'
			sampShowDialog(1385, '{0C2265}FBI Tools {ffffff}| Маскировка', 'Введите: причину', '»', 'x', 1)
		end
	}
}

local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}
local tCarsTypeName = {"Автомобиль", "Мотоицикл", "Вертолёт", "Самолёт", "Прицеп", "Лодка", "Другое", "Поезд", "Велосипед"}
local tCarsSpeed = {43, 40, 51, 30, 36, 45, 30, 41, 27, 43, 36, 61, 46, 30, 29, 53, 42, 30, 32, 41, 40, 42, 38, 27, 37,
54, 48, 45, 43, 55, 51, 36, 26, 30, 46, 0, 41, 43, 39, 46, 37, 21, 38, 35, 30, 45, 60, 35, 30, 52, 0, 53, 43, 16, 33, 43,
29, 26, 43, 37, 48, 43, 30, 29, 14, 13, 40, 39, 40, 34, 43, 30, 34, 29, 41, 48, 69, 51, 32, 38, 51, 20, 43, 34, 18, 27,
17, 47, 40, 38, 43, 41, 39, 49, 59, 49, 45, 48, 29, 34, 39, 8, 58, 59, 48, 38, 49, 46, 29, 21, 27, 40, 36, 45, 33, 39, 43,
43, 45, 75, 75, 43, 48, 41, 36, 44, 43, 41, 48, 41, 16, 19, 30, 46, 46, 43, 47, -1, -1, 27, 41, 56, 45, 41, 41, 40, 41,
39, 37, 42, 40, 43, 33, 64, 39, 43, 30, 30, 43, 49, 46, 42, 49, 39, 24, 45, 44, 49, 40, -1, -1, 25, 22, 30, 30, 43, 43, 75,
36, 43, 42, 42, 37, 23, 0, 42, 38, 45, 29, 45, 0, 0, 75, 52, 17, 32, 48, 48, 48, 44, 41, 30, 47, 47, 40, 41, 0, 0, 0, 29, 0, 0
}
local tCarsType = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1,
3, 1, 1, 1, 1, 6, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 6, 3, 2, 8, 5, 1, 6, 6, 6, 1,
1, 1, 1, 1, 4, 2, 2, 2, 7, 7, 1, 1, 2, 3, 1, 7, 6, 6, 1, 1, 4, 1, 1, 1, 1, 9, 1, 1, 6, 1,
1, 3, 3, 1, 1, 1, 1, 6, 1, 1, 1, 3, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 9, 9, 4, 4, 4, 1, 1, 1,
1, 1, 4, 4, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 1, 1,
1, 3, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 4,
1, 1, 1, 2, 1, 1, 5, 1, 2, 1, 1, 1, 7, 5, 4, 4, 7, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 1, 5, 5
}

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
                        ftext('Обнаружено обновление {0C2265}FBI Tools{ffffff}. Для обновления нажмите кнопку в окошке.')
                        ftext('Примечание: Если у вас не появилось окошко введите {0C2265}/ft')
                        updwindows.v = true
                        canupdate = true
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

function libs()
    if not limgui or not lsampev or not lsphere or not lrkeys or not limadd then
        ftext('Начата загрузка недостающих библиотек')
        ftext('По окончанию загрузки скрипт будет перезагружен')
        if limgui == false then
            imgui_download_status = 'proccess'
            downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/imgui.lua', 'moonloader/lib/imgui.lua', function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    imgui_download_status = 'proccess'
                    print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    imgui_download_status = 'succ'
                elseif status == 64 then
                    imgui_download_status = 'failed'
                end
            end)
            while imgui_download_status == 'proccess' do wait(0) end
            if imgui_download_status == 'failed' then
                print('Не удалось загрузить: imgui.lua')
                thisScript():unload()
            else
                print('Файл: imgui.lua успешно загружен')
                if doesFileExist('moonloader/lib/MoonImGui.dll') then
                    print('Imgui был загружен')
                else
                    imgui_download_status = 'proccess'
                    downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/MoonImGui.dll', 'moonloader/lib/MoonImGui.dll', function(id, status, p1, p2)
                        if status == dlstatus.STATUS_DOWNLOADINGDATA then
                            imgui_download_status = 'proccess'
                            print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                        elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                            imgui_download_status = 'succ'
                        elseif status == 64 then
                            imgui_download_status = 'failed'
                        end
                    end)
                    while imgui_download_status == 'proccess' do wait(0) end
                    if imgui_download_status == 'failed' then
                        print('Не удалось загрузить Imgui')
                        thisScript():unload()
                    else
                        print('Imgui был загружен')
                    end
                end
            end
        end
        if not lsampev then
            local folders = {'samp', 'samp/events'}
            local files = {'events.lua', 'raknet.lua', 'synchronization.lua', 'events/bitstream_io.lua', 'events/core.lua', 'events/extra_types.lua', 'events/handlers.lua', 'events/utils.lua'}
            for k, v in pairs(folders) do if not doesDirectoryExist('moonloader/lib/'..v) then createDirectory('moonloader/lib/'..v) end end
            for k, v in pairs(files) do
                sampev_download_status = 'proccess'
                downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/samp/'..v, 'moonloader/lib/samp/'..v, function(id, status, p1, p2)
                    if status == dlstatus.STATUS_DOWNLOADINGDATA then
                        sampev_download_status = 'proccess'
                        print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                    elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                        sampev_download_status = 'succ'
                    elseif status == 64 then
                        sampev_download_status = 'failed'
                    end
                end)
                while sampev_download_status == 'proccess' do wait(0) end
                if sampev_download_status == 'failed' then
                    print('Не удалось загрузить sampev')
                    thisScript():unload()
                else
                    print(v..' был загружен')
                end
            end
        end
        if not lsphere then
            sphere_download_status = 'proccess'
            downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/sphere.lua', 'moonloader/lib/sphere.lua', function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    sphere_download_status = 'proccess'
                    print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sphere_download_status = 'succ'
                elseif status == 64 then
                    sphere_download_status = 'failed'
                end
            end)
            while sphere_download_status == 'proccess' do wait(0) end
            if sphere_download_status == 'failed' then
                print('Не удалось загрузить Sphere.lua')
                thisScript():unload()
            else
                print('Sphere.lua был загружен')
            end
        end
        if not lrkeys then
            rkeys_download_status = 'proccess'
            downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/rkeys.lua', 'moonloader/lib/rkeys.lua', function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    rkeys_download_status = 'proccess'
                    print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    rkeys_download_status = 'succ'
                elseif status == 64 then
                    rkeys_download_status = 'failed'
                end
            end)
            while rkeys_download_status == 'proccess' do wait(0) end
            if rkeys_download_status == 'failed' then
                print('Не удалось загрузить rkeys.lua')
                thisScript():unload()
            else
                print('rkeys.lua был загружен')
            end
        end
        if not limadd then
            imadd_download_status = 'proccess'
            downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/lib/imgui_addons.lua', 'moonloader/lib/imgui_addons.lua', function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    imadd_download_status = 'proccess'
                    print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    imadd_download_status = 'succ'
                elseif status == 64 then
                    imadd_download_status = 'failed'
                end
            end)
            while imadd_download_status == 'proccess' do wait(0) end
            if imadd_download_status == 'failed' then
                print('Не удалось загрузить imgui_addons.lua')
                thisScript():unload()
            else
                print('imgui_addons.lua был загружен')
            end
        end
        ftext('Все необходимые библиотеки были загружены')
        reloadScripts()
    else
        print('Все необходиме библиотеки были найдены и загружены')
    end
end

function checkStats()
    while not sampIsLocalPlayerSpawned() do wait(0) end
    checkstat = true
    sampSendChat('/stats')
	setVirtualKeyDown(key.VK_TAB, false)
	wait(3)
	setVirtualKeyDown(key.VK_TAB, false)
	local chtime = os.clock() + 10
    while chtime > os.clock() do wait(0) end
    local chtime = nil
    checkstat = false
    if rang == -1 and frak == -1 then
        frak = 'Нет'
        rang = 'Нет'
        ftext('Не удалось определить статистику персонажа. Повторить попытку?', -1)
        ftext('Подтвердить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | Отменить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
        opyatstat = true
    end
end

function ykf()
    if not doesFileExist('moonloader/fbitools/yk.txt') then
        local fpathyk = os.getenv('TEMP') .. '\\yk.txt'
        downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/yk.txt', fpath, function(id, status, p1, p2)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                local f = io.open(fpathyk, 'r')
                if f then
                    local file = io.open("moonloader/fbitools/yk.txt", "w")
                    file:write(u8:decode(f:read('*a')))
                    file:close()
                else
                    local file = io.open("moonloader/fbitools/yk.txt", "w")
                    file:write("Произошла ошибка закачки УК.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
                    file:close()
                end
            elseif status == 64 then
                local file = io.open("moonloader/fbitools/yk.txt", "w")
                file:write("Произошла ошибка закачки УК.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
                file:close()
            end
        end)
    end
    if not doesFileExist('moonloader/fbitools/yk.txt') then
        local file = io.open("moonloader/fbitools/yk.txt", "w")
        file:write("Произошла ошибка закачки УК.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
        file:close()
    end

end

function shpf()
    if not doesFileExist("moonloader/fbitools/shp.txt") then
        local file = io.open("moonloader/fbitools/shp.txt", 'w')
        file:write(shpt)
        file:close()
    end
end

function fpf()
    if not doesFileExist('moonloader/fbitools/fp.txt') then
        local fpathfp = os.getenv('TEMP') .. '\\fp.txt'
        downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/fp.txt', fpath, function(id, status, p1, p2)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                local f = io.open(fpathfp, 'r')
                if f then
                    local file = io.open("moonloader/fbitools/fp.txt", "w")
                    file:write(u8:decode(f:read('*a')))
                    file:close()
                else
                    local file = io.open("moonloader/fbitools/fp.txt", "w")
                    file:write("Произошла ошибка закачки ФП.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
                    file:close()
                end
            elseif status == 64 then
                local file = io.open("moonloader/fbitools/fp.txt", "w")
                file:write("Произошла ошибка закачки ФП.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
                file:close()
            end
        end)
    end
    if not doesFileExist('moonloader/fbitools/fp.txt') then 
        local file = io.open("moonloader/fbitools/fp.txt", "w")
        file:write("Произошла ошибка закачки ФП.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
        file:close()
    end
end

function akf()
    if not doesFileExist('moonloader/fbitools/ak.txt') then
        local fpathak = os.getenv('TEMP') .. '\\ak.txt'
        downloadUrlToFile('https://raw.githubusercontent.com/WhackerH/kirya/master/ak.txt', fpath, function(id, status, p1, p2)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                local f = io.open(fpathak, 'r')
                if f then
                    local file = io.open("moonloader/fbitools/ak.txt", "w")
                    file:write(u8:decode(f:read('*a')))
                    file:close()
                else
                    local file = io.open("moonloader/fbitools/ak.txt", "w")
                    file:write("Произошла ошибка закачки АК.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
                    file:close()
                end
            elseif status == 64 then
                local file = io.open("moonloader/fbitools/ak.txt", "w")
                file:write("Произошла ошибка закачки АК.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
                file:close()
            end
        end)
    end
    if not doesFileExist('moonloader/fbitools/ak.txt') then
        local file = io.open("moonloader/fbitools/ak.txt", "w")
        file:write("Произошла ошибка закачки АК.\nИзменить текст этой шпоры можно в файле: moonloader/fbitools/yk.txt")
        file:close()
    end
end

function suf()
    if not doesFileExist('moonloader/fbitools/su.txt') then
        local file = io.open('moonloader/fbitools/su.txt', 'w')
        file:write(sut)
        file:close()
        file = nil
    end
end

function mcheckf() if not doesFileExist('moonloader/fbitools/mcheck.txt') then io.open("moonloader/fbitools/mcheck.txt", "w"):close() end end

function sampGetPlayerNicknameForBinder(nikkid)
    local nick = '-1'
    local nickid = tonumber(nikkid)
    if nickid ~= nil then
        if sampIsPlayerConnected(nickid) then
            nick = sampGetPlayerNickname(nickid)
        end
    end
    return nick
end

function sumenu(args)
    return
    {
      {
        title = '{5b83c2}« Раздел №1 »',
        onclick = function()
        end
      },
      {
        title = '{ffffff}» Избиение - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Избиение")
        end
      },
      {
        title = '{ffffff}» Вооруженное нападение на гражданского - {ff0000}3 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 3 Вооруженное нападение на гражданского")
        end
      },
      {
        title = '{ffffff}» Вооруженное нападение на гос.служащего - {ff0000}6 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 6 Вооруженное нападение на ПО")
        end
      },
      {
        title = '{ffffff}» Убийство человека - {ff0000}3 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 3 Убийство человека")
        end
      },
      {
        title = '{ffffff}» Хулиганство - {ff0000}1 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 1 Хулиганство")
        end
      },
      {
        title = '{ffffff}» Неадекватное поведение - {ff0000}1 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 1 Неадекватное поведение")
        end
      },
      {
        title = '{ffffff}» Попрошайничество - {ff0000}1 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 1 Попрошайничество")
        end
      },
      {
        title = '{ffffff}» Оскорбление - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Оскорбление")
        end
      },
      {
        title = '{ffffff}» Наезд на пешехода - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Наезд на пешехода")
        end
      },
      {
        title = '{ffffff}» Игнорирование спец.сигнала - {ff0000}1 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 1 Игнорирование спец.сигнала")
        end
      },
      {
        title = '{ffffff}» Угон транспортного средства - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Угон транспортного средства")
        end
      },
      {
        title = '{ffffff}» Порча чужого имущества - {ff0000}1 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.. " 1 Порча чужого имущества")
        end
      },
      {
        title = '{ffffff}» Уничтожение чужого имущества - {ff0000}4 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 4 Уничтожение чужого имущества")
        end
      },
      {
        title = '{ffffff}» Неподчинение сотруднику ПО - {ff0000}1 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 1 Неподчинение сотруднику ПО")
        end
      },
      {
        title = '{ffffff}» Уход от сотрудника ПО - {ff0000}2 уровень розыска',
        onclick = function()
          sampSendChat("/su "..args.." 2 Уход от сотрудника ПО")
        end
      },
      {
          title = '{ffffff}» Уход с места ДТП - {ff0000}3 уровень розыска',
          onclick = function()
            sampSendChat('/su '..args.. ' 3 Уход с места ДТП')
          end
      },
      {
        title = '{ffffff}» Побег из места заключения - {ff0000}6 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 6 Побег из места заключения")
        end
      },
      {
        title = '{ffffff}» Проникновение на охраняемую территорию - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Проникновение на охр. территорию")
        end
      },
      {
        title = '{ffffff}» Провокация - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Провокация")
        end
      },
      {
        title = '{ffffff}» Угрозы - {ff0000}1 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 1 Угрозы")
        end
      },
      {
        title = '{ffffff}» Предложение интим. услуг - {ff0000}1 уровень розыска',
        onclick = function()
          sampSendChat('/su '..args..' 1 Предложение интимных услуг')
        end
      },
      {
        title = '{ffffff}» Изнасилование - {ff0000}3 уровень розыска',
        onclick = function()
          sampSendChat('/su '..args..' 3 Изнасилование')
        end
      },
      {
        title = '{ffffff}» Чистосердечное признание - {ff0000}1 уровень розыска.',
        onclick = function()
          local result = isCharInAnyCar(PLAYER_PED)
          if result then
            sampSendChat("/clear "..args)
            wait(1400)
            sampSendChat("/su "..args.." 1 Чистосердечное признание")
          else
            sampAddChatMessage("{0C2265}FBI Tools {FFFFFF}| Вы должны быть в машине.", -1)
          end
        end
      },
      {
        title = '{ffbc54}« Раздел №2 »',
        onclick = function()
        end
      },
      {
        title = '{ffffff}» Хранение материалов - {ff0000}3 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 3 Хранение материалов")
        end
      },
      {
        title = '{ffffff}» Хранение наркотиков - {ff0000}3 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 3 Хранение наркотиков")
        end
      },
      {
        title = '{ffffff}» Продажа ключей от камеры - {ff0000}6 уровень розыска',
        onclick = function()
          sampSendChat("/su "..args.." 6 Продажа ключей от камеры")
        end
      },
      {
        title = '{ffffff}» Употребление наркотиков - {ff0000}3 уровень розыска',
        onclick = function()
          sampSendChat("/su "..args.." 3 Употребление наркотиков")
        end
      },
      {
        title = '{ffffff}» Продажа наркотиков - {ff0000}2 уровень розыска',
        onclick = function()
          sampSendChat("/su "..args.." 2 Продажа наркотиков")
        end
      },
      {
        title = '{ffffff}» Покупка военной формы - {ff0000}2 уровень розыска',
        onclick = function()
          sampSendChat("/su "..args.." 2 Покупка военной формы")
        end
      },
      {
        title = '{ffffff}» Предложение взятки гос.служащему - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Предложение взятки гос.служащему")
        end
      },
      {
        title = '{ae0620}« Раздел №3 »',
        onclick = function()
        end
      },
      {
        title = '{ffffff}» Уход в AFK от ареста - {ff0000}6 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 6 Уход")
        end
      },
      {
        title = '{ffffff}» Совершение терракта - {ff0000}6 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 6 Совершение теракта")
        end
      },
      {
        title = '{ffffff}» Неуплата штрафа - {ff0000}2 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 2 Неуплата штрафа")
        end
      },
      {
        title = '{ffffff}» Превышение полномочий адвоката - {ff0000}3 уровень розыска.',
        onclick = function()
          sampSendChat("/su "..args.." 3 Превышение полномочий адвоката")
        end
      },
      {
        title = '{ffffff}» Похищение гражданского/гос.служащего - {ff0000}4 уровень розыска',
        onclick = function()
          sampSendChat("/su "..args.." 4 Похищение")
        end
      },
      {
        title = '{ffffff}» Статус ООП - {ff0000}6 уровень розыска',
        onclick = function()
          sampSendChat("/su "..args.." 6 ООП")
        end
      }
    }
end
function pkmmenu(id)
	return
	{
		{
			title = '{ffffff}» Надеть наручники',
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(string.format('/me %s руки %s и %s наручники', cfg.main.male and 'заломал' or 'заломала', sampGetPlayerNickname(id):gsub("_", " "), cfg.main.male and 'достал' or 'достала'))
					wait(1400)
					sampSendChat(string.format('/cuff %s', id))
				end
			end
		},
		{
			title = "{ffffff}» Вести за собой",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(string.format('/me %s один из концов наручников к себе, после чего %s за собой %s', cfg.main.male and 'пристегнул' or 'пристегнула', cfg.main.male and 'повел' or 'повела', sampGetPlayerNickname(id):gsub("_", " ")))
					wait(1400)
					sampSendChat(string.format('/follow %s', id))
				end
			end
		},
		{
			title = "{ffffff}» Произвести обыск",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(string.format("/me надев перчатки, %s руками по торсу", cfg.main.male and 'провел' or 'провела'))
					wait(cfg.commands.zaderjka)
					sampSendChat(('/take %s'):format(id))
				end
			end
		},
		{
			title = "{ffffff}» Произвести арест",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(('/me достав ключи от камеры %s ее'):format(cfg.main.male and 'открыл' or 'открыла'))
					wait(cfg.commands.zaderjka)
					sampSendChat(('/me %s %s в камеру'):format(cfg.main.male and 'затолкнул' or 'затолкнула', sampGetPlayerNickname(id):gsub("_", " ")))
					wait(cfg.commands.zaderjka)
					sampSendChat(('/arrest %s'):format(id))
					wait(cfg.commands.zaderjka)
					sampSendChat(('/me закрыв камеру %s ключи в карман'):format(cfg.main.male and 'убрал' or 'убрала'))
				end
			end
		},
		{
			title = '{ffffff}» Снять наручники',
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(('/me %s наручники с %s'):format(cfg.main.male and 'снял' or 'сняла', sampGetPlayerNickname(id):gsub("_", " ")))
					wait(1400)
					sampSendChat(('/uncuff %s'):format(id))
				end
			end
        },
        {
            title = "{ffffff}» Снять маску",
            onclick = function()
                if sampIsPlayerConnected(id) then
                    sampSendChat(("/offmask %s"):format(id))
                end
            end
        },
		{
			title = "{ffffff}» Выдать розыск за проникновение",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 2 Проникновение на охр. территорию"):format(id))
				end
			end
		},
		{
			title = "{ffffff}» Выдать розыск за хранение наркотиков",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 3 Хранение наркотиков"):format(id))
				end
			end
		},
		{
			title = "{ffffff}» Выдать розыск за хранение материалов",
			onclick = function()
				if sampIsPlayerConnected(id) then
					sampSendChat(("/su %s 3 Хранение материалов"):format(id))
				end
			end
		},
		{
		title = "{ffffff}» Выдать розыск за продажу наркотиков",
        onclick = function()
          if cfg.main.male == true then
            sampSendChat("/su "..id.." 2 Продажа наркотиков")
            wait(1200)
            sampSendChat("/me заломал руки "..sampGetPlayerNickname(id).." и достал наручники")
            wait(1200)
            sampSendChat("/cuff "..id)
          end
          if cfg.main.male == false then
            sampSendChat("/su "..id.." 2 Продажа наркотиков")
            wait(1200)
            sampSendChat("/me заломала руки "..sampGetPlayerNickname(id).." и достала наручники")
            wait(1200)
            sampSendChat("/cuff "..id)
          end
        end
      },
      {
        title = "{ffffff}» Выдать розыск за продажу оружия",
        onclick = function()
          if cfg.main.male == true then
            sampSendChat("/su "..id.." 2 Продажа нелегального оружия")
            wait(1200)
            sampSendChat("/me заломал руки "..sampGetPlayerNickname(id).." и достал наручники")
            wait(1200)
            sampSendChat("/cuff "..id)
          end
          if cfg.main.male == false then
            sampSendChat("/su "..id.." 2 Продажа нелегального оружия")
            wait(1200)
            sampSendChat("/me заломала руки "..sampGetPlayerNickname(id).." и достала наручники")
            wait(1200)
            sampSendChat("/cuff "..id)
          end
        end
      },
	  {
        title = "{ffffff}» Выдать розыск за продажу ключей от камеры",
        onclick = function()
          if cfg.main.male == true then
            sampSendChat("/su "..id.." 6 Продажа ключей от камеры")
            wait(1200)
            sampSendChat("/me заломал руки "..sampGetPlayerNickname(id).." и достал наручники")
            wait(1200)
            sampSendChat("/cuff "..id)
          end
          if cfg.main.male == false then
            sampSendChat("/su "..id.." 6 Продажа ключей от камеры")
            wait(1200)
            sampSendChat("/me заломала руки "..sampGetPlayerNickname(id).." и достала наручники")
            wait(1200)
            sampSendChat("/cuff "..id)
          end
        end
      },
      {
        title = "{ffffff}» Выдать розыск за вооруженное нападение на ПО",
        onclick = function()
          sampSendChat("/su "..id.. " 6 Вооруженное нападение на ПО")
        end
      },
      {
        title = "{ffffff}» Выдать розыск",
        onclick = function()
          pID = tonumber(args)
          submenus_show(sumenu(id), "{0C2265}FBI Tools {ffffff}| "..sampGetPlayerNickname(id).."["..id.."] ")
        end
      },
      {
        title = '{ffffff}» Данные о судимости',
        onclick = function()
          if cfg.main.male == true then
            sampSendChat("/me достал мобильный компьютер")
            wait(cfg.commands.zaderjka)
            sampSendChat("/me пробил "..sampGetPlayerNickname(id).." в базе данных")
            wait(cfg.commands.zaderjka)
            sampSendChat("/mdc "..id)
            wait(cfg.commands.zaderjka)
            sampSendChat("/me распечатал информацию")
            wait(cfg.commands.zaderjka)
            sampSendChat("/me передал информацию человек напротив")
            wait(cfg.commands.zaderjka)
            sampSendChat("/me убрал мобильный компьютер")
          end
        end
      },
	  {
        title = '{ffffff}» Сорвать маску',
        onclick = function()
          if cfg.main.male == true then
            sampSendChat("/offmask "..id)
          end
        end
      },
	  {
        title = '{ffffff}» Заполнить акт-задержания',
        onclick = function()
          if cfg.main.male == true then
            sampSendChat("/me достал бланк задержания")
            wait(cfg.commands.zaderjka)
            sampSendChat("/me заполнил бланк задержания на имя "..sampGetPlayerNickname(id).."")
            wait(cfg.commands.zaderjka)
            sampSendChat("/me поставил подпись")
            wait(cfg.commands.zaderjka)
            sampSendChat("Расписываться будете?")
          end
        end
      },
	  {
        title = "{ffffff}» Аннулировать лицензию на вождение",
        onclick = function()
          if cfg.main.male == true then
			sampSendChat("/me достал КПК и аннулировал лицензию на вождение у "..sampGetPlayerNickname(id):gsub('_', ' '))
            wait(1200)
            sampSendChat("/take "..id)
          end
          if cfg.main.male == false then
			sampSendChat("/me достала КПК и аннулировала лицензию на вождение у "..sampGetPlayerNickname(id):gsub('_', ' '))
            wait(1200)
            sampSendChat("/take "..id)
          end
        end
      },
	  {
        title = "{ffffff}» Аннулировать лицензию на оружие",
        onclick = function()
          if cfg.main.male == true then
			sampSendChat("/me достал КПК и аннулировал лицензию на оружие у "..sampGetPlayerNickname(id):gsub('_', ' '))
            wait(1200)
            sampSendChat("/take "..id)
          end
          if cfg.main.male == false then
			sampSendChat("/me достала КПК и аннулировала лицензию на оружие у "..sampGetPlayerNickname(id):gsub('_', ' '))
            wait(1200)
            sampSendChat("/take "..id)
          end
        end
		}
	}
end

function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	style.WindowRounding = 2.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ChildWindowRounding = 2.0
	style.FrameRounding = 2.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0

	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function onScriptTerminate(scr)
    if scr == script.this then
		showCursor(false)
	end
end

if limgui then
    function imgui.TextQuestion(text)
        imgui.TextDisabled('(?)')
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(450)
            imgui.TextUnformatted(text)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        end
    end
    function imgui.CentrText(text)
        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize(text)
        imgui.SetCursorPosX( width / 2 - calc.x / 2 )
        imgui.Text(text)
    end
    function imgui.CustomButton(name, color, colorHovered, colorActive, size)
        local clr = imgui.Col
        imgui.PushStyleColor(clr.Button, color)
        imgui.PushStyleColor(clr.ButtonHovered, colorHovered)
        imgui.PushStyleColor(clr.ButtonActive, colorActive)
        if not size then size = imgui.ImVec2(0, 0) end
        local result = imgui.Button(name, size)
        imgui.PopStyleColor(3)
        return result
    end
    function imgui.OnDrawFrame()
        if infbar.v then
		
            imgui.ShowCursor = false
            _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            local myname = sampGetPlayerNickname(myid)
            local myping = sampGetPlayerPing(myid)
            local myweapon = getCurrentCharWeapon(PLAYER_PED)
            local myweaponammo = getAmmoInCharWeapon(PLAYER_PED, myweapon)
            local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
            local myweaponname = getweaponname(myweapon)
            imgui.SetNextWindowPos(imgui.ImVec2(cfg.main.posX, cfg.main.posY), imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(cfg.main.widehud, 140), imgui.Cond.FirstUseEver)
            imgui.Begin('FBI Tools', infbar, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
            --imgui.CentrText('FBI Tools')
            --imgui.Separator()
            imgui.Text((u8"Информация: %s [%s] | Пинг: %s"):format(myname, myid, myping))
            imgui.Text((u8 'Оружие: %s [%s]'):format(myweaponname, myweaponammo))
            if isCharInAnyCar(playerPed) then
                local vHandle = storeCarCharIsInNoSave(playerPed)
                local result, vID = sampGetVehicleIdByCarHandle(vHandle)
                local vHP = getCarHealth(vHandle)
                local carspeed = getCarSpeed(vHandle)
                local speed = math.floor(carspeed)
                local vehName = tCarsName[getCarModel(storeCarCharIsInNoSave(playerPed))-399]
                local ncspeed = math.floor(carspeed*2)
                imgui.Text((u8 'Транспорт: %s [%s] | HP: %s | Скорость: %s'):format(vehName, vID, vHP, ncspeed))
            else
                imgui.Text(u8 'Транспорта нет')
            end
            if valid and doesCharExist(ped) then 
                local result, id = sampGetPlayerIdByCharHandle(ped)
                if result then
                    local targetname = sampGetPlayerNickname(id)
                    local targetscore = sampGetPlayerScore(id)
                    imgui.Text((u8 'Цель: %s [%s] | Уровень: %s'):format(targetname, id, targetscore))
                else
                    imgui.Text(u8 'Цель: Нет')
                end
            else
                imgui.Text(u8 'Цель: Нет')
            end
            imgui.Text((u8 'Квадрат: %s'):format(u8(kvadrat())))
            imgui.Text((u8 'Время: %s'):format(os.date('%H:%M:%S')))
            imgui.Text((u8 'Тайзер: %s'):format(u8(stazer and 'Вкл' or 'Выкл')))
            if imgui.IsMouseClicked(0) and changetextpos then
                changetextpos = false
                sampToggleCursor(false)
                mainw.v = true
                saveData(cfg, 'moonloader/config/fbitools/config.json')
            end
            imgui.End()
        end
        if imegaf.v then
            imgui.ShowCursor = true
            local x, y = getScreenResolution()
            local btn_size = imgui.ImVec2(-0.1, 0)
            imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver)
            imgui.SetNextWindowPos(imgui.ImVec2(x/2+300, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.Begin(u8'FBI Tools | Мегафон', imegaf, imgui.WindowFlags.NoResize)
            for k, v in ipairs(incar) do
                local mx, my, mz = getCharCoordinates(PLAYER_PED)
                if sampIsPlayerConnected(v) then
                    local result, ped = sampGetCharHandleBySampPlayerId(v)
                    if result then
                        local px, py, pz = getCharCoordinates(ped)
                        local dist = math.floor(getDistanceBetweenCoords3d(mx, my, mz, px, py, pz))
                        if isCharInAnyCar(ped) then
                            local carh = storeCarCharIsInNoSave(ped)
                            local carhm = getCarModel(carh)
                            if imgui.Button(("%s [EVL%sX] | Distance: %s m.##%s"):format(tCarsName[carhm-399], v, dist, k), btn_size) then
                                lua_thread.create(function()
                                    imegaf.v = false
                                    sampSendChat(("/m Водитель а/м %s [EVL%sX]"):format(tCarsName[carhm-399], v))
                                    wait(1400)
                                    sampSendChat("/m Прижмитесь к обочине или мы откроем огонь!")
                                    wait(300)
                                    sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x0C2265)
                                    sampAddChatMessage('', 0x0C2265)
                                    sampAddChatMessage(' {ffffff}Ник: {0C2265}'..sampGetPlayerNickname(v)..' ['..v..']', 0x0C2265)
                                    sampAddChatMessage(' {ffffff}Уровень: {0C2265}'..sampGetPlayerScore(v), 0x0C2265)
                                    sampAddChatMessage(' {ffffff}Фракция: {0C2265}'..sampGetFraktionBySkin(v), 0x0C2265)
                                    sampAddChatMessage('', 0x0C2265)
                                    sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x0C2265)
                                    gmegafid = v
                                    gmegaflvl = sampGetPlayerScore(v)
                                    gmegaffrak = sampGetFraktionBySkin(v)
                                    gmegafcar = tCarsName[carhm-399]
                                end)
                            end
                        end
                    end
                end
            end
            imgui.End()
        end
        if updwindows.v then
            local updlist = ttt
            imgui.LockPlayer = true
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(700, 290), imgui.Cond.FirstUseEver)
            imgui.Begin(u8('FBI Tools | Обновление'), updwindows, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            imgui.Text(u8('Вышло обновление скрипта FBI Tools! Что бы обновиться нажмите кнопку внизу. Список изменений:'))
            imgui.Separator()
            imgui.BeginChild("uuupdate", imgui.ImVec2(690, 200))
            for line in ttt:gmatch('[^\r\n]+') do
                imgui.TextWrapped(line)
            end
            imgui.EndChild()
            imgui.Separator()
            imgui.PushItemWidth(305)
            if imgui.Button(u8("Обновить"), imgui.ImVec2(339, 25)) then
                lua_thread.create(goupdate)
                updwindows.v = false
            end
            imgui.SameLine()
            if imgui.Button(u8("Отложить обновление"), imgui.ImVec2(339, 25)) then
                updwindows.v = false
                ftext("Если вы захотите установить обновление введите команду {0C2265}/ft")
            end
            imgui.End()
        end
        if mainw.v then
            imgui.ShowCursor = true
            local x, y = getScreenResolution()
            local btn_size = imgui.ImVec2(-0.1, 0)
            imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver)
            imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.Begin('FBI Tools | Main Menu | Version: '..thisScript().version, mainw, imgui.WindowFlags.NoResize)
            if imgui.Button(u8'Биндер', btn_size) then
                bMainWindow.v = not bMainWindow.v
            end
            if imgui.Button(u8(cfg.main.nwanted and 'Выключить обновленный Wanted' or 'Включить обновленный Wanted'), btn_size) then
                cfg.main.nwanted = not cfg.main.nwanted
                ftext(cfg.main.nwanted and 'Обновленый Wanted включен' or 'Обновленый Wanted выключен')
                saveData(cfg, 'moonloader/config/fbitools/config.json')
            end
            if imgui.Button(u8(cfg.main.nclear and 'Выключить дополненый Clear' or 'Включить дополненый Clear'), btn_size) then
                cfg.main.nclear = not cfg.main.nclear
                ftext(cfg.main.nclear and 'Дополненый Clear включен' or 'Дополненый Clear выключен')
                saveData(cfg, 'moonloader/config/fbitools/config.json')
            end
            if imgui.Button(u8 'Команды скрипта', btn_size) then cmdwind.v = not cmdwind.v end
            if imgui.Button(u8'Настройки скрипта', btn_size) then
                setwindows.v = not setwindows.v
            end
            if imgui.Button(u8 'Сообщить о ошибке / баге', btn_size) then os.execute('explorer "https://vk.me/fbitools"') end
            if canupdate then if imgui.Button(u8 '[!] Доступно обновление скрипта [!]', btn_size) then updwindows.v = not updwindows.v end end
            if imgui.CollapsingHeader(u8 'Действия со скриптом', btn_size) then
                if imgui.Button(u8'Перезагрузить скрипт', btn_size) then
                    thisScript():reload()
                end
                if imgui.Button(u8 'Отключить скрипт', btn_size) then
                    thisScript():unload()
                end
            end
            imgui.End()
            if cmdwind.v then
                local x, y = getScreenResolution()
                imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
                imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.Begin(u8'FBI Tools | Команды', cmdwind)
                for k, v in ipairs(fthelp) do
                    if imgui.CollapsingHeader(v['cmd']..'##'..k) then
                        imgui.TextWrapped(u8('Описание: %s'):format(u8(v['desc'])))
                        imgui.TextWrapped(u8("Использование: %s"):format(u8(v['use'])))
                    end
                end
                imgui.End()
            end
            if bMainWindow.v then
                imgui.LockPlayer = true
                imgui.ShowCursor = true
                local iScreenWidth, iScreenHeight = getScreenResolution()
                imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize(imgui.ImVec2(1000, 510), imgui.Cond.FirstUseEver)
                imgui.Begin(u8("FBI Tools | Биндер##main"), bMainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
                imgui.BeginChild("##bindlist", imgui.ImVec2(995, 442))
                for k, v in ipairs(tBindList) do
                    if imadd.HotKey("##HK" .. k, v, tLastKeys, 100) then
                        if not rkeys.isHotKeyDefined(v.v) then
                            if rkeys.isHotKeyDefined(tLastKeys.v) then
                                rkeys.unRegisterHotKey(tLastKeys.v)
                            end
                            rkeys.registerHotKey(v.v, true, onHotKey)
                        end
                        saveData(tBindList, fileb)
                    end
                    imgui.SameLine()
                    imgui.CentrText(u8(v.name))
                    imgui.SameLine(850)
                    if imgui.Button(u8 'Редактировать бинд##'..k) then imgui.OpenPopup(u8 "Редактирование биндера##editbind"..k) 
                        bindname.v = u8(v.name) 
                        bindtext.v = u8(v.text)
                    end
                    if imgui.BeginPopupModal(u8 'Редактирование биндера##editbind'..k, _, imgui.WindowFlags.NoResize) then
                        imgui.Text(u8 "Введите название биндера:")
                        imgui.InputText("##Введите название биндера", bindname)
                        imgui.Text(u8 "Введите текст биндера:")
                        imgui.InputTextMultiline("##Введите текст биндера", bindtext, imgui.ImVec2(500, 200))
                        imgui.Separator()
                        if imgui.Button(u8 'Ключи', imgui.ImVec2(90, 20)) then imgui.OpenPopup('##bindkey') end
                        if imgui.BeginPopup('##bindkey') then
                            imgui.Text(u8 'Используйте ключи биндера для более удобного использования биндера')
                            imgui.Text(u8 'Пример: /su {targetid} 6 Вооруженное нападение на ПО')
                            imgui.Separator()
                            imgui.Text(u8 '{myid} - ID вашего персонажа | '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                            imgui.Text(u8 '{myrpnick} - РП ник вашего персонажа | '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' '))
                            imgui.Text(u8 ('{naparnik} - Ваши напарники | '..naparnik()))
                            imgui.Text(u8 ('{kv} - Ваш текущий квадрат | '..kvadrat()))
                            imgui.Text(u8 '{targetid} - ID игрока на которого вы целитесь | '..targetid)
                            imgui.Text(u8 '{targetrpnick} - РП ник игрока на которого вы целитесь | '..sampGetPlayerNicknameForBinder(targetid):gsub('_', ' '))
                            imgui.Text(u8 '{smsid} - Последний ID того, кто вам написал в SMS | '..smsid)
                            imgui.Text(u8 '{smstoid} - Последний ID того, кому вы написали в SMS | '..smstoid)
                            imgui.Text(u8 '{megafid} - ID игрока, за которым была начата погоня | '..gmegafid)
                            imgui.Text(u8 '{rang} - Ваше звание | '..u8(rang))
                            imgui.Text(u8 '{frak} - Ваша фракция | '..u8(frak))
                            imgui.Text(u8 '{dl} - ID авто, в котором вы сидите | '..mcid)
                            imgui.Text(u8 '{f6} - Отправить сообщение в чат через эмуляцию чата (использовать в самом начале)')
                            imgui.Text(u8 '{noe} - Оставить сообщение в полле ввода а не отправлять его в чат (использовать в самом начале)')
                            imgui.Text(u8 '{wait:sek} - Задержка между строками, где sek - кол-во миллисекунд. Пример: {wait:2000} - задержка 2 секунды. (использовать отдельно на новой строчке)')
                            imgui.Text(u8 '{screen} - Сделать скриншот экрана (использовать отдельно на новой строчке)')
                            imgui.EndPopup()
                        end
                        imgui.SameLine()
                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 90 - imgui.GetStyle().ItemSpacing.x))
                        if imgui.Button(u8 "Удалить бинд##"..k, imgui.ImVec2(90, 20)) then
                            table.remove(tBindList, k)
                            saveData(tBindList, fileb)
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 180 + imgui.GetStyle().ItemSpacing.x) / 2)
                        if imgui.Button(u8 "Сохранить##"..k, imgui.ImVec2(90, 20)) then
                            v.name = u8:decode(bindname.v)
                            v.text = u8:decode(bindtext.v)
                            bindname.v = ''
                            bindtext.v = ''
                            saveData(tBindList, fileb)
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button(u8 "Закрыть##"..k, imgui.ImVec2(90, 20)) then imgui.CloseCurrentPopup() end
                        imgui.EndPopup()
                    end
                end
                imgui.EndChild()
                imgui.Separator()
                if imgui.Button(u8"Добавить клавишу") then
                    tBindList[#tBindList + 1] = {text = "", v = {}, time = 0, name = "Бинд"..#tBindList + 1}
                    saveData(tBindList, fileb)
                end
                imgui.End()
            end
            if setwindows.v then
                --
                cput            = imgui.ImBool(cfg.commands.cput)
                ceject          = imgui.ImBool(cfg.commands.ceject)
                ftazer          = imgui.ImBool(cfg.commands.ftazer)
                deject          = imgui.ImBool(cfg.commands.deject)
                kmdcb           = imgui.ImBool(cfg.commands.kmdctime)
                carb            = imgui.ImBool(cfg.main.autocar)
                stateb          = imgui.ImBool(cfg.main.male)
                tagf            = imgui.ImBuffer(u8(cfg.main.tar), 256)
                parolf          = imgui.ImBuffer(u8(tostring(cfg.main.parol)), 256)
                tagb            = imgui.ImBool(cfg.main.tarb)
                xcord           = imgui.ImInt(cfg.main.posX)
                ycord           = imgui.ImInt(cfg.main.posY)
                clistbuffer     = imgui.ImInt(cfg.main.clist)
                waitbuffer      = imgui.ImInt(cfg.commands.zaderjka)
                clistb          = imgui.ImBool(cfg.main.clistb)
                parolb          = imgui.ImBool(cfg.main.parolb)
                offptrlb        = imgui.ImBool(cfg.main.offptrl)
                offwntdb        = imgui.ImBool(cfg.main.offwntd)
                ticketb         = imgui.ImBool(cfg.commands.ticket)
                tchatb          = imgui.ImBool(cfg.main.tchat)
                strobbsb        = imgui.ImBool(cfg.main.strobs)
                megafb          = imgui.ImBool(cfg.main.megaf)
                infbarb         = imgui.ImBool(cfg.main.hud)
                autobpb         = imgui.ImBool(cfg.main.autobp)
                deagleb         = imgui.ImBool(cfg.autobp.deagle)
                shotb           = imgui.ImBool(cfg.autobp.shot)
                smgb            = imgui.ImBool(cfg.autobp.smg)
                m4b             = imgui.ImBool(cfg.autobp.m4)
                rifleb          = imgui.ImBool(cfg.autobp.rifle)
                armourb         = imgui.ImBool(cfg.autobp.armour)
                specb           = imgui.ImBool(cfg.autobp.spec)
                dvadeagleb      = imgui.ImBool(cfg.autobp.dvadeagle)
                dvashotb        = imgui.ImBool(cfg.autobp.dvashot)
                dvasmgb         = imgui.ImBool(cfg.autobp.dvasmg)
                dvam4b          = imgui.ImBool(cfg.autobp.dvam4)
                dvarifleb       = imgui.ImBool(cfg.autobp.dvarifle)
                --
                imgui.LockPlayer = true
                local iScreenWidth, iScreenHeight = getScreenResolution()
                imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(15,6))
                imgui.Begin(u8'Настройки##1', setwindows, imgui.WindowFlags.NoResize)
                imgui.BeginChild('##set', imgui.ImVec2(140, 400), true)
                if imgui.Selectable(u8'Основные', show == 1) then show = 1 end
                if imgui.Selectable(u8'Команды', show == 2) then show = 2 end
                if imgui.Selectable(u8'Клавиши', show == 3) then show = 3 end
                if imgui.Selectable(u8'Авто-БП', show == 4) then show = 4 end
                imgui.EndChild()
                imgui.SameLine()
                imgui.BeginChild('##set1', imgui.ImVec2(800, 400), true)
                if show == 1 then
                    if imadd.ToggleButton(u8 'Инфобар', infbarb) then cfg.main.hud = infbarb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine() imgui.Text(u8 "Инфо-бар")
                    if infbarb.v then
                        imgui.SameLine()
                        if imgui.Button(u8 'Изменить местоположение') then
                            mainw.v = false
                            changetextpos = true
                            ftext('По завешению нажмите левую кнопку мыши')
                        end
                    end
                    if imadd.ToggleButton(u8'Скрывать сообщения о начале преследования', offptrlb) then cfg.main.offptrl = offptrlb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 'Скрывать сообщения о начале преследования')
                    if imadd.ToggleButton(u8'Скрывать сообщения о выдаче розыска', offwntdb) then cfg.main.offwntd = offwntdb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 'Скрывать сообщения о выдаче розыска')
                    if imadd.ToggleButton(u8'Мужские отыгровки', stateb) then cfg.main.male = stateb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 'Мужские отыгровки')
                    if imadd.ToggleButton(u8'Использовать автотег', tagb) then cfg.main.tarb = tagb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end imgui.SameLine(); imgui.Text(u8 'Использовать автотег')
                    if tagb.v then
                        if imgui.InputText(u8'Введите ваш Тег.', tagf) then cfg.main.tar = u8:decode(tagf.v) saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    end
                    if imadd.ToggleButton(u8'Использовать авто логин', parolb) then cfg.main.parolb = parolb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 'Использовать авто логин')
                    if parolb.v then
                        if imgui.InputText(u8'Введите ваш пароль.', parolf, imgui.InputTextFlags.Password) then cfg.main.parol = u8:decode(parolf.v) saveData(cfg, 'moonloader/config/fbitools/config.json') end
                        if imgui.Button(u8'Узнать пароль') then ftext('Ваш пароль: {0C2265}'..cfg.main.parol) end
                    end
                    if imadd.ToggleButton(u8'Использовать автоклист', clistb) then cfg.main.clistb = clistb.v end; imgui.SameLine() saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.Text(u8 'Использовать автоклист')
                    if clistb.v then
                        if imgui.SliderInt(u8"Выберите значение клиста", clistbuffer, 0, 33) then cfg.main.clist = clistbuffer.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    end
                    if imadd.ToggleButton(u8'Открывать чат на T', tchatb) then cfg.main.tchat = tchatb.v end saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.SameLine(); imgui.Text(u8 'Открывать чат на T')
                    if imadd.ToggleButton(u8 'Автоматически заводить авто', carb) then cfg.main.autocar = carb.v end saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.SameLine(); imgui.Text(u8 'Автоматически заводить авто')
                    if imadd.ToggleButton(u8 'Стробоскопы', strobbsb) then cfg.main.strobs = strobbsb.v end saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.SameLine(); imgui.Text(u8 'Стробоскопы')
                    if imadd.ToggleButton(u8'Расширенный мегафон', megafb) then cfg.main.megaf = megafb.v end saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.SameLine(); imgui.Text(u8 'Расширенный мегафон')
                    if imgui.InputInt(u8'Задержка в отыгровках', waitbuffer) then cfg.commands.zaderjka = waitbuffer.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                end
                if show == 2 then
                    if imadd.ToggleButton(u8('Отыгровка /cput'), cput) then cfg.commands.cput = cput.v end; imgui.SameLine(); imgui.Text(u8 'Отыгровка /cput')
                    if imadd.ToggleButton(u8('Отыгровка /ceject'), ceject) then cfg.commands.ceject = ceject.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 'Отыгровка /ceject')
                    if imadd.ToggleButton(u8('Отыгровка /ftazer'), ftazer) then cfg.commands.ftazer = ftazer.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 'Отыгровка /ftazer')
                    if imadd.ToggleButton(u8('Отыгровка /deject'), deject) then cfg.commands.deject = deject.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 'Отыгровка /deject')
                    if imadd.ToggleButton(u8('Отыгровка /ticket'), ticketb) then cfg.commands.ticket = ticketb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 'Отыгровка /ticket')
                    if imadd.ToggleButton(u8('Использовать /time F8 при /kmdc'), kmdcb) then cfg.commands.kmdctime = kmdcb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end; imgui.SameLine(); imgui.Text(u8 'Использовать /time F8 при /kmdc')
                end
                if show == 3 then
                    if imadd.HotKey(u8'##Клавиша быстрого тазера', config_keys.tazerkey, tLastKeys, 100) then
                        rkeys.changeHotKey(tazerbind, config_keys.tazerkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.tazerkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8'Клавиша быстрого тазера')
                    if imadd.HotKey('##fastmenu', config_keys.fastmenukey, tLastKeys, 100) then
                        rkeys.changeHotKey(fastmenubind, config_keys.fastmenukey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.fastmenukey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Клавиша быстрого меню'))
                    if imadd.HotKey('##oopda', config_keys.oopda, tLastKeys, 100) then
                        rkeys.changeHotKey(oopdabind, config_keys.oopda.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.oopda.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Клавиша подтверждения'))
                    if imadd.HotKey('##oopnet', config_keys.oopnet, tLastKeys, 100) then
                        rkeys.changeHotKey(oopnetbind, config_keys.oopnet.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Клавиша отмены'))
                    if imadd.HotKey('##megaf', config_keys.megafkey, tLastKeys, 100) then
                        rkeys.changeHotKey(megafbind, config_keys.megafkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.megafkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Клавиша мегафона'))
                    if imadd.HotKey('##dkld', config_keys.dkldkey, tLastKeys, 100) then
                        rkeys.changeHotKey(dkldbind, config_keys.dkldkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.dkldkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Клавиша доклада'))
                    if imadd.HotKey('##cuff', config_keys.cuffkey, tLastKeys, 100) then
                        rkeys.changeHotKey(cuffbind, config_keys.cuffkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.cuffkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Надеть наручники на преступника'))
                    if imadd.HotKey('##uncuff', config_keys.uncuffkey, tLastKeys, 100) then
                        rkeys.changeHotKey(uncuffbind, config_keys.uncuffkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.uncuffkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Снять наручники'))
                    if imadd.HotKey('##follow', config_keys.followkey, tLastKeys, 100) then
                        rkeys.changeHotKey(followbind, config_keys.followkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.followkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Вести преступника за собой'))
                    if imadd.HotKey('##cput', config_keys.cputkey, tLastKeys, 100) then
                        rkeys.changeHotKey(cputbind, config_keys.cputkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.cputkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Посадить преступника в авто'))
                    if imadd.HotKey('##ceject', config_keys.cejectkey, tLastKeys, 100) then
                        rkeys.changeHotKey(cejectbind, config_keys.cejectkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.cejectkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Высадить преступника в участок'))
                    if imadd.HotKey('##take', config_keys.takekey, tLastKeys, 100) then
                        rkeys.changeHotKey(takebind, config_keys.takekey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.takekey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Обыскать преступника'))
                    if imadd.HotKey('##arrest', config_keys.arrestkey, tLastKeys, 100) then
                        rkeys.changeHotKey(arrestbind, config_keys.arrestkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.arrestkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Арестовать преступника'))
                    if imadd.HotKey('##deject', config_keys.dejectkey, tLastKeys, 100) then
                        rkeys.changeHotKey(dejectbind, config_keys.dejectkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.dejectkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Вытащить преступника из авто'))
                    if imadd.HotKey('##siren', config_keys.sirenkey, tLastKeys, 100) then
                        rkeys.changeHotKey(sirenbind, config_keys.sirenkey.v)
                        ftext('Клавиша успешно изменена. Старое значение: '.. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. ' | Новое значение: '.. table.concat(rkeys.getKeysName(config_keys.sirenkey.v), " + "))
                        saveData(config_keys, 'moonloader/config/fbitools/keys.json')
                    end
                    imgui.SameLine()
                    imgui.Text(u8('Включить / выключить сирену на авто'))
                elseif show == 4 then
                    if imadd.ToggleButton(u8 'Автобп', autobpb) then cfg.main.autobp = autobpb.v end saveData(cfg, 'moonloader/config/fbitools/config.json'); imgui.SameLine(); imgui.Text(u8 'Автоматически брать боеприпасы')
                    if imgui.Checkbox(u8 "Desert Eagle", deagleb) then cfg.autobp.deagle = deagleb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    if deagleb.v then
                        imgui.SameLine(110)
                        if imgui.Checkbox(u8 'Два компекта##1', dvadeagleb) then cfg.autobp.dvadeagle = dvadeagleb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    end
                    if imgui.Checkbox(u8 "Shotgun", shotb) then cfg.autobp.shot = shotb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    if shotb.v then
                        imgui.SameLine(110)
                        if imgui.Checkbox(u8 'Два компекта##2', dvashotb) then cfg.autobp.dvashot = dvashotb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    end
                    if imgui.Checkbox(u8 "SMG", smgb) then cfg.autobp.smg = smgb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    if smgb.v then
                        imgui.SameLine(110)
                        if imgui.Checkbox(u8 'Два компекта##3', dvasmgb) then cfg.autobp.dvasmg = dvasmgb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    end
                    if imgui.Checkbox(u8 "M4A1", m4b) then cfg.autobp.m4 = m4b.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    if m4b.v then
                        imgui.SameLine(110)
                        if imgui.Checkbox(u8 'Два компекта##4', dvam4b) then cfg.autobp.dvam4 = dvam4b.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    end
                    if imgui.Checkbox(u8 "Rifle", rifleb) then cfg.autobp.rifle = rifleb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    if rifleb.v then
                        imgui.SameLine(110)
                        if imgui.Checkbox(u8 'Два компекта##5', dvarifleb) then cfg.autobp.dvarifle = dvarifleb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                    end
                    if imgui.Checkbox(u8 "Броня", armourb) then cfg.autobp.armour = armourb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end 
                    if imgui.Checkbox(u8 "Спец. оружие", specb)then cfg.autobp.spec = specb.v saveData(cfg, 'moonloader/config/fbitools/config.json') end
                end
                imgui.EndChild()
                imgui.End()
            end
        end
        if shpwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8('FBI Tools | Шпора'), shpwindow)
            for line in io.lines('moonloader\\fbitools\\shp.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if akwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8('FBI Tools | Административный кодекс'), akwindow)
            for line in io.lines('moonloader\\fbitools\\ak.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if fpwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8('FBI Tools | Федеральное постановление'), fpwindow)
            for line in io.lines('moonloader\\fbitools\\fp.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if ykwindow.v then
            imgui.ShowCursor = true
            local iScreenWidth, iScreenHeight = getScreenResolution()
            imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver)
            imgui.Begin(u8('FBI Tools | Уголовный кодекс'), ykwindow)
            for line in io.lines('moonloader\\fbitools\\yk.txt') do
                imgui.TextWrapped(u8(line))
            end
            imgui.End()
        end
        if memw.v then
            imgui.ShowCursor = true
            local sw, sh = getScreenResolution()
            --imgui.SetWindowPos('##' .. thisScript().name, imgui.ImVec2(sw/2 - imgui.GetWindowSize().x/2, sh/2 - imgui.GetWindowSize().y/2))
            --imgui.SetWindowSize('##' .. thisScript().name, imgui.ImVec2(670, 500))
            imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
            imgui.SetNextWindowSize(imgui.ImVec2(670, 330), imgui.Cond.FirstUseEver)
            imgui.Begin(u8('FBI Tools | Список сотрудников [Всего: %s]'):format(#tMembers), memw)
            imgui.BeginChild('##1', imgui.ImVec2(670, 300))
            imgui.Columns(5, _)
            imgui.SetColumnWidth(-1, 180) imgui.Text(u8 'Ник игрока'); imgui.NextColumn()
            imgui.SetColumnWidth(-1, 190) imgui.Text(u8 'Должность');  imgui.NextColumn()
            imgui.SetColumnWidth(-1, 80) imgui.Text(u8 'Статус') imgui.NextColumn()
            imgui.SetColumnWidth(-1, 120) imgui.Text(u8 'Дата приема') imgui.NextColumn() 
            imgui.SetColumnWidth(-1, 70) imgui.Text(u8 'AFK') imgui.NextColumn() 
            imgui.Separator()
            for _, v in ipairs(tMembers) do
                imgui.TextColored(imgui.ImVec4(getColor(v.id)), u8('%s[%s]'):format(v.nickname, v.id))
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip();
                    imgui.PushTextWrapPos(450.0);
                    imgui.TextColored(imgui.ImVec4(getColor(v.id)), u8("%s\nУровень: %s"):format(v.nickname, sampGetPlayerScore(v.id)))
                    imgui.PopTextWrapPos();
                    imgui.EndTooltip();
                end
                imgui.NextColumn()
                imgui.Text(('%s [%s]'):format(v.sRang, v.iRang))
                imgui.NextColumn()
                if v.status ~= u8("На работе") then
                    imgui.TextColored(imgui.ImVec4(0.80, 0.00, 0.00, 1.00), v.status);
                else
                    imgui.TextColored(imgui.ImVec4(0.00, 0.80, 0.00, 1.00), v.status);
                end
                imgui.NextColumn()
                imgui.Text(v.invite)
                imgui.NextColumn()
                if v.sec ~= 0 then
                    if v.sec < 360 then 
                        imgui.TextColored(getColorForSeconds(v.sec), tostring(v.sec .. u8(' сек.')));
                    else
                        imgui.TextColored(getColorForSeconds(v.sec), tostring("360+" .. u8(' сек.')));
                    end
                else
                    imgui.TextColored(imgui.ImVec4(0.00, 0.80, 0.00, 1.00), u8("Нет"));
                end
                imgui.NextColumn()
            end
            imgui.Columns(1)
            imgui.EndChild()
            imgui.End()
        end
    end
end

if lsampev then
    function sp.onPlayerQuit(id, reason)
        if gmegafhandle ~= -1 and id == gmegafid then
            sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x0C2265)
            sampAddChatMessage('', 0x0C2265)
            sampAddChatMessage(' {ffffff}Игрок: {0C2265}'..sampGetPlayerNickname(gmegafid)..'['..gmegafid..'] {ffffff}вышел из игры', 0x0C2265)
            sampAddChatMessage(' {ffffff}Уровень: {0C2265}'..gmegaflvl, 0x0C2265)
            sampAddChatMessage(' {ffffff}Фракция: {0C2265}'..gmegaffrak, 0x0C2265)
            sampAddChatMessage(' {ffffff}Причина выхода: {0C2265}'..quitReason[reason], 0x0C2265)
            sampAddChatMessage('', 0x0C2265)
            sampAddChatMessage(' {ffffff}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~', 0x0C2265)
            gmegafid = -1
            gmegaflvl = nil
            gmegaffrak = nil
            gmegafhandle = nil
        end
    end

    function sp.onSendSpawn()
        if cfg.main.clistb and rabden then
            lua_thread.create(function()
                wait(1400)
                ftext('Цвет ника сменен на: {0C2265}' .. cfg.main.clist)
                sampSendChat('/clist '..cfg.main.clist)
            end)
        end
    end

    function sp.onServerMessage(color, text)
        if text:match(" ^Вы начали преследование за преступником %S!$") then
            local nick = text:match(" ^Вы начали преследование за преступником (%S)!$")
            local id = sampGetPlayerIdByNickname(nick)
            gmegafid = id
            gmegaflvl = sampGetPlayerScore(id)
            gmegaffrak = sampGetFraktionBySkin(id)
        end
        if nazhaloop then
            if text:match('Посылать сообщение в /d можно раз в 10 секунд!') then
                zaproop = true
                ftext('Не удалось подать в ООП игрока {0C2265}'..nikk..'{ffffff}. Повторить попытку?')
                ftext('Подтвердить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | Отменить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "))
            end
            if nikk == nil then
                dmoop = false
                nikk = nil
                zaproop = false
                aroop = false
                nazhaloop = false
            end
            if color == -8224086 and text:find(nikk) then
                dmoop = false
                nikk = nil
                zaproop = false
                aroop = false
                nazhaloop = false
                ftext("Рассмотр дела отменен.", -1)
            end
        end
        if (text:match('дело на имя .+ рассмотрению не подлежит, ООП') or text:match('дело .+ рассмотрению не подлежит %- ООП.')) and color == -8224086 then
            local ooptext = text:match('Mayor, (.+)')
            table.insert(ooplistt, ooptext)
        end
	    if color == -65366 and (text:match('SMS%: .+. Отправитель%: .+')) then
			local text, nick = text:match('SMS%: (.+). Отправитель%: (.+)')
			local colors = ("{%06X}"):format(bit.rshift(color, 8))
			if bNotf then
				notf.addNotification('Вам пришло сообщение от '..nick..'\nСообщение: '..text, 5,2)
			end
		end
	    if text:find('удалил из розыскиваемых') then
            local chist, jertva = text:match('%[Clear%] (.+) удалил из розыскиваемых (.+)')
			local id = sampGetPlayerIdByNickname(chist)
           	if bNotf then
				notf.addNotification('Внимание! '..chist..' удалил '..text..' из БД!\nЗапросите: /fbd: '..id, 5,1)
			end
        end
        if text:find('{00AB06}Чтобы завести двигатель, нажмите клавишу {FFFFFF}"2"{00AB06} или введите команду {FFFFFF}"/en"') then
            if cfg.main.autocar then
                lua_thread.create(function()
                    while not isCharInAnyCar(PLAYER_PED) do wait(0) end
                    if not isCarEngineOn(storeCarCharIsInNoSave(PLAYER_PED)) then
                        while sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() do wait(0) end
                        setVirtualKeyDown(key.VK_2, true)
                        wait(150)
                        setVirtualKeyDown(key.VK_2, false)
                    end
                end)
            end
        end
        if color == -8224086 then
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(departament, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if color == -1920073984 and (text:match('.+ .+%: .+') or text:match('%(%( .+ .+%: .+ %)%)')) then
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(radio, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if color == -3669760 and text:match('%[Wanted %d+: .+%] %[Сообщает%: .+%] %[.+%]') then
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(wanted, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if color == -65366 and (text:match('SMS%: .+. Отправитель%: .+') or text:match('SMS%: .+. Получатель%: .+')) then
            if text:match('SMS%: .+. Отправитель%: .+%[%d+%]') then smsid = text:match('SMS%: .+. Отправитель%: .+%[(%d+)%]') elseif text:match('SMS%: .+. Получатель%: .+%[%d+%]') then smstoid = text:match('SMS%: .+. Получатель%: .+%[(%d+)%]') end
            local colors = ("{%06X}"):format(bit.rshift(color, 8))
            table.insert(sms, os.date(colors.."[%H:%M:%S] ") .. text)
        end
        if mcheckb then
            if text:find('---======== МОБИЛЬНЫЙ КОМПЬЮТЕР ДАННЫХ ========---') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('Имя:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('Организация:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('Преступление:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('Сообщил:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('Уровень розыска:') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:close()
            end
            if text:find('---============================================---') then
                local open = io.open("moonloader/fbitools/mcheck.txt", 'a')
                open:write(string.format('%s\n', text))
                open:write(' \n')
                open:close()
            end
        end
        if text:find('Вы посадили в тюрьму') then
            local nik, sek = text:match('Вы посадили в тюрьму (%S+) на (%d+) секунд')
            if sek == '3600' or sek == '3000'  then
                lua_thread.create(function()
                    nikk = nik:gsub('_', ' ')
                    aroop = true
                    wait(3000)
                    ftext(string.format("Запретить рассмотр дела на имя {0C2265}%s", nikk), -1)
                    ftext('Подтвердить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | Отменить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                end)
            end
        end
        if text:find('Вы посадили преступника на') then
            local sekk = text:match('Вы посадили преступника на (.+) секунд!')
            if sekk == '3000' or sekk == '3600' then
                lua_thread.create(function()
                    nikk = sampGetPlayerNickname(tdmg)
                    dmoop = true
                    wait(50)
                    ftext(string.format("Запретить рассмотр дела на имя {0C2265}%s", nikk:gsub('_', ' ')), -1)
                    ftext('Подтвердить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopda.v), " + ")..'{ffffff} | Отменить: {0C2265}'..table.concat(rkeys.getKeysName(config_keys.oopnet.v), " + "), -1)
                end)
            end
        end
        if status then
            if text:find("ID: %d+ | .+ | %g+: .+%[%d+%] %- %{......%}.+%{......%}") then
                if not text:find("AFK") then
                    local id, invDate, nickname, sRang, iRang, status = text:match("ID: (%d+) | (.+) | (%g+): (.+)%[(%d+)%] %- %{.+%}(.+)%{.+%}")
                    table.insert(tMembers, Player:new(id, sRang, iRang, status, invDate, false, 0, nickname))
                else
                    local id, invDate, nickname, sRang, iRang, status, sec = text:match("ID: (%d+) | (.+) | (%g+): (.+)%[(%d+)%] %- %{.+%}(.+)%{.+%} | %{.+%}%[AFK%]: (%d+).+")
                    table.insert(tMembers, Player:new(id, sRang, iRang, status, invDate, true, sec, nickname))
                end
                return false
            end
            if text:find("ID: %d+ | .+ | %g+: .+%[%d+%]
