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
	-- look if I shall move objects deffinitions elsewhere
		
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
	}
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
end

-- Levels
LVL = {
	{
	n=1,
	diff=DIFF.EASY,
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{5,1,1,1,1,1,1,1,1,1,1,1,1},
		{5,0,0,0,0,0,0,0,0,0,0,0,0},	
		{5,0,0,0,0,0,0,0,0,0,0,0,0},	
		{5,0,0,0,0,0,0,0,0,0,0,0,0},
		{5,0,0,0,2,2,2,2,2,2,2,0,0},
		{5,0,0,0,0,0,6,0,0,0,0,0,0},	
		{5,0,0,0,0,0,0,0,0,0,0,0,0},
		{5,0,0,0,0,0,0,0,3,3,3,5,5},	
		{5,0,0,0,0,0,0,0,0,0,0,0,5},	
		{5,0,0,0,0,0,0,0,0,0,0,0,5},
		{5,0,0,0,0,0,0,0,0,0,0,0,5},
		{5,0,0,0,0,0,0,0,0,0,0,0,5},	
		{5,0,0,0,0,0,0,0,0,0,0,0,5},
		{5,0,0,0,0,0,0,0,0,0,0,0,5}		
	}
	},
	{
	n=2,
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
	print("press Z to start",70,50,4)
	if btn(4) then
		StageInit(1)	
		SetMode(M.PLAY)
 	end
	
	rectb(0,0,240,136,12)
end


function PlayTic()
	-- function vars
	is_btnpress=false
	is_collided=false

	cls(15)	
		
	-- ball launch	
	if not is_launchball and btnp(4) then
		ball.dx=STAGE.ball.startdx
		ball.dy=-STAGE.ball.startdy
		is_launchball=true
	end
	
	-- BALL MOVE
	if ball.dx > STAGE.ball.maxdx then -- speed limit
		ball.dx=STAGE.ball.maxdx
	elseif ball.dx < -STAGE.ball.maxdx then 
		ball.dx= -STAGE.ball.maxdx
	end		

	ball.x=ball.x+ball.dx
	ball.y=ball.y+ball.dy
	
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
	end
	is_btnpress=true
	end
	if btn(3) then -- right
		if math.abs(pad.dx) < pad.sp then
		pad.dx=pad.dx+pad.ac
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
			colBallBrick(ball,br)						
		end
	end	

	-- collision ball-paddle
	colBallPad(ball,pad)	

	-- TIME
	if is_launchball then
		STAGE.time=STAGE.time-1
	end	

	-- LEVEL WIN
	local enemy_lives = 0
	for i, br in ipairs(bricks) do		
		if br.t==6 and br.v then			
			enemy_lives=enemy_lives+1				
		end
	end
	if enemy_lives == 0 then		
		StageInit(STAGE.n+1)
	end

	-- GAMEOVER
	if ball.y > 136 then
		Player.lives=Player.lives-1
		sfx(1)
		if Player.lives < 0 then SetMode(M.TITLE) end
		GameGo()
	end

	if STAGE.time < 0 then
		SetMode(M.TITLE)
	end
 
 	-- DRAW		
	rectb(wall.x0,wall.y0,wall.w,wall.h,12) -- walls	

	ball:draw()
	pad:draw()	
 
	for i, br in ipairs(bricks) do
		if bricks[i].v then
			br:draw()
		end
	end  
 
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
	wall:init(29,212,8,136)

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
		draw=function(self)
			spr(1, self.x-1, self.y, 0, 1, 0)
			spr(1, self.x+self.w-7, self.y, 0, 1, 1)
			rect(self.x+7,self.y,self.w-14,self.h,12)
			line(self.x+4,self.y+self.h-1,self.x+self.w-5,self.y+self.h-1,11)						
		end	
	}
	pad:init(58,125,30,4,0.4)	
	
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
	end

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
	
	
	GameGo()
end

function GameGo()
	is_launchball=false
	ball:init(pad.x+pad.w/2,pad.y-3,2,0,0,11)	
end



-- PHYSICS

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
	if is_collided then return end
	local col = colCircRect(ball, br)
	if col == 0 then return end		
	if col == 1 then -- left
		if checkBrickBorder(br, 1) then return 0 end
		ball.x = br.x-ball.r
		ball.dx = -math.abs(ball.dx)
	elseif col == 2 then -- right
		if checkBrickBorder(br, 2) then return 0 end	
		ball.x = br.x+br.w+ball.r
		ball.dx = math.abs(ball.dx)
	elseif col == 3 then -- up
		if checkBrickBorder(br, 3) then return 0 end
		ball.y = br.y-ball.r		
		ball.dy = -math.abs(ball.dy)		
	elseif col == 4 then -- down
		if checkBrickBorder(br, 4) then return 0 end	
		ball.y = br.y+br.h+ball.r
		ball.dy = math.abs(ball.dy)

	end
	is_collided=true	

	sfx(0,"D-7")
	Player.points = Player.points + 1	
	if br.t > 1  and br.t < 5 then 
		br.t = br.t - 1
		br.c = brick_c[br.t]		
	elseif br.t==1 then
		br.v=false
	elseif br.t==6 then
		br.v=false
		Player.points = Player.points + 4
	end
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

-- util
function DeepCopy(t)
	if type(t)~="table" then return t end
	local r={}
	for k,v in pairs(t) do
	 if type(v)=="table" then
	  r[k]=DeepCopy(v)
	 else
	  r[k]=v
	 end
	end
	return r
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
-- 017:00000000000cc00000cccc000ccccdc00cccddc000cddc00000cc00000000000
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

