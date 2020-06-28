script_name ("ATmaze") -- �������� �������
script_author ("M.Kot") -- ����� �������
script_version(4.2)

require "lib.moonloader" -- ����������� ����������
local imgui = require 'imgui'
local encoding = require 'encoding'
local memory = require 'memory'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local script_changelog = [[
���� - warn
����. ���� - ban 7 ��.
DM - 10 min jail|prison
DB - 10 min jail|prison
TK - 10 min jail|prison
SK - 10 min jail|prison
MG - 1 min mute
NRP - jail 10 min|uval
Bag use - kick next warn
���� � ��� �� ��������� - warn
��� �� ��������� - offwarn
����������� (����. �����) - mute 10 ���
������� - ban 1 ��
���.� ����� - prison 5 ��� (�� 2 ���. �����)
���� ������ - jail 5 ���
���� (����. �����) - mute 5 ���
������ (�� 2/2) - mute 5 ���
���� - mute 5 ���
����������� ������� - mute 20 ���
��� (����. �����) - mute 5 ���
�����������/���������� ������ - mute 30 ���
]]


local samp = require 'lib.samp.events'
local text_buffer = imgui.ImBuffer(256)
local changelog = imgui.ImBuffer(65536)
local tag = "[AdminTools]: " -- ���
local dlstatus = require('moonloader').download_status
local main_color = 0x5A90CE
local second_color = 0x518fd1
local main_color_text = "[5A90CE]"
local white_color = "[FFFFFF]"
local ToScreen = convertGameScreenCoordsToWindowScreenCoords
local color_dialog = 0xDEB887
local dialogArr = {"������� �������� �� ����� ��", "���������� ������", "����� �� �����������", "�������� ������"}
local dialogStr = ""
local tCarsSpeed = {43, 40, 51, 30, 36, 45, 30, 41, 27, 43, 36, 61, 46, 30, 29, 53, 42, 30, 32, 41, 40, 42, 38, 27, 37,
54, 48, 45, 43, 55, 51, 36, 26, 30, 46, 0, 41, 43, 39, 46, 37, 21, 38, 35, 30, 45, 60, 35, 30, 52, 0, 53, 43, 16, 33, 43,
29, 26, 43, 37, 48, 43, 30, 29, 14, 13, 40, 39, 40, 34, 43, 30, 34, 29, 41, 48, 69, 51, 32, 38, 51, 20, 43, 34, 18, 27,
17, 47, 40, 38, 43, 41, 39, 49, 59, 49, 45, 48, 29, 34, 39, 8, 58, 59, 48, 38, 49, 46, 29, 21, 27, 40, 36, 45, 33, 39, 43,
43, 45, 75, 75, 43, 48, 41, 36, 44, 43, 41, 48, 41, 16, 19, 30, 46, 46, 43, 47, -1, -1, 27, 41, 56, 45, 41, 41, 40, 41,
39, 37, 42, 40, 43, 33, 64, 39, 43, 30, 30, 43, 49, 46, 42, 49, 39, 24, 45, 44, 49, 40, -1, -1, 25, 22, 30, 30, 43, 43, 75,
36, 43, 42, 42, 37, 23, 0, 42, 38, 45, 29, 45, 0, 0, 75, 52, 17, 32, 48, 48, 48, 44, 41, 30, 47, 47, 40, 41, 0, 0, 0, 29, 0, 0
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

local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)
local settings_window_state = imgui.ImBool(false)
local tpmenu_window_state = imgui.ImBool(false)
local tpmenu_secon_state = imgui.ImBool(false)
local ReconWindow = imgui.ImBool(false)
local ApanelWindow = imgui.ImBool(false)
local wallhack = imgui.ImBool(false)

local themes = import "AdminTools/imgui_themes.lua"

local checked_radio = imgui.ImInt(1)

function ClearChat()
    local memory = require "memory"
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

for _, str in ipairs(dialogArr) do
    dialogStr = dialogStr .. str .. "\n"
end

local reasons = {'ban', 'kick', 'mute', 'sban', "slap", "warn", "offwarn", "offmute", "offban", "pm", "givegun", "sethp", "flip", "setsp", 'prison', 'jail', 'offprison', 'offjail'}

function main()
    while not  isSampAvailable() do wait(100) end

    _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        blue()
    name = sampGetPlayerNickname(id)

    commandss()

    sampAddChatMessage(tag .. "{ff0505}Admin Tools by M.Kot | D.Kot ������� [V. "..thisScript().version.."]", -1) -- ��������� � ��� ��� ������
    sampAddChatMessage(tag .. "{ff0505}����� ������������ � ��������� ������� /mz", -1) -- ���� ����� ��� � ����������
    sampAddChatMessage(tag .. "{ff0505}������ ������ ������ ��� ��������� ������ �������������. ������� ��������!", -1) -- ���� ����� ��� � ����������
    wait(2500)
    update();

    while true do
        wait(0)
                imgui.Process = main_window_state.v or secondary_window_state.v or settings_window_state.v or tpmenu_window_state.v or tpmenu_secon_state.v or ReconWindow.v or ApanelWindow.v
                if not main_window_state.v and not secondary_window_state.v and not settings_window_state.v and not tpmenu_window_state.v and not tpmenu_secon_state.v and not ReconWindow.v and not ApanelWindow.v then
                  imgui.Process = false
                end
        if isKeyJustPressed(VK_F5) then
            sampSendChat("/gotomark")
        end

        if wallhack.v then
            nameTagOn()
        else
            nameTagOff()
        end

        local result, button, list, input = sampHasDialogRespond(10) -- /dialog0 (MsgBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�������� ����!", color_dialog)
            end
        end


        local result, button, list, input = sampHasDialogRespond(20) -- /dialog0 (MsgBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                sampSendChat("����� ������� ��� ������������ �� �� �����. �������� ����!")
            else -- ���� ������ ������ ������ (�������)
                sampSendChat("��� ��� � ��� ���� �������������, �� �������� � ������ ������ ��� ���������.")
            end
        end


        local result, button, list, input = sampHasDialogRespond(45) -- /dialog0 (MsgBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�������� ����!", main_color)
            else -- ���� ������ ������ ������ (�������)
                sampSendChat("")
            end
        end


        local result, button, list, input = sampHasDialogRespond(11) -- /dialog1 (InputBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                sampSendChat("/a ����� /o")
                wait(1200)
                sampSendChat("/o [INFO] ��������� ������ ������ �������, ��� ������������� ����������� ��� � " .. input, color_dialog)
                wait(1200)
                sampSendChat("/a ��������� /o")
            else -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�������� ����!", main_color)
            end
        end


        local result, button, list, input = sampHasDialogRespond(51) -- /dialog1 (InputBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                sampSendChat("/re " .. input)
            else -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�������� ����!", main_color)
            end
        end


        local result, button, list, input = sampHasDialogRespond(12) -- /dialog2 (ListBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                if list == 0 then
                    sampShowDialog(13, "����", "������� ID ������", "�������", "�������", 1)
                elseif list == 1 then
                    sampAddChatMessage("� ������� � ID 12 ������ ����� {FFFFFF}" .. list .. " � ��� ����������: {FF00FF}" .. dialogArr[list+1], color_dialog)
                elseif list == 2 then
                    sampAddChatMessage("� ������� � ID 12 ������ ����� {FFFFFF}" .. list .. " � ��� ����������: {FF00FF}" .. dialogArr[list+1], color_dialog)
                elseif list == 3 then
                    sampAddChatMessage("� ������� � ID 12 ������ ����� {FFFFFF}" .. list .. " � ��� ����������: {FF00FF}" .. dialogArr[list+1], color_dialog)
                end
            else -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�� ������� ������ � ID 12", color_dialog)
            end
        end


        local result, button, list, input = sampHasDialogRespond(13) -- /dialog3 (PasswordBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                sampSendChat("/pm " .. input, color_dialog)
            else -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�� ������� ������ � ID 13", color_dialog)
            end
        end


        local result, button, list, input = sampHasDialogRespond(14) -- /dialog4 (TabListBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                if list == 0 then
                    sampAddChatMessage("� ������� � ID 14 ������ ����� {FFFFFF}" .. list, color_dialog)
                elseif list == 1 then
                    sampAddChatMessage("� ������� � ID 14 ������ ����� {FFFFFF}" .. list, color_dialog)
                elseif list == 2 then
                    sampAddChatMessage("� ������� � ID 14 ������ ����� {FFFFFF}" .. list, color_dialog)
                elseif list == 3 then
                    sampAddChatMessage("� ������� � ID 14 ������ ����� {FFFFFF}" .. list, color_dialog)
                end
            else -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�� ������� ������ � ID 14", color_dialog)
            end
        end


        local result, button, list, input = sampHasDialogRespond(15) -- /dialog5 (TabListHeaderBox)

        if result then -- ���� ������ ������
            if button == 1 then -- ���� ������ ������ ������ (�������)
                if list == 0 then
                    sampAddChatMessage("� ������� � ID 15 ������ ����� {FFFFFF}" .. list, color_dialog)
                elseif list == 1 then
                    sampAddChatMessage("� ������� � ID 15 ������ ����� {FFFFFF}" .. list, color_dialog)
                elseif list == 2 then
                    sampAddChatMessage("� ������� � ID 15 ������ ����� {FFFFFF}" .. list, color_dialog)
                elseif list == 3 then
                    sampAddChatMessage("� ������� � ID 15 ������ ����� {FFFFFF}" .. list, color_dialog)
                end
            else -- ���� ������ ������ ������ (�������)
                sampAddChatMessage("�� ������� ������ � ID 15", color_dialog)
            end
        end

    end
end

function samp.onSendCommand(cmd)
    if cmd:match('/re (%d+)') then
	spec_id = cmd:match('/re (%d+)')
	    if sampIsPlayerConnected(spec_id) then
			ReconWindow.v = true
		else
			sampAddChatMessage('����� � ID '.. spec_id .. ' �� ��������� � �������.', -1)
		end
    end
    if cmd:match('/reoff') then
        ReconWindow.v = false
    end
end

function samp.onPlayerQuit(id, reason)
	if id == spec_id then
		spec_id = 0 ReconWindow.v = false sampSendChat('/reoff')
	end
end

function cmd_mz(arg)
  main_window_state.v = not main_window_state.v
end

function cmd_test(arg)
  secondary_window_state.v = not secondary_window_state.v
end

function cmd_settingsmze(arg)
    settings_window_state.v = not settings_window_state.v
end

function cmd_tpmenu(arg)
    tpmenu_window_state.v = not tpmenu_window_state.v
end
function cmd_tpmenu2(arg)
    tpmenu_secon_state.v = not tpmenu_secon_state.v
end
function cmd_apanel(arg)
    ApanelWindow.v = not ApanelWindow.v
end


function forma()
    if active_report then
        lua_thread.create(function()
            lasttime = os.time()
            lasttimes = 0
            time_out = 10
            while lasttimes < time_out do
                lasttimes = os.time() - lasttime
                wait(0)
                printStyledString("ADMIN FORM " .. time_out - lasttimes .. " WAIT", 1000, 4)
                if lasttimes == time_out then
                    active_report = false
                    printStyledString("Forma skipped", 1000, 4)
                end
            end
        end)
    else
        if isKeyJustPressed(VK_P) and not sampIsChatInputActive() and not sampIsDialogActive() then
            printStyledString('You can�t skip the form temporarily', 1000, 4)
        end
    end
end

function cmd_update(arg)
    if #arg == 0 then
        sampShowDialog(10, "������������ � ���������� 4.1", "���� ��������� ����� ������\n�������� ������ ������ /mzr\n���� ��������� ����� ������ - /adminp\n��� �������� Wallhack � ���������\n��������� ������ ��������� � ������������� ������ � ����������\n������� ���� ���������� �� ���������\n��� �������� ��� �� ������ ���\n���� ��������� ����� ����� ����� ������", "�������", "", 0)
    end

end
function cmd_mzr(arg)
    if #arg == 0 then
        sampShowDialog(10, "{08F800}������ ������� �� ������:", "{5A90CE}/pr [ID] - �������� ������ � /pm �� ��� �� �������� report �������������\n{5A90CE}/sn [ID] - �������� ������ � /pm �� ��� �� ������� �� �����������\n{5A90CE}pmch [ID] - �������� ������ � /pm �� ��� �� ����������� ��� ������\n{5A90CE}/of [ID] - �������� ������ � /pm ����� �� �� �������� 1/2\n{5A90CE}/of2 [ID] - �������� ������ � /pm ����� �� �� �������� 2/2, � �� ��� �� �������� ��� ���� �� ��� ���\n{5A90CE}/tb [ID] - �������� ������ � /pm �� ��� ����� ������ �� ������� ������ �� �������\n{5A90CE}/rput [ID] - �������� ������ � /pm ����� �� ������ ��� �� �����\n{5A90CE}/nv [ID] - �������� ������ � /pm �� ��� �� ������\n{5A90CE}/pmg [ID] - �������� ������ � /pm �� ��� �� ��� �������\n{5A90CE}/nak1 [ID ������] [ID ������] - �������� ������ � /pm �� ��� ���� �� �� �������� � ���������� �� ����� ����� ������ �� ������\n{5A90CE}/nak2 [ID] - �������� ������ � /pm �� ��� ������ �� �������������� ����� �������� �� ������\n{5A90CE}/afk [ID] = �������� ������ � /pm �� ��� ���� �� ��� ��� esc, �� �� ������ ��������� ��� �������\n{5A90CE}/bb [ID] - ��������� ������ ������� 1 ���� � ���������� � /pm\n{5A90CE}/k [ID] - ��������� vip ���������� ������\n{5A90CE}/kk [ID] - ������������� vip ���������� ������\n{5A90CE}/st1 [ID] [���� ID ������] - �������� � /a �� ��� �� ������ �������� �� ������ ������\n{5A90CE}/st2 [ID] [���� ID ������] - �������� � /a �� ��� �� ��������� �������� �� ������ ������\n{5A90CE}/lid [ID] - ������� ������ � /pm ��� �����, ����� ������ �� �������\n{5A90CE}/nrp [ID] - �������� ������� � /pm, ����� ����� ������ ��� �� ���\n{5A90CE}/������� - ������ ��� ������ ������� ����� /alogin\n/ut [ID] - ��������� ������ �������� ������", "�������", "", 0)
    end

end
function cmd_mzd(arg)
    if #arg == 0 then
        sampShowDialog(10, "{08F800}������ ���������:", "{E3E630}/dm [ID] - �������� ������ �� �� � prison\n{E3E630}/db [ID] - �������� ������ �� �� � prison\n{E3E630}/tk [ID] - �������� ������ �� �� � prison\n{E3E630}/sk [ID] - �������� ������ �� �� � prison\n{C90303}/cheat [ID] - ��������� ������ �� ����\n{C90303}/vcheat [ID} - �������� ������ �� ����.���� �� 7 ����\n{E3E630}/caps [ID] - �������� ������ �� ���� �� 5 �����\n{E3E630}/osk [ID] - �������� ������ �� ��� �� 10 �����\n/oskp [ID] - �������� ������ �� ��� ������� �� 20 �����\n{C90303}/mq [ID] - �������� ������ �� 30 ����� �� ����. �����\n{E3E630}/flood [ID] - �������� ������ �� ���� �� 5 �����\n{E3E630}/cop [ID] - �������� ������ �� ���� � ����� � /prison\n{E3E630}/kb [ID] - ������ ��� ������ �� ������ ����� � ������\n{E3E630}/eva [ID] - ������ ��� ������ �� ������ � /vad\n{E3E630}/forum [ID] - �������� ������/��������������, ���������, � ������� �� ��� �� ���� ��������� ������\n{E3E630}/kb [ID] - ������ /kban �� ����./������ �����\n{E3E630}/kfjb [ID] - ������ /kban �� ������ �� ������\n{C90303}/afjb [ID] - ������ /awarn �� ������ �� ������\n{C90303}/relog [ID] - ������ /sban � �������� relog\n{C90303}/npa [ID] - ������ /awarn � �������� ��������� ������ �������������", "�������", "", 0)
    end

end
function cmd_mda(arg)
    if #arg == 0 then
        sampShowDialog(10, "{08F800}������ ��������� �� ���� ������� ������:", "{C90303}/acheat [ID ������] [ID ������] - ������ /warn �� ���� �� ���� ������� ������\n{C90303}/avcheat [ID ������] [ID ������] - ������ /ban �� ����.���� �� ���� ������� ������\n{E3E630}/dma [ID ������] [ID ������] - �������� � /prison �� �� �� ���� ������� ������\n{E3E630}/atk [ID ������] [ID ������] - �������� � /prison �� �� �� ���� ������� ������\n{E3E630}/ask[ID ������] [ID ������] - �������� � /prison �� �� �� ���� ������� ������\n{C90303}/amq [ID ������] [ID ������] - ������ /ban �� ����.����� �� ���� ������� ������\n{E3E630}/aeva [ID ������] [ID ������] - ������ /kban �� /evad | /vadgo\n{E3E630}/acop [ID ������] [ID ������] - �������� ������ � �������� �� ���� � ����� �� ����� ������� ��������������\n{C90303}/arelog [ID] [ID ������] - ������ /sban c �������� relog �� ���� ������� ������", "�������", "", 0)
    end

end
function cmd_pozdr(arg)
    if #arg == 0 then
        sampShowDialog(11, "���������� ������� � ����������", "������� �������� ���������(������: 9 ���)", "����������", "������", 1)
    end

end

function imgui.OnDrawFrame()
  if main_window_state.v then
		imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(800, 700), imgui.Cond.FirstUseEver)
    if imgui.Begin(u8"Admin Tools Maze Role Play", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
	    imgui.BeginChild('##leftpane1', imgui.ImVec2(150, 650), true)

	    if imgui.Button(u8" ������� ���� ", imgui.ImVec2(135, 30)) then
	      secondary_window_state.v = false
	      settings_window_state.v = false
	      main_window_state.v = true
	    end

	    if imgui.Button(u8" ������ ������ ", imgui.ImVec2(135, 30)) then
	      main_window_state.v = false
	      settings_window_state.v = false
	      secondary_window_state.v = true
	    end

	    if imgui.Button(u8" ��������� ", imgui.ImVec2(135, 30)) then
	      main_window_state.v = false
	      secondary_window_state.v = false
	      settings_window_state.v = true
	    end



	    imgui.EndChild()
	    imgui.SameLine()
	    imgui.BeginChild("##Otherdsf1", imgui.ImVec2(615, 650), true, imgui.WindowFlags.NoScrollbar)

	    if imgui.Button(u8'�������� ���', imgui.ImVec2(110, 25)) then
	      ClearChat()
	    end
	    imgui.SameLine()
	    if imgui.Button(u8'������������', imgui.ImVec2(110, 25)) then
	      sampSendChat("/spawn")
	    end
	    imgui.SameLine()
	    if imgui.Button(u8'����������������', imgui.ImVec2(120, 25)) then
            reconnect()
          end
	    if imgui.CollapsingHeader(u8"�����������") then
	      if imgui.Button(u8'�������� � ������ ����������� "������ �����"') then
	        lua_thread.create(function()
	          sampSendChat("/a ����� /aad")
	          wait(1200)
	          sampSendChat('/aad [��] ������ ������� ����������� "������ �����". �������� >> /gotomp')
	          wait(1200)
	          sampSendChat('/mp ������ �����')
	          wait(1200)
	          sampSendChat("/a ��������� /aad")
	        end)
	      end
	      if imgui.Button(u8'�������� � ������ ����������� "������"') then
	        lua_thread.create(function()
	          sampSendChat("/a ����� /aad")
	          wait(1200)
	          sampSendChat('/aad [��] ������ ������� ����������� "������". �������� >> /gotomp')
	          wait(1200)
	          sampSendChat('/mp ������')
	          wait(1200)
	          sampSendChat("/a ��������� /aad")
	        end)
	      end
	      if imgui.Button(u8'�������� � ������ ����������� "�����"') then
	        lua_thread.create(function()
	          sampSendChat("/a ����� /aad")
	          wait(1200)
	          sampSendChat('/aad [��] ������ ������� ����������� "�����". �������� >> /gotomp')
	          wait(1200)
	          sampSendChat('/mp �����')
	          wait(1200)
	          sampSendChat("/a ��������� /aad")
	        end)
	      end
	      if imgui.Button(u8'�������� � ������ ����������� "������� �������"') then
	        lua_thread.create(function()
	          sampSendChat("/a ����� /aad")
	          wait(1200)
	          sampSendChat('/aad [��] ������ ������� ����������� "������� �������". �������� >> /gotomp')
	          wait(1200)
	          sampSendChat('/mp ������� �������')
	          wait(1200)
	          sampSendChat("/a ��������� /aad")
	        end)
	      end
	    end


	    if imgui.CollapsingHeader(u8"��������� ��� ��������� � �������") then
	      if imgui.Button(u8'�������������') then
	        lua_thread.create(function()
	          sampSendChat('������������. � ������������� ������� �������, ' .. name .. '.')
	          wait(1000)
	          sampSendChat('��������� ���� ��������/������')
	        end)
	      end
	      if imgui.Button(u8'������� �� �� ������ � ����������� ������') then
	        lua_thread.create(function()
	          sampSendChat('�����... ������ ��������� ��� ������.')
	          wait(1000)
	          sampSendChat('��������� ���� �����!')
	        end)
	      end
	      if imgui.Button(u8'���������� �� ��� �� ���� ������') then
	        lua_thread.create(function()
	          sampSendChat('��������, � ��� �� ����� ������.')
	          wait(1000)
	          sampSendChat('�������� ���!')
	        end)
	      end
	      if imgui.Button(u8'������� �� ��� �� ������ ������') then
	        lua_thread.create(function()
	          sampSendChat('� ��� �����. ������� �� �������� ��������.')
	          wait(1000)
	          sampSendChat('�������� ���!')
	        end)
	      end
	      if imgui.Button(u8'������/�������/�������') then
	        lua_thread.create(function()
	          sampSendChat('��.�����, �� �������������� � �������/��������/������ ��������.')
	          wait(1000)
	          sampSendChat('������ � ������� ��� ������� ���������:')
	          wait(1000)
	          sampSendChat('����� ����������� ��������, ���� ����������� ��������!')
	          wait(1000)
	          sampSendChat('� ��������� ������ �� ������ ���� �������������!')
	        end)
	      end
	    end


	    if imgui.CollapsingHeader(u8"��������� /o") then
	      if imgui.Button(u8'info') then
	        lua_thread.create(function()
	          sampSendChat('/a ����� /o')
	          wait(1150)
	          sampSendChat('/o [INFO] ��. ������ ������� Maze Role Play. ������������� ������� ������ ��� �������� ����!')
	          wait(1150)
	          sampSendChat('/o [INFO] ���� ������? ������� ����������? ���� ���� ������� � /mm >> ����� � ��������������!')
	          wait(1150)
	          sampSendChat('/o [INFO] ��. ������/�����������, ��������� �������������, ������� ������!')
	          wait(1150)
	          sampSendChat('/o [INFO] �������� ���� ��� � �������� ���� �� Maze Role Play!')
	          wait(1150)
	          sampSendChat('/a ��������� /o')
	        end)
	      end
	      if imgui.Button(u8'����� � ��') then
	        lua_thread.create(function()
	          sampSendChat('/a ����� /o')
	          wait(1200)
	          sampSendChat('/o [��] ��������! � ����-����� 2.0 �������� �����.')
	          wait(1200)
	          sampSendChat('/o [��] ������� ���������� ����� ��.���� ������ ����� ��������������� ����� �������.')
	          wait(1200)
	          sampSendChat('/o [��] ��� ������� ��� �����,������� ����� ������ ��� ������ �� ��� � ������.')
	          wait(1200)
	          sampSendChat('/o [��] ��� ����������, ������� �������� � /report "��"!')
	          wait(1200)
	          sampSendChat('/a ��������� /o')
	        end)
	      end
	    end

	    imgui.EndChild()
		end
		imgui.End()
  end
  if secondary_window_state.v then
		imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(800, 700), imgui.Cond.FirstUseEver)
    if imgui.Begin(u8"Command List AT", secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
	    imgui.BeginChild('##leftpane2', imgui.ImVec2(150, 650), true)

	    if imgui.Button(u8" ������� ���� ", imgui.ImVec2(135, 30)) then
	      secondary_window_state.v = false
	      settings_window_state.v = false
	      main_window_state.v = true
	    end

	    if imgui.Button(u8" ������ ������ ", imgui.ImVec2(135, 30)) then
	      main_window_state.v = false
	      settings_window_state.v = false
	      secondary_window_state.v = true
	    end

	    if imgui.Button(u8" ��������� ", imgui.ImVec2(135, 30)) then
	      main_window_state.v = false
	      secondary_window_state.v = false
	      settings_window_state.v = true
	    end

	    imgui.EndChild()
	    imgui.SameLine()
	    imgui.BeginChild("##Otherdsf2", imgui.ImVec2(615, 650), true, imgui.WindowFlags.NoScrollbar)

	    imgui.Text(u8"������ ������ �� ������ ������:", second_color)
	    imgui.Text(u8"/mzr - ������ ������ ��� ������ � ������")
	    imgui.Text(u8"/mzd - ������ ������ ��� ���������")
        imgui.Text(u8"/mda - ������ ������ ��� ��������� �� ���� ������� ������")
        imgui.Text(u8"/tpmenu - �������� ����")
        imgui.Text(u8"/update - ���������� ������������ � ����� ����������")
	    imgui.EndChild()
		end
    imgui.End()
  end
  if settings_window_state.v then
		imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(800, 700), imgui.Cond.FirstUseEver)
    if imgui.Begin(u8"Settings AT", settings_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
	    imgui.BeginChild('##leftpane3', imgui.ImVec2(150, 650), true)

	    if imgui.Button(u8" ������� ���� ", imgui.ImVec2(135, 30)) then
	      secondary_window_state.v = false
	      settings_window_state.v = false
	      main_window_state.v = true
	    end

	    if imgui.Button(u8" ������ ������ ", imgui.ImVec2(135, 30)) then
	      main_window_state.v = false
	      settings_window_state.v = false
	      secondary_window_state.v = true
	    end

	    if imgui.Button(u8" ��������� ", imgui.ImVec2(135, 30)) then
	      main_window_state.v = false
	      secondary_window_state.v = false
	      settings_window_state.v = true
	    end

	    imgui.EndChild()
	    imgui.SameLine()
	    imgui.BeginChild("##Otherdsf3", imgui.ImVec2(615, 650), true, imgui.WindowFlags.NoScrollbar)

        imgui.Checkbox(u8'Wallhack', wallhack)
        imgui.SameLine()
        imgui.TextQuestion(u8"������ ���� ������� ������ �����")

        if imgui.CollapsingHeader(u8"����� ����") then
            for i, value in ipairs(themes.colorThemes) do
                if imgui.RadioButton(value, checked_radio, i) then
                    themes.SwitchColorTheme(i)
                end
            end
          end
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          imgui.Text(u8" ")
          if imgui.Button(u8" ������������� ������ ", imgui.ImVec2(145, 25)) then
            imgui.OpenPopup(u8"Reload Script")
          end
          if imgui.BeginPopupModal(u8"Reload Script", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(125, 0)
            imgui.Text(u8"������������� ������?")
            if imgui.Button(u8'��', bsize) then
                settings_window_state.v = false
                imgui.CloseCurrentPopup()
                reloading()
            end
            imgui.SameLine()
            if imgui.Button(u8'���', bsize) then
                imgui.CloseCurrentPopup()
            end
			imgui.EndPopup()
        end
        imgui.SameLine()
        if imgui.Button(u8" ��������� ������ ", imgui.ImVec2(145, 25)) then
            imgui.OpenPopup(u8"Off Script")
        end
        if imgui.BeginPopupModal(u8"Off Script", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(125, 0)
            imgui.Text(u8"��������� ������?")
            if imgui.Button(u8'��', bsize) then
                settings_window_state.v = false
                imgui.CloseCurrentPopup()
                offscript()
            end
            imgui.SameLine()
            if imgui.Button(u8'���', bsize) then
                imgui.CloseCurrentPopup()
            end
			imgui.EndPopup()
        end
	    imgui.EndChild()
        end
    imgui.End()
  end
  if tpmenu_window_state.v then
		imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(415, 400), imgui.Cond.FirstUseEver)
    if imgui.Begin(u8"Teleport Menu AT", tpmenu_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
	    imgui.BeginChild('##leftpane4', imgui.ImVec2(130, 350), true)

	    if imgui.Button(u8" �������� ", imgui.ImVec2(115, 30)) then
        tpmenu_window_state.v = true
        tpmenu_secon_state.v = false
          end
          if imgui.Button(u8" ������������� ", imgui.ImVec2(115, 30)) then
            tpmenu_secon_state.v = true
            tpmenu_window_state.v = false
              end

	    imgui.EndChild()
	    imgui.SameLine()
	    imgui.BeginChild("##Otherdsf4", imgui.ImVec2(260, 350), true, imgui.WindowFlags.NoScrollbar)

        if imgui.CollapsingHeader(u8"���� �����������") then
            if imgui.CollapsingHeader(u8"���� ���. �����������") then
	    if imgui.Button(u8" ����� ") then
            setCharCoordinates(PLAYER_PED, 1480, -1751, 15)
            sampAddChatMessage("�� ���� ���������������!", -1)
                end
        if imgui.Button(u8" LSPD ") then
            setCharCoordinates(PLAYER_PED, 1544, -1676, 13)
            sampAddChatMessage("�� ���� ���������������!", -1)
                 end
                 if imgui.Button(u8" �������� ") then
                    setCharCoordinates(PLAYER_PED, 1187, -1325, 13)
                    sampAddChatMessage("�� ���� ���������������!", -1)
                         end
                         if imgui.Button(u8" S.W.A.T. ") then
                            setCharCoordinates(PLAYER_PED, 928, -1689, 13)
                            sampAddChatMessage("�� ���� ���������������!", -1)
                                 end
                                 if imgui.Button(u8" FBI ") then
                                    setCharCoordinates(PLAYER_PED, 333, -1522, 35)
                                    sampAddChatMessage("�� ���� ���������������!", -1)
                                         end
                                         if imgui.Button(u8" San News ") then
                                            setCharCoordinates(PLAYER_PED, 1653, -1667, 21)
                                            sampAddChatMessage("�� ���� ���������������!", -1)
                                                 end
                                                 if imgui.Button(u8" ���. ������� ") then
                                                    setCharCoordinates(PLAYER_PED, 2671, -2398, 13)
                                                    sampAddChatMessage("�� ���� ���������������!", -1)
                                                         end
            end
            if imgui.CollapsingHeader(u8"���� �����. �����������") then
                         if imgui.CollapsingHeader(u8"�����") then
                         if imgui.Button(u8" Grove Street ") then
                            setCharCoordinates(PLAYER_PED, 2490, -1667, 13)
                            sampAddChatMessage("�� ���� ���������������!", -1)
                                 end
                                 if imgui.Button(u8" Ballas ") then
                                    setCharCoordinates(PLAYER_PED, 2000, -1124, 26)
                                    sampAddChatMessage("�� ���� ���������������!", -1)
                                         end
                                         if imgui.Button(u8" Rifa ") then
                                            setCharCoordinates(PLAYER_PED, 2170, -1802, 13)
                                            sampAddChatMessage("�� ���� ���������������!", -1)
                                                 end
                                                 if imgui.Button(u8" Aztec ") then
                                                    setCharCoordinates(PLAYER_PED, 1666, -2114, 13)
                                                    sampAddChatMessage("�� ���� ���������������!", -1)
                                                         end
                                                         if imgui.Button(u8" Vagos ") then
                                                            setCharCoordinates(PLAYER_PED, 2781, -1616, 10)
                                                            sampAddChatMessage("�� ���� ���������������!", -1)
                                                                 end
                                                                end
                                                                if imgui.CollapsingHeader(u8"�����") then
                                                                    if imgui.Button(u8" Hitmans ") then
                                                                        setCharCoordinates(PLAYER_PED, 891, -1102, 23)
                                                                        sampAddChatMessage("�� ���� ���������������!", -1)
                                                                             end
                                                                 if imgui.Button(u8" Yakuzza ") then
                                                                    setCharCoordinates(PLAYER_PED, 1164, -2037, 69)
                                                                    sampAddChatMessage("�� ���� ���������������!", -1)
                                                                         end
                                                                         if imgui.Button(u8" La Coza Nostra ") then
                                                                            setCharCoordinates(PLAYER_PED, 901, -932, 42)
                                                                            sampAddChatMessage("�� ���� ���������������!", -1)
                                                                                 end
                                                                                 if imgui.Button(u8" Russian Mafia ") then
                                                                                    setCharCoordinates(PLAYER_PED, 657, -1304, 13)
                                                                                    sampAddChatMessage("�� ���� ���������������!", -1)
                                                                                         end
                                                                                        end
            end
        end

	    imgui.EndChild()
	    imgui.End()
		end
  end
  if tpmenu_secon_state.v then
    imgui.ShowCursor = true
imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
imgui.SetNextWindowSize(imgui.ImVec2(415, 400), imgui.Cond.FirstUseEver)
if imgui.Begin(u8"Teleport Menu AT2", tpmenu_secon_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
    imgui.BeginChild('##leftpane5', imgui.ImVec2(130, 350), true)

    if imgui.Button(u8" �������� ", imgui.ImVec2(115, 30)) then
    tpmenu_window_state.v = true
    tpmenu_secon_state.v = false
      end
      if imgui.Button(u8" ������������� ", imgui.ImVec2(115, 30)) then
        tpmenu_secon_state.v = true
        tpmenu_window_state.v = false
          end

    imgui.EndChild()
    imgui.SameLine()
    imgui.BeginChild("##Otherdsf5", imgui.ImVec2(260, 350), true, imgui.WindowFlags.NoScrollbar)

    if imgui.CollapsingHeader(u8"����� ��� �����������") then
        if imgui.Button(u8" ������ �����/������� ������� ") then
            setCharCoordinates(PLAYER_PED, 1544, -1357, 329)
            sampAddChatMessage("�� ���� ���������������!", -1)
                 end
                 if imgui.Button(u8" ������ �1 ") then
                    setCharCoordinates(PLAYER_PED, -2311, 1544, 18)
                    sampAddChatMessage("�� ���� ���������������!", -1)
                         end
                         if imgui.Button(u8" ������ �2 ") then
                            setCharCoordinates(PLAYER_PED, -1470, 1489, 8)
                            sampAddChatMessage("�� ���� ���������������!", -1)
                                 end
                                 if imgui.Button(u8" ��������� ") then
                                    setCharCoordinates(PLAYER_PED, 288, -1611, 114)
                                    sampAddChatMessage("�� ���� ���������������!", -1)
                                         end
                                         if imgui.Button(u8" ����� ") then
                                            sampSendChat("/derby")
                                                 end
    end

    imgui.EndChild()
    imgui.End()
    end
end
if ApanelWindow.v then
    imgui.ShowCursor = true
imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
imgui.SetNextWindowSize(imgui.ImVec2(415, 400), imgui.Cond.FirstUseEver)
changelog.v = u8:encode(script_changelog)
if imgui.Begin(u8"Admin Panel", ApanelWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse) then
    imgui.BeginChild("##Otherdsf6", imgui.ImVec2(400, 360), true)

    if imgui.CollapsingHeader(u8"�������������� � �����") then
        if imgui.Button(u8" �������� ��� (� ����) ", imgui.ImVec2(140, 25)) then
            sampSendChat("/cc")
        end
        if imgui.Button(u8" �������� ���� (����) ", imgui.ImVec2(140, 25)) then
            sampSendChat("/gg")
        end
    end

    if imgui.CollapsingHeader(u8"�������������� � ����") then
     if imgui.Button(u8" ���������� ��� ���� ", imgui.ImVec2(140, 25)) then
        sampSendChat("/spawncars")
    end
    if imgui.Button(u8" �������� ��� ���� ", imgui.ImVec2(140, 25)) then
        sampSendChat("/repcars")
    end
    if imgui.Button(u8" ��������� ��� ���� ", imgui.ImVec2(140, 25)) then
        sampSendChat("/fuelcars")
    end
end

if imgui.CollapsingHeader(u8'������� ������ ���������') then
    imgui.InputTextMultiline(u8"##Changelog", changelog, imgui.ImVec2(900, 300), imgui.InputTextFlags.ReadOnly)
    end

    imgui.EndChild()
    imgui.End()
end
end
    if ReconWindow.v then
        local x, y = ToScreen(552, 240)
        local w, h = ToScreen(638, 330)
        if isKeyJustPressed(VK_U) and not sampIsChatInputActive() and not sampIsDialogActive() then
			imgui.ShowCursor = not imgui.ShowCursor
		end
		imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(w-x, 160), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"����������##reconInfo", ReconWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoTitleBar)
        imgui.Text(u8"����/��� ������ = U")
        local isPed, pPed = sampGetCharHandleBySampPlayerId(spec_id)
		local speed, health, armor, interior, model, carSpeed, carHealth, carHundle, carModel
		local score, ping = sampGetPlayerScore(spec_id), sampGetPlayerPing(spec_id)
		local spacing, height = 90.0, 162.0
		local btnSize = imgui.ImVec2(-0.001, 0)
		if isPed and doesCharExist(pPed) then
			speed = getCharSpeed(pPed)
			health = sampGetPlayerHealth(spec_id)
			armor = sampGetPlayerArmor(spec_id)
			model = getCharModel(pPed)
			interior = getCharActiveInterior(playerPed)
			if isCharInAnyCar(pPed) then
				carHundle = storeCarCharIsInNoSave(pPed)
				carSpeed = getCarSpeed(carHundle)
				carModel = getCarModel(carHundle)
				carHealth = getCarHealth(carHundle)
			end
		end
		local spacing = 90.0

		imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1.0, 8.0))
		imgui.Text(u8(getNick(spec_id) .. "[" .. spec_id .. "]"))
		imgui.PopStyleVar()

		imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1.0, 2.5))
		imgui.Text(u8"�����:"); imgui.SameLine(spacing); imgui.Text(isPed and health or u8"���")
		imgui.Text(u8"�����:"); imgui.SameLine(spacing); imgui.Text(isPed and armor or u8"���")
		imgui.Text(u8"�������:"); imgui.SameLine(spacing); imgui.Text(score)
		imgui.Text(u8"����:"); imgui.SameLine(spacing); imgui.Text(ping)
		imgui.Text(u8"����:"); imgui.SameLine(spacing); imgui.Text(isPed and model or u8"���")
		imgui.Text(u8"��������:"); imgui.SameLine(spacing); imgui.Text(isPed and (isCharInAnyCar(pPed) and math.floor(carSpeed) .. " / " .. tCarsSpeed[carModel - 399] or math.floor(speed)) or u8"���")
		imgui.Text(u8"��������:"); imgui.SameLine(spacing); imgui.Text(isPed and interior or u8"���")
		imgui.PopStyleVar()
		imgui.End()
		y = y + 163
		if isPed and doesCharExist(pPed) and isCharInAnyCar(pPed) then
			imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.0, 0.0))
			imgui.SetNextWindowSize(imgui.ImVec2(w-x, 53), imgui.Cond.FirstUseEver)
			imgui.Begin(u8"##reconCarInfo", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoSavedSettings)

			imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1.0, 2.5))
			imgui.Text(u8"���������:"); imgui.SameLine(spacing); imgui.Text(isPed and tCarsName[carModel-399] or u8"���")
			imgui.Text(u8"�����:"); imgui.SameLine(spacing); imgui.Text(isPed and carHealth or u8"���")
			imgui.Text(u8"������:"); imgui.SameLine(spacing); imgui.Text(isPed and carModel or u8"���")
			imgui.PopStyleVar()

			imgui.End()
        end
        local ex, ey = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(20, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(0, 0), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'    ���������', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
        if imgui.Button(u8'UPDATE', imgui.ImVec2(100,0)) then
			sampSendChat("/re "..spec_id)
		end
        if imgui.Button(u8'JAIL', imgui.ImVec2(100,0)) then
			imgui.OpenPopup(u8"JAIL")
		end
		if imgui.BeginPopupModal(u8"JAIL", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			bsize = imgui.ImVec2(125, 0)
			if imgui.Button(u8'���� �������', bsize) then
				sampSetChatInputEnabled(true)
				sampSetChatInputText('/jail '..spec_id..' ')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'��', bsize) then
				sampSendChat('/jail '..spec_id..' 10 ��')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'��', bsize) then
				sampSendChat('/jail '..spec_id..' 10 ��')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'��', bsize) then
				sampSendChat('/jail '..spec_id..' 10 ��')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'��', bsize) then
				sampSendChat('/jail '..spec_id..' 5 ��')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'��� � �����', bsize) then
				sampSendChat('/jail '..spec_id..' 5 ��� � �����')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'���', bsize) then
				sampSendChat('/jail '..spec_id..' 10 �����')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'�������', bsize) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.Button(u8'MUTE', imgui.ImVec2(100, 0)) then
			imgui.OpenPopup(u8"MUTE")
		end
		if imgui.BeginPopupModal(u8"MUTE", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			bsize = imgui.ImVec2(150, 0)
			if imgui.Button(u8'���� �������', bsize) then
				sampSetChatInputEnabled(true)
				sampSetChatInputText('/mute '..spec_id..' ')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'��', bsize) then
				sampSendChat('/mute '..spec_id..' 1 ��')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'����', bsize) then
				sampSendChat('/mute '..spec_id..' 5 ����')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'����', bsize) then
				sampSendChat('/mute '..spec_id..' 5 ����')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'���', bsize) then
				sampSendChat('/mute '..spec_id..' 10 ����������� �������/�������������')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'����/��� ���', bsize) then
				sampSendChat('/mute '..spec_id..' 30 ����������/����������� ������')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'���', bsize) then
				sampSendChat('/mute '..spec_id..' 5 ���')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'��� �������', bsize) then
				sampSendChat('/mute '..spec_id..' 10 ����������� �������')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'�������', bsize) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.Button(u8'KICK', imgui.ImVec2(100, 0)) then
			imgui.OpenPopup(u8"KICK")
		end
		if imgui.BeginPopupModal(u8"KICK", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			bsize = imgui.ImVec2(130, 0)
            if imgui.Button(u8'���� �������', bsize) then
                ReconWindow.v = false
				sampSetChatInputEnabled(true)
				sampSetChatInputText('/kick '..spec_id..' ')
				imgui.CloseCurrentPopup()
			end
            if imgui.Button(u8'AFK no esc', bsize) then
                ReconWindow.v = false
				sampSendChat('/kick '..spec_id..' ��� ��� ESC')
				imgui.CloseCurrentPopup()
			end
            if imgui.Button(u8'������ ������', bsize) then
                ReconWindow.v = false
				sampSendChat('/kick '..spec_id..' ������')
				imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'relog', bsize) then
                ReconWindow.v = false
				sampSendChat('/kick '..spec_id..' relog')
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'�������', bsize) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.Button(u8'WARN', imgui.ImVec2(100, 0)) then
			imgui.OpenPopup(u8"WARN")
		end
		if imgui.BeginPopupModal(u8"WARN", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			bsize = imgui.ImVec2(175, 0)
            if imgui.Button(u8'���� �������', bsize) then
                ReconWindow.v = false
				sampSetChatInputEnabled(true)
				sampSetChatInputText('/warn '..spec_id..' ')
				imgui.CloseCurrentPopup()
			end
            if imgui.Button(u8'����', bsize) then
                    ReconWindow.v = false
                    sampSendChat('/warn '..spec_id..' ������������� ��� ��������')
				imgui.CloseCurrentPopup()
            end
			if imgui.Button(u8'�������', bsize) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		if imgui.Button(u8'BAN', imgui.ImVec2(100, 0)) then
			imgui.OpenPopup(u8"BAN")
		end
		if imgui.BeginPopupModal(u8"BAN", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
			bsize = imgui.ImVec2(125, 0)
            if imgui.Button(u8'���� �������', bsize) then
                ReconWindow.v = false
				sampSetChatInputEnabled(true)
				sampSetChatInputText('/ban '..spec_id..' ')
				imgui.CloseCurrentPopup()
			end
            if imgui.Button(u8'����. ����', bsize) then
                ReconWindow.v = false
				sampSendChat('/ban '..spec_id..' 7 ������������� ����')
				imgui.CloseCurrentPopup()
            end
			if imgui.Button(u8'�������', bsize) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
        end
        if imgui.Button(u8'OTHERS', imgui.ImVec2(100, 0)) then
			imgui.OpenPopup(u8"OTHERS")
		end
		if imgui.BeginPopupModal(u8"OTHERS", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
            bsize = imgui.ImVec2(125, 0)
            if imgui.Button(u8'STATS', bsize) then
				sampSendChat('/getstats '..spec_id)
				imgui.CloseCurrentPopup()
            end
			if imgui.Button(u8'SETSP', bsize) then
				sampSendChat('/setsp '..spec_id)
				imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'SLAP', bsize) then
				sampSendChat('/slap '..spec_id)
				imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'FLIP', bsize) then
				sampSendChat('/flip '..spec_id)
				imgui.CloseCurrentPopup()
            end
            if imgui.Button(u8'�� � ������', bsize) then
                lua_thread.create(function()
                ReconWindow.v = false
                sampSendChat('/reoff ')
                imgui.CloseCurrentPopup()
                wait(1000)
                sampSendChat("/g "..spec_id)
            end)
        end
        if imgui.Button(u8'�� � ����', bsize) then
            lua_thread.create(function()
            ReconWindow.v = false
            sampSendChat('/reoff ')
            imgui.CloseCurrentPopup()
            wait(1000)
            sampSendChat("/gethere "..spec_id)
        end)
    end
    if imgui.Button(u8'REOFF', bsize) then
        ReconWindow.v = false
        sampSendChat('/REOFF')
        imgui.CloseCurrentPopup()
    end
			if imgui.Button(u8'�������', bsize) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
        end
		imgui.End()
    end
    end


function samp.onShowMenu()
	if ReconWindow.v then
		return false
	end
end

function samp.onHideMenu()
	if ReconWindow.v then
		return false
	end
end

function getNick(id)
    nick = sampGetPlayerNickname(id)
    return nick
end

function blue()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function commandss()
    sampRegisterChatCommand("mz", cmd_mz)
    sampRegisterChatCommand("commandsinmenumz192391239921939", cmd_test) -- �� ������� � ��� :)
    sampRegisterChatCommand("settingsinmenumz12312312313", cmd_settingsmze) -- �� ������� � ��� :)
    sampRegisterChatCommand("tpmenu", cmd_tpmenu)
    sampRegisterChatCommand("tpmenu123123123intpmenu1blabla", cmd_tpmenu2)
    sampRegisterChatCommand("adminp", cmd_apanel)

    sampRegisterChatCommand('pr', function(id)
        sampSendChat(string.format('/pm %s ��������� �����, ������� ��� ������ ��������������!', id))
    end)
    sampRegisterChatCommand('sn', function(id)
        lua_thread.create(function()
        sampSendChat(string.format('/pm %s ��������� �����, ����� �� �����������!', id))
        wait(1000)
        sampShowDialog(51, "����-������", "������� ID ����������", "�������", "������", 1)
    end)
end)
    sampRegisterChatCommand('pmch', function(id)
        lua_thread.create(function()
        sampSendChat(string.format('/pm %s ��������� �����, ������ ��������� ��� ������!', id))
        wait(1150)
        sampSendChat(string.format('/re %s', id))
    end)
end)
    sampRegisterChatCommand('of', function(id)
        sampSendChat(string.format('/pm %s ��������� �����, ���������� ���������� ���������! 1/2', id))
    end)
    sampRegisterChatCommand('of2', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ��������� �����, ����������, � ��������� ��� �� ���������! 2/2', id))
            wait(1200)
            sampSendChat(string.format('/mute %s 5 offtop', id))
        end)
    end)
    sampRegisterChatCommand('tb', function(id)
        sampSendChat(string.format('/pm %s ��������� �����, �������� �������, ��� ��������� � ����, ��� ������� ������� �� ������!', id))
    end)
    sampRegisterChatCommand('ut', function(id)
        sampSendChat(string.format('/pm %s ��������� �����, ������� �������� ��� ������!', id))
    end)
    sampRegisterChatCommand('npa', function(id)
    sampSendChat(string.format('/awarn %s ��������� ������ �������������', id))
    end)
    sampRegisterChatCommand('rput', function(id)
        sampSendChat(string.format('/pm %s ��������� �����, �������� ��� �� �����! ������������� �� ����� ����������� � �� �������!', id))
    end)
    sampRegisterChatCommand('nv', function(id)
        sampSendChat(string.format('/pm %s ��������� �����, �� ������!', id))
    end)
    sampRegisterChatCommand('cheat', function(id)
        sampSendChat(string.format('/warn %s ������������� ���-��������', id))
    end)
    sampRegisterChatCommand('vcheat', function(id)
        sampSendChat(string.format('/ban %s 7 ����.����', id))
    end)
    sampRegisterChatCommand('caps', function(id)
        sampSendChat(string.format('/mute %s 5 Caps Lock', id))
    end)
    sampRegisterChatCommand('osk', function(id)
        sampSendChat(string.format('/mute %s 10 ���. ���./�������', id))
    end)
    sampRegisterChatCommand('oskp', function(id)
        sampSendChat(string.format('/mute %s 20 ���. �������', id))
    end)
    sampRegisterChatCommand('mat', function(id)
        sampSendChat(string.format('/mute %s 5 mat/mat in /rep', id))
    end)
    sampRegisterChatCommand('mq', function(id)
        sampSendChat(string.format('/mute %s 30 ����. �����', id))
    end)
    sampRegisterChatCommand('3', function(id)
        sampSendChat(string.format('/banan %s ����/�������', id))
    end)
    sampRegisterChatCommand('flood', function(id)
        sampSendChat(string.format('/mute %s 5 flood', id))
    end)
    sampRegisterChatCommand('relog', function(id)
        sampSendChat(string.format('/sban %s relog', id))
    end)
    sampRegisterChatCommand('k', function(id)
        sampSendChat(string.format('/vadgo %s ', id))
    end)
    sampRegisterChatCommand('kk', function(id)
        sampSendChat(string.format('/evad %s relog', id))
    end)
    sampRegisterChatCommand('cop', function(id)
        sampSendChat(string.format('/prison %s 5 Cop in Ghetto', id))
    end)
    sampRegisterChatCommand('afjb', function(id)
        sampSendChat(string.format('/awarn %s 5 ������ �� ������', id))
    end)
    sampRegisterChatCommand('kfjb', function(id)
        sampSendChat(string.format('/kban %s 10 ������ �� ������', id))
    end)
    sampRegisterChatCommand('dm', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/prison %s 10 DeathMatch', id))
            wait(1200)
            sampSendChat(string.format('/pm %s DM - Death Match, �������� ������ ��� �������. �� ���� �������� �� DM.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ ��: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('kb', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/kban %s 5 ����. | ������ �����', id))
            wait(1200)
            sampSendChat(string.format('/pm %s �� �������� ��� ������ �� ������/������������ ����� �� ������.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ ��: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('aa', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ������������. �� �������� ��������� �� ������ �� ������.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, �������� ��������� �� ���������� � �������:', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ������ �� �������������/�������/������� > ��������� ��������� �� ������� ����������: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('eva', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/kban %s 5 /evad | /vadgo', id))
            wait(1200)
            sampSendChat(string.format('/pm %s �� �������� ��� ������ �� ������/��, ������� �� ���������� � /vad.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ ��: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('db', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/prison %s 10 DriveBy', id))
            wait(1200)
            sampSendChat(string.format('/pm %s DriveBy - �������� ������ �����������. �� ���� �������� �� DB.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ ��: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('tk', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/prison %s 10 Team Kill', id))
            wait(1200)
            sampSendChat(string.format('/pm %s Team Kill - �������� ������ ����� �� �������. �� ���� �������� �� TK.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ ��: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('forum', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/gethere %s', id))
            wait(2000)
            sampSendChat(string.format('/freeze %s', id))
            wait(1000)
            sampSendChat(string.format('������������. � ������������� '..name.. ".", id))
            wait(1200)
            sampSendChat(string.format('� ��������� � ��� �� ��� �������, ��� �� ��� ��������� ������.', id))
            wait(1200)
            sampSendChat(string.format('������ ������ ���������� � �������: ', id))
            wait(1200)
            sampSendChat(string.format('������ �� �������������/�������/������� > ��������� ������ �� �������������� ', id))
            wait(1200)
            sampSendChat(string.format('� ��� ������� �������������� �� ��������� ������? ', id))
            wait(1200)
            sampShowDialog(20, "�������� ������ �� ������", "� ������ ������� ��������������?", "�������", "�� �������", 0)
        end)
    end)
    sampRegisterChatCommand('sk', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/prison %s 10 Spawn Kill', id))
            wait(1200)
            sampSendChat(string.format('/pm %s Spawn Kill - �������� ������� �� ����� ������. �� ���� �������� �� SK.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ ��: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('mg', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/mute %s 1 MetaGaming', id))
            wait(1200)
            sampSendChat(string.format('/pm %s MetaGaming - ������������� OOC ��-��� � IC ���. �� ���� �������� �� MG.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ ��: forum.maze-rp.ru!', id))
        end)
    end)
    sampRegisterChatCommand('bb', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/makeadmin %s 1', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���������� ���. �� �������� ����� �������������� 1 ������.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ��� ����, ����� ���������������� � �������, ������� /alogin � ������!', id))
            wait(1000)
            sampSendChat(string.format('/pm %s ��� ADM ������ ����� ������� ����� ���� ������. ��������� ���!', id))
        end)
    end)
    sampRegisterChatCommand('pmg', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ��.�����, � ��� �����. ������� �� �������� ��������. ��������� ���!', id))
        end)
    end)
    sampRegisterChatCommand('afk', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ��.�����, �� �������������� � AFK ��� ESC.', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ���� �� ���, ������� �������� "+" � ���!', id))
            wait(1200)
            sampSendChat(string.format('/pm %s � ��������� ������ � ���� �������� ��� �������!', id))
        end)
    end)
    sampRegisterChatCommand('nak2', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ������ �� �������������� �� ������ �������� �� ����� ������ - forum.maze-rp.ru.', id))
        end)
    end)
    sampRegisterChatCommand('admm', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ������������. �� ����� ������� ����� �������������� ����� �������� ���:', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ����� ������� /adm � ������� ���. ���� "���������", �������� �������, ������������ � ��������.', id))
        end)
    end)
    sampRegisterChatCommand('nrp', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ��.�����, ������� ������� ��� NonRP nick �� ��: Name_Surname! ', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ��� �������� ��� ���������� ������ �� ����� �������...', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ...� ����� ������� ��������������� � ����� �������!', id))
        end)
    end)
    sampRegisterChatCommand('lid', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/pm %s ��.�����, ����� �������� �������, ����������: ', id))
            wait(1200)
            sampSendChat(string.format('/pm %s �����: ������ ������. �����, ���: �������� ������ �� ������, ������ ������!', id))
            wait(1200)
            sampSendChat(string.format('/pm %s ...� ����� ������� ��������������� � ����� �������!', id))
        end)
    end)
    sampRegisterChatCommand('�������', function(id)
        lua_thread.create(function()
            sampSendChat(string.format('/agm', id))
            wait(1200)
            sampSendChat(string.format('/lammo', id))
            wait(1200)
            sampSendChat(string.format('/btrack', id))
            wait(1200)
            sampSendChat(string.format('/showmc', id))
            wait(1200)
            sampSendChat(string.format('/showbc', id))
            wait(1000)
            sampSendChat(string.format('/a [������] �� ������ ������ ��������. �����: ��������!', id))
            wait(1200)
        end)
    end)
    sampRegisterChatCommand('amg', function(ids)
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/mute %s 1 MG || ' .. adminname, idnar))
    end)
    sampRegisterChatCommand('acheat', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/warn %s Cheats || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('avcheat', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/ban %s 7 Vred. Cheats || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('dma', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/prison %s 10 DeathMatch || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('atk', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/prison %s 10 TeamKill || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('ask', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/prison %s 10 SpawnKill || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('amq', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/ban %s 7 ����.����� || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('aeva', function(ids)
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/kban %s 5 /evad | /vadgo || ' .. adminname, idnar))
    end)
    sampRegisterChatCommand('arelog', function(ids)
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/sban %s relog || ' .. adminname, idnar))
    end)
    sampRegisterChatCommand('adb', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/prison %s 10 DriveBy || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('nak', function(ids)
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/pm %s �� ���� �������� �� ������� �������������� ' .. adminname, idnar))
    end)
    sampRegisterChatCommand('acop', function(ids)
        lua_thread.create(function()
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/prison %s 5 Cop in Ghetto || ' .. adminname, idnar))
        wait(1000)
        sampSendChat("/a [Forma] +")
    end)
end)
    sampRegisterChatCommand('nak1', function(ids)
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/pm %s ���� �� �� �������� � ����������, ������ ������ �� ADM ' .. adminname, idnar))
    end)
    sampRegisterChatCommand('st1', function(ids)
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/a [������] ���������. ������� �������� �� ������ ������ [ ID: %s] Nick: ' .. adminname, idnar))
    end)
    sampRegisterChatCommand('st2', function(ids)
        local idnar = string.sub(ids, 0, string.find(ids, "%s"))
                sampAddChatMessage(ids, -1)
        local idadm = string.sub(ids, string.find(ids, "%s") + 1, string.len(ids))
        local name = sampGetPlayerNickname(idadm) -- ��� ��� ������ �� ����
        local adminname = string.sub(name, 0, 1) .. '.' .. string.sub(name, string.find(name, '_') + 1, string.len(name))
        sampSendChat(string.format('/a [������] �������. �������� �������� �� ������ ������ [ ID: %s] Nick: ' .. adminname, idnar))
    end)




    sampRegisterChatCommand("mzr", cmd_mzr)
    sampRegisterChatCommand("mzd", cmd_mzd)
    sampRegisterChatCommand("mda", cmd_mda)
    sampRegisterChatCommand("update", cmd_update)
    sampRegisterChatCommand("pozdr", cmd_pozdr)
end

function update()
    local fpath = os.getenv('TEMP') .. '\\Tvoj_Script_Nazvanie.json' -- ���� ����� �������� ��� ������ ��� ��������� ������
    downloadUrlToFile('https://raw.githubusercontent.com/KenshiTV/scriptsoption/master/obnovlenie.txt', fpath, function(id, status, p1, p2) -- ������ �� ��� ������ ��� ���� ������� ������� � ��� � ���� ��� ����� ������ ����
      if status == dlstatus.STATUS_ENDDOWNLOADDATA then
      local f = io.open(fpath, 'r') -- ��������� ����
      if f then
        local info = decodeJson(f:read('*a')) -- ������
        updatelink = info.updateurl
        if info and info.latest then
          version = tonumber(info.latest) -- ��������� ������ � �����
        if version > tonumber(thisScript().version) then -- ���� ������ ������ ��� ������ ������������� ��...
            lua_thread.create(goupdate)
        else -- ���� ������, ��
            update = false
            sampAddChatMessage('{FFFFFF}[AdminTools]: ���������� {B70A0A}�� ����{FFFFFF} �������')
        end
        end
      end
    end
  end)
  end

  function goupdate()
    sampAddChatMessage(('{FFFFFF}[AdminTools]:{53D229} ���������� {FFFFFF}����������. ��������...'), 0x6495ED)
    sampAddChatMessage(('{FFFFFF}[AdminTools]:{FFFFFF} ������� ������: '..thisScript().version..". ����� ������: "..version), 0x6495ED)
    wait(300)
    downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- ������ ��� ������ � latest version
    if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
        sampAddChatMessage(('{FFFFFF}[AdminTools]:{FFFFFF} ���������� {53D229}���������! {FFFFFF} ����� ������ ��� ���� ��������� ��������� ������� /update'), 0x6495ED)
        thisScript():reload()
    end
  end)
  end

  function reconnect()
    local ip, port = sampGetCurrentServerAddress()
    closeConnect()
    sampConnectToServer(ip, port)
  end

  function closeConnect()
    local bs = raknetNewBitStream()
    raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, bs)
    raknetDeleteBitStream(bs)
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr()
	activeWH = true
	memory.setfloat(pStSet + 39, 1488.0)
	memory.setint8(pStSet + 47, 0)
	memory.setint8(pStSet + 56, 1)
end

function nameTagOff()
	local pStSet = sampGetServerSettingsPtr()
	activeWH = false
	memory.setfloat(pStSet + 39, 50.0)
	memory.setint8(pStSet + 47, 0)
	memory.setint8(pStSet + 56, 1)
end

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

function reloading()
    showCursor(false, false)
    thisScript():reload() 
  end
  function offscript()
    showCursor(false, false)
    thisScript():unload()
  end