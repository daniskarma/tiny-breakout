--ARKANOID
-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

-- TODO:
	-- FIX BALL BRICK COLLISIONS
  	-- paddle sprite	
		

function BOOT()
	-- poke(0x7FC3F,1,1) -- hide cursor
	cls()
	gameBOOT()
	mode=2
end

function gameBOOT()
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
	
	brick_c={{7,6,5},{8,9,10},{2,3,4},{1,2,3},{14,13,12}}
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
		newbrick.v=true
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
			end		
		end
	end
	
	layout1={
		{0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0},		
		{0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0},		
		{0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0},		
		{0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0},		
		{0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0}		
	}

	layout={
		{2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,3,4,4,4,3,2,2,2,2},
		{1,2,1,2,0,0,0,0,0,0,2,1,2},
		{2,3,3,3,0,0,0,0,0,0,3,3,1},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,1},
		{0,0,0,0,0,0,0,0,0,0,0,0,5},
		{0,0,0,0,0,5,5,5,0,0,0,0,5},
		{0,0,0,0,0,5,0,5,0,0,0,0,5},
		{0,0,0,0,0,5,5,5,0,0,0,0,5},
		{0,0,0,0,0,0,0,0,0,0,0,0,5},
		{0,0,0,0,0,0,0,0,0,0,0,0,5},	
		{0,0,0,0,0,0,0,0,0,0,0,0,5},
		{0,0,0,0,0,0,0,0,0,0,0,0,5}	
	}

	bricks = {}	
	for i=1,13 do
		for j = 1,15 do
			if layout[j][i] > 0 then
				local newbrick=brick:new(
					wall.x0+1+i*14-14,
					wall.y0+1+j*5-5,
					layout[j][i],
					{i,j})
				table.insert(bricks,newbrick)
			end
		end
	end

	lives=3
	points=0
	timeleft=360*60

	ball_maxdx = 3
	ball_maxdy = 2	
	ball_startdx = 1.4
	ball_startdy = 1.4
	
	gameGo()
end

function gameGo()
	is_launchball=false
	ball:init(pad.x+pad.w/2,pad.y-3,2,0,0,11)	
end

function game()
	-- function vars
	is_btnpress=false
	is_collided=false

	cls(15)	
		
	-- ball launch	
	if not is_launchball and btnp(4) then
		ball.dx=ball_startdx
		ball.dy=-ball_startdy
		is_launchball=true
	end
	
	-- BALL MOVE
	if ball.dx > ball_maxdx then -- speed limit
		ball.dx= ball_maxdx
	elseif ball.dx < -ball_maxdx then 
		ball.dx= -ball_maxdx
	end		

	ball.x=ball.x+ball.dx
	ball.y=ball.y+ball.dy
	
	-- collision ball walls
	if ball.x>wall.x1-ball.r  then -- right
		ball.x = wall.x1-ball.r-1
		ball.dx=-math.abs(ball.dx)
		sfx(0)
	end	
	if ball.x<wall.x0+ball.r then -- left
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

	-- ball move with pad
	if not is_launchball then
		ball.x=pad.x+pad.w/2
		ball.y=pad.y-3
	end	
		
	-- collision paddle walls
	if pad.x<wall.x0+1 then
		pad.x=wall.x0+1
	end
	if pad.x+pad.w >wall.x1 then
		pad.x=wall.x1-pad.w 
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
		timeleft=timeleft-1
	end	

	-- END
	if ball.y > 136 then
		lives=lives-1
		sfx(1)
		if lives < 0 then mode = 0 end
		gameGo()
	end

	if timeleft < 0 then
		mode = 0
	end
 
 	-- DRAW		
	rectb(wall.x0,wall.y0,wall.w,wall.h,12) -- walls	
	ball:draw()
	pad:draw()
 
	for i, br in ipairs(bricks) do
		br:draw()
	end  
 
	-- UI
	print("LIVES: "..lives,wall.x0,1,12)
	print("TIME: "..math.floor(timeleft/60),wall.x0+50,1,12)
	print("POINTS: "..points,wall.x0+110,1,12)

	-- debug
	-- rect(ball.x,ball.y,1,1,2)
	--rect(10,8,40,10,12)
	--print("",12,10,2)
	--print(bricks[2].x,12,18,2)
end

function colCircRect(ball, box)
	local box_cx=box.x+((box.w-1)/2)
	local box_cy=box.y+((box.h-1)/2)
	
	local dist_x=box_cx-ball.x
	local dist_y=box_cy-ball.y
	
	local maxdist_x = box.w/2
	local maxdist_y = box.h/2

	if math.abs(dist_x) < maxdist_x+(ball.r) and math.abs(dist_y) < maxdist_y+ball.r then	
		if math.abs(dist_y) < maxdist_y then
			if dist_x > 0 then				
				return 1 -- col left
			elseif dist_x < 0 then				
				return 2 -- col right
			end
		elseif math.abs(dist_x) < maxdist_y then
			if dist_y > 0 then				
				return 3 -- col up
			elseif dist_y < 0 then				
				return 4 -- col down
			end	
		else -- corner
			if dist_x > 0 and dist_y > 0 then 
				return 5 -- up left
			elseif dist_x < 0 and dist_y > 0 then 
				return 6 -- up right
			elseif dist_x < 0 and dist_y < 0 then 
				return 7 -- down right
			elseif dist_x > 0 and dist_y < 0 then 
				return 8 -- down left
			end
		end		
	else	
		return 0 -- sin colision		
	end
end


function colBallBrick(ball, br)
	if is_collided then return end
	local col = colCircRect(ball, br)
	if col == 0 then return end		
	if col == 1 then -- left		
		ball.x = br.x-ball.r
		ball.dx = -math.abs(ball.dx)
	elseif col == 2 then -- right	
		ball.x = br.x+br.w+ball.r
		ball.dx = math.abs(ball.dx)
	elseif col == 3 then -- up
		ball.y = br.y-ball.r		
		ball.dy = -math.abs(ball.dy)		
	elseif col == 4 then -- down		
		ball.y = br.y+br.h+ball.r
		ball.dy = math.abs(ball.dy)
	elseif col == 5 then -- up left		
		ball.y = br.y-ball.r		
		ball.dy = -math.abs(ball.dy)
	elseif col == 6 then -- up right
		ball.y = br.y-ball.r		
		ball.dy = -math.abs(ball.dy)
	elseif col == 7 then -- down right
		ball.y = br.y+br.h+ball.r
		ball.dy = math.abs(ball.dy)	
	elseif col == 8 then -- down left
		ball.y = br.y+br.h+ball.r
		ball.dy = math.abs(ball.dy)
	end
	is_collided=true	

	sfx(0,"D-7")	
	if br.t > 1  and br.t < 5 then 
		br.t = br.t - 1
		br.c = brick_c[br.t]
		points = points + 1
	elseif br.t==1 then
		br.v=false
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

function startMenu()
	cls()
	print("press A to start",70,50,4)
	if btn(4) then
		gameBOOT()
	 mode=2
 end
	
	rectb(0,0,240,136,12)
end

function gameOver()
	cls()
	print("GAME OVER",90,20,4)
	print("press A to start",70,50,4)
	if btn(4) then
		gameBOOT()
	 mode=2
	 end
	
	rectb(0,0,240,136,12)
end

function TIC()
	if mode == 1 then startMenu()
	elseif mode == 2 then game()
	elseif mode == 0 then gameOver()
	end
	
end
-- <TILES>
-- 001:0022dccc0222dccc0222dccc0822dccc0088eccc000000000000000000000000
-- 002:cccd2200cccd2220cccd2220cccd2280ccce8800000000000000000000000000
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

