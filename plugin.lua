local game, kit, menu
game =
	{
	factors = {},
	groups = {},
	marks = {},
	notes = {},
	points = {},
	velocities = {},
	}
kit = {}
DataSheet =
	{
	BM = function(v)
		return {StartTime = v.StartTime, Note = v.Note} end,
	HO = function(v)
		local endTime = v.EndTime
		local endTime = (endTime ~= 0) and endTime or nil
		return {StartTime = v.StartTime, Lane = v.Lane, EndTime = endTime} end,
	SF = function(v)
		return {StartTime = v.StartTime, Multiplier = v.Multiplier} end,
	SV = function(v)
		return {StartTime = v.StartTime, Multiplier = v.Multiplier} end,
	TP = function(v)
		return {StartTime = v.StartTime, Bpm = v.Bpm} end,
	RAW = function(v)
		return v end,
	COS = function(v, ...)--{StartTime = 0}
		local Table = {}
		for i2, v2 in ipairs({...}) do
			Table[v2] = v[v2] end
		return Table end,
	COSidx = function(v, ...)--{1 = StartTime, StartTime = 0}
		local Table = {...}
		for _, v2 in ipairs(Table) do
			Table[v2] = v[v2] end
		return Table end,
	COSval = function(v, ...)--{0}
		local Table = {...}
		for i, v2 in ipairs(Table) do
			Table[i] = v[v2] end
		return unpack(Table) end,
	}
function StartUp()
	if (not utils) or (not imgui) then return true end
	u = 
		{
		CreateBM = utils.CreateBookmark,
		CreateEA = utils.CreateEditorAction,
		}
	iPushCol = imgui.PushStyleColor
	iPopCol = imgui.PopStyleColor
	icol = imgui_col
	iPushVar = imgui.PushStyleVar
	ivar = imgui_style_var
	iSL = imgui.SameLine
	iButton = imgui.Button
	iTextFormatless = imgui.TextUnformatted
	StartUp = function()
		iPushVar(ivar.WindowBorderSize, 5)
end end
math.infinite = 1/0
math.coinflip = function(LOW, BIG)
	return math.random(LOW or 0, BIG or 1) == 1 end
do
	local gmatch, Index
string.igmatch = function(STRING, PATTERN)
	gmatch = string.gmatch(STRING, PATTERN)
	Index = 0
	return function()
		local Match = gmatch()
		if Match ~= nil then
			Index = Index + 1
			return Index, Match
end end end
end--do
string.split = function(STRING, FORMAT)
	FORMAT = FORMAT or "%g+"
	local Table = {}
	for i, v in STRING:igmatch(FORMAT) do
		Table[i] = v end
	return Table end
--¿START ¿END numeric
function game.SetupSelection(START, END)
	if START and END then
		return START, END end
	local Notes = state.SelectedHitObjects
	return game.SetupOffsets(Notes) end
function game.SetupOffsets(TABLE)
	local TABLE = TABLE or state.SelectedHitObjects
	if #TABLE == 0 then
		return -1, -1 end
	local Start, End = TABLE[1].StartTime, TABLE[#TABLE].StartTime
	return Start, End end
function game.Create(USER, DATA)
	local Table = {}
	for i, v in ipairs(DATA) do
		Table[i] = utils[USER](unpack(v)) end
	return Table end
--¿DEFAULT string
function game.GetString(STRING, DEFAULT)
	return DataSheet[STRING and STRING:upper()] or DataSheet[DEFAULT or "RAW"] end

--PERFORM boolean
--... {action, data}
function game.Perform(PERFORM, ACTIONS)
	local CreateEA = {}
	local Length = #ACTIONS
	for i = 1, Length, 2 do
		CreateEA[i] = u.CreateEA(ACTIONS[i], ACTIONS[i+1]) end
	print(CreateEA)
	if (not PERFORM) or (#CreateEA == 0) then
		return CreateEA end
	actions.PerformBatch(CreateEA) end

function kit.FindFirst(TABLE, START)
	local Start, End = 1, #TABLE
	local Index = #TABLE+1
	while Start <= End do
		local Mid = math.floor((Start + End)/2)
		if TABLE[Mid].StartTime >= START then
			Index, End = Mid, Mid-1
		else
			Start = Mid+1
	end end
	return Index end
function kit.FindLast(TABLE, END)
	local Start, End = 1, #TABLE
	local Index = 0
	while Start <= End do
		local Mid = math.floor((Start + End)/2)
		if TABLE[Mid].StartTime <= END then
			Index, Start = Mid, Mid+1
		else
			End = Mid-1
	end end
	return Index end
 --Returns indexs of TABLE's values START and END
  --Input: Time, Output: Index
--¿START ¿END numeric
function game.FirstLast(TABLE, START, END)
	local START, END = game.SetupSelection(START, END)
	local START, END = kit.FindFirst(TABLE, START), kit.FindLast(TABLE, END)
	return START, END end
 --Returns values of TABLE's indexes START and END
  --Input: Index, Output: Table
--¿STRING string
--¿TABLE table
function game.Between(STRING, START, END, TABLE)
	if not (START and END) then return {} end
	local Sheet = GetString(STRING)
	local TABLE = TABLE or map.SelectedHitObjects
	local Table, Index = {}, 0
	for i = START, END do
		local v = TABLE[i]
		Index = Index+1
		Table[Index] = v end
	return Table, START, END end
--¿STRING string
function game.Get(STRING, TABLE)
	local Sheet = game.GetString(STRING)
	local Table = {}
	for i, v in ipairs(TABLE) do
		Table[i] = Sheet(v) end
	return Table end
--¿STRING string
function game.GetUnique(STRING, TABLE)
	local Sheet = game.GetString(STRING)
	local Holder, Table, Index = {}, {}, 0
	for i, v in ipairs(TABLE) do
		local Data = Sheet(v)
		if not Holder[Data.StartTime] then
			Holder[Data.StartTime] = true
			Index = Index+1
			Table[Index] = Data
	end end
	return Table end
--¿STRING string
--¿START ¿END numeric
function game.Quarry(STRING, TABLE, START, END)
	local START, END = game.FirstLast(TABLE, START, END)
	local Sheet = game.GetString(STRING)
	local Table, Index = {}, 0
	for i = START, END do
		Index = Index+1
		Table[Index] = Sheet(TABLE[i]) end
	return Table end
kit.Get = function(STRING, TABLE, ...)
	local Sheet = DataSheet[STRING or "COSval"]
	local Data = TABLE or game.Get(game.GetString(STRING, "HO"), TABLE)
	for i, v in ipairs(Data) do
		Data[i] = Sheet(v, ...) end
	return Data end
do
local KeyIndex = {}
for i = 65, 90 do
	KeyIndex[i] = false end
kit.KeyKall = function(...)
	for i, v in ipairs({...}) do
		if utils.IsKeyDown(v) then return true end end
	return false end
function kit.IsKeyCom(KEY, ...)
	if kit.KeyKall(select(2, ...))	then
		if kit.IsKeyPressed(KEY) then
			return true, true end
		return false, true end
	return false, false
end
function kit.IsKeyPressedEx(...)
	if kit.KeyKall(select(2, ...)) then
		return false, false end
	return kit.IsKeyPressed(...) end
function kit.IsKeyPressed(KEY)
	local Key = tonumber(KEY)
	if utils.IsKeyDown(KEY) then
		if not KeyIndex[Key] then
			KeyIndex[Key] = true
			return true, true end
		return false, true end
	KeyIndex[Key] = false
	return false, false
end
end
--FIND table
--¿END boolean
table.find = function(TABLE, FIND, END)
	local Holder = 1
	local Index = false
	local End = #FIND
	for i, v in ipairs(TABLE) do
		if v == FIND[Holder] then
			if Holder == 1 then
				Index = i end
			if Holder == End then
				if END then
					Index = i + 1 end break end
			Holder = Holder + 1
		else
			Holder = 1
	end end
	return Index end
table.unique = function(TABLE)
	local Table, Holder = {}, {}
	local Index = 0
	for i, v in ipairs(TABLE) do
		if not Holder[v] then
			Holder[v] = true
			Index = Index + 1
			Table[Index] = v
	end end
	return Table end
table.copy = function(TABLE)
	local Table = {}
	if next(DFSD) ~= 1 then
		for i, v in next, TABLE do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	else
		for i, v in ipairs(TABLE) do
			Table[i] = type(v) == "table" and table.copy(v) or v end
	end
	return Table end
table.keys = function(TABLE)
	local Table = {}
	local Index = 0
	for i, v in next, TABLE do
		Table[i] = v end
	return table.unique(Table) end
kit.pack = function(TABLE, CONDENSE)
	local Table = {}
	local Index = 0
	local IdxAd
	local Sheet
	if CONDENSE then
		Table[0] = {}
		IdxAd = 1
		local Index = 0
		Sheet = function(TABLE, I, V)
			Index = Index + 1
			TABLE[0][Index] = I
		end
	else
		local Index = 0
		Sheet = function(TABLE, I, V)
			Index = Index + 1
			TABLE[Index] = I
		end
		IdxAd = 1
	end
	for i, v in next, TABLE do
		Sheet(Table, i, v) end
	for i, v in next, TABLE do
		Table[i] = v end
	return Table
end
kit.userdatafy = function(TABLE)
	local _Keys
	if TABLE[0] then
		_Keys = TABLE[0]
	else
		_Keys = {unpack(TABLE)}
	end
	local Copy = TABLE
	if not _Keys then print("w!", "userdatafy: No keys, table returned, ", TABLE)return TABLE end
	return setmetatable({}, {
		__index = function(_, KEY)
			if type(KEY) == "number" then
				local Key = _Keys[KEY]
				return Key and Copy[Key]
			end
			return Copy[KEY]
		end,
		__call = function(_, KEY)
			if type(KEY) == "number" then
				local Key = _Keys[KEY]
				return Key and Copy[Key]
			end
			return Copy[KEY]
		end,
		__newindex = function(_, KEY, VALUE)
			Copy[KEY] = VALUE
		end,
		__tostring = function(self)
			return table.concat(self._Keys or {}, ", ")
		end	
		})
end
_size =
	{
	[-2] = vector.New(-1, -1),
	[-1] = vector.New(-1, 0),
	[0] = vector.New(0, 0),
	[1] = vector.New(80, 20),
	[2] = vector.New(37, 20),
	}
CBBoolean =--Che Be Ballin'
	{
	[1] = false,
	[2] = false,
	[3] = false,
	}
_Mark =
	{
	Active = false,
	Notes = {},
	Start = 0,
	CyclePoint = false,
	SearchEnd = nil,
	End = 0,
	InText = "",
	Marks = {},
	Quarry = {},
	Remove = {},
	}
do
	local Size = _size[1]
	local Start, End
function BookmarksMaker()
	-- imgui.SetNextItemWidth(80)
	-- ui.Setting(imgui.BeginCombo("###Settings", "Settings"))iSL()
	local Place = iButton("Place", Size)
	iSL()ui.Remove(iButton("Remove", Size))
	if _Mark.Active then
		iSL()ui.Cycle(iButton("Cycle", Size))
	end
	if #_Mark.InText ~= 0 then
		iSL()ui.Clear(iButton("Clear", Size))iSL()
		imgui.SetNextItemWidth(-1)
		if _Mark.CyclePoint and not _Mark.SearchEnd then
			-- local Indent = (80+12)*4
			-- imgui.Indent(Indent)
			local Start = iButton("Start", _size[2])
			iSL(0, 3)
			local End = iButton("End", _size[2])
			iSL(0, 3)
			ui.InputStartEnd(Start, End)
			-- imgui.Unindent(Indent)
		end
		ui.InputHint(imgui.InputTextWithHint("##From", "Start Cycle From", "", 50, 64))
		ui.Place(Place)
	end
	_Mark.InText = select(2, imgui.InputTextMultiline("##BookmarkInputer", _Mark.InText, 9999, _size[-2], 32))
end
end--do
function fixYamlValues(TABLE)
	for i, v in pairs(TABLE) do
		if type(v) == "table" then
			fixValues(v)
		else
			local Number = tonumber(v)
			if Number then--fix number
				TABLE[i] = Number
			elseif v == "false" or v == "true" then--fix boolean
				TABLE[i] = v == "true"
end end end end
ui = {}
--[[
a b c d e f h
i j k l m n o
p q r s t u v
w x y z
]]
ui.Clear = function(CLEAR)
	if CLEAR then
		_Mark.InText = ""
	end
end
ui.Cycle = function(CYCLE)
	if CYCLE then
		_Mark.Active = false
		_Mark.SearchEnd = false
		_Mark.CyclePoint = false
	end
end
do
	local Start, End
ui.InputHint = function(ACTIVE, OUTTEXT)
	if ACTIVE then
		if #OUTTEXT == 0 then
			print("s!", "Cycle Cleared")
			_Mark.CyclePoint = false return end
		Start, End = string.find(_Mark.InText, OUTTEXT)
		if not Start then
			print("e!", Start, End)
		else
			print("s!", Start, End)
			_Mark.Active = false
			_Mark.SearchEnd = false
			_Mark.CyclePoint = string.split(OUTTEXT)
	end end
end
ui.InputStartEnd = function(START, END)
	if START then
		_Mark.SearchEnd = false
		print("i!", "Cycling: Start")
	elseif END then
		_Mark.SearchEnd = true
		print("i!", "Cycling: End")
	end
end
end--do
do
local function StartCruor(TIMES)
	local Start, End = _Mark.Start, _Mark.End
	local Notes = _Mark.Notes
	local Table = {}
	local Index = 0
	for i = Start, End do
		Index = Index + 1
		local Time = TIMES[Index]
		if not Time then
			_Mark.Start = i
			return Table, true end
		Table[Index] = {Time.StartTime, Notes[i]}
	end
	return Table, false
end
ui.Place = function(PLACE)
	if PLACE then
		local RAW = game.Quarry("RAW", map.Bookmarks)
		local BM = kit.Get("COSval", RAW, "StartTime")
		local _BM = _Mark
		local Remove, Holder = {}, {}
		if not _Mark.Active then
			_BM.Notes = string.split(_BM.InText)
			if _BM.CyclePoint then
				local Index = table.find(_BM.Notes, _BM.CyclePoint, _BM.SearchEnd)
				_BM.Start = Index or 1
			else
				_BM.Start = 1
			end
			_BM.End = #_BM.Notes
			_BM.Marks = {}
		end
		_BM.Marks, _BM.Active = StartCruor(game.GetUnique("HO", state.SelectedHitObjects))
		local Addite = game.Create("CreateBookmark", _BM.Marks)
		for i, v in ipairs(_BM.Marks) do
			local V1 = v[1]
			if not Holder[V1] then
				Holder[V1] = true
		end end
		local EndValue = _BM.Marks[#_BM.Marks][1]
		for i, v in ipairs(BM) do
			if not Holder[v] then
				if v > EndValue then break end
				Holder[v] = true
			else
				Remove[#Remove+1] = RAW[i]
		end end
		actions.PerformBatch(
			{
			u.CreateEA(40, Addite),
			u.CreateEA(43, Remove)
			})
	end
end
end--do
ui.Setting = function(SETTING)
	if SETTING then
		for i = 1, 3 do
			_, CBBoolean[i] = imgui.CheckBox("asdf###"..i, CBBoolean[i])
		end
		imgui.EndCombo()
	end
end
ui.Remove = function(REMOVE)
	if REMOVE then
		local Bookmarks = game.Quarry("RAW", map.Bookmarks)
		local Count = #Bookmarks
		if Count ~= 0 then
			print("i!", "Removed: ".. Count.. " Bookmarks")
			actions.Perform(u.CreateEA(43, Bookmarks))
	end end
end
function draw()
	if StartUp() then return end
	if imgui.Begin("moro.Bookmark") then
		BookmarksMaker()
		imgui.End()
	end
end
