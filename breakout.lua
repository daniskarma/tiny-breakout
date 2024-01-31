--ARKANOID
-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

-- BUGLIST
	-- ball overlap a little in the bricks

-- TODO
	-- performance seems fixed with rewrite (test it more and continue rewrite)
	-- averiguar el orden en el que deben estar las declaraciones
	-- move all physics to one place
	-- check if enemy_lives is efficient or is better to move it ot STAGE table
	-- check if table parts is efficient as a global and creating and destroying values
	-- revise separation betwen draw and update functions and placement
	-- check ipairs usage (performance)
		
local testlayout={
	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0}	
}

-- temp
parts={}
rnd=math.random

-- modes
M={
	BOOT=0,
	TITLE=1,    -- title screen	
	PLAY=2,	
	GAMEOVER=3,	
}

-- Difficulty
DIFF={
	EASY=1,
	MEDIUM=1.25,
	HARD=1.5,
}

-- Player
Player={
	lives=3,
	points=0,
}


-- Stage
DEFAULT_STAGE={
	n=0,		
	time=200*60, --current stage time
	ball={
		maxdx=2,
		maxdy=1.5,
		startdx=1.4,
		startdy=1.4,
	},
	won_time=60,
	energy_bricks=0,
}
STAGE={}
function setStage(diff, level)
	STAGE=DeepCopy(DEFAULT_STAGE)
	STAGE.time=STAGE.time-600*diff
	STAGE.ball.maxdx=STAGE.ball.maxdx*diff
	STAGE.ball.maxdy=STAGE.ball.maxdy*diff
	STAGE.ball.startdx=STAGE.ball.startdx*diff
	STAGE.ball.startdy=STAGE.ball.startdy*diff
	STAGE.n=level
	STAGE.won_time=30
end

-- ELEMENTS

wall={
	init=function(self,x0,x1,y0,y1)
		self.x0=x0
		self.x1=x1
		self.y0=y0
		self.y1=y1		
		self.w =self.x1-self.x0+1
		self.h =self.y1-self.y0+1
	end	
}

ball={
	init=function(self,x,y,r,dx,dy,c)
		self.x =x
		self.y =y
		self.r =r
		self.dx=dx
		self.dy=dy		
		self.c =c
	end,
	draw=function(self)			
		circ(self.x,self.y,self.r,self.c)			
	end	
}	

pad={
	init=function(self,x,y,w,sp,ac,c)
		self.x =x
		self.y =y
		self.w =w
		self.h =5
		self.sp=sp
		self.ac=ac
		self.dx=0			
	end,
	start_direction=1,	
	draw=function(self)
		spr(1, self.x-1, self.y, 0, 1, 0)
		spr(1, self.x+self.w-7, self.y, 0, 1, 1)
		rect(self.x+7,self.y,self.w-14,self.h,12)
		line(self.x+4,self.y+self.h-1,self.x+self.w-5,self.y+self.h-1,11)		
	end,
	draw_dir=function(self, a)
		local delay1 = (time()/100)%8
		local delay2 = ((time()+400)/100)%8		
		pix(self.x+(self.w/2)+(4*self.start_direction)+(delay1*self.start_direction),self.y-7-delay1,12)
		pix(self.x+(self.w/2)+(4*self.start_direction)+(delay2*self.start_direction),self.y-7-delay2,12)					
	end
}

brick_c={{7,6,5},{8,9,10},{2,3,4},{1,2,3},{14,13,12}} --brick colors
brick={}	
function brick:new(x,y,t,id)
	local newbrick = {}
	setmetatable(newbrick, self)
	self.__index=self
	newbrick.x=x
	newbrick.y=y
	newbrick.w=14
	newbrick.h=5
	newbrick.c=brick_c[t]		
	newbrick.t=t
	newbrick.gw=1
	if newbrick.t > 0 then
		newbrick.v=true
	else
		newbrick.v=false
	end

	newbrick.id=id
	return newbrick		
end
function brick:draw()
	if self.v then
		if self.t < 6 then			
			rect(self.x,self.y,self.w,self.h,self.c[3])
			rect(self.x+1,self.y+1,self.w-2,self.h-2,self.c[2])
			line(self.x+1,self.y+self.h-1,self.x+self.w-1,self.y+self.h-1,self.c[1])
			line(self.x+self.w-1,self.y+1,self.x+self.w-1,self.y+self.h-1,self.c[1])
			rect(self.x+self.w-1,self.y,1,1,self.c[2])
			rect(self.x,self.y+self.h-1,1,1,self.c[2])	
		elseif self.t == 6 then
			spr(3, self.x-1, self.y, 15)
			spr(4, self.x+7, self.y, 15)		
		end	
		
	end
	if self.gw>0 then
		rect(self.x,self.y,self.w,self.h,12)			
		self.gw=self.gw-1
	end
end

-- POWERUPS
pws={} --powerups array
powerup={}
function powerup:new(x,y,pw)
	local newpowerup = {}
	setmetatable(newpowerup, self)
	self.__index=self	
	newpowerup.x =x
	newpowerup.y =y
	newpowerup.r =3		
	newpowerup.dy=0.5
	newpowerup.dx=0	
	newpowerup.pw=pw
	table.insert(pws,newpowerup)
end
	
function powerup:draw()	
	spr(16+self.pw,self.x-self.r,self.y-self.r,0)			
end	

function pws:update()
	for _,powerup in ipairs(self) do
		powerup.y=powerup.y+powerup.dy
		if colCircRect(powerup, pad)>0 then
			table.remove(pws, _)
		end		
	end
end	


-- Levels
LVL = {
	{
	n=1,
	title="How did you get here?",
	diff=DIFF.EASY,
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,6},	
		{5,1,1,1,1,1,1,1,1,1,1,1,1},
		{5,0,0,0,0,0,0,0,0,0,0,0,0},	
		{5,0,0,0,0,0,6,0,0,0,0,0,0},	
		{5,0,0,0,0,0,0,0,0,0,0,0,0},
		{5,0,0,0,2,2,2,2,2,2,2,0,0},
		{5,0,6,0,0,0,6,0,0,0,0,0,0},	
		{5,0,0,0,0,0,0,0,0,0,6,0,0},
		{5,0,0,0,0,0,0,0,3,3,3,5,5},	
		{5,0,0,0,0,0,0,0,0,0,0,0,5},	
		{5,0,0,0,0,0,0,0,0,0,6,0,5},
		{5,0,0,0,0,0,0,0,0,0,0,0,5},
		{5,1,0,0,0,0,0,0,0,0,0,0,5},	
		{5,1,1,1,1,1,1,1,1,1,1,1,5},
		{5,0,0,0,0,0,0,0,0,0,0,0,5}		
	}
	},
	{
	n=2,
	title="Get out of my body!",
	diff=DIFF.EASY,
	map={
		{0,0,0,6,0,0,0,0,0,6,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1},	
		{1,1,1,1,1,1,1,1,1,1,1,1,1},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0}		
		}
	},
}

-- game state
Game={
	-- mode
	m=M.BOOT,	
}

function SetMode(m)
	Game.m=m
end

local FPS={value=0,frames=0,lastTime=-1000} -- cuidado al moverlo

function FPS:getValue()
  if (time()-self.lastTime <= 1000) then
    self.frames=self.frames+1
  else 
    self.value=self.frames
    self.frames=0
    self.lastTime=time()
  end
  return self.value
end

function TIC()
	TICF[Game.m]()
	PrintShadow("FPS: "..FPS:getValue(),3,129,12,nil,1,1)	
end


function Boot()
	-- poke(0x7FC3F,1,1) -- hide cursor	
	SetMode(M.TITLE)
end

function TitleTic()
	cls()
	Player.lives=3

	print("press Z to start",70,50,4)
	if btn(4) then
		StageInit(1)	
		SetMode(M.PLAY)
 	end
	
	rectb(0,0,240,136,12)
end


function PlayTic()
	-- function vars
	local is_btnpress=false
	local is_collided=false	
		
	-- ball launch	
	if not is_launchball and btnp(4) then
		ball.dx=STAGE.ball.startdx*pad.start_direction
		ball.dy=-STAGE.ball.startdy
		is_launchball=true
	end
	
	-- BALL MOVE
	if ball.dx > STAGE.ball.maxdx then -- speed limit
		ball.dx=STAGE.ball.maxdx
	elseif ball.dx < -STAGE.ball.maxdx then 
		ball.dx= -STAGE.ball.maxdx
	end		

	if STAGE.won_time == 30 then -- pauses ball when won
		ball.x=ball.x+ball.dx
		ball.y=ball.y+ball.dy
	end
	
	-- collision ball walls
	if ball.x>wall.x1-ball.r  then -- right
		ball.x = wall.x1-ball.r-1
		ball.dx=-math.abs(ball.dx)
		sfx(0)
	end	
	if ball.x<wall.x0+ball.r+1 then -- left
		ball.x = wall.x0+ball.r+1
		ball.dx=math.abs(ball.dx)
		sfx(0)
	end
	if ball.y<wall.y0+ball.r then -- up
		ball.y = wall.y0+ball.r+1
		ball.dy=math.abs(ball.dy)
		sfx(0)
	end	
		
	-- PADDLE MOVE
	if btn(2) then -- left
		if math.abs(pad.dx) < pad.sp then
		pad.dx=pad.dx-pad.ac
		pad.start_direction=-1
	end
	is_btnpress=true
	end
	if btn(3) then -- right
		if math.abs(pad.dx) < pad.sp then
		pad.dx=pad.dx+pad.ac
		pad.start_direction=1
	end
	is_btnpress=true
	end
	if not is_btnpress then -- friction
		pad.dx=pad.dx/1.5
	end
	if math.abs(pad.dx)<0.01 then
		pad.dx=0
	end -- kill speed
	pad.x=pad.x+pad.dx --move paddle
	pad.x=math.floor(pad.x+0.5)--smooth movement
		
	-- collision paddle walls
	if pad.x<wall.x0+1 then
		pad.x=wall.x0+1
	end
	if pad.x+pad.w >wall.x1 then
		pad.x=wall.x1-pad.w 
	end

	-- ball move with pad
	if not is_launchball then
		ball.x=pad.x+pad.w/2
		ball.y=pad.y-3		
	end	
			 
	-- collision brick ball
	for i, br in ipairs(bricks) do
		if is_collided then break end
		if br.v then			
			is_collided=colBallBrick(ball,br)				
		end
	end	

	-- collision ball-paddle
	colBallPad(ball,pad)	

	-- TIME
	if is_launchball and STAGE.energy_bricks > 0 then
		STAGE.time=STAGE.time-1
	end	

	-- LEVEL WIN	
	if STAGE.energy_bricks == 0 then		
		STAGE.won_time=STAGE.won_time-1
	end
	if STAGE.won_time < 0 then
		StageInit(STAGE.n+1)
	end
	-- GAMEOVER
	if ball.y > 136 then
		Player.lives=Player.lives-1
		sfx(1)
		if Player.lives < 0 then SetMode(M.TITLE) end
		PrepareBall()
	end

	if STAGE.time < 0 then
		SetMode(M.TITLE)
	end

	
 
 	---- DRAW
	cls(15)			
	rectb(wall.x0,wall.y0,wall.w,wall.h,12) -- walls	

	ball:draw()
	pad:draw()
	if not is_launchball then		
		pad:draw_dir()
	end	
 
	for i, br in ipairs(bricks) do		
		br:draw()		
	end  

	if next(pws) ~= nil then
		for _,pwup in ipairs(pws) do
			pwup:draw()			
		end
		pws:update()
	end
	
	--UpdatePart(part)
	DrawPart(parts)
	UpdatePart(parts)
 
	-- UI
	print("LIVES: "..Player.lives,wall.x0,1,12)
	print("TIME: "..math.floor(STAGE.time/60),wall.x0+50,1,12)
	print("POINTS: "..Player.points,wall.x0+110,1,12)

	-- debug
	-- rect(ball.x,ball.y,1,1,2)
	--rect(10,8,40,10,12)
	-- print(checkBrickBorder(bricks[195], dir),12,10,2)
	--print(bricks[2].x,12,18,2)
end


function gameOver()
	cls()
	print("GAME OVER",90,20,4)
	print("press A to start",70,50,4)
	if btn(4) then
		gameBOOT()
	 	SetMode(M.PLAY)
	end
	
	rectb(0,0,240,136,12)
end


TICF={
	[M.BOOT]=Boot,
	[M.TITLE]=TitleTic,	
	[M.PLAY]=PlayTic,	
	[M.GAMEOVER]=GameOverTic,	
}

function StageInit(level)
	setStage(LVL[level].diff,LVL[level].n)	
	wall:init(29,212,8,136)	
	pad:init(58,125,30,4,0.4)	

	bricks = {}	
	for i=1,15 do
		for j = 1,13 do			
			local newbrick=brick:new(
				wall.x0+1+j*14-14,
				wall.y0+1+i*5-5,
				LVL[level].map[i][j],
				{i,j})
			table.insert(bricks,newbrick)			
		end
	end	
	
	-- stablish STAGE energy bricks
	for i, br in ipairs(bricks) do		
		if br.t==6 and br.v then			
			STAGE.energy_bricks=STAGE.energy_bricks+1				
		end
	end
	
	PrepareBall()
end	

function PrepareBall()
	is_launchball=false
	ball:init(pad.x+pad.w/2,pad.y-3,2,0,0,11)	
end


---- PHYSICS
function colCircRect(ball, box)
	local box_cx=box.x+((box.w-1)/2)
	local box_cy=box.y+((box.h-1)/2)
	
	local dist_x=box_cx-ball.x
	local dist_y=box_cy-ball.y
	
	local maxdist_x = box.w/2
	local maxdist_y = box.h/2

	if math.abs(dist_x) > maxdist_x+(ball.r) or math.abs(dist_y) > maxdist_y+ball.r then return 0 end -- no col
	if ball.dx == 0 and ball.dy > 0 then return 3 end -- col up
	if ball.dx == 0 and ball.dy < 0 then return 4 end -- col down

	if ball.dx > 0 and ball.dy > 0 then -- up left
		if ball.x-ball.dx >= box.x then return 3 end -- col up
		if ball.y-ball.dy >= box.y then return 1 end -- col left
		local p1 = ball.dx/ball.dy
		local p2 = (box.x-ball.x-ball.dx)/(box.y-ball.y-ball.dy)
		if p1 >= p2 then return 3 -- col up
		else return 1 -- col left
		end
	end
	if ball.dx > 0 and ball.dy < 0 then -- down left
		if ball.x-ball.dx >= box.x then return 4 end -- col down
		if ball.y-ball.dy <= box.y+box.h then return 1 end -- col left
		local p1 = ball.dx/ball.dy
		local p2 = (box.x-ball.x-ball.dx)/(box.y+box.h-ball.y-ball.dy)
		if p1 >= p2 then return 4 -- col down
		else return 1  -- col left
		end
	end
	if ball.dx < 0 and ball.dy < 0 then -- down right
		if ball.x-ball.dx <= box.x+box.w then return 4 end -- col down
		if ball.y-ball.dy <= box.y+box.h then return 2 end -- col right
		local p1 = ball.dx/ball.dy
		local p2 = (ball.x-ball.dx-box.x+box.w)/(ball.y-ball.dy-box.y+box.h)
		if p1 >= p2 then return 4 -- col down
		else return 2 -- col right
		end
	end

	if ball.dx < 0 and ball.dy > 0 then -- up right
		if ball.x-ball.dx <= box.x+box.w then return 3 end -- col up
		if ball.y-ball.dy >= box.y then return 2 end -- col right
		local p1 = ball.dx/ball.dy
		local p2 = (ball.x-ball.dx-box.x+box.w)/(ball.y-ball.dy-box.y)
		if p1 >= p2 then return 3 -- col up
		else return 2  -- col right
		end
	end

	return 0
end

-- returns true if theres a block in the place of the suppose collision
function checkBrickBorder(br, dir)
	col = br.id[2]
	row = br.id[1]
	n = (row - 1) * 13 + col -- bricks[n]

	-- dir: 1 left, 2 right, 3 up, 4 down
	if dir == 1 then
		if col == 1 then return true end
		if bricks[n-1].v == true then return true end

	elseif dir == 2 then
		if col == 13 then return true end
		if bricks[n+1].v == true then return true end

	elseif dir == 3 then
		if row == 1 then return true end
		if bricks[n-13].v == true then return true end

	elseif dir == 4 then
		if row == 15 then return false end
		if bricks[n+13].v == true then return true end
	end

	return false
end

function colBallBrick(ball, br)	
	local col = colCircRect(ball, br)
	if col == 0 then return false end		
	if col == 1 then -- left
		if checkBrickBorder(br, 1) then return false end
		ball.x = br.x-ball.r
		ball.dx = -math.abs(ball.dx)
	elseif col == 2 then -- right
		if checkBrickBorder(br, 2) then return false end	
		ball.x = br.x+br.w+ball.r
		ball.dx = math.abs(ball.dx)
	elseif col == 3 then -- up
		if checkBrickBorder(br, 3) then return false end
		ball.y = br.y-ball.r		
		ball.dy = -math.abs(ball.dy)		
	elseif col == 4 then -- down
		if checkBrickBorder(br, 4) then return false end	
		ball.y = br.y+br.h+ball.r
		ball.dy = math.abs(ball.dy)
	end
		

	sfx(0,"D-7")
	Player.points = Player.points + 1	
	if br.t > 1  and br.t < 5 then 
		br.t = br.t - 1
		br.c = brick_c[br.t]		
	elseif br.t==1 then
		br.v=false
		powerup:new(br.x+br.w/2,br.y+br.h/2,0)
	elseif br.t==6 then
		br.v=false
		Player.points=Player.points + 4
		STAGE.energy_bricks=STAGE.energy_bricks-1
		Explode(br.x,br.y)
		br.gw=6		
	end
	return true
end

function colBallPad(ball, pad)
	local col = colCircRect(ball, pad)	
	if col == 0 or col == 4 then return end
	local pad_cx=pad.x+(pad.w/2)
	local pad_cy=pad.y+(pad.h/2)
	local dist_x=(pad_cx-ball.x)/(pad.w/2)
	ball.dx=ball.dx-dist_x

	if ball.y <= pad_cy then		
		ball.y = pad.y-ball.r
		ball.dy=-math.abs(ball.dy)
	else
		ball.y = pad.y+pad.h+ball.r
		ball.dy=math.abs(ball.dy)
	end

	sfx(0,"D-5")	
end

---- EFFECTS
-- particles


function AddPart(_x,_y,_dx,_dy,_g,_c,_maxage)
	local _p={}
	_p.x=_x
	_p.y=_y
	_p.dx=_dx
	_p.dy=_dy
	_p.g=_g
	_p.c=_c
	_p.maxage=_maxage
	_p.age=0
	table.insert(parts,_p)
end


function DrawPart(parts)
	if next(parts) ~= nil then
		for _,p in pairs(parts) do
			pix(p.x, p.y, p.c)
			p.x=p.x+p.dx
			p.y=p.y+p.dy
			p.dy=p.dy+p.g			
		end
	end
end

function UpdatePart(parts)
	if next(parts) ~= nil then
		for _,p in pairs(parts) do
			p.age=p.age+1
			if p.age>p.maxage then				
				table.remove(parts, _)
			end
		end
	end
end

-- particle explosion

function Explode(x, y)
	for i=1,20 do
		AddPart(x+rnd()*20,y+rnd()*4,1+1.5*rnd(-1,1),-1.5*rnd(-1,1),0.1,12,15+rnd()*3)
	end
end

-- util

function DeepCopy(t)
	if type(t)~="table" then return t end
	local _r={}
	for k,v in pairs(t) do
	 if type(v)=="table" then
	  _r[k]=DeepCopy(v)
	 else
	  _r[k]=v
	 end
	end
	return _r
   end



-- FPS show

function PrintShadow(message,x,y,color,gap,size,smallmode)
 print(message,x,y,0,gap,size,smallmode)
 print(message,x,y-1,color,gap,size,smallmode)
end





-- <TILES>
-- 001:0022dccc0222dccc0222dccc0822dccc0088eccc000000000000000000000000
-- 002:cccd2200cccd2220cccd2220cccd2280ccce8800000000000000000000000000
-- 003:fddddddafdeeeeabfdeeeabcfdeeeeabfe00000affffffffffffffffffffffff
-- 004:adddddefbaeeee0fcbaeee0fbaeeee0fa000000fffffffffffffffffffffffff
-- 016:0055500005666600566666706ccccc7066666670066667000077700000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:0123456789aaaaaaaaaaaa9876543210
-- 004:000111122334556789aabccdeeeeffff
-- 005:00000000000000000fffff0000000000
-- </WAVES>

-- <SFX>
-- 000:4100510171019102a103c103d105e107f107f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f10041000010f000
-- 001:3504440055037500750195009501c501c501e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500360000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

