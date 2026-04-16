game =
	{
	factors = {},
	groups = {},
	marks = {},
	notes = {},
	points = {},
	velocities == {},
	}
kit = {}
DataSheet =
	{
	BM = function(v)
		return {StartTime = v.StartTime, Note = v.Note} end,
	HO = function(v)
		local endTime = v.EndTime
		local endTime = (endTime ~= 0) and endTime
		return {StartTime = v.StartTime, Lane = v.Lane, EndTime = endTime} end,
	SF = function(v)
		return {StartTime = v.StartTime, Multiplier = v.Multiplier} end,
	SV = function(v)
		return {StartTime = v.StartTime, Multiplier = v.Multiplier} end,
	TP = function(v)
		return {StartTime = v.StartTime, Bpm = v.Bpm} end,
	RAW = function(v)
		return v end,
	}
_Size =
	{
	Infinite = vector.new(-1, -1),
	Regular = vector.new(0, 0),
	Micro = vector.new(1, 1),
	Button = vector.new(80, 20),
	}
_Bookmarks =
	{
	Active = false,
	Notes = {},
	Start = 0,
	End = 0,
	InText = "",
	Marks = {},
	Quarry = {},
	Remove = {},
	}
Infinite = 1/0
function StartUp()
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
	
	iButton = imgui.Button
	iTextFormatless = imgui.TextUnformatted
	StartUp = function()
		iPushVar(ivar.WindowBorderSize, 5)
	end end
function string.split(STRING, FORMAT)
	local FORMAT = FORMAT or "%g+"
	local Table = {}
	local Index = 0
	for i in STRING:gmatch(FORMAT) do
		Index = Index+1
		Table[Index] = i end
	return Table end

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
function game.GetString(STRING)
	return DataSheet[STRING and STRING:upper()] or DataSheet["RAW"] end
--PERFORM boolean
--... {action, data}
function game.Perform(PERFORM, ...)
	local CreateEA = {}
	for i, v in ipairs({...}) do
		CreateEA[i] = u.CreateEA(v[1], v[2]) end
	if not (PERFORM) then
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

function StartCruor(TIMES)
	local Start, End = _Bookmarks.Start, _Bookmarks.End
	local Notes = _Bookmarks.Notes
	local Table = {}
	local Index = 0
	for i = Start, End do
		Index = Index + 1
		local Time = TIMES[Index]
		if not Time then
			_Bookmarks.Start = i
			return Table, true end
		Table[Index] = {Time.StartTime, Notes[i]}
	end
	return Table, false
end

function BookmarksMaker()
	local Size = _Size.Button
	local Place = iButton("Place", Size)
	imgui.SameLine()
	local Remove = iButton("Remove", Size)
	if #_Bookmarks.InText ~= 0 then
		imgui.SameLine()
		local Clear = iButton("Clear", Size)
		if Clear then _Bookmarks.InText = "" end end
	if _Bookmarks.Active then
		imgui.SameLine()
		local Reset = iButton("Cycle", Size)
		if Reset then _Bookmarks.Active = false end end
	if Place then
		local RAW = game.Quarry("RAW", map.Bookmarks)
		local BM = game.Get("BM", RAW)
		local _BM = _Bookmarks
		local Remove, Holder = {}, {}
		if not _Bookmarks.Active then
			_BM.Notes = string.split(_BM.InText)
			_BM.Start = 1
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
		for i, v in ipairs(BM) do
			local V1 = v.StartTime
			if not Holder[V1] then
				Holder[V1] = true
			else
				Remove[#Remove+1] = RAW[i]
		end end
		actions.PerformBatch(
			{
			u.CreateEA(40, Addite),
			u.CreateEA(43, Remove),
			})
	end
	if Remove then
		local Bookmarks = game.Quarry("RAW", map.Bookmarks)
		local Count = #Bookmarks
		if Count ~= 0 then
			print("i!", "Removed: ".. Count.. " Bookmarks")
			actions.Perform(u.CreateEA(43, Bookmarks))
	end end
	local Active, OutText = imgui.InputTextMultiline("##BookmarkInputer", _Bookmarks.InText, 9999, _Size.Infinite)
	if Active then
		_Bookmarks.InText = OutText end
end
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

function draw()
	StartUp()
	if imgui.Begin("moro.Bookmark") then
		BookmarksMaker()
		imgui.End()
	end
end
