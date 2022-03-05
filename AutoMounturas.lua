--[[
	Ariel Camilo // ariel.cami@gmail.com // 2 de Marzo 2022

	El script hará el cobro real de las habilidades de jinete y monturas,
	y enviará al jugador el mensaje correspondiente.

	Este script NO es para dar monturas gratis, sino más bien para
	ahorrar tiempo en entrenar e ir a comprar la montura.

	A partir del nivel 60 el script hará el cobro aplicando un descuento 
	en precio de las habilidades Experto jinete y Artesano jinete, dependiendo de la reputación
	en Orgrimmar o Ventormenta según la facción, y enviará el mensaje correspondiente.

	Al nivel 77 el script también hará el cobro por Vuelo en clima frío.

	PD: Fueron muchas horas de trabajo, te agradecería una estrella o un follow, Gracias!
]]
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local MontPal_id = {34769,34767,13819,23214,'33,25 de plata por ',41325,'4,14 de oro ',478325,'47,84 de oro '}  
local MontBru_id = {5784,23161,'9,50 de oro por ','[Corcel vil]','[Corcel nefasto]'}
local MontPal_Na = {'[Caballo de guerra thalassiano]','[Caballo de guerra]','[Destrero thalassiano]','[Destrero]'}
local RidingCost = {38000,'3,80 de oro por ',475000,'47,50 de oro por ','57 de oro ',47500,570000,'4,75 de oro ',3000000}
local RidSkill = {33388,33391,34090,34091,54197,'[Aprendiz jinete]','[Oficial jinete]','[Experto jinete]','[Artesano jinete]'}
local pag,money,y,insuf,consig,deoro,deplata = '¡Pagaste ','de oro por ',' y ','¡Dinero insuficiente para ',', consigue ','de oro ','de plata por '
local entrena = 'y compra estas habilidades en sus respectivos entrenadores.'
local precios,por = {'95 de plata por '},'por '
local descu60 = {'(12,5g ','(25g ','(37,5g ','(50g ','(250g ','(500g ','(750g ','(1000g '}
local dedesc = 'de descuento por ser '
local AHVE = {'amistoso en ','honorable en ','venerado en ','exaltado en '}
local capit = {'Orgrimmar) ','Ventormenta) '}
local Soy_ = {'neutral','amistoso','honorable','venerado','exaltado'}
local M_60str = {'[Caballo marrón]','[Lobo gris]','[Carnero azul]','[Sable de la noche rayado]','[Caballo esquelético negro]','[Kodo marrón]','[Mecazancudo morado]','[Raptor esmeralda]','[Halcón zancudo azul]','[Elekk morado]'}
local M100str = {'[Palomino presto]','[Lobo gris presto]','[Carnero gris presto]','[Sable de la Niebla presto]','[Caballo de guerra esquelético ocre]','[Gran kodo marrón]','[Mecazancudo amarillo presto]','[Raptor naranja presto]','[Halcón zancudo morado presto]','[Gran elekk verde]'}
local Mounts = {458,23227, 580,23251, 6897,23239, 10793,23219, 64977,66846, 18990,23249, 17455,23222, 8395,23243, 35020,35027, 35711,35712}
local Volad = {'[Jinete del viento leonado]','[Grifo dorado]','[Jinete del viento rojo presto]','[Grifo rojo presto]'}
local Rep_Cost = {2875000,2750000,2625000,2500000,51000000,48500000,46000000,43500000,41000000,3000000}
local Cost_dru = {2407300,2282300,2157300,2032300,50190000,47690000,45190000,42690000,40190000,'253,23 de oro '}
local strs = {'287,50 ','275 ','262,50 ','250 ','5100 ','4850 ','4600 ','4350 ','4100 ','300 de oro '}
local ridc,hund,fift = {'237,50 ' ,'225 ' ,'212,50 ' ,'200 ' ,'5000 ' ,'4750 ', '4500 ', '4250 ','4000 '},'100 de oro ','50 de oro '
local Voladora = {32243,32235,32246,32289,33943,40120}
local dudu = {'240,73 ','228,23 ','215,73 ','203,23 ','5019 ','4769 ','4519 ','4269 ','4019 '}
local Guer,Pala,Caza,Pica,Sace,Caba,Cham,Mago,Bruj,Drui = 1,2,4,8,16,32,64,128,256,1024
local function CambioDeNivel(e,P,N)              local L,C,R,H,A,Gold = P:GetLevel(),P:GetClassMask(),P:GetRaceMask(),P:IsHorde(),P:IsAlliance(),P:GetCoinage()
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function Repu(Q) -- Gestor de Reputación nivel 60 y 70
 	if H then tt=76 else tt=72 end	local Neut,Neu1,Amis,Ami1,Hono,Hon1,Vene,Ven1,Exal = 1,2999,3000,8999,9000,20999,21000,41999,42000
    if L == 60 then  												
            if P:GetReputation(tt) >= Neut and P:GetReputation(tt) <= Neu1 then Q=10 return Q
        elseif P:GetReputation(tt) >= Amis and P:GetReputation(tt) <= Ami1 then Q=1 return Q
        elseif P:GetReputation(tt) >= Hono and P:GetReputation(tt) <= Hon1 then Q=2 return Q
        elseif P:GetReputation(tt) >= Vene and P:GetReputation(tt) <= Ven1 then Q=3 return Q
        elseif P:GetReputation(tt) >= Exal then                                 Q=4 return Q end  
    end
    if L == 70 then
            if P:GetReputation(tt) >= Neut and P:GetReputation(tt) <= Neu1 then Q=5 return Q
        elseif P:GetReputation(tt) >= Amis and P:GetReputation(tt) <= Ami1 then Q=6 return Q
        elseif P:GetReputation(tt) >= Hono and P:GetReputation(tt) <= Hon1 then Q=7 return Q
        elseif P:GetReputation(tt) >= Vene and P:GetReputation(tt) <= Ven1 then Q=8 return Q
        elseif P:GetReputation(tt) >= Exal                 				  then Q=9 return Q end
    end 
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	local function Paladin() -- Función específica para Paladines
		if L==20 then 						if H then x=1 z=1 else x=3 z=2 end 
			if Gold >= MontPal_id[6] then 
				P:ModifyMoney( -MontPal_id[6] ) P:LearnSpell( RidSkill[1] ) P:LearnSpell( MontPal_id[x] ) 
				P:SendBroadcastMessage("|cfffd7dff"..pag..RidingCost[2].."|cff19e8ff"..RidSkill[6].."|cfffd7dff"..y..
				"|cfffd7dff"..MontPal_id[5].."|cff19e8ff"..MontPal_Na[z].."|cfffd7dff"..".")
				else                        
					P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[6].."|cffff0000"..y.."|cff19e8ff"
                	..MontPal_Na[z].."|cffff0000"..consig..MontPal_id[7]..entrena) end end
		if L==40 then						
			if Gold >= MontPal_id[8] then  
				P:ModifyMoney( -MontPal_id[8] ) P:LearnSpell( RidSkill[2] ) P:LearnSpell( MontPal_id[x] ) 
				P:SendBroadcastMessage("|cfffd7dff"..pag..RidingCost[4].."|cff19e8ff"..RidSkill[7].."|cfffd7dff"..y..
				"|cfffd7dff"..MontPal_id[5].."|cff19e8ff"..MontPal_Na[z].."|cfffd7dff"..".")
				else                       if H then x=2 z=3 else x=4 z=4 end  
					P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[7].."|cffff0000"..y.."|cff19e8ff"
                	..MontPal_Na[z].."|cffff0000"..consig..MontPal_id[9]..entrena) end end
	end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	local function Brujo() -- Función específica para Brujos
		if L==20 then 						
			if Gold >= MontPal_id[6] then 
				P:ModifyMoney( -MontPal_id[6] ) P:LearnSpell( RidSkill[1] ) P:LearnSpell( MontBru_id[1] ) 
				P:SendBroadcastMessage("|cfffd7dff"..pag..RidingCost[2].."|cff19e8ff"..RidSkill[6].."|cfffd7dff"..y
				..MontPal_id[5].."|cff19e8ff"..MontBru_id[4].."|cfffd7dff"..".")
				else                        
					P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[6].."|cffff0000"..y.."|cff19e8ff"
                	..MontBru_id[4].."|cffff0000"..consig..MontPal_id[7]..entrena) end end
		if L==40 then				
			if Gold >= RidingCost[7] then  
				P:ModifyMoney( -RidingCost[7] ) P:LearnSpell( RidSkill[2] ) P:LearnSpell( MontBru_id[2] ) 
				P:SendBroadcastMessage("|cfffd7dff"..pag..RidingCost[4].."|cff19e8ff"..RidSkill[7].."|cfffd7dff"..y..
				"|cfffd7dff"..MontBru_id[3].."|cff19e8ff"..MontBru_id[5].."|cfffd7dff"..".")
				else                        
					P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[7].."|cffff0000"..y.."|cff19e8ff"
                	..MontBru_id[5].."|cffff0000"..consig..RidingCost[5]..entrena) end end 
	end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function Druida() -- Función específica para Druidas
																local dd='3,23 de oro por ' local form = {'[Forma voladora]','[Forma de vuelo presto]'}
			if H then w=76 ha=1 else w=72 ha=2 end
				if P:GetReputation(w) >= 3000 and P:GetReputation(w) <= 8900 then   T=5  t=1
			elseif P:GetReputation(w) >= 9000 and P:GetReputation(w) <= 20999 then  T=6  t=2
			elseif P:GetReputation(w) >= 21000 and P:GetReputation(w) <= 41999 then T=7  t=3
			elseif P:GetReputation(w) >= 42000 then 								T=8  t=4  end

	if L==60 then 	
		if P:GetReputation(w) <= 2999 then			
			if Gold >= 2532300 then P:ModifyMoney(-2532300) P:LearnSpell(RidSkill[3]) P:LearnSpell(Voladora[5])
			P:SendBroadcastMessage("|cfffd7dff"..pag..strs[4]..deoro..por.."|cff19e8ff"..RidSkill[8].."|cfffd7dff"..y..dd.."|cff19e8ff"..form[1].."|cfffd7dff.") 
		else P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[8].."|cffff0000"..y.."|cff19e8ff"..form[1].."|cffff0000"..consig
			..Cost_dru[10]..entrena) end end		

		if P:GetReputation(w) >= 3000 then 
			if Gold >= Cost_dru[Repu(Q)] then P:ModifyMoney(-(Cost_dru[Repu(Q)])) P:LearnSpell(RidSkill[3]) P:LearnSpell(Voladora[5]) 
				P:SendBroadcastMessage("|cfffd7dff"..pag..ridc[Repu(Q)]..deoro..descu60[t]..dedesc..AHVE[t]..capit[ha]..
					por.."|cff19e8ff"..RidSkill[8].."|cfffd7dff"..y..dd.."|cff19e8ff"..form[1].."|cfffd7dff.")
			else P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[8].."|cffff0000"..y.."|cff19e8ff"..form[1].."|cffff0000"..consig
			..dudu[Repu(Q)]..entrena) end end
	end

	if L==70 then 	if H then w=76 else w=72 end  
		if P:GetReputation(w) <= 2999 then			local nine,five = '19 de oro por ','5000 de oro por '
			if Gold >= 50190000 then P:ModifyMoney(-50190000) P:LearnSpell(RidSkill[4]) P:LearnSpell(Voladora[6])
			P:SendBroadcastMessage("|cfffd7dff"..pag..five.."|cff19e8ff"..RidSkill[9].."|cfffd7dff"..y..nine.."|cff19e8ff"..form[2].."|cfffd7dff.") 
		else P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[9].."|cffff0000"..y.."|cff19e8ff"..form[2].."|cffff0000"..consig
			..dudu[Repu(Q)]..deoro..entrena) end end

	if P:GetReputation(w) >= 3000 then      		local nine,five = '19 de oro por ','5000 de oro por '    
			if Gold >= Cost_dru[Repu(Q)] then P:ModifyMoney(-(Cost_dru[Repu(Q)])) P:LearnSpell(RidSkill[4]) P:LearnSpell(Voladora[6]) 
				P:SendBroadcastMessage("|cfffd7dff"..pag..ridc[Repu(Q)]..deoro..descu60[T]..dedesc..AHVE[t]..capit[ha]
				..por.."|cff19e8ff"..RidSkill[9].."|cfffd7dff"..y..nine.."|cff19e8ff"..form[2].."|cfffd7dff.")
			else P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[9].."|cffff0000"..y.."|cff19e8ff"..form[2].."|cffff0000"..consig
			..dudu[Repu(Q)]..deoro..entrena) end end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RepartirMounts()	-- Gestor de monturas	

	if L==20 then  if C==2 or C==256 then return end
		if Gold >= RidingCost[6] then P:ModifyMoney(-RidingCost[6]) P:LearnSpell(RidSkill[1])
			if R==1   then P:LearnSpell( Mounts[1] ) elseif R==2    then P:LearnSpell( Mounts[3] )
		elseif R==4   then P:LearnSpell( Mounts[5] ) elseif R==8    then P:LearnSpell( Mounts[7] )
		elseif R==16  then P:LearnSpell( Mounts[9] ) elseif R==32   then P:LearnSpell( Mounts[11])
		elseif R==64  then P:LearnSpell( Mounts[13]) elseif R==128  then P:LearnSpell( Mounts[15])
		elseif R==512 then P:LearnSpell( Mounts[17]) elseif R==1024 then P:LearnSpell( Mounts[19]) end end 
	end

	if L==40 then  if C==2 or C==256 then return end
		if Gold >= RidingCost[7] then P:ModifyMoney(-RidingCost[7]) P:LearnSpell(RidSkill[2])
			if R==1   then P:LearnSpell( Mounts[2] ) elseif R==2    then P:LearnSpell( Mounts[4] )
		elseif R==4   then P:LearnSpell( Mounts[6] ) elseif R==8    then P:LearnSpell( Mounts[8] )
		elseif R==16  then P:LearnSpell( Mounts[10]) elseif R==32   then P:LearnSpell( Mounts[12])
		elseif R==64  then P:LearnSpell( Mounts[14]) elseif R==128  then P:LearnSpell( Mounts[16])
		elseif R==512 then P:LearnSpell( Mounts[18]) elseif R==1024 then P:LearnSpell( Mounts[20]) end end	
	end

	if L==60 then 	if C==1024 then return end  	if H then w=76 V=1 hh=1 else w=72 V=2 hh=2 end

		if P:GetReputation(w) >= 3000 and P:GetReputation(w) <= 8900 then   K=5  kk=1
	elseif P:GetReputation(w) >= 9000 and P:GetReputation(w) <= 20999 then  K=6  kk=2
	elseif P:GetReputation(w) >= 21000 and P:GetReputation(w) <= 41999 then K=7  kk=3
	elseif P:GetReputation(w) >= 42000 then 								K=8  kk=4  end

		if P:GetReputation(w) <= 2999 then			
			if Gold >= Rep_Cost[10] then 
				P:ModifyMoney(-Rep_Cost[10] ) P:LearnSpell(RidSkill[3]) P:LearnSpell(Voladora[V])
				P:SendBroadcastMessage("|cfffd7dff"..pag..strs[4]..deoro..por.."|cff19e8ff"..RidSkill[8]
					.."|cfffd7dff"..y..fift..por.."|cff19e8ff"..Volad[hh].."|cfffd7dff.") 
			else P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[8].."|cffff0000"..y.."|cff19e8ff"..Volad[hh].."|cffff0000"..consig..strs[10]..entrena) 
			end
		end

		if P:GetReputation(w) >= 3000 then  	if H then AH=1 else AH=2 end
			if Gold >= Rep_Cost[Repu(Q)] then P:ModifyMoney(-(Rep_Cost[Repu(Q)])) P:LearnSpell(RidSkill[3]) P:LearnSpell(Voladora[V])
			P:SendBroadcastMessage("|cfffd7dff"..pag..ridc[Repu(Q)]..deoro..descu60[kk]..dedesc..AHVE[kk]..capit[AH]..por.."|cff19e8ff"..RidSkill[8]
				.."|cfffd7dff"..y..fift..por.."|cff19e8ff"..Volad[hh].."|cfffd7dff.") 
			else 
				P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[8].."|cffff0000"..y.."|cff19e8ff"
                	..Volad[hh].."|cffff0000"..consig..strs[Repu(Q)]..deoro..entrena)
			end 
		end
	end

	if L==70 then 	if C==1024 then return end    if H then w=76 V=3 else w=72 V=4 end
		if P:GetReputation(w) <= 2999 then			
			if Gold >= Rep_Cost[5] then P:ModifyMoney(-Rep_Cost[5] ) P:LearnSpell(RidSkill[4]) P:LearnSpell(Voladora[V]) end
			end

		if P:GetReputation(w) >= 3000 then 
			if Gold >= Rep_Cost[Repu(Q)] then P:ModifyMoney(-(Rep_Cost[Repu(Q)])) P:LearnSpell(RidSkill[4]) P:LearnSpell(Voladora[V]) end 
		end
	end	
end	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function Mensajes()  -- Gestor de mensajes nivel 20, 40 y 60 solamente.
		if L==20 then 		if C==2 or C==256 then return end
			if R==1 then o=1 elseif R==2 then o=2 elseif R==4 then o=3 elseif R==8 then o=4 elseif R==16 then o=5    
		elseif R==32 then o=6 elseif R==64 then o=7 elseif R==128 then o=8 elseif R==512 then o=9 elseif R==1024 then o=10 end

			if Gold >= RidingCost[6] then P:SendBroadcastMessage("|cfffd7dff"..pag..RidingCost[2].."|cff19e8ff"..RidSkill[6].."|cfffd7dff"..y.."|cfffd7dff"
										  ..precios[1].."|cff19e8ff"..M_60str[o].."|cfffd7dff"..".")
			else
				P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[6].."|cffff0000"..y.."|cff19e8ff"
                	..M_60str[o].."|cffff0000"..consig..RidingCost[8]..entrena) end
		end

		if L==40 then  		if C==2 or C==256 then return end
			if R==1 then o=1 elseif R==2 then o=2 elseif R==4 then o=3 elseif R==8 then o=4 elseif R==16 then o=5    
		elseif R==32 then o=6 elseif R==64 then o=7 elseif R==128 then o=8 elseif R==512 then o=9 elseif R==1024 then o=10 end

		if Gold >= RidingCost[7] then P:SendBroadcastMessage("|cfffd7dff"..pag..RidingCost[4]..por.."|cff19e8ff"..RidSkill[7].."|cfffd7dff"..y.."|cfffd7dff"
									  ..MontBru_id[3].."|cff19e8ff"..M100str[o].."|cfffd7dff"..".")
			else
				P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[7].."|cffff0000"..y.."|cff19e8ff"
                	..M100str[o].."|cffff0000"..consig..RidingCost[5]..entrena) end
		end

		if L==60 then			if H then w=76 hh=1 else w=72 hh=2 end	 

			if P:GetReputation(w) <= 2999 then
				if Gold >= Rep_Cost[10] then
					P:SendBroadcastMessage("|cfffd7dff"..pag..strs[4]..deoro..por.."|cff19e8ff"..RidSkill[8]
					.."|cfffd7dff"..y..fift..por.."|cff19e8ff"..Volad[hh].."|cfffd7dff.") 
				else 
					P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[8].."|cffff0000"..y.."|cff19e8ff"
                		..Volad[hh].."|cffff0000"..consig..strs[10]..entrena) end 
				end
			end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function Main() 				if C==1024 then return end  -- Gestor de monturas y mensajes nivel 70

	if L==70 then 		
		if H then l=1 w=76 AH=1 hh=3  else l=2 w=72 AH=2 hh=4 end

	if P:GetReputation(w) <= 2999 then			
		if Gold >= Rep_Cost[5] then 
			P:ModifyMoney(-Rep_Cost[5] ) P:LearnSpell(RidSkill[4]) P:LearnSpell(Voladora[hh]) P:SendBroadcastMessage("|cfffd7dff"..pag..ridc[5]..deoro..por.."|cff19e8ff"..RidSkill[9]
				.."|cfffd7dff"..y..hund..por.."|cff19e8ff"..Volad[hh].."|cfffd7dff.") else
				P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[9].."|cffff0000"..y.."|cff19e8ff"
                	..Volad[hh].."|cffff0000"..consig..strs[5]..entrena) end
			end

		if P:GetReputation(w) >= 3000 and P:GetReputation(w) <= 8900 then   K=5  kk=1
	elseif P:GetReputation(w) >= 9000 and P:GetReputation(w) <= 20999 then  K=6  kk=2
	elseif P:GetReputation(w) >= 21000 and P:GetReputation(w) <= 41999 then K=7  kk=3
	elseif P:GetReputation(w) >= 42000 then 								K=8  kk=4  end 

	if P:GetReputation(w) >= 3000 then 
		if Gold >= Rep_Cost[Repu(Q)] then 
				P:ModifyMoney(-(Rep_Cost[Repu(Q)])) P:LearnSpell(RidSkill[4]) P:LearnSpell(Voladora[hh])
				P:SendBroadcastMessage("|cfffd7dff"..pag..ridc[Repu(Q)]..deoro..descu60[K]..dedesc..AHVE[kk]..capit[AH]..por.."|cff19e8ff"..RidSkill[9]
				.."|cfffd7dff"..y..hund..por.."|cff19e8ff"..Volad[hh].."|cfffd7dff.") else
				P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff"..RidSkill[8].."|cffff0000"..y.."|cff19e8ff"
                	..Volad[hh].."|cffff0000"..consig..strs[Repu(Q)]..deoro..entrena) end end
		end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Llamada de métodos por nivel
	if L==20 or L==40 then if C==Pala or C==Bruj then if C==Pala then Paladin() else Brujo() end else RepartirMounts() Mensajes() end end
	if L==60 then if C==Drui then Druida() else RepartirMounts() end end
	if L==70 then if C==Drui then Druida() else Main() end end

-- Vuelo en clima fío
	if L==77 then if Gold >= 10000000 then P:ModifyMoney(-10000000) P:LearnSpell(RidSkill[5])
			P:SendBroadcastMessage("|cfffd7dff"..pag.."1000 de oro por |cff19e8ff[Vuelo en clima frío]|cfffd7dff.") 
		else 
			P:SendBroadcastMessage("|cffff0000"..insuf.."|cff19e8ff[Vuelo en clima frío]|cffff0000, consigue 1000 de oro y aprende esta habilidad en Dalaran.") end
	end	
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function Logeo(E,P) -- Mensaje cuando el jugador logea
	P:SendBroadcastMessage("Módulo |cff00ff0d[Munturas automáticas]|r corriendo.")
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterPlayerEvent(13, CambioDeNivel)
RegisterPlayerEvent(3, Logeo)
