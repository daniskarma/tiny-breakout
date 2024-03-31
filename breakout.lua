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
	-- movement keys sometimes not responding when moving pad against wall and while keeping one direction you press the other direction
	-- reset ball radius when loss and restart from pad

-- TODO
	-- performance seems fixed with rewrite (test it more and continue rewrite)
	-- averiguar el orden en el que deben estar las declaraciones
	-- move all physics to one place
	-- check if enemy_lives is efficient or is better to move it ot STAGE table
	-- check if table parts is efficient as a global and creating and destroying values
	-- revise separation betwen draw and update functions and placement
	-- check ipairs usage (performance)
	-- maybe move each object physics (movements and width change) to its own function?
	-- asegurar que establecemos una semilla aleatoria para los random	
	-- normalizar nombres (snake_case, upper, CamelCase...)
	-- add +1 lifep ower up and show lives as ball symbols
	-- add timer to powerups
	-- timeup should end game or take a life?
	-- sustitute drawing button function (looks hideous) for triangle sprite

	--PERFORMANCE: Parece algo mejor pero hay que seguir mejorandola

	--joystick abajo a la derecha para touch control

-- temp
 
math.randomseed(tstamp())

-- input constants

controller={	
	right = {
		type='b',
		pos={
			x=10,
			y=0,
			r=8,
			a=0,
		},
		hold=false,
		holdtime=0,
		pressed=false,
		color=2
	},
	left = {
		type='b',
		pos={
			x=-10,
			y=0,
			r=8,
			a=180,
		},
		hold=false,
		holdtime=0,
		pressed=false,
		color=2
	},
}

BTN={ACTION="ACTION", LEFT="LEFT", RIGHT="RIGHT"}

--particle array
parts={}

-- modes
M={
	BOOT=0,
	TITLE=1,    -- title screen	
	PLAY=2,	
	GAMEOVER=3,
	GAMEWIN=4,	
}

-- Difficulty
DIFF={
	EASY=1,
	MEDIUM=1.25,
	HARD=1.5,
}

-- Player
Player={
	lives=0,
	points=0,
}

-- Stage
DEFAULT_STAGE={
	n=0,		
	time=200*60, --current stage time
	ball={
		maxdx=1.5,
		maxdy=1,
		startdx=1,
		startdy=1,
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
	STAGE.init_time=time()
end

-- ELEMENTS
wall={
	init=function(self,x0,y0)
		self.x0=x0
		self.x1=x0 + 183
		self.y0=y0
		self.y1=y0+127		
		self.w =self.x1-self.x0+1
		self.h =self.y1-self.y0+1		
	end	
}

ball={}
function ball:new(x,y,r,dx,dy,c)
	local newball= {}
	setmetatable(newball, self)
	self.__index=self	
	newball.x =x
	newball.y =y
	newball.r =r
	newball.dx=dx
	newball.dy=dy		
	newball.c =c
	return newball
end
function ball:draw()			
	circ(self.x,self.y,self.r,self.c)			
end		

pad={
	init=function(self,x,y,w,sp,ac,c)
		self.x =x
		self.y =y
		self.w =w --30
		self.h =5
		self.sp=sp
		self.ac=ac --acceleration
		self.dx=0
		self.tw=w --target width			
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
	local to_remove = {}
	for i=#self,1,-1 do
		self[i].y=self[i].y+self[i].dy
		if colCircRect(self[i], pad)>0 then
			if self[i].pw==0 then -- POWER increase pad
				if pad.tw < 46	then 
					pad.tw=pad.tw+8
				end	
			elseif self[i].pw==1 then -- POWER decrease pad
				if pad.tw > 14	then 
					pad.tw=pad.tw-8
				end
			elseif self[i].pw==2 then -- POWER give two balls
				if #balls < 5	then
					for i=1,2 do 
						local newball = ball:new(
							balls[1].x+math.random(),
							balls[1].y+math.random(),
							balls[1].r,
							balls[1].dx*((math.random(0, 1) == 0) and -1 or 1)*math.random(),
							((math.random(0, 1) == 0) and -1 or 1),
							11
						)
						table.insert(balls, newball)
						
					end
				end
			elseif self[i].pw==3 then -- POWER increase ball size
				if balls[1].r < 4	then 
					for _, ball in ipairs(balls) do
						ball.r = ball.r + 1
					end	
				end
			elseif self[i].pw==4 then -- POWER reduce ball size
				if balls[1].r > 1	then 
					for _, ball in ipairs(balls) do
						ball.r = ball.r - 1
					end	
				end		
			elseif self[i].pw==5 then -- POWER reduce ball size
				if Player.lives<6 then
					Player.lives=Player.lives+1
				end
			end
			table.insert(to_remove, i)
		end	
		if self[i].y > 140 then
			table.insert(to_remove, i)
		end
	end
	if next(to_remove) ~= nil then
		for i = #to_remove, 1, -1 do
			table.remove(pws, to_remove[i])
		end
	end
end	

function pws:clear()
	for i=#self, 1, -1 do		
		table.remove(pws, i)			
	end
end	

-- Levels
LVL = {
	{
	n=1,
	title="How did you get here?",
	diff=DIFF.EASY,
	map={
		{5,5,5,5,5,5,5,5,5,5,5,5,5},	
		{5,0,0,0,0,0,0,0,0,0,0,0,5},
		{5,0,0,0,0,0,0,0,0,0,0,0,5},	
		{5,0,0,0,0,0,0,0,0,0,0,0,5},	
		{5,1,1,1,1,1,1,1,1,1,1,1,5},	
		{1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1},	
		{1,1,1,1,1,1,6,1,1,1,1,1,1},
		{0,0,0,0,0,0,1,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},		
	}
	},
	{
	n=2,
	title="You shouldn't be here!",
	diff=DIFF.EASY,
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,6,1,1,1,1,1,1},	
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
	--DEBUG
	--rect(200-2,129-2,30,9,14)
	PrintShadow("FPS: "..FPS:getValue(),200,12,12,nil,1,1)			
	
end


function Boot()
	--poke(0x7FC3F,1,1) -- hide cursor	
	SetMode(M.TITLE)
end

function TitleTic()
	cls()
	print("press Z to start",70,50,4)
	if input(BTN.ACTION) then
		Player.lives=3
		StageInit(1)	
		SetMode(M.PLAY)
 	end	
	rectb(0,0,240,136,12)
	
end

function GameOverTic()
	cls()
	printc("GAME OVER",120,40,4,true)
	printc("press Z to start",120,50,4,true)
	if input(BTN.ACTION) then
		Player.lives=1
		StageInit(1)	
		SetMode(M.PLAY)
 	end	
	rectb(0,0,240,136,12)
end

function GameWinTic()
	cls()
	printc("CONGRATULATIONS!",120,30,4,true)
	printc("YOU WIN THE GAME!",120,40,4,true)
	printc("press Z to start",120,50,4,true)
	if input(BTN.ACTION) then
		Player.lives=1
		StageInit(1)	
		SetMode(M.PLAY)
 	end	
	rectb(0,0,240,136,12)
end


function PlayTic()
	-- function vars
	local is_btnpress=false
	local is_collided=false	
	local is_loaded=false

	is_loaded = STAGE.init_time + 1000 > time()

	-- PADDLE
	if pad.tw < pad.w then 
		pad.w=pad.w-2
		pad.x=pad.x+1	
	end
	if pad.tw > pad.w then 
		pad.w=pad.w+2
		pad.x=pad.x-1			
	end

	-- PADDLE MOVEMENT
	if input(BTN.LEFT) then -- left
		if math.abs(pad.dx) < pad.sp then
		pad.dx=pad.dx-pad.ac
		pad.start_direction=-1
	end
	is_btnpress=true
	end
	if input(BTN.RIGHT) then -- right
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

	-- -- BALL -- --
	for i=#balls, 1, -1 do	

		-- ball launch	
		if not is_launchball and input(BTN.ACTION) and not is_loaded then
			balls[i].dx=STAGE.ball.startdx*pad.start_direction
			balls[i].dy=-STAGE.ball.startdy
			is_launchball=true
		end
		
		-- BALL MOVE
		if balls[i].dx > STAGE.ball.maxdx then -- speed limit
			balls[i].dx=STAGE.ball.maxdx
		elseif balls[i].dx < -STAGE.ball.maxdx then 
			balls[i].dx= -STAGE.ball.maxdx
		end		

		if STAGE.won_time == 30 then -- pauses ball when won
			balls[i].x=balls[i].x+balls[i].dx
			balls[i].y=balls[i].y+balls[i].dy
		end
		
		-- collision ball walls
		if balls[i].x>wall.x1-balls[i].r  then -- right
			balls[i].x = wall.x1-balls[i].r-1
			balls[i].dx=-math.abs(balls[i].dx)
			sfx(0)
		end	
		if balls[i].x<wall.x0+balls[i].r+1 then -- left
			balls[i].x = wall.x0+balls[i].r+1
			balls[i].dx=math.abs(balls[i].dx)
			sfx(0)
		end
		if balls[i].y<wall.y0+balls[i].r then -- up
			balls[i].y = wall.y0+balls[i].r+1
			balls[i].dy=math.abs(balls[i].dy)
			sfx(0)
		end	
		
		-- ball move with pad
		if not is_launchball then
			balls[i].x=pad.x+pad.w/2
			balls[i].y=pad.y-3		
		end	
				
		-- collision brick ball
		for k=1, #bricks do
			if is_collided then break end
			if bricks[k].v then			
				is_collided=colBallBrick(balls[i],bricks[k])				
			end
		end	

		-- collision ball-paddle
		colBallPad(balls[i],pad)
		
		if balls[i].y > 136 then
			table.remove(balls,i)
		end
	end

	-- TIME
	if is_launchball and STAGE.energy_bricks > 0 then
		STAGE.time=STAGE.time-1
	end	

	-- LEVEL WIN	
	if STAGE.energy_bricks == 0 then		
		STAGE.won_time=STAGE.won_time-1
	end
	if STAGE.won_time < 0 then
		if LVL[STAGE.n+1] ~= nil then
			StageInit(STAGE.n+1)
		else
			SetMode(M.GAMEWIN)
		end
	end

	-- GAMEOVER
	if #balls < 1 then
		Player.lives=Player.lives-1
		sfx(1)
		if Player.lives < 0 then SetMode(M.GAMEOVER) end
		PrepareBall()
	end

	if STAGE.time < 0 then
		SetMode(M.GAMEOVER)
	end	
 
 	---- DRAW	
	cls(13) --general background
	rect(wall.x0,wall.y0,wall.w,wall.h,15) -- play background	
	--shadow botton	
	line(wall.x0+1,wall.y1-1,wall.x1-1,wall.y1-1,00)

	for i=wall.x0+1,wall.x1-1 do
		if i%2 == 0 then
			pix(i,wall.y1-3,00)
		else
			pix(i,wall.y1-2,00)
		end
	end

	for i=1, #balls do		
		balls[i]:draw()		
	end
	
	pad:draw()
	if not is_launchball then		
		pad:draw_dir()
	end	
 
	for i=1, #bricks do		
		bricks[i]:draw()		
	end  

	if next(pws) ~= nil then
		for i=1, #pws do
			pws[i]:draw()			
		end
		pws:update()
	end
	
	--Particles
	DrawPart(parts)
	UpdatePart(parts)	

	-- stage load screen
	if is_loaded then			
		rect(wall.x0,wall.y0,wall.w,wall.h,00) -- play background	
		printc("LEVEL: "..STAGE.n, wall.x0+(wall.x1-wall.x0)/2, 50, 12, true)
		printc(LVL[STAGE.n].title, wall.x0+(wall.x1-wall.x0)/2, 60, 12, true)		
	end

	DrawUI()

	-- DEBUG

	--line(wall.x0+(wall.x1-wall.x0)/2, wall.y0, wall.x0+(wall.x1-wall.x0)/2, wall.y1,12)	
	-- rect(ball.x,ball.y,1,1,2)
	--rect(10,8,40,10,12)
	-- print(checkBrickBorder(bricks[195], dir),12,10,2)
	--print(bricks[2].x,12,18,2)
	
end


function gameOver()
	cls()
	print("GAME OVER",90,20,4)
	print("press A to start",70,50,4)
	if input(BTN.ACTION) then
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
	[M.GAMEWIN]=GameWinTic,	
}

function StageInit(level)
	setStage(LVL[level].diff,LVL[level].n)	
	wall:init(4,4)	
	pad:init(50,120,30,4,0.4)
	pws:clear()	

	bricks = {}
	balls = {}	
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
	for i=1,#bricks do		
		if bricks[i].t==6 and bricks[i].v then			
			STAGE.energy_bricks=STAGE.energy_bricks+1				
		end
	end
	
	PrepareBall()
end	

function PrepareBall()
	pws:clear()
	is_launchball=false
	local newball = ball:new(pad.x+pad.w/2,pad.y-3,2,0,0,11)
	table.insert(balls, newball)		
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
		local pwchance = math.random(0,7)
		pwchance=5 -- debug override	
		if pwchance < 6 then
			powerup:new(br.x+br.w/2,br.y+br.h/2,pwchance)
		end
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

---- UI
-- Draw

function DrawUI()		
	--playground bevel
	line(wall.x0,wall.y1,wall.x1,wall.y1,12)
	line(wall.x1,wall.y0,wall.x1,wall.y1,12)
	line(wall.x0,wall.y0,wall.x1,wall.y0,14)
	line(wall.x0,wall.y0,wall.x0,wall.y1,14)
	pix(wall.x0,wall.y0, 15)
	pix(wall.x0,wall.y1, 15)
	pix(wall.x1,wall.y0, 15)
	rect(0,wall.y1+1,240,136, 13) -- botton ui for hiding ball	
	
	-- margins
	local left_margin = wall.x1+4
	local right_margin = 240-4

	--info bevel
	local info_top = 35
	local info_botton = 80

	rect(left_margin,info_top,right_margin-left_margin,info_botton-info_top, 15)
	line(left_margin,info_botton,right_margin,info_botton,12)
	line(right_margin,info_top,right_margin,info_botton,12)
	line(left_margin,info_top,right_margin,info_top,00)
	line(left_margin,info_top,left_margin,info_botton,00)	
	pix(left_margin,info_botton, 15)
	pix(right_margin,info_top, 15)
	
	print("LIVES ",left_margin+3,info_top+3,12)
	for i=0,Player.lives-1 do
		circ(left_margin+3+2+i*7,info_top+12,2,11)
	end
	print("TIME "..string.char(10)..math.floor(STAGE.time/60),left_margin+3,info_top+17,12)
	print("POINTS "..string.char(10)..Player.points,left_margin+3,info_top+31,12)

	--top bevel
	local info_top = 4
	local info_botton = 30

	rect(left_margin,info_top,right_margin-left_margin,info_botton-info_top, 15)
	line(left_margin,info_botton,right_margin,info_botton,12)
	line(right_margin,info_top,right_margin,info_botton,12)
	line(left_margin,info_top,right_margin,info_top,00)
	line(left_margin,info_top,left_margin,info_botton,00)	
	pix(left_margin,info_botton, 15)
	pix(right_margin,info_top, 15)	


	-- TODO move to a proper location---
	mx,my,mp,mm,mr=mouse()
	x=215
	y=120
	if mr then
		x=mx
		y=my
	end
	updatecontroller(controller,x,y)
	drawcontroller(controller,x,y)	
	---------------------------

end

function updatebutton(b,xo,yo)
	mx,my,mp=mouse()
	mx=mx-xo
	my=my-yo
	xdif=mx-b.pos.x
	ydif=my-b.pos.y
	if not joystickinuse and mp and (xdif^2+ydif^2)<b.pos.r^2 then
		b.hold=true
		b.holdtime=b.holdtime+1
	else
		b.hold=false
		b.holdtime=0
	end
	if b.hold and b.holdtime==1 then
		b.pressed=true
	else
		b.pressed=false
	end
end

function drawbutton(b,xo,yo)
	if b.hold then
		tric(b.pos.x+xo,b.pos.y+1+yo,b.pos.r,b.color, b.pos.a)
	else
		tric(b.pos.x+xo,b.pos.y+1+yo,b.pos.r,15, b.pos.a)
		tric(b.pos.x+xo,b.pos.y+yo,b.pos.r,b.color, b.pos.a)
	end	
end

function updatecontroller(con,xo,yo)
	for k,v in pairs(con) do		
		updatebutton(v,xo,yo)		
	end
end

function drawcontroller(con,xo,yo)	
	for k,v in pairs(controller) do
		drawbutton(v,xo,yo)
	end
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
		for i=1, #parts do
			pix(parts[i].x, parts[i].y, parts[i].c)
			parts[i].x=parts[i].x+parts[i].dx
			parts[i].y=parts[i].y+parts[i].dy
			parts[i].dy=parts[i].dy+parts[i].g			
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
		AddPart(x+math.random()*20,y+math.random()*4,1+1.5*math.random(-1,1),-1.5*math.random(-1,1),0.1,12,15+math.random()*3)
	end
end

-- INPUT

function input(option)
	if option == BTN.ACTION then
		local mx,my,mp=mouse()
		local is_mouse = false
		if mp then
			if wall.x0 ~= nil then
				if mx > wall.x0 and mx < wall.x1 and my > wall.y0 and my < wall.y1 then
					is_mouse = true
				end
			else
				is_mouse = true
			end
		end
		return btn(4) or peek(0xFF88)==48 or is_mouse
	elseif option == BTN.RIGHT then
		return peek(0xFF80)==8 or controller.right.hold
	elseif option == BTN.LEFT then
		return peek(0xFF80)==4 or controller.left.hold
	else
		return false
	end
	return false
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

-- TODO - No tiene en cuenta distintos anchos por caracter
-- Para centrar correctamente una fuente tiene que tener fixed=true
function printc(...)
	local firstArg = select(1, ...)
    local secondArg = select(2, ...)
    local new_x = secondArg - (#firstArg / 2)*6
    local args = {select(3, ...)}
    table.insert(args, 1, new_x)
    table.insert(args, 1, firstArg)
    print(table.unpack(args))
end


-- FPS show
function PrintShadow(message,x,y,color,gap,size,smallmode)
	print(message,x,y,0,gap,size,smallmode)
	print(message,x,y-1,color,gap,size,smallmode)
end

-- TODO finish
function tric(x,y,r,c,a)
	local a1 = math.rad(a)
	local a2 = math.rad(a+360/3)
	local a3 = math.rad(a+2*360/3)
	local x1 = x + math.cos(a1) * r
	local x2 = x + math.cos(a2) * r
	local x3 = x + math.cos(a3) * r
	local y1 = y + math.sin(a1) * r
	local y2 = y + math.sin(a2) * r
	local y3 = y + math.sin(a3) * r
	
	tri(x1,y1,x2,y2,x3,y3,c)
end





-- <TILES>
-- 001:0022dccc0222dccc0222dccc0822dccc0088eccc000000000000000000000000
-- 002:cccd2200cccd2220cccd2220cccd2280ccce8800000000000000000000000000
-- 003:fddddddafdeeeeabfdeeeabcfdeeeeabfe00000affffffffffffffffffffffff
-- 004:adddddefbaeeee0fcbaeee0fbaeeee0fa000000fffffffffffffffffffffffff
-- 005:0000dccd0000dccd0000dccd0000dccd0000dccd0000dccd0000dccd0000dccd
-- 016:0055500005666600566666706ccccc7066666670066667000077700000000000
-- 017:00333000032222003222228022ccc28022222280022228000088800000000000
-- 018:0055500005666600566c66706666667066c6c670066667000077700000000000
-- 019:0055500005ccc6005ccccc706ccccc706ccccc7006ccc7000077700000000000
-- 020:003330000322220032222280222c228022222280022228000088800000000000
-- 021:0055500005666600566c667066ccc670666c6670066667000077700000000000
-- 032:00000000000000000c0000c00000000000000000000000000cccccc000000000
-- 033:00000000000000000cc00cc00cf00cf000000000000000000cccccc000000000
-- 034:00000000000000000c0000c000000000000000000c0000c000cccc0000000000
-- 035:00000000000000000c0000c000000000000cc00000c00c0000c00c00000cc000
-- 036:00000000000000000c0000c00000000000000000000cc00000c00c00000cc000
-- 037:00000000000000000c0000c000000000000000000000000000cccc0000000000
-- 038:0c0000c000c00c00000cc0000c0000c0000000000000000000cccc000c0000c0
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
-- 002:f0f0e0e0c0d0b0b0a0a0808070706050404030202010100000000000000010001000201040205020603080309040a060b070c070d090e0b0e0c0f0e0310000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

