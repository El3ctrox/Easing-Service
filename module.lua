--// Utils
local Task = require(script.Parent.Task)
local Styles = require(script.Styles)

--// Vars
local easings = {}
local nextId = 1

--// Functions
local Clock = os.clock
local Max = math.max
local Min = math.min
local Clamp = math.clamp

local function emptyFunction() end

local function lerp(begin,goal,fade)
	
	if typeof(begin)=="number" then
		
		return begin + (goal - begin) * fade
	else
		
		return begin:Lerp(goal,fade)
	end
end

--// Methods
local function Reset(self)
	
	easings[self._id] = nil
	
	self._reversing = false
	self._repeats = 0
	self._toYield = nil
	
	return self
end
local function Resume(self, delay: number?, fade: number?)
	
	self._toUnyield = Clock() + (delay or 0)
	self._started = self._toUnyield - (fade or self._lastFade)*self._infos[1]
	self._toYield = nil
	
	easings[self._id] = self
	
	return self
end
local function Play(self, delay: number?, fade: number?)
	
	Reset(self)
	return Resume(self, delay, fade)
end
local function ReversePlay(self, delay: number?, fade: number?)
	self._reversing = true
	
	return Play(self, delay, fade)
end
local function SetStyle(self, styleName: string)
	
	assert(typeof(styleName)=="string", "Argument 1 (styleName) must to be a string, got "..typeof(styleName))

	local formula = Styles[ styleName:lower() ]
	assert(formula,"Style \""..styleName.."\" not exist")
	
	self._formula = formula
	
	return self
end
local function GetFade(self)
	return ( Clock() - self._started ) / self._infos[1]
end
local function Stop(self, delay: number?)
	
	if (delay or 0) == 0 then
		
		easings[self._id] = nil
		self._lastFade = GetFade(self)
	else
		
		self._toYield = Clock() + delay
	end
	
	return self
end

--// Module
local Easing = {}

--// Constructor
function Easing.new(object: Instance|{}, infos: {}, goal: any, begin: any)
	
	--> Assert Info
	local infos = infos or {}
	infos[1] = infos[1] or 1
	infos[2] = infos[2] or "linear"
	infos[3] = infos[3] or false
	infos[4] = infos[4] or 0
	infos[5] = infos[5] or 0
	infos[6] = infos[6] or 0
	
	assert(typeof(infos[1] ), "Info 1 (duration) must to be a number, got "..typeof(infos[1] ) )
	assert(typeof(infos[2] ), "Info 2 (styleName) must to be a string, got "..typeof(infos[2] ) )
	assert(typeof(infos[3] ), "Info 3 (reverse) must to be a boolean, got "..typeof(infos[3] ) )
	assert(typeof(infos[4] ), "Info 4 (repeats) must to be a number, got "..typeof(infos[4] ) )
	assert(typeof(infos[5] ), "Info 5 (repeatDelay) must to be a number, got "..typeof(infos[5] ) )
	assert(typeof(infos[6] ), "Info 6 (reverseDelay) must to be a number, got "..typeof(infos[6] ) )
	
	--> Load Begin
	local objectType = typeof(object)
	if objectType ~= "function" then
		
		begin = begin or {}
		
		for i,_ in next,goal do
			
			if not begin[i] then
				
				begin[i] = object[i]
			end
		end
	else
		
		begin = begin or 0
	end
	
	--> Instance
	local self = {
		--> Callbacks
		Finished = emptyFunction,
		Repeating = emptyFunction,
		Reversing = emptyFunction,
		
		--> Methods
		Play = Play,
		Stop = Stop,
		Resrt = Reset,
		Resume = Resume,
		ReversePlay = ReversePlay,
		SetStyle = SetStyle,
		GetFade = GetFade,
		
		--> Track Stats
		_reversing = false,
		_started = 0,
		_repeats = 0,
		
		_toYield = nil,
		_toUnyield = 0,
		_lastFade = 0,
		
		--> Anim Infos
		_goal = goal,
		_begin = begin,
		_infos = infos,
		_formula = nil,
		
		--> Infos
		_id = nextId,
		Object = objectType ~= "function" and object,
		Callback = objectType == "function" and object,
	}
	
	--> Setup
	self:SetStyle(infos[2] )
	nextId += 1
	
	--> End
	return self
end

--// Loop
local easingTask = Task.new(function()
	
	for id = 1,nextId-1 do
		
		local easing = easings[id]
		if easing == nil then continue end
		
		--> Yield & Unyield
		local currentTime = Clock()
		
		if currentTime < easing._toUnyield then continue end
		
		if easing._toYield and currentTime > easing._toYield then
			
			easings[id] = nil
			easing._lastFade = (currentTime - easing._started) / easing._infos[1]
			
			continue
		end
		
		--> Vars
		local started = easing._started
		local infos = easing._infos
		local duration = infos[1]
		
		--> Fade
		local timing = currentTime - started
		local fade = timing / duration 
		
		--> Lerp
		local begins = easing._begin
		local object = easing.Object
		local multiplier = easing._formula( Clamp( easing._reversing and 1-fade or fade, 0, 1) )
		
		if object then
			
			--assert( typeof(multiplier)=="number", infos[2] )
			
			for i,goal in next,easing._goal do
				
				local begin = begins[i]
				object[i] = lerp(begin, goal, multiplier)
			end
		else
			
			easing.Callback( lerp(begins, easing._goal, multiplier) )
		end
		
		--> Controller
		if fade >= 1 then
			
			local reversing = easing._reversing
			local repeateds = easing._repeats
			local reverse = infos[3]
			local repeats = infos[4]
			
			if reverse and not reversing then
				
				-- reverse
				local reverseDelay = infos[6]
				
				easing._started = currentTime + reverseDelay - (timing%duration)
				easing._unyield = currentTime + reverseDelay
				easing._reversing = true
				
				easing:Reversing()
				
			elseif repeateds < repeats then
				
				-- repeat
				local repeatDelay = infos[5]
				
				easing._repeats += 1
				easing._started = currentTime + repeatDelay - (timing%duration)
				easing._unyield = currentTime + repeatDelay
				easing._reversing = false
				
				easing:Repeating(easing._repeats)
			else
				
				-- finish
				easings[id] = nil
				easing._lastFade = 1
				
				easing:Finished()
			end
		end
		
		--> End
	end
end):SetRepeats(-1):Resume()

--// End
return Easing
