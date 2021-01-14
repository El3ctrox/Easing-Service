--[[
Easing local functions adapted from Robert Penner's AS3 tweening equations.
--]]

--// Consts
local PI = math.pi
local HALF_PI = PI/2

local ELASTIC_A = 1
local ELASTIC_P = 0.3
local ELASTIC_S = ELASTIC_P/4

local A = 1.70158
local B = A + 1

--// local functions
local sin = math.sin
local cos = math.cos

local function linear(fade)
	return fade
end

local function inQuadratic(fade)
	return fade^2
end
local function outQuadratic(fade)
	fade -= 1
	return 1-fade^2
end
local function inOutQuadratic(fade)
	return fade < .5
		and inQuadratic(fade*2)/2
		or ( 1+outQuadratic(fade*2-1) ) / 2
end
local function outInQuadratic(fade)
	return fade < .5
		and outQuadratic(fade*2)/2
		or ( 1+inQuadratic(fade*2-1) ) / 2
end

local function inCubic(fade)
	return fade^3
end
local function outCubic(fade)
	fade -= 1
	return 1-fade^3
end
local function inOutCubic(fade)
	return fade < .5
		and inCubic(fade*2)/2
		or ( 1+outCubic(fade*2-1) ) / 2
end
local function outInCubic(fade)
	return fade < .5
		and outCubic(fade*2)/2
		or ( 1+inCubic(fade*2-1) ) / 2
end

local function inQuartic(fade)
	return fade^4
end
local function outQuartic(fade)
	fade -= 1
	return 1-fade^4
end
local function inOutQuartic(fade)
	return fade < .5
		and inQuartic(fade*2)/2
		or ( 1+outQuartic(fade*2-1) ) / 2
end
local function outInQuartic(fade)
	return fade < .5
		and outQuartic(fade*2)/2
		or ( 1+inQuartic(fade*2-1) ) / 2
end

local function inQuintic(fade)
	return fade^5
end
local function outQuintic(fade)
	fade -= 1
	return 1+fade^5
end
local function inOutQuintic(fade)
	return fade < .5
		and inQuintic(fade*2)/2
		or ( 1+outQuintic(fade*2-1) ) / 2
end
local function outInQuintic(fade)
	return fade < .5
		and outQuintic(fade*2)/2
		or ( 1+inQuintic(fade*2-1) ) / 2
end

local function inExponential(fade)
	if fade == 0 then
		return 0
	end
	
	return 2^(10 * (fade - 1))
end
local function outExponential(fade)
	if fade == 1 then
		return 1
	end
	
	return 1 - 2^(-10 * fade)
end
local function inOutExponential(fade)
	return fade < .5
		and inExponential(fade*2)/2
		or ( 1+outExponential(fade*2-1) ) / 2
end
local function outInExponential(fade)
	return fade < .5
		and outExponential(fade*2)/2
		or ( 1+inExponential(fade*2-1) ) / 2
end

local function inSine(fade)
	return 1-cos(fade * HALF_PI)
end
local function outSine(fade)
	return sin(fade * HALF_PI)
end
local function inOutSine(fade)
	return fade < .5
		and inSine(fade*2)/2
		or ( 1+outSine(fade*2-1) ) / 2
end
local function outInSine(fade)
	return fade < .5
		and outSine(fade*2)/2
		or ( 1+inSine(fade*2-1) ) / 2
end

local function inCircular(fade)
	return -( (1-fade*fade)^.5 - 1)
end
local function outCircular(fade)
	return 1-(fade-1)*(fade-1)^.5
end
local function inOutCircular(fade)
	return fade < .5
		and inCircular(fade*2)/2
		or ( 1+outCircular(fade*2-1) ) / 2
end
local function outInCircular(fade)
	return fade < .5
		and outCircular(fade*2)/2
		or ( 1+inCircular(fade*2-1) ) / 2
end

local function inElastic(fade)
	if fade == 0 or fade == 1 then
		return fade
	end
	
	fade -= 1
	return -(ELASTIC_A * 2^(-10 * fade) * sin((fade - ELASTIC_S) * (2 * PI) / ELASTIC_P))
end
local function outElastic(fade)
	if fade == 0 or fade == 1 then
		return fade
	end
	
	return ELASTIC_A * 2^(-10 * fade) *  sin((fade - ELASTIC_S) * (2 * PI) / ELASTIC_P) + 1
end
local function inOutElastic(fade)
	return fade < .5
		and inElastic(fade*2)/2
		or ( 1+outElastic(fade*2-1) ) / 2
end
local function outInElastic(fade)
	return fade < .5
		and outElastic(fade*2)/2
		or ( 1+inElastic(fade*2-1) ) / 2
end

local function inBack(fade)
	return B * fade^3 - A * fade^2
end
local function outBack(fade)
	fade -= 1
	return 1 + B * fade^3 + A * fade^2
end
local function inOutBack(fade)
	return fade < .5
		and inBack(fade*2)/2
		or ( 1+outBack(fade*2-1) ) / 2
end
local function outInBack(fade)
	return fade < .5
		and outBack(fade*2)/2
		or ( 1+inBack(fade*2-1) ) / 2
end

local function outBounce(fade)
	
	if fade < 1/2.75 then
		return 7.5625 * fade^2
		
	elseif fade < 2/2.75 then
		fade -= 1.5/2.75
		
		return 7.5625 * fade^2 + 0.75
		
	elseif fade < 2.5/2.75 then
		fade -= 2.25/2.75
		
		return 7.5625 * fade^2 + 0.9375
		
	else
		fade -= 2.625/2.75
		
		return 7.5625 * fade^2 + 0.984375
	end
end
local function inBounce(fade)
	
	return 1 - outBounce(1-fade)
end
local function inOutBounce(fade)
	return fade < .5
		and inBounce(fade*2)/2
		or ( 1+outBounce(fade*2-1) ) / 2
end
local function outInBounce(fade)
	return fade < .5
		and outBounce(fade*2)/2
		or ( 1+inBounce(fade*2-1) ) / 2
end

--// End
return {
	linear = linear,
	
	inquadratic = inQuadratic,
	outquadratic = outQuadratic,
	inoutquadratic = inOutQuadratic,
	outinquadratic = outInQuadratic,
	
	incubic = inCubic,
	outcubic = outCubic,
	inoutcubic = inOutCubic,
	outincubic = outInCubic,
	
	inquartic = inQuartic,
	outquartic = outQuartic,
	inoutquartic = inOutQuartic,
	outinquartic = outInQuartic,
	
	inquintic = inQuintic,
	outquintic = outQuintic,
	inoutquintic = inOutQuintic,
	outinquintic = outInQuintic,
	
	inexponential = inExponential,
	outexponential = outExponential,
	inoutexponential = inOutExponential,
	outinexponential = outInExponential,
	
	insine = inSine,
	outsine = outSine,
	inoutsine = inOutSine,
	outinsine = outInSine,
	
	incircular = inCircular,
	outcircular = outCircular,
	inoutcircular = inOutCircular,
	outincircular = outInCircular,
	
	inelastic = inElastic,
	outelastic = outElastic,
	inoutelastic = inOutElastic,
	outinelastic = outInElastic,
	
	inback = inBack,
	outback = outBack,
	inoutback = inOutBack,
	outinback = outInBack,
	
	inbounce = inBounce,
	outbounce = outBounce,
	inoutbounce = inOutBounce,
	outinbounce = outInBounce,
}
