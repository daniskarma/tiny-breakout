-- title:   tiny bricks
-- author:  vacceos media
-- desc:    tiny breakout-style game
-- site:    
-- license: MIT License
-- version: 0.1
-- script:  lua



-- TODO
	-- para publicar cambiar saveid
	-- normalizar nombres (snake_case, upper, CamelCase...)

 

function BOOT() 

math.randomseed(tstamp())

-- input constants
controller={	
	right = {
		type='b',
		pos={
			x=85,
			y=0,
			r=35,
			a=0,
		},
		pressed=false,
		color=2
	},
	left = {
		type='b',
		pos={
			x=-85,
			y=0,
			r=35,
			a=180,
		},
		pressed=false,
		color=2
	},
	pos = {
		x=120,
		y=90	
	}
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


-- Player
Player={
	lives=0,
	points=0,
	hscore = 0,
}

-- Stage
DEFAULT_STAGE={
	n=0,		
	time=255*60, --current stage time 
	ball={
		maxdx=1.5,
		maxdy=1,
		startdx=1,
		startdy=1,
	},
	won_time=60,
	energy_bricks=0,
	ball_size_time=0,
	pad_size_time=0,
	hit_time_zero=false,
	micro_points=0,
	diff=1
}
STAGE={}

starting_level = 1
-- Levels
LVL = {
	{
	n=1,
	title="How did you get here?",
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,6,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{1,1,1,1,1,1,1,1,1,1,1,1,1},	
		{2,2,2,2,2,2,2,2,2,2,2,2,2},			
		{1,1,1,1,1,1,1,1,1,1,1,1,1},	
		{2,2,2,2,2,2,2,2,2,2,2,2,2},
		{1,1,1,1,1,1,1,1,1,1,1,1,1},	
		{2,2,2,2,2,2,2,2,2,2,2,2,2},			
		{1,1,1,1,1,1,1,1,1,1,1,1,1},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},		
		}
	},
	{
	n=2,
	title="Two eyes are looking",
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,1,1,1,1,1,0,1,1,1,1,1,0},
		{0,1,2,2,2,1,0,1,2,2,2,1,0},	
		{1,1,2,6,2,1,1,1,2,6,2,1,1},	
		{0,1,2,2,2,1,0,1,2,2,2,1,0},	
		{0,1,1,1,1,1,0,1,1,1,1,1,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},		
		}
	},
	{
	n=3,
	title="Piramid",
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,1,0,0,0,0,0,0},	
		{0,0,0,0,0,4,1,4,0,0,0,0,0},	
		{0,0,0,0,3,4,1,4,3,0,0,0,0},
		{0,0,0,2,3,4,0,4,3,2,0,0,0},	
		{0,0,1,2,3,4,6,4,3,2,1,0,0},
		{0,5,5,5,5,5,5,5,5,5,5,5,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0}		
		}
	},
	{
	n=4,
	title="Stairway to me",
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,6},
		{1,1,4,4,4,4,4,4,4,4,4,4,4},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{4,4,4,4,4,4,4,4,4,4,4,1,1},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,4,4,4,4,4,4,4,4,4,4,4},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{4,4,4,4,4,4,4,4,4,4,4,1,1},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,4,4,4,4,4,4,4,4,4,4,4},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{4,4,4,4,4,4,4,4,4,4,4,1,1}				
		}
	},	
	{
	n=5,
	title="The blob",
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,4,4,4,0,0,0,0,0},
		{0,0,0,0,3,3,3,3,3,0,0,0,0},	
		{0,0,0,3,3,2,2,2,3,3,0,0,0},	
		{0,0,3,3,2,2,1,2,2,3,3,0,0},
		{0,4,3,2,2,1,1,1,2,2,3,4,0},	
		{0,4,3,2,1,1,6,1,1,2,3,4,0},	
		{0,4,3,2,2,1,1,1,2,2,3,4,0},
		{0,0,3,3,2,2,1,2,2,3,3,0,0},	
		{0,0,0,3,3,2,2,2,3,3,0,0,0},	
		{0,0,0,0,3,3,3,3,3,0,0,0,0},
		{0,0,0,0,0,4,4,4,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0}		
		}
	},
	{
	n=6,
	title="Balance", 
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,1,1,0,0,0,0,0,1,1,0,0},
		{0,1,1,1,1,0,0,0,1,1,1,1,0},	
		{0,1,1,1,1,0,0,0,1,1,1,1,0},	
		{0,1,6,6,1,0,0,0,1,6,6,1,0},
		{0,2,2,2,2,0,0,0,2,2,2,2,0},	
		{0,2,2,2,2,0,0,0,2,2,2,2,0},
		{0,2,2,2,2,0,0,0,2,2,2,2,0},
		{0,2,6,6,2,0,0,0,2,6,6,2,0},	
		{0,3,3,3,3,0,0,0,3,3,3,3,0},	
		{0,3,3,3,3,0,0,0,3,3,3,3,0},
		{0,3,3,3,3,0,0,0,3,3,3,3,0},
		{0,3,6,6,3,0,0,0,3,6,6,3,0},	
		{0,5,5,5,5,0,0,0,5,5,5,5,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0}		
		}
	},	
	{
	n=7,
	title="TIC", 
	map={	
		{0,0,6,0,0,0,6,0,0,0,6,0,0},	
		{2,2,2,2,2,2,2,2,2,2,2,2,2},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,3,3,3,0,0,3,0,0,3,3,3,0},
		{0,3,3,3,0,0,3,0,0,3,3,3,0},	
		{0,0,3,0,0,0,3,0,0,3,0,0,0},	
		{0,0,3,0,0,0,3,0,0,3,0,0,0},	
		{0,0,3,0,0,0,3,0,0,3,0,0,0},
		{0,0,3,0,0,0,3,0,0,3,0,0,0},	
		{0,0,3,0,0,0,3,0,0,3,0,0,0},	
		{0,0,3,0,0,0,3,0,0,3,0,0,0},
		{0,0,3,0,0,0,3,0,0,3,3,3,0},
		{0,0,3,0,0,0,3,0,0,3,3,3,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{2,2,2,2,2,2,2,2,2,2,2,2,2},		
		}
	},
	{
	n=8,
	title="80",
	map={
		{4,4,4,4,4,4,4,4,4,4,4,4,4},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,5,3,3,3,3,0,5,3,3,3,5,0},	
		{0,3,3,6,3,3,0,3,3,6,3,3,0},	
		{0,3,0,0,0,3,0,3,0,0,0,3,0},
		{0,3,0,0,0,3,0,3,0,0,0,3,0},	
		{0,3,3,3,3,3,0,3,0,0,0,3,0},	
		{0,3,3,3,3,3,0,3,0,0,0,3,0},	
		{0,3,0,0,0,3,0,3,0,0,0,3,0},	
		{0,3,0,0,0,3,0,3,0,0,0,3,0},	
		{0,3,0,0,0,3,0,3,0,0,0,3,0},			
		{0,3,3,6,3,3,0,3,3,6,3,3,0},	
		{0,5,3,3,3,5,0,5,3,3,3,5,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{4,4,4,4,4,4,4,4,4,4,4,4,4},	
					
		}
	},
	{
	n=9,
	title="The Chaos Machine",
	map={		
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,4,4,4,0,0,0,0,0,4,4,4,0},	
		{0,4,6,4,0,0,0,0,0,4,6,4,0},
		{0,4,4,4,0,0,0,0,0,4,4,4,0},
		{0,0,0,0,0,4,4,4,0,0,0,0,0},	
		{0,0,0,0,0,4,6,4,0,0,0,0,0},	
		{0,0,0,0,0,4,4,4,0,0,0,0,0},
		{0,4,4,4,0,0,0,0,0,4,4,4,0},	
		{0,4,6,4,0,0,0,0,0,4,6,4,0},
		{0,4,4,4,0,0,0,0,0,4,4,4,0},	
		{0,0,0,0,0,4,4,4,0,0,0,0,0},	
		{0,0,0,0,0,4,6,4,0,0,0,0,0},
		{0,0,0,0,0,4,4,4,0,0,0,0,0},
		{0,4,4,4,0,0,0,0,0,4,4,4,0},	
		{0,4,6,4,0,0,0,0,0,4,6,4,0},
		{0,4,4,4,0,0,0,0,0,4,4,4,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},		
		}
	},
	{
	n=10,
	title="Don't you love me?", -- too long
	map={
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,4,4,0,0,0,4,4,0,0,0},	
		{0,0,4,4,4,0,0,0,4,4,4,0,0},
		{0,0,4,4,4,4,0,4,4,4,4,0,0},	
		{0,0,4,4,4,4,4,4,4,4,4,0,0},	
		{0,0,4,4,4,4,4,4,4,4,4,0,0},
		{0,0,4,4,4,4,4,4,4,4,4,0,0},	
		{0,0,0,4,4,4,4,4,4,4,0,0,0},	
		{0,0,0,4,4,4,6,4,4,4,0,0,0},
		{0,0,0,0,4,4,4,4,4,0,0,0,0},	
		{0,0,0,0,4,4,4,4,4,0,0,0,0},	
		{0,0,0,0,4,4,4,4,4,0,0,0,0},
		{0,0,0,0,0,4,4,4,0,0,0,0,0},
		{0,0,0,0,0,4,4,4,0,0,0,0,0},	
		{0,0,0,0,0,0,4,0,0,0,0,0,0},
		{0,0,0,0,0,0,4,0,0,0,0,0,0},	
		}
	},

	{
	n=11,
	title="What!?", -- weird collisions
	map={
		{0,5,0,0,0,0,0,2,0,0,0,0,0},
		{0,5,0,0,0,0,0,2,0,0,0,0,0},	
		{0,0,0,0,0,0,0,2,0,0,0,0,0},
		{0,0,0,0,0,0,0,2,0,0,0,0,0},	
		{0,5,0,0,0,0,0,2,0,0,0,0,0},	
		{0,5,0,0,0,2,2,2,2,2,0,0,0},
		{0,5,0,0,0,2,4,4,4,2,0,0,0},	
		{0,5,2,2,2,2,4,6,4,2,2,2,2},	
		{0,5,0,0,0,2,4,4,4,2,0,0,0},
		{0,5,0,0,0,2,2,2,2,2,0,0,0},	
		{0,5,0,0,0,0,0,2,0,0,0,0,0},	
		{0,5,0,0,0,0,0,2,0,0,0,0,0},
		{0,5,0,0,0,0,0,2,0,0,0,0,0},
		{0,5,0,0,0,0,0,2,0,0,0,0,0},
		{0,5,0,0,0,0,0,2,0,0,0,0,0},	
		{0,5,5,5,5,5,5,5,5,5,5,5,5},
		{0,0,0,0,0,0,0,0,0,0,0,0,0}		
		}
	},
	{
	n=12, 
	title="Last defence",
	map={
		{1,1,1,1,1,1,1,1,1,1,1,1,1},
		{2,2,2,2,2,2,2,2,2,2,2,2,2},
		{3,3,3,3,3,3,3,3,3,3,3,3,3},	
		{4,4,4,4,4,4,4,4,4,4,4,4,4},
		{0,0,0,0,0,0,0,0,0,0,0,0,0},	
		{0,0,0,0,0,5,4,5,0,0,0,0,0},
		{0,0,0,0,0,5,6,5,0,0,0,0,0},	
		{0,0,0,0,0,5,5,5,0,0,0,0,0},	
		{0,5,4,5,0,0,0,0,0,5,4,5,0},
		{0,5,6,5,0,0,0,0,0,5,6,5,0},	
		{0,5,5,5,0,0,0,0,0,5,5,5,0},	
		{0,0,0,0,0,0,0,0,0,0,0,0,0},
		{4,4,4,4,4,4,4,4,4,4,4,4,4},	
		{3,3,3,3,3,3,3,3,3,3,3,3,3},	
		{0,4,4,4,4,0,0,4,4,4,4,4,0},
		{0,0,3,3,3,0,0,0,3,3,3,0,0},		
		{0,0,0,4,0,0,0,0,0,4,0,0,0}		
		}
	},
	-- {
	-- n=0,
	-- title="You shouldn't be here!",
	-- diff=DIFF.EASY,
	-- map={
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},
	-- 	{0,0,0,0,0,0,0,0,0,0,0,0,0},	
	-- 	}
	-- },
}

-- game state
Game={
	-- mode
	m=M.BOOT,	
}


TICF={
	[M.BOOT]=Boot,
	[M.TITLE]=TitleTic,	
	[M.PLAY]=PlayTic,	
	[M.GAMEOVER]=GameOverTic,
	[M.GAMEWIN]=GameWinTic,	
}

-- ELEMENTS
wall={
	init=function(self,x0,y0)
		self.x0=x0
		self.x1=x0 + 170
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
	newball.r =r -- 2
	newball.dx=dx
	newball.dy=dy		
	newball.c =c
	newball.stuck_c = 0
	newball.stuck_t = 0
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

brick_c={{7,6,5},{8,9,10},{2,3,4},{1,2,3},{14,13,12},{0,14,13}} --brick colors
brick={}	
function brick:new(x,y,t,id)
	local newbrick = {}
	setmetatable(newbrick, self)
	self.__index=self
	newbrick.x=x
	newbrick.y=y
	newbrick.w=13
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
			rect(self.x,self.y,self.w,self.h,self.c[3])
			rect(self.x+1,self.y+1,self.w-2,self.h-2,self.c[2])
			line(self.x+1,self.y+self.h-1,self.x+self.w-1,self.y+self.h-1,self.c[1])
			line(self.x+self.w-1,self.y+1,self.x+self.w-1,self.y+self.h-1,self.c[1])
			rect(self.x+self.w-1,self.y,1,1,self.c[2])
			rect(self.x,self.y+self.h-1,1,1,self.c[2])					
			spr(6,self.x+4,self.y,0)
			
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
			sfx(51, -1, -1, 1)
			if self[i].pw == 0 then -- POWER five extra life
				if Player.lives < 8 then
					Player.lives = Player.lives + 1
				else
					Player.points = Player.points + 50
				end
			elseif self[i].pw==1 then -- POWER give two balls
				if #balls < 8	then
					local rate = 1
					if #balls == 1 then rate = 2 end
					for iball=#balls,1,-1 do
						for _=1,rate do 
							local newball = ball:new(
								balls[iball].x+math.random(),
								balls[iball].y+math.random(),
								balls[iball].r,
								balls[iball].dx*((math.random(0, 1) == 0) and -1 or 1)*math.random(),
								((math.random(0, 1) == 0) and -1 or 1),
								11
							)
							table.insert(balls, newball)							
						end
					end
				end
			elseif self[i].pw==2 then -- POWER increase pad
				STAGE.pad_size_time = time()+45000
				if pad.tw < 46	then 
					pad.tw=pad.tw+8					
				end	
			elseif self[i].pw==3 then -- POWER decrease pad
				STAGE.pad_size_time = time()+45000
				if pad.tw > 14	then 
					pad.tw=pad.tw-8					
				end			
			elseif self[i].pw==4 then -- POWER increase ball size
				STAGE.ball_size_time = time()+45000
				if balls[1].r < 4	then 
					for i=1, #balls do
						balls[i].r = balls[i].r + 1
					end	
				end
			elseif self[i].pw==5 then -- POWER reduce ball size
				STAGE.ball_size_time = time()+45000
				if balls[1].r > 0	then 
					for i=1, #balls do
						balls[i].r = balls[i].r - 1
					end	
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

FPS={value=0,frames=0,lastTime=-1000} -- cuidado al moverlo
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

end -- BOOT

function setStage(level)
	STAGE=DeepCopy(DEFAULT_STAGE)
	STAGE.diff=1+1*((level-1)/#LVL)
	STAGE.time=STAGE.time
	-- STAGE.time=STAGE.time*diff
	STAGE.ball.maxdx=STAGE.ball.maxdx*STAGE.diff
	STAGE.ball.maxdy=STAGE.ball.maxdy*STAGE.diff
	STAGE.ball.startdx=STAGE.ball.startdx*STAGE.diff
	STAGE.ball.startdy=STAGE.ball.startdy*STAGE.diff
	STAGE.n=level
	STAGE.won_time=30
	STAGE.init_time=time()
end

function SetMode(m)
	if m == M.TITLE then
		 music(0) 
	elseif m == M.GAMEWIN then
		music(2)	
	elseif m == M.GAMEOVER then
		music(3)	
	elseif m == M.PLAY then
		music(1)		
	end
	Game.m=m
end




function TIC()
	TICF[Game.m]()	
	--DEBUG
	--rect(200-2,129-2,60,9,14)
	--PrintShadow("FPS: "..FPS:getValue(),200,129,12,nil,1,1)		
	poke(0x3FFB,0)
end


function Boot()
	--poke(0x7FC3F,1,1) -- disable cursor	
	SetMode(M.TITLE)
end

function TitleTic()
	cls()	
	print("TINY",45,20,12,true,1, true)	
	spr(48, 30, 30, 0, 3, 0, 0, 7 ,2)	
	if (time()//500%2) == 0 then 
		printc("START",120,100,4)
	else
		printc("START",120,100,3)
	end
	rectb(0,0,240,136,12)

	if input(BTN.ACTION) then
		Player.points = 0
		Player.lives = 6
		Player.hscore = pmem(1)
		StageInit(starting_level)
		SetMode(M.PLAY)
 	end	
	
end

function GameOverTic()
	cls()
	printc("GAME OVER",121,41,14,true, 3)
	printc("GAME OVER",120,40,12,true, 3)
	gameEndUpdate()	
end

function GameWinTic()
	cls()
	printc("CONGRATULATIONS!",121,31,14,true, 2)
	printc("CONGRATULATIONS!",120,30,12,true, 2)

	printc("YOU WON",121,51,14,true, 2)
	printc("YOU WON",120,50,12,true, 2)

	gameEndUpdate()	
end

function gameEndUpdate()
	-- menuda cutrez esta funcion, en general.	

	if Player.points > pmem(1) then		
		if (time()//500%2) == 0 then 
			printc("NEW HIGH SCORE!",120,95,4)
		else
			printc("NEW HIGH SCORE!",120,95,3)
		end
		Player.hscore = Player.points		
	end

	local padding = 6 - (string.len(tostring(Player.points)))
	print("YOUR SCORE:"..string.rep(".", padding)..tostring(Player.points),70,75,4,true, 1)
	print("YOUR SCORE:"..string.rep(".", padding),70,75,12,true, 1)
	local padding = 6 - (string.len(tostring(Player.hscore)))
	print("HIGH SCORE:"..string.rep(".", padding)..tostring(Player.hscore),70,82,4,true, 1)
	print("HIGH SCORE:"..string.rep(".", padding),70,82,12,true, 1)	

	if (time()//500%2) == 0 then 
		printc("START",120,110,4)
	else
		printc("START",120,110,3)
	end

	if input(BTN.ACTION) then
		pmem(1, Player.hscore)
		StageInit(1)
		SetMode(M.TITLE)
 	end	
	rectb(0,0,240,136,12)
end


function PlayTic()
	updatecontroller(controller)
	-- function vars
	local is_btnpress=false
	local is_collided=false	
	local is_loaded=false

	is_loaded = STAGE.init_time + 1000 > time()

	-- PADDLE
	if STAGE.pad_size_time < time() then
		pad.tw = 30
	end
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
		pad.dx = 0
	end
	if pad.x+pad.w >wall.x1 then
		pad.x=wall.x1-pad.w 
		pad.dx = 0
	end

	-- -- BALL -- --
	for i=#balls, 1, -1 do
		-- balls size
		if STAGE.ball_size_time < time() then
			balls[i].r = 2
		end

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
			sfx(48)
		end	
		if balls[i].x<wall.x0+balls[i].r+1 then -- left
			balls[i].x = wall.x0+balls[i].r+1
			balls[i].dx=math.abs(balls[i].dx)
			sfx(48)
		end
		if balls[i].y<wall.y0+balls[i].r then -- up
			balls[i].y = wall.y0+balls[i].r+1
			balls[i].dy=math.abs(balls[i].dy)
			sfx(48)
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
		STAGE.time=STAGE.time-(1*STAGE.diff)
		-- TODO - fix difficulty formula
	end	

	if STAGE.time == 0 then
		if not STAGE.hit_time_zero then
			STAGE.hit_time_zero = true
			sfx(50)
		end
	end	

	if STAGE.time < 0 then
		STAGE.micro_points = STAGE.micro_points + 1 * STAGE.diff
		if STAGE.micro_points >= 300 then
			Player.points = Player.points - 1
			STAGE.micro_points = 0
		end
		STAGE.time = 0
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
		Player.lives = Player.lives - 1	
		Player.points = Player.points - 50
		if Player.lives < 0 then 
			sfx(49)
			SetMode(M.GAMEOVER) 
		end
		sfx(49)
		PrepareBall()
	end

	if Player.points < 0 then
		Player.points = 0
	end
 
 	---- DRAW	
	cls(0) --general background
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

	if next(pws) ~= nil then
		for i=1, #pws do
			pws[i]:draw()			
		end
		pws:update()
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
	
	--Particles
	DrawPart(parts)
	UpdatePart(parts)	

	-- stage load screen, splash screen
	if is_loaded then			
		rect(wall.x0,wall.y0,wall.w,wall.h,00) -- play background	
		printc("LEVEL: "..STAGE.n, wall.x0+(wall.x1-wall.x0)/2, 45, 12, true)
		printc(LVL[STAGE.n].title, wall.x0+(wall.x1-wall.x0)/2, 65, 12, true)		
	end

	DrawUI()

	-- DEBUG

	
	-- PrintShadow(" : "..tostring(math.abs(pad.dx) < pad.sp),195,15,12,nil,1,1)
	PrintShadow("diff: "..STAGE.diff,200,100,12,nil,1,1)	
	PrintShadow("#LVL: "..#LVL,200,110,12,nil,1,1)	
	PrintShadow("n: "..STAGE.n,200,120,12,nil,1,1)	
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


function StageInit(level)	
	setStage(level)	
	wall:init(34,4)	
	pad:init(50,120,30,4,0.4)
	pws:clear()	

	bricks = {}
	balls = {}	
	for i=1,17 do
		for j = 1,13 do			
			local newbrick=brick:new(
				wall.x0+1+j*13-13,
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
		if row == 17 then return false end
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
	if br.t > 1  and br.t < 5 then 
		sfx(48,"D-7")
		br.t = br.t - 1
		br.c = brick_c[br.t]	
		Player.points = Player.points + 1		
	elseif br.t==1 then
		sfx(48,"D-7")
		br.v=false
		local pwchance = math.random(0,14)
		if pwchance == 0 then
			pwchance = pwchance + math.random(0,1)
		end	
		if pwchance < 6 then
			powerup:new(br.x+br.w/2,br.y+br.h/2,pwchance)
		end
		Player.points = Player.points + 1	
	elseif br.t == 5 then
		sfx(48)
		ball.stuck_c = ball.stuck_c + 1
		if ball.stuck_c == 1 then
			ball.stuck_t = time()
		end
		if ball.stuck_c > 5 and time() > ball.stuck_t + 5000 then
			stuckBall(ball)
		end
	elseif br.t == 6 then
		sfx(52,"C-4",-1,3,6)
		br.v=false
		Player.points=Player.points + 5
		STAGE.energy_bricks=STAGE.energy_bricks-1
		Explode(br.x,br.y)
		br.gw=6			
	end
	if br.t ~= 5 then
		ball.stuck_c = 0
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
	ball.stuck_c = 0
	sfx(48,"D-5")	
end

function stuckBall(ball)
	ball.dx = ball.dx + (((math.random(0, 1) == 0) and -1 or 1)*0.2)
	ball.stuck_c = 0
	Explode(ball.x,ball.y)
end

---- UI
-- Draw

function draw_bevel(left,right,top,botton)
	rect(left,top,right-left,botton-top, 15)
	line(left,botton,right,botton,12)
	line(right,top,right,botton,12)
	line(left,top,right,top,00)
	line(left,top,left,botton,00)	
	pix(left,botton, 15)
	pix(right,top, 15)
end

function DrawUI()		
	--playground bevel
	-- line(wall.x0,wall.y1,wall.x1,wall.y1,12)
	-- line(wall.x1,wall.y0,wall.x1,wall.y1,12)
	-- line(wall.x0,wall.y0,wall.x1,wall.y0,14)
	-- line(wall.x0,wall.y0,wall.x0,wall.y1,14)
	-- pix(wall.x0,wall.y0, 15)
	-- pix(wall.x0,wall.y1, 15)
	-- pix(wall.x1,wall.y0, 15)
	rect(0,wall.y1+1,240,136, 0) -- botton ui for hiding ball	

	-- new UI
	rectb(wall.x0,wall.y0,wall.w,wall.h,0)
	rectb(wall.x0,wall.y0-1,wall.w,wall.h+1,13)
	----
	local info_y0 = 4
	local info_y1 = 50

	-- info left	
	local left_x0 = 1
	local left_x1 = wall.x0-2

	--draw_bevel(left_x0,left_x1,info_y0,info_y1)
	
	
	print("LIVES ",left_x0+2,info_y0+3,12)
	for i=0,Player.lives-1 do
		circ(left_x0+3+1+i*7-(i//4)*28,info_y0+12+(i//4)*7,2,4)
	end
	
	print("TIME ",left_x0+2,info_y0+28,12)
	local time_c = 4
	print(math.floor(STAGE.time/60),left_x0+3,info_y0+35,time_c)

	-- info right
	local right_x0 = wall.x1+2
	local right_x1 = 240-2

	-- draw_bevel(right_x0,right_x1,info_y0,info_y1)

	print("HIGH",right_x0+2,info_y0+3,12)
	print("SCORE",right_x0+2,info_y0+9,12)
	print(Player.hscore,right_x0+2,info_y0+16,4)

	print("SCORE ",right_x0+2,info_y0+28,12)
	print(Player.points,right_x0+2,info_y0+35,4)

	

	drawcontroller(controller)
end



function updatebutton(b,xo,yo)
	local mx,my,mp=mouse()
	local quiral = (b.pos.x<0 and -1) or 1
	local is_left = b.pos.x<0
	local x0 = xo
	local x1 = xo
	local y0 = yo-45
	local y1 = yo+45	
	if quiral > 0 then
		x1 = x1 + (quiral*b.pos.r)
		x0 = x0 - 1
	else
		x0 = x0 + (quiral*b.pos.r) 
	end

	if mp and mx>x0 and mx<x1 and my>y0 and my<y1 then
		b.pressed=true		
	else
		b.pressed=false		
	end
end

function drawbutton(b,xo,yo)
	local quiral = (b.pos.x<0 and -1) or 1
	local is_left = b.pos.x<0
	local x0 = xo
	local x1 = xo
	local y0 = yo-45
	local y1 = yo+45	
	if quiral > 0 then
		x1 = x1 + (quiral*b.pos.r)
		x0 = x0 - 1
	else
		x0 = x0 + (quiral*b.pos.r) 
	end
	local is_down = false
	if is_left and input(BTN.LEFT) then
		is_down = true
	elseif not is_left and input(BTN.RIGHT) then
		is_down = true
	end
	if b.pressed or is_down then
		--rectb(x0,y0,math.abs(x1-x0),y1-y0,12)
		tric(x0+b.pos.r/2,yo+2,b.pos.r/3, b.pos.a, 13)
		
	else
		--rectb(x0,y0,math.abs(x1-x0),y1-y0,12)		
		tric(x0+b.pos.r/2,yo+2,b.pos.r/3, b.pos.a, 15)
		tric(x0+b.pos.r/2,yo,b.pos.r/3, b.pos.a, 13)
		
	end		
end

function updatecontroller(con)
	local xo = controller.pos.x
	local yo = controller.pos.y
	for k,v in pairs(con) do	
		if v.type == 'b' then
			updatebutton(v,v.pos.x+xo,v.pos.y+yo)
		end
	end
end

function drawcontroller(con)
	local xo = controller.pos.x
	local yo = controller.pos.y
	for k,v in pairs(controller) do
		if v.type == 'b' then
			drawbutton(v,v.pos.x+xo,v.pos.y+yo)			
		end
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
		return btnp(4) or is_mouse
	elseif option == BTN.RIGHT then
		return peek(0xFF80)==8 or controller.right.pressed == true
	elseif option == BTN.LEFT then
		return peek(0xFF80)==4 or controller.left.pressed == true
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

-- No tiene en cuenta distintos anchos por caracter
-- Para centrar correctamente una fuente tiene que tener fixed=true
function printc(...)
	local firstArg = select(1, ...)
    local secondArg = select(2, ...)
	local scale = (select(6, ...)~=nil and select(6, ...) or 1)
    local new_x = secondArg - (#firstArg / 2)*6*scale
    local args = {select(3, ...)}
    table.insert(args, 1, new_x)
    table.insert(args, 1, firstArg)
    print(table.unpack(args))
end


-- HELPERS
function PrintShadow(message,x,y,color,gap,size,smallmode)
	print(message,x,y,0,gap,size,smallmode)
	print(message,x,y-1,color,gap,size,smallmode)
end

function sign(v)
	return v>0 and 1 or
		v<0 and -1 or 0
end

-- TODO finish
function tric(x,y,r,a,c)	
	local t = getTriPoints(x,y,r,a) 
	tri(t.x1,t.y1,t.x2,t.y2,t.x3,t.y3,c)
end

function getTriPoints(x,y,r,a)
	local a1 = math.rad(a)
	local a2 = math.rad(a+360/3)
	local a3 = math.rad(a+2*360/3)
	local triangle = {
		x1 = x + math.cos(a1) * r,
		x2 = x + math.cos(a2) * r,
		x3 = x + math.cos(a3) * r,
		y1 = y + math.sin(a1) * r,
		y2 = y + math.sin(a2) * r,
		y3 = y + math.sin(a3) * r,
	}
	return triangle
end




-- <TILES>
-- 001:0022dccc0222dccc0222dccc0822dccc0088eccc000000000000000000000000
-- 002:cccd2200cccd2220cccd2220cccd2280ccce8800000000000000000000000000
-- 003:fddddddafdeeeeabfdeeeabcfdeeeeabfe00000affffffffffffffffffffffff
-- 004:adddddefbaeeee0fcbaeee0fbaeeee0fa000000fffffffffffffffffffffffff
-- 005:0000dccd0000dccd0000dccd0000dccd0000dccd0000dccd0000dccd0000dccd
-- 006:00a000000aba0000abcba0000aba000000a00000000000000000000000000000
-- 016:0055500005666600566c667066ccc670666c6670066667000077700000000000
-- 017:0055500005666600566c66706666667066c6c670066667000077700000000000
-- 018:0055500005666600566666706ccccc7066666670066667000077700000000000
-- 019:00333000032222003222228022ccc28022222280022228000088800000000000
-- 020:0055500005ccc6005ccccc706ccccc706ccccc7006ccc7000077700000000000
-- 021:003330000322220032222280222c228022222280022228000088800000000000
-- 049:0000000004444000044444400440444006600660066666000990099009909990
-- 050:0000000000444400044444400440044006600660066666600999990009900990
-- 051:0000000004444000044440040044000400660006006600060099000900990009
-- 052:0000000044444004444440044404400460000006600000069000000999099009
-- 053:0000000040044000400440044044400466660006666600069999900090999000
-- 054:0000000044444000444440004000000066000000666660000999900000099000
-- 065:0222222002222110011111100111100000000000000000000000000000000000
-- 066:0220022002200220011001100110011000000000000000000000000000000000
-- 067:0222200202222001011110010111100000000000000000000000000000000000
-- 068:2222200222222002111110011111100100000000000000000000000000000000
-- 069:2002200220022002100110011001100100000000000000000000000000000000
-- 070:2222200022221000111110001111000000000000000000000000000000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:0123456789aaaaaaaaaaaa9876543210
-- 004:000111122334556789aabccdeeeeffff
-- 005:00000000000000000fffff0000000000
-- 006:45566778899aabbccbbaa99887766554
-- 008:77777777777777770000000000000000
-- </WAVES>

-- <SFX>
-- 000:72039202b201d200e20ff20df20cf20cf20ef200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200472000000000
-- 001:670e9700b70cd70ff700f700f70ef70ff700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700400000000000
-- 002:91d031b0419001700160414071209110a100b100d100e100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100210000000000
-- 004:0804080308020800080f080e080d080d080d080d080d080d080d080d080d080d080d080d080d080d080d080d080d080d080d080d080d180d380d480da04000000000
-- 005:780c780b780b780a780a780a780a7809780978098809880988098809880988099809980898089808a808a808b808b808b808c808c808c808c808d808b00000000000
-- 006:202050106000b000d000d000d000d000e000e000f000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000e000402000000000
-- 048:4100510171019102a103c103d105e107f107f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f10041000010f000
-- 049:34a444a054937490748194709461c431c441e420f410f400f200f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000360000000000
-- 050:f0f0e0e0c0d0b0b0a0a08080707060504040502070109000b000d000d000d000c000901060204020603080309040a060b070c070d090e0b0e0c0f0e0210000000000
-- 051:36e556c466b376a1a670c66fe65df63cf62bd61ab60e96348667769766c766e0f600f600f600f600f600f600f600f600f600f600f600f600f600f600975000000000
-- 052:e70b2794278747776757674777377726b7169715c714a704c703b702c70fd70fd70fe70fe70fe70ff70ff70ff70ef70ef70ef70ef70df70df70bf70b370000000000
-- </SFX>

-- <PATTERNS>
-- 000:6fd10200000060001800000060002200000060000260001a60002200000060001860002260000200000060000200000090000200000090001890000290002200000090002290001890002200000090001a90000290002200000090000290000280002200001080000280002280001800000080000200002080002280001a00000080000200001080001a000000800022b00002b00018000000b00022b00002000000b00022b00018000000b0001a000000b00002b00022b00002000000b00002
-- 001:612168600068800068000000600068600068800068000000a00068000000000000000000900068d00068000060600068000060600068600068800068000000600068600068700068000000d00068d00068b00068000000000000d00068d00068b00068000000600068600068800068000060d00068d00068b00068000000600068600068800068000000000000b00068b00068800068000060a00068000060000060600068600068800068000060000060d00068d00068b00068000000000000
-- 002:666144000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:4f8100000000400000000000000000000000000000000000400000000000400000000000000000000000000000000000400000000000400000000000000000000000000000000000400000000000400000000000000000000000000000000000400000000000400000000000000000000000000000000000400000000000400000000000000000000000000000000000400000000000400000000000000000000000000000000000400000000000400000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

