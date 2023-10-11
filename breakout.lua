--ARKANOID
-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

--TODO:
 	-- fix collision overlap
  -- paddle sprite
		
		

function BOOT()
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
			self.w =self.x1-self.x0
			self.h =self.y1-self.y0
		end	
	}
	wall:init(6,233,8,136)

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
			self.h =4
			self.sp=sp
			self.ac=ac
			self.c =c
			self.dx=0			
		end,
		draw=function(self)
			rect(self.x,self.y,self.w,self.h,self.c)
		end	
	}
	pad:init(30,120,30,4,0.4,12)
	
	
	brick_c={4,6,2,9}
	brick={}	
	function brick:new(x,y,t)
		local newbrick = {}
		setmetatable(newbrick, self)
		self.__index=self
		newbrick.x=x
		newbrick.y=y
		newbrick.w=15
		newbrick.h=5
		newbrick.c=brick_c[t]
		newbrick.t=t
		newbrick.v=true
		return newbrick		
	end
	function brick:draw()
		if self.v then
			rect(self.x,self.y,self.w,self.h,self.c)
		end
	end
	
	layout={
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,0,0,0,0,1,1,1,1,1,1,1,1},
		{1,1,0,1,0,0,1,1,1,1,1,1,1,1},
		{1,1,0,1,1,1,1,1,1,1,1,1,1,1},
		{1,2,1,1,1,1,1,1,1,1,1,1,1,1},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2}
	}
	bricks = {}	
	for i=1,14 do
		for j = 1,7 do
			if layout[j][i] > 0 then
				local newbrick=brick:new(
					wall.x0+2+i*16-16,
					wall.y0+2+j*6-6,
					layout[j][i])
				table.insert(bricks,newbrick)
			end
		end
	end		
	lives=3
	points=0
	timeleft=60*60
	
	gameGo()
end

function gameGo()
	ball:init(pad.x+pad.w/2,pad.y-3,2,0,0,11)
	is_launchball=false
end

function game()
	--function vars
	is_btnpress=false

	cls()
	--ball
	ball.x=ball.x+ball.dx
	ball.y=ball.y+ball.dy
		
	--ball launch
	
	if not is_launchball and btn(4) then
		ball.dx=1
		ball.dy=-1
		is_launchball=true
	end
	
	--collision ball walls
	if ball.x>wall.x1-ball.r-2 or ball.x<wall.x0+ball.r+2 then
		ball.dx=-ball.dx
		sfx(0)
	end	
	if ball.y<wall.y0+ball.r+1 then
		ball.dy=-ball.dy
		sfx(0)
	end
	if ball.y>wall.y1+ball.r+4 then
		ball.dy=-ball.dy
		sfx(0)
	end
		
 --paddle	
 if btn(2) then --left
 	if math.abs(pad.dx) < pad.sp then
  	pad.dx=pad.dx-pad.ac
  end
  is_btnpress=true
 end
 if btn(3) then --right
 	if math.abs(pad.dx) < pad.sp then
  	pad.dx=pad.dx+pad.ac
  end
  is_btnpress=true
 end
 if not is_btnpress then --friction
 	pad.dx= pad.dx/1.5
 end
 if math.abs(pad.dx)<0.01 then
  pad.dx=0
 end --kill speed
 pad.x=pad.x+pad.dx --move paddle
	pad.x=math.floor(pad.x+0.5)--smooth movement
	--ball move with pad
	if not is_launchball then
		ball.x=pad.x+pad.w/2
		ball.y=pad.y-3
	end	
	
	--collision paddle walls
 if pad.x<wall.x0+1 then pad.x=wall.x0+1 end
 if pad.x+pad.w >wall.x1-1 then pad.x=wall.x1-pad.w-1 end
 
 --collision ball-paddle
	local colision=colBallPad(ball,pad)
	if colision ~= 0 then sfx(0,"D-5") end
	
 
 --collision brick ball
 for i, br in ipairs(bricks) do
 	if br.v then
	 	local colision=colCircRect(ball,br)
			if colision ~= 0 then
			 sfx(0,"D-7")
				points = points +1
				if br.t >1 then 
					br.t = br.t -1
					br.c = brick_c[br.t]
				elseif br.t==1 then
					br.v=false
				end
		 end			
		end
 end
 
 --TIME
 
 if is_launchball then
 	timeleft=timeleft-1
 end
 
 --END
 if ball.y > 136 then
  lives=lives-1
  sfx(1)
 	if lives < 0 then mode = 0 end
  gameGo()
 end
 
 if timeleft < 0 then
 	mode = 0
 end
 
 --DRAW
	--walls
	rectb(wall.x0,wall.y0,wall.w,wall.h,12)
	
	ball:draw()
	pad:draw()
 
 for i, br in ipairs(bricks) do
 	br:draw()
 end
   
 
 --UI
 print("LIVES: "..lives,6,1,12)
 print("TIME: "..math.floor(timeleft/60),60,1,12)
 print("POINTS: "..points,120,1,12)

--debug


--	print(pad.y-ball.y,12,10,2)
--	print(bricks[2].x,12,18,2)
end

function colCircRect(ball, box)
	local box_cx=box.x+(box.w/2)
	local box_cy=box.y+(box.h/2)
	
	local dist_x=math.abs(box_cx-ball.x)
	local dist_y=math.abs(box_cy-ball.y)
	
	local maxdist_x = box.w/2
	local maxdist_y = box.h/2

	if dist_x <= maxdist_x+(ball.r) and dist_y <= maxdist_y+ball.r then
	 	
		if dist_x >= maxdist_x then
			if ball.dx > 0 then
				ball.x = ball.x - ball.dx
				ball.dx = -ball.dx
				return 1 --col left
			elseif ball.dx < 0 then
				ball.x = ball.x - ball.dx
				ball.dx = -ball.dx
				return 2 --col right
			end
		elseif dist_y >= maxdist_y then
			if ball.dy > 0 then
				ball.y = ball.y - ball.dy
				ball.dy = -ball.dy
				return 3 --col up
			elseif ball.dy < 0 then
				ball.y = ball.y - ball.dy
				ball.dy = -ball.dy
				return 4 -- col down
			end
		end
		
	else	
		return 0 -- sin colision		
	end
end

function colBallPad(ball,box)
	local box_cx=box.x+(box.w/2)
	local box_cy=box.y+(box.h/2)
	
	local dist_x=box_cx-ball.x
	local dist_y=math.abs(box_cy-ball.y)
		
	local maxdist_x = box.w/2
	local maxdist_y = box.h/2
	
	local reldist_x=dist_x/maxdist_x

	if math.abs(dist_x) <= maxdist_x+(ball.r) and dist_y <= maxdist_y+ball.r then
	 ball.y =box.y-ball.r
	 ball.dy=-ball.dy
		if math.abs(ball.dx)<2.5 then
			ball.dx=ball.dx-reldist_x+1.2
		end
		return 1		
	else	
		return 0 -- sin colision		
	end		
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
	elseif mode == 2 then	game()
	elseif mode == 0 then gameOver()
	end
	
end
-- <TILES>
-- 001:0eeeeeeeeeddddddeddddddd0eeeeeee00000000000000000000000000000000
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

