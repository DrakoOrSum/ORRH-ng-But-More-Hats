local MainModel = script.Parent

--==========================================================================================================--
--                                       Noise generation code                                            ==--
--==========================================================================================================--
--
local perm = {
	151,160,137,91,90,15,
	131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
	190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
	88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
	77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
	102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
	135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
	5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
	223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
	129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
	251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
	49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
	151,160,137,91,90,15,
	131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
	190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
	88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
	77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
	102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
	135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
	5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
	223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
	129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
	251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
	49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}
local floor = math.floor
local function grad( hash, x, y )
    local h = hash%8;          -- Convert low 3 bits of hash code
    local u = h<4 and x or y;  -- into 8 simple gradient directions,
    local v = h<4 and y or x;  -- and compute the dot product with (x,y).
    return ((h%2==1) and -u or u) + ((floor(h/2)%2==1) and -2.0*v or 2.0*v);
end
local function PerlinNoise(x,y)
    local ix0, iy0, ix1, iy1;
    local fx0, fy0, fx1, fy1;
    local s, t, nx0, nx1, n0, n1;

    ix0 = floor(x); -- Integer part of x
    iy0 = floor(y); -- Integer part of y
    fx0 = x - ix0;        -- Fractional part of x
    fy0 = y - iy0;        -- Fractional part of y
    fx1 = fx0 - 1.0;
    fy1 = fy0 - 1.0;
    ix1 = (ix0 + 1) % 255;  -- Wrap to 0..255
    iy1 = (iy0 + 1) % 255;
    ix0 = ix0 % 255;
    iy0 = iy0 % 255;
    
	t=(fy0*fy0*fy0*(fy0*(fy0*6-15)+10));
	s=(fx0*fx0*fx0*(fx0*(fx0*6-15)+10));

    nx0 = grad(perm[ix0 + perm[iy0+1]+1], fx0, fy0);
    nx1 = grad(perm[ix0 + perm[iy1+1]+1], fx0, fy1);
    n0 = nx0 + t*(nx1-nx0);

    nx0 = grad(perm[ix1 + perm[iy0+1]+1], fx1, fy0);
    nx1 = grad(perm[ix1 + perm[iy1+1]+1], fx1, fy1);
    n1 = nx0 + t*(nx1-nx0);

    return 0.5*(1 + (0.507 * (n0 + s*(n1-n0))))
end
function PerlinNoiseMap(lambda)
	local key = math.random()*10000
	local map = {}
	for x = 1, GenerateOptions.width do
		map[x] = {}
		for z = 1, GenerateOptions.length do
			map[x][z] = PerlinNoise(x/lambda, z/lambda + key)
		end
	end
	return map
end
-- end perlin noise generation code


function _G.CFrameFromTopBack(at, top, back)
	local right = top:Cross(back)
	return CFrame.new(at.x, at.y, at.z,
	                  right.x, top.x, back.x,
	                  right.y, top.y, back.y,
	                  right.z, top.z, back.z)
end

--"Fill" function
function FillTriangle(a, b, c)
	-- make a-b the longest edge to start
	local ab = (a-b).magnitude
	local ac = (a-c).magnitude
	local bc = (b-c).magnitude
	if ac > ab then
		if ac > bc then
			-- turn ac to the longest
			a, b, c = a, c, b
		else
			-- turn bc to the longest
			a, b, c = b, c, a
		end
	elseif bc > ab then
		if bc > ac then
			-- turn bc to the longest
			a, b, c = b, c, a
		else
			-- turn ac to the longest
			a, b, c = a, c, b
		end
	end

	-- rearrange to make right angle triangels fill right
	local edg1 = (c-a):Dot((b-a).unit)
	local edg2 = (a-b):Dot((c-b).unit)
	local edg3 = (b-c):Dot((a-c).unit)
	if edg1 <= (b-a).magnitude and edg1 >= 0 then
		a, b, c = a, b, c
	elseif edg2 <= (c-b).magnitude and edg2 >= 0 then
		a, b, c = b, c, a
	elseif edg3 <= (a-c).magnitude and edg3 >= 0 then
		a, b, c = c, a, b
	else 
		assert(false, "unreachable")
	end

	--calculate lengths
	local len1 = (c-a):Dot((b-a).unit)
	local len2 = (b-a).magnitude - len1
	local width = (a + (b-a).unit*len1 - c).magnitude
	
	--calculate "base" CFrame to pasition parts by
	local maincf = _G.CFrameFromTopBack(a, (b-a):Cross(c-b).unit, -(b-a).unit)
	
	local w1,w2;
	--make parts
	local mat = 'Slate'
	if len1 > 0.2 then
		w1 = Instance.new('WedgePart', fill)
		w1.BottomSurface = 'Smooth'
		w1.TopSurface = 'Smooth'
		w1.RightSurface = 'Weld'
		w1.LeftSurface = 'Weld'
		w1.FormFactor = 'Custom'
		w1.Material = mat
		w1.Anchored = true
		--
		w1.Size = Vector3.new(0.2, width, len1)
		w1.CFrame = maincf*CFrame.Angles(math.pi,0,math.pi/2)*CFrame.new(0,width/2,len1/2)
	end
	--
	if len2 > 0.2 then
		w2 = Instance.new('WedgePart', fill)
		w2.BottomSurface = 'Smooth'
		w2.TopSurface = 'Smooth'
		w2.RightSurface = 'Weld'
		w2.LeftSurface = 'Weld'
		w2.FormFactor = 'Custom'
		w2.Material = mat
		w2.Anchored = true
		--
		w2.Size = Vector3.new(0.2, width, len2)
		w2.CFrame = maincf*CFrame.Angles(math.pi,math.pi,-math.pi/2)*CFrame.new(0,width/2,-len1 - len2/2)
	end
	--
	if w1 and w2 then
		return w1, w2
	elseif w1 then
		return w1
	elseif w2 then
		return w2
	end
end


--==========================================================================================================--
--                                           Level Generation                                             ==--
--==========================================================================================================--

local INNER_RADIUS = 30
local RADIUS = 200
local RADIAL_STEPS = 9
local RING_STEPSIZE = 14

local ShardList = {}
local BasePartList = {}

local baseCF = CFrame.Angles(0, 0, 0.1)

local KillablePartModel = MainModel:WaitForChild('KillableParts')

function PerlinNoise_Key(key,lambda,x,y)
	return PerlinNoise(x/lambda + key, y/lambda)
end

function GenerateLevel()
	--
	local key = math.random(1,100)
	--
	local function noiselayer(coord, lambda)
		return PerlinNoise_Key(key, lambda, coord.x, coord.z)
	end
	local function noise(coord)
		return noiselayer(coord, 90)*30 + noiselayer(coord, 60)*30 + noiselayer(coord, 30)*10
	end
	local function modify(coord, radius, theta)
		local frac = (radius-INNER_RADIUS)/(RADIUS-INNER_RADIUS)
		frac = ((frac*2 - 1)^2)^0.8
		return coord + Vector3.new(0, -80 + frac*70 + (1-frac)*noise(coord)*2, 0)
	end
	--
	local function RocketDestructible(part)
		local v = Instance.new('BoolValue')
		v.Parent = part
		v.Name = 'RocketDestructible'
		v.Value = true
	end
	--
	local ringWidth = (RADIUS-INNER_RADIUS)/RADIAL_STEPS
	--
	local prevRingThetas = {0}
	local prevRingRadius = 0
	local prevRingOffs = CFrame.new()
	--
	local function wrap(prevRingIndex)
		return 1 + ((prevRingIndex-1)%(#prevRingThetas))
	end
	--
	for rstep = 1, RADIAL_STEPS-1 do
		local ringRadius = (rstep+1) * ringWidth + INNER_RADIUS
		local ringOffs = CFrame.new(0, 0, -ringRadius)
		--
		local ring_stepcount = math.floor(2*math.pi*ringRadius/RING_STEPSIZE)
		local ring_steptheta = 2*math.pi/ring_stepcount
		--
		local function tri(a, b, c)
			local partList = {FillTriangle(a, b, c)}
			for _, p in pairs(partList) do
				p.BrickColor = BrickColor.new('Dark stone grey')
				p.Name = 'LevelPart'
				p.Parent = KillablePartModel
				RocketDestructible(p)
				BasePartList[#BasePartList+1] = p
			end
		end
		--
		local ringThetas = {0}
		--
		local lastMyTheta = 0
		local lastPrevRingIndex = 1
		for radial_i = 1, ring_stepcount do
			local currentMyTheta = radial_i * ring_steptheta
			ringThetas[#ringThetas+1] = currentMyTheta
			--if rstep ~= 1 then
				if currentMyTheta > prevRingThetas[wrap(lastPrevRingIndex+1)] or radial_i == ring_stepcount then
					-- greater than next angle, fill lower tri
					local a = (baseCF * CFrame.Angles(0, lastMyTheta, 0) * ringOffs).p
					local b = (baseCF * CFrame.Angles(0, prevRingThetas[lastPrevRingIndex], 0) * prevRingOffs).p
					local c = (baseCF * CFrame.Angles(0, prevRingThetas[wrap(lastPrevRingIndex+1)], 0) * prevRingOffs).p
					a = modify(a, ringRadius, lastMyTheta)
					b = modify(b, prevRingRadius, prevRingThetas[lastPrevRingIndex])
					c = modify(c, prevRingRadius, prevRingThetas[wrap(lastPrevRingIndex+1)])
					tri(a, b, c)

					-- and the upper tri
					local a = (baseCF * CFrame.Angles(0, lastMyTheta, 0) * ringOffs).p
					local b = (baseCF * CFrame.Angles(0, prevRingThetas[wrap(lastPrevRingIndex+1)], 0) * prevRingOffs).p
					local c = (baseCF * CFrame.Angles(0, currentMyTheta, 0) * ringOffs).p
					a = modify(a, ringRadius, lastMyTheta)
					b = modify(b, prevRingRadius, prevRingThetas[wrap(lastPrevRingIndex+1)])
					c = modify(c, ringRadius, currentMyTheta)
					tri(a, b, c)

					-- and advance the bottom
					lastPrevRingIndex = wrap(lastPrevRingIndex + 1)
				else
					-- not greater than next angle, keep filling upper tris
					local a = (baseCF * CFrame.Angles(0, lastMyTheta, 0) * ringOffs).p
					local b = (baseCF * CFrame.Angles(0, currentMyTheta, 0) * ringOffs).p
					local c = (baseCF * CFrame.Angles(0, prevRingThetas[lastPrevRingIndex], 0) * prevRingOffs).p
					a = modify(a, ringRadius, lastMyTheta)
					b = modify(b, ringRadius, currentMyTheta)
					c = modify(c, prevRingRadius, prevRingThetas[lastPrevRingIndex])
					tri(a, b, c)
				end 
			--end
			--
			if rstep == RADIAL_STEPS-1 then
				local b = (baseCF * CFrame.Angles(0, lastMyTheta, 0) * CFrame.new(0, 0, -ringRadius)).p
				local c = (baseCF * CFrame.Angles(0, currentMyTheta, 0) * CFrame.new(0, 0, -ringRadius)).p
				b = modify(b, ringRadius, lastMyTheta)
				c = modify(c, ringRadius, currentMyTheta)
				local edgePart = Instance.new('Part', MainModel)
				edgePart.Name = 'LevelPart'
				edgePart.Anchored = true
				edgePart.BrickColor = BrickColor.new('Really black')
				edgePart.FormFactor = 'Custom'
				edgePart.TopSurface = 'Inlet'
				edgePart.Size = Vector3.new(3, 2, (b-c).magnitude+0.1)
				edgePart.CFrame = CFrame.new(b, c)*CFrame.new(1.3, 0, -(b-c).magnitude/2)
			-- elseif rstep == 1 then
			-- 	local a = (baseCF * CFrame.Angles(0, lastMyTheta, 0) * CFrame.new(0, 0, -ringRadius)).p
			-- 	local d = (baseCF * CFrame.Angles(0, currentMyTheta, 0) * CFrame.new(0, 0, -ringRadius)).p
			-- 	a = modify(a, ringRadius, lastMyTheta)
			-- 	d = modify(d, ringRadius, currentMyTheta)
			-- 	local edgePart = Instance.new('Part', MainModel)
			-- 	edgePart.Name = 'LevelPart'
			-- 	edgePart.Anchored = true
			-- 	edgePart.BrickColor = BrickColor.new('Really black')
			-- 	edgePart.FormFactor = 'Custom';
			-- 	edgePart.Size = Vector3.new(3, 2, (a-d).magnitude)
			-- 	edgePart.CFrame = CFrame.new(a, d)*CFrame.new(-1.3, 0, -(a-d).magnitude/2)
			end
			--
			lastMyTheta = currentMyTheta
		end
		--
		prevRingOffs = ringOffs
		prevRingRadius = ringRadius
		prevRingThetas = ringThetas
	end

	-- spawns
	local SpawnPoints = MainModel:WaitForChild('SpawnPoints')
	local TeamSpawnPoints = SpawnPoints:WaitForChild('TeamSpawnPoints')
	--
	local SPAWNSIZE = 60
	local SPAWNHEIGHT = 20
	local BEAMWIDTH = 10
	for i = 0, 5 do
		local theta = i*math.pi*2/6 + math.pi/6
		local cf = baseCF * CFrame.Angles(0, theta, 0) * CFrame.new(0, -SPAWNHEIGHT/2-8.5, -RADIUS-SPAWNSIZE/2-1)
		--
		local a = (baseCF * CFrame.Angles(0, theta, 0) * CFrame.new(-SPAWNSIZE/2, -SPAWNHEIGHT/2-8.5, -RADIUS-SPAWNSIZE-1)).p
		local b = (baseCF * CFrame.Angles(0, theta+math.pi/6, 0) * CFrame.new(0, -SPAWNHEIGHT/2-8.5, -RADIUS)).p
		--
		local c = (baseCF * CFrame.Angles(0, theta, 0) * CFrame.new(SPAWNSIZE/2, -SPAWNHEIGHT/2-8.5, -RADIUS-SPAWNSIZE-1)).p
		local d = (baseCF * CFrame.Angles(0, theta-math.pi/6, 0) * CFrame.new(0, -SPAWNHEIGHT/2-8.5, -RADIUS)).p
		--
		local spawn = Instance.new('Part')
		spawn.TopSurface = 'Inlet'
		spawn.BrickColor = BrickColor.new('Really black')
		spawn.Anchored = true
		spawn.FormFactor = 'Custom'
		spawn.Size = Vector3.new(SPAWNSIZE, SPAWNHEIGHT, SPAWNSIZE)
		spawn.CFrame = cf
		spawn.Parent = MainModel
		--
		local actualSpawn = Instance.new('Part')
		actualSpawn.Name = 'Spawn'
		actualSpawn.Anchored = true
		actualSpawn.BrickColor = BrickColor.new('Bright violet')
		actualSpawn.FormFactor = 'Custom'
		actualSpawn.Size = Vector3.new(SPAWNSIZE-2, 0.2, SPAWNSIZE-2)
		actualSpawn.CFrame = spawn.CFrame*CFrame.new(0, SPAWNHEIGHT/2, 0)*CFrame.Angles(0,math.pi,0)
		actualSpawn.Parent = SpawnPoints
		--
		if i == 0 or i == 3 then
			local teamSpawn = actualSpawn:Clone()
			if i == 0 then
				teamSpawn.Name = 'Team1'
				teamSpawn.BrickColor = BrickColor.new(21)
			else
				teamSpawn.Name = 'Team2'
				teamSpawn.BrickColor = BrickColor.new(23)
			end
			teamSpawn.Parent = TeamSpawnPoints
		end
		--
		local beam1 = Instance.new('Part')
		beam1.TopSurface = 'Inlet'
		beam1.BrickColor = BrickColor.new('Really black')
		beam1.Anchored = true
		beam1.FormFactor = 'Custom'
		beam1.Size = Vector3.new(BEAMWIDTH, SPAWNHEIGHT/2, (a-b).magnitude)
		beam1.CFrame = CFrame.new(a, b)*CFrame.new(-BEAMWIDTH/2, SPAWNHEIGHT/5, -(a-b).magnitude/2)
		beam1.Parent = MainModel
		--
		local beam2 = Instance.new('Part')
		beam2.TopSurface = 'Inlet'
		beam2.BrickColor = BrickColor.new('Really black')
		beam2.Anchored = true
		beam2.FormFactor = 'Custom'
		beam2.Size = Vector3.new(BEAMWIDTH, SPAWNHEIGHT/2, (c-d).magnitude)
		beam2.CFrame = CFrame.new(c, d)*CFrame.new(BEAMWIDTH/2, SPAWNHEIGHT/5, -(c-d).magnitude/2)
		beam2.Parent = MainModel
	end

	-- center
	local locii = {{At=CFrame.new(0,0,0), Size=1.8}}
	--
	for i = 0, 5 do
		at = baseCF*CFrame.Angles(0, math.pi*2/6*i, 0)*CFrame.new(0, 0, -RADIUS)
		size = 1.1
		locii[#locii+1] = {At=at, Size=size}
	end
	--
	for _, locusDat in pairs(locii) do
		local locus = locusDat.At
		local size = locusDat.Size
		--
		for i = 1, 27 do
			local part = Instance.new('Part')
			part.Name = 'BlackDecoration'
			part.BrickColor = BrickColor.new('Really black')
			local radialFrac = math.random()
			local invradialFrac = (1-radialFrac)
			local radius = radialFrac*(INNER_RADIUS*3)
			local theta = math.pi*2*math.random()
			--
			part.Size = Vector3.new(6+math.random()*invradialFrac*12,
				                    20 + math.random()*40*size + math.random()*invradialFrac*400*size,
				                    6+math.random()*invradialFrac*12) * size
			part.CFrame = CFrame.new((locus * CFrame.Angles(0,theta,0) * 
			                          CFrame.new(0,0,-radius*size + 20) * 
			                          CFrame.Angles(0, math.random()*2*math.pi, 0)).p)
			part.Anchored = true
			part.Parent = MainModel
			ShardList[#ShardList+1] = part
		end
	end
end

GenerateLevel()

wait()

script.Parent:WaitForChild('LevelReady'):Fire()

-- map falling appart
local initialPartCount = #BasePartList --+ #ShardList

-- wait for the level to be initialized
local RoundTimer = Workspace:WaitForChild('RoundTimer')
RoundTimer:WaitForChild('OutOfTime').Event:wait()

wait(0.1)

local TimeLeftValue = RoundTimer:WaitForChild('Time')
local initialTimeRemaining = TimeLeftValue.Value

local function rand(a,b)
	return a + math.random()*(b-a)
end

-- main game loop
while true do
	wait(math.random(2, 5))
	--
	local fireAt = (baseCF*CFrame.Angles(0, math.random()*math.pi*2, 0)*CFrame.new(0, 0, -rand(30, RADIUS-10))).p
	--
	local crasher = Instance.new('Part')
	crasher.FormFactor = 'Custom'
	crasher.BrickColor = BrickColor.new('Really black')
	crasher.Size = Vector3.new(rand(10,20), rand(40,80), rand(10,20))
	crasher.CFrame = CFrame.new(fireAt + Vector3.new(0, 100, 0))*CFrame.Angles(0, rand(0,math.pi*2), 0)
	crasher.Transparency = 1
	crasher.CanCollide = false
	crasher.Parent = MainModel
	--
	local down = Instance.new('BodyVelocity')
	down.Parent = crasher
	down.maxForce = Vector3.new(0, 10000000, 0)
	down.velocity = Vector3.new(0, -10, 0)
	--
	crasher.Touched:connect(function(part)
		if part:FindFirstChild('RocketDestructible') and not part:FindFirstChild('KillBrick') then
			part.CanCollide = false
			part.Anchored = false
			--
			local float = Instance.new('BodyForce')
			float.force = Vector3.new(0, 196.2*part:GetMass(), 0)
			float.Parent = part
			--
			local rad = part.Position - crasher.Position
			rad = Vector3.new(rad.x, 0, rad.z).unit
			part.Velocity = rad*4 + Vector3.new(rand(-2,2), rand(-2,2), rand(-2,2))
			--
			part.RotVelocity = Vector3.new(rand(-5,5), 0, rand(-5,5))
			--
			local sc = script.Parent:WaitForChild('KillBrick'):Clone()
			sc.Parent = part
			sc.Disabled = false
		end
	end)
	--
	Spawn(function()
		for i = 1, 0, 0.05 do
			wait()
			crasher.Transparency = i
		end
		crasher.Transparency = 0
	end)
end

