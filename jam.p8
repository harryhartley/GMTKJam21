pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--main

function _init()
	t=0
	winanim=0
	nolevels=6
	state=-1
	dir={{-1,0},{1,0},{0,-1},{0,1}}
	currentplayer={}
	currentobjects={}
	moves={}
	bonds={}
 l0={133,135,151}
 l1={170,134,168}
 l2={133,120,121}
 l3={135,104,133,120,106}
 l4={137,134,121,102}
 l5={167,86,104,151}
 loadlevel(state)
end

function _update60()
	if winanim>0 then
		winanim-=1
	else
		if state==-1 then
			for b=0,5 do
				if btnp(b) then
					while fadeanim do
						fadeout()
					end
					state=0
					loadlevel(state)
					fadein()
				end
			end
		elseif state==-2 then
			for b=0,5 do
				if btnp(b) then
					while fadeanim do
						fadeout()
					end
					state=0
					loadlevel(state)
					fadein()
				end
			end
		elseif state==-3 then
		 levelselect()
		elseif state>=nolevels then
			state=-2
		elseif state>=0 then
			if btnp(4) then
				moves={}
	   bonds={}
	   sfx(12)
				loadlevel(state)
			end
			if btnp(5) then
				rewind()
			end
			moveinput()
			updatewin()
			if checkwin() then
				state+=1
				moves={}
	   bonds={}
				loadlevel(state)
			end
		end
	end
	t+=1
end

function _draw()
	cls()
	if winanim>0 then
		x=0
	else
		fadein()
		if state==-1 then
			title()
		elseif state==-2 then
		 gameover()	
		elseif state>=0 then
			map(16*state,0,0,0)
			drawplayer(currentplayer)
			drawobjects(currentobjects)
			colourbonds()
			drawui()
		end
	end
end
-->8
--load

function loadlevel(level)
 if level==0 then
 	parseleveldata(l0)
 elseif level==1 then
 	parseleveldata(l1)
 elseif level==2 then
 	parseleveldata(l2)
 elseif level==3 then
 	parseleveldata(l3)
 elseif level==4 then
 	parseleveldata(l4)
 elseif level==5 then
 	parseleveldata(l5)
 end
end

function parseleveldata(entities)
 currentobjects={}
 for k,v in pairs(entities) do
 	truepos={x=(v%16),y=flr(v/16)}
 	if k==1 then
 		currentplayer=truepos
 	else
 		add(currentobjects,truepos)
 	end
 end
end
-->8
--move

function moveinput()
	for b=0,3 do
		if btnp(b) then
			add(moves,b)
			moveplayer(b)
			checkbonds()
		end
	end
end

function moveplayer(b)
	newx=currentplayer.x+dir[b+1][1]
	newy=currentplayer.y+dir[b+1][2]
	if checkwalls(newx,newy) then
		if checkobjects(newx,newy,b) then
	 	currentplayer.x=newx
	 	currentplayer.y=newy
	 	sfx(0)
--			add(moves,b)
	 else
	 	sfx(1)
	 end
	else
		sfx(1)
	end
end

function moveobject(id,b)
	currentobjects[id].x+=dir[b+1][1]
	currentobjects[id].y+=dir[b+1][2]
end

function checkwalls(x,y)
	if fget(mget((state*16)+x,y),0) then
	 return false
	end
	return true
end

function checkobjects(x,y,b)
	if hasobject(x,y) then
		--
		currentid=getblockid(x,y)
		currentbond=getbond(currentid)
		--
		for k,id in pairs(currentbond) do
			obj=currentobjects[id]
			destx = obj.x+dir[b+1][1]
			desty = obj.y+dir[b+1][2]
			if hasobject(destx,desty) then
				if not isinbond(currentbond, getblockid(destx,desty)) then
					return false
				end
			elseif not checkwalls(destx,desty) then
				return false
			end
		end
		--
		for k,id in pairs(currentbond) do
			moveobject(id,b)
		end
		--
	end
	return true
end

function checkbonds()
	for k,v in pairs(currentobjects) do
		if istile(v.x,v.y,7) then
			if istile(v.x+1,v.y,7) and hasobject(v.x+1,v.y) then
				for l,w in pairs(currentobjects) do
					if w.x==v.x+1 and w.y==v.y then
						addbond(k,l)
					end
				end
			end
			if istile(v.x,v.y+1,7) and hasobject(v.x,v.y+1) then
				for l,w in pairs(currentobjects) do
					if w.x==v.x and w.y==v.y+1 then
						addbond(k,l)
					end
				end
			end
		end
	end
end

function checkbondsrewind()
	for k,v in pairs(currentobjects) do
		if istile(v.x,v.y,7) then
			if istile(v.x+1,v.y,7) and hasobject(v.x+1,v.y) then
				for l,w in pairs(currentobjects) do
					if w.x==v.x+1 and w.y==v.y then
						addbondrewind(k,l)
					end
				end
			end
			if istile(v.x,v.y+1,7) and hasobject(v.x,v.y+1) then
				for l,w in pairs(currentobjects) do
					if w.x==v.x and w.y==v.y+1 then
						addbondrewind(k,l)
					end
				end
			end
		end
	end
end
-->8
--draw

function drawplayer(player)
	spr(2,player.x*8,player.y*8)
end

function drawobjects(objects)
	for k,v in pairs(objects) do
		spr(3,v.x*8,v.y*8)
	end
end

function title()
	print("gmtk game jam 2021",18,10,7)
 print("sokolink by",18,26,7)
 print("hyhy and dawsonicus",18,34,7)
 print("controls: ",18,50,7)
 print("movement: ⬆️⬅️➡️⬇️",25,58,7)
 print("rewind: x/❎",25,66,7)
 print("restart level: z/🅾️",25,72,7)
 if t%60>15 then
 	print("press any key to start",18,88,7)
	end
end

function gameover()
	print("all levels complete!",18,20,7)
 print("press any key to retry",
 	18,30,7)
end

function levelselect()
	print("idk do this never")
end

function colourbonds()
	bondpal={8,12,11,10}
	for k,bond in pairs(bonds) do
		for l,id in pairs(bond) do
			px=currentobjects[id].x*8
			py=currentobjects[id].y*8
			for i=3,4 do
				for j=3,4 do
					pset(px+i,py+j,bondpal[k])
				end
			end
		end
	end
end

function drawui()
	rect(0,0,127,16,5)
	rectfill(1,1,126,15,1)
 print("level:"..(state+1).."/"..nolevels,2,2,7)
 print("moves:"..#moves,48,2,7)
 print("time:"..flr(time()),92,2,7)
 print("restart: z/🅾️",2,10,7)
 print("rewind: x/❎",76,10,7)
end
-->8
--gamestate

function addbond(a,b)
	temp={}
 existsany=false
	for k,bond in pairs(bonds) do
		exists=false
		for id in all(bond) do
			if id==a or id==b then
				exists=true
				existsany=true
			end
		end
		if exists then
			match=false
			for k,v in pairs(bond) do
				if v==a then
					match=true
				end
			end
			if not match then
				add(bond, a)
				sfx(5)
			end
			match=false
			for k,v in pairs(bond) do
				if v==b then
					match=true
				end
			end
			if not match then
				add(bond, b)
				sfx(5)
			end
		end
		add(temp, bond)
	end
	if not existsany then
		add(temp, {a,b})
		sfx(5)
	end
	bonds=temp
end

function addbondrewind(a,b)
	temp={}
 existsany=false
	for k,bond in pairs(bonds) do
		exists=false
		for id in all(bond) do
			if id==a or id==b then
				exists=true
				existsany=true
			end
		end
		if exists then
			match=false
			for k,v in pairs(bond) do
				if v==a then
					match=true
				end
			end
			if not match then
				add(bond, a)
			end
			match=false
			for k,v in pairs(bond) do
				if v==b then
					match=true
				end
			end
			if not match then
				add(bond, b)
			end
		end
		add(temp, bond)
	end
	if not existsany then
		add(temp, {a,b})
	end
	bonds=temp
end

function getbond(id)
	for k,bond in pairs(bonds) do
		for i,num in pairs(bond) do
		 if num==id then
		 	return bond
		 end
		end
	end
	return {id}
end

function isinbond(bond, id)
	for k,num in pairs(bond) do
		if id==num then
			return true
		end
	end
	return false
end

function rewind()
	bonds={}
	loadlevel(state)
	deli(moves, #moves)
	for k,v in pairs(moves) do
		moveplayer(v)
  checkbondsrewind()
	end
end

function updatewin()
	notowin=0
	totalno=0
	for x=0,15 do
		for y=0,15 do
			cspr = mget((state*16)+x,y)
			if cspr==5 or cspr==6 then
				totalno+=1
				if cspr==6 then
					notowin+=1
				end
				exists=false
				for k,v in pairs(currentobjects) do
				 if v.x==x and v.y==y then
				  exists=true
				 end
				end
				if exists then
					mset((state*16)+x,y,6)
				else
					mset((state*16)+x,y,5)
				end
			end
		end
	end
	newnotowin=0
	for x=0,15 do
		for y=0,15 do
			cspr = mget((state*16)+x,y)
			if cspr==6 then
				newnotowin+=1
			end
		end
	end
	if newnotowin>notowin and newnotowin<totalno then
		sfx(6)
	end
end

function checkwin()
	for x=0,15 do
		for y=0,15 do
			if mget((state*16)+x,y)==5 then
				return false
			end
		end
	end
	sfx(2)
	fadeout()
	winanim=45
	return true
end
-->8
--animation

function fadeout()
	dpal={0,1,1, 2,1,13,6,
       4,4,9,3, 13,1,13,14}
	for i=0,10 do
  for j=1,15 do
   col = j
   for k=1,((i+(j%5))/4) do
    col=dpal[col]
   end
   pal(j,col,1)
  end
  flip()
 end
end

function fadein()
	pal()
end
-->8
--helpers

function hasobject(x,y)
	for k,v in pairs(currentobjects) do
	 if v.x==x and v.y==y then
	  	return true
	 end
	end
	return false
end

function istile(x,y,tile)
	return mget((state*16)+x,y)==tile
end

function getblockid(x,y)
	for k,v in pairs(currentobjects) do
		if v.x==x and v.y==y then
			return k
		end
	end
	return -1
end
__gfx__
00000000000000000000000000000000666666666688886666bbbb6666cccc661dddddd100000000000000000000000000000000000000000000000000000000
0000000000000000004444000555555066666666686666866b6666b66c6666c6d111161d00000000000000000000000000000000000000000000000000000000
000000000000000000ffff000d1d1d1066d6666686666668b666666bc66c666cd111116d00000000000000000000000000000000000000000000000000000000
000000000000000000f1f1000d166d106666666686666668b666666bc6ccc66cd111111d00000000000000000000000000000000000000000000000000000000
0000000000000000055555500d166d1066666d6686666668b666666bc66c666cd111111d00000000000000000000000000000000000000000000000000000000
0000000000000000505555050d1d1d106666666686666668b666666bc666666cd611111d00000000000000000000000000000000000000000000000000000000
0000000000000000004444000555555066666666686666866b6666b66c6666c6d161111d00000000000000000000000000000000000000000000000000000000
00000000000000000040040000000000666666666688886666bbbb6666cccc661dddddd100000000000000000000000000000000000000000000000000000000
__gff__
0001000300040408010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101080808080101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010808080505080101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101080804040504080101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101080808080801010101010101010101010108080808010101010101010101010808080808080801010101010101080404040408080101010101010101010104040404040505050101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010108080404050801010101010101010101010108050508010101010101080808080804040404040801010101010101080404040404080801010101010101010104040404010101010101010000000000000000000000000000000000000000000000000000000000000000
0108080808080801010808080808080801010101010808040404080801010101010101080808080808040408010101010101080505080807040404040801010101010101080404040407070801010101010101010101070707010101010101000000000000000000000000000000000000000000000000000000000000000000
0108040404040808080804040404040801010101010807070404080101010101010101080407070404040408010101010101080404040407040707040808010101010101080807040404040808010101010101010101040401010101010101010000000000000000000000000000000000000000000000000000000000000000
0108040404040404040404040504040801010101010807070408080808010101010101080404040404040808010101010101080804040404040404040508010101010101010807040404040408010101010101010101010401010101010101010000000000000000000000000000000000000000000000000000000000000000
0108040404040404040404040404040801010101010804040808040408010101010101080808080808080801010101010101010808040404040408040508010101010101010808080404040408010101010101010104040404040101010101010000000000000000000000000000000000000000000000000000000000000000
0108040404040808080805040404040801010101010804040404040408010101010101010101010101010101010101010101010108080808080808080808010101010101010101080808080808010101010101010104040404040101010101010000000000000000000000000000000000000000000000000000000000000000
0108080808080801010808080808080801010101010808040404040808010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010108080808080801010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010300001a750127001b7002b70008700247002470024700007002470024700247002470000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400001d75018650147500000000000000000000000000000000000000000000001c4001c4001c4001c4001c4001c4000000000000000000000000000000000000000000000000000000000000000000000000
021000001e550225502555021550215502c550315502850023500225003050032500355002a50016500105002b500245000050000500005000050000500005000050000500005000050000500005000050000500
000200001b75021750297001f750227001a7502175021700307001670016700007001670000700167001670000700007000070000700007000070000700007000070000700007000070000700007000070000700
00040000237502a7502e7502775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001575016750197501c75000700227502c7000070029750007002d750317500070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00020000137501975000000000000000000000000002c750000000000000000000003675000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2804002014650146001b600250000060000000006000d6001b620190001b0000000000000000000000000000146202a0000000000000000000000000000000001a62000000000000000000000000000000000000
00080020127551370518755007051d70500705097551c705267551e70500705007052f755237050070500705187551a70500705267552d7052f7052f755007053475534755007053775519755197551975500705
00080020127551370518755007051d70500705097551c705267551e70500705007052f755237050070500705187551a70500705347552d7052f70533755007053470537755007053770500705397553b7053c755
00080020127551370518755007051d70500705097551c7053a70532755327053170530705307550070500705187551a70500705347552d7052f70533755007053470530755007053770500705327553b7051f705
00080020127551370518755007051d705007050f755127053a7052e755327053170530705307550070500705187551a705007052f7552d7052f705367550070534705237550070537705287052c7553b7051f705
00030000300502e0502b050280501705023050160501f050140501b050150500d0500b0500a0500a0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 07084344
01 07084344
01 07084344
01 07094344
01 07084344
01 07084344
01 07084344
01 07094344
00 070a4344
00 070a4344
00 070b4344
00 070a4344
01 07084344
01 07084344
01 07084344
01 07094344
01 07084344
01 07084344
01 07084344
01 07094344
00 070a4344
00 070a4344
00 070b4344
01 070a4344

