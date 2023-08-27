--[[
    Ariel Camilo - Agosto 2023
    En ningún momento este Script fue concebido para regalar monturas, sino para ahorrar el tiempo de ir a comprarlas.

    -> El jugador aprende la montura y la habilidad en jinete correspondientes, pero también aplica el cobro correspondiente.
    -> Para todo cobro, se calcula la reputación con la facción de la que se obtiene la Equitación o la montura.
    Ejemplo:
        Al nivel 20 y 40, Un Humano, para comprar Equitación con descuento, debe tener reputación con Ventormenta.
        igualmente para comprar una montura con descuento, debe tener reputación con Ventormenta.
        Pero al nivel 60 esto cambia.
        El descuento de la Equitación se obtiene con Ventormenta,
        Pero el descuento para la montura voladora es con Bastión del Honor.

    -> Paladines y Brujos, obtienen sus monturas de clase, en lugar de las munturas genéricas.
    -> Druidas obtienen las 2 formas voladoras, en lugar de las monturas voladoras genéricas.
]]

-- Control
local SCRIPT_ON         =   true
local SCRIPT_MESSAGE    =   true

local repPerRace = {-- IDs de las reputaciones que venden monturas terrestres, ofrecen descuento con amistoso+
    [20]={--> Nivel -> Raza -> ID de la reputación
        [1]     = 72,   -- Humano:              Ventormenta
        [2]     = 76,   -- Orco:                Orgrimmar
        [4]     = 47,   -- Enano:               Forjaz
        [8]     = 69,   -- Elfo de la Noche:    Darnassus
        [16]    = 68,   -- No-Muerto:           Entrañas
        [32]    = 81,   -- Tauren:              Cima del Trueno
        [64]    = 54,   -- Gnomo:               Exiliados de Gnomeregan
        [128]   = 530,  -- Trol:                Trols Lanza Negra
        [512]   = 911,  -- Elfo de Sangre:      Ciudad de Lunargenta
        [1024]  = 930}, -- Draenei:             El Exodar
    [40]={[1]=72,[2]=76,[4]=47,[8]=69,[16]=68,[32]=81,[64]=54,[128]=530,[512]=911,[1024]=930}, --> Es lo mismo que la tabla 20
    [60]={--> Nivel -> Facción -> {Capital, Vendedor Montura Voladora}
        [1]={72,946},   -- Alianza, {Ventormenta, Bastión del Honor}
        [2]={76,947}},  -- Horda, {Orgrimmar, Thrallmar} 
    [70]={[1]={72,946},[2]={76,947}}}       --> Es lo mismo que la tabla 60   
        
local mount = {-- Nivel -> Raza -> {ID de las monturas (Spell), Costo}
    [20]={
        [1]={458,10000},
        [2]={580,10000},
        [4]={6777,10000},
        [8]={66847,10000},
        [16]={17462,10000},
        [32]={18990,10000},
        [64]={10969,10000},
        [128]={8395,10000},
        [512]={35022,10000},
        [1024]={34406,10000}},
    [40]={
        [1]={23227,100000},
        [2]={23252,100000},
        [4]={23239,100000},
        [8]={23338,100000},
        [16]={17465,100000},
        [32]={23249,100000},
        [64]={23223,100000},
        [128]={23243,100000},
        [512]={35027,100000},
        [1024]={35714,100000}},
    [60]={
        [1]={32235,500000},
        [2]={32243,500000},
    },
    [70]={
        [1]={32242,1000000},
        [2]={32246,1000000}
    }
}

local riding = {-- Nivel -> {SpellID, Precio}, link
    [20] = {33388, 40000,       "\124cff71d5ff\124Hspell:33388\124h[Aprendiz jinete]\124h\124r"},
    [40] = {33391, 500000,      "\124cff71d5ff\124Hspell:33391\124h[Oficial jinete]\124h\124r"},
    [60] = {34090, 2500000,     "\124cff71d5ff\124Hspell:34090\124h[Experto jinete]\124h\124r"},
    [70] = {34091, 50000000,    "\124cff71d5ff\124Hspell:34091\124h[Artesano jinete]\124h\124r"},
    [77] = {54197, 10000000,    "\124cff71d5ff\124Hspell:54197\124h[Vuelo en clima frío]\124h\124r"}
}

local link = {
    [20] = {
        [1]="\124cff71d5ff\124Hspell:458\124h[Caballo marrón]\124h\124r",
        [2]="\124cff71d5ff\124Hspell:580\124h[Lobo gris]\124h\124r",
        [4]="\124cff71d5ff\124Hspell:6777\124h[Carnero gris]\124h\124r",
        [8]="\124cff71d5ff\124Hspell:66847\124h[Sable del Alba rayado]\124h\124r",
        [16]="\124cff71d5ff\124Hspell:17462\124h[Caballo esquelético rojo]\124h\124r",
        [32]="\124cff71d5ff\124Hspell:18990\124h[Kodo marrón]\124h\124r",
        [64]="\124cff71d5ff\124Hspell:10969\124h[Mecazancudo azul]\124h\124r",
        [128]="\124cff71d5ff\124Hspell:8395\124h[Raptor esmeralda]\124h\124r",
        [512]="\124cff71d5ff\124Hspell:35022\124h[Halcón zancudo negro]\124h\124r",
        [1024]="\124cff71d5ff\124Hspell:34406\124h[Elekk marrón]\124h\124r"},
    [40] = {
        [1]="\124cff71d5ff\124Hspell:23227\124h[Palomino presto]\124h\124r",
        [2]="\124cff71d5ff\124Hspell:23252\124h[Lobo grisáceo presto]\124h\124r",
        [4]="\124cff71d5ff\124Hspell:23239\124h[Carnero gris presto]\124h\124r",
        [8]="\124cff71d5ff\124Hspell:23338\124h[Sable de la Tempestad presto]\124h\124r",
        [16]="\124cff71d5ff\124Hspell:17465\124h[Caballo de guerra esquelético verde]\124h\124r",
        [32]="\124cff71d5ff\124Hspell:23249\124h[Gran kodo marrón]\124h\124r",
        [64]="\124cff71d5ff\124Hspell:23223\124h[Mecazancudo blanco presto]\124h\124r",
        [128]="\124cff71d5ff\124Hspell:23243\124h[Raptor naranja presto]\124h\124r",
        [512]="\124cff71d5ff\124Hspell:35027\124h[Halcón zancudo morado presto]\124h\124r",
        [1024]="\124cff71d5ff\124Hspell:35714\124h[Gran elekk morado]\124h\124r"},
    [60] = {
        [1]="\124cff71d5ff\124Hspell:32235\124h[Grifo dorado]\124h\124r",
        [2]="\124cff71d5ff\124Hspell:32243\124h[Jinete del viento leonado]\124h\124r"}, 
    [70] = {
        [1]="\124cff71d5ff\124Hspell:32242\124h[Grifo azul presto]\124h\124r",
        [2]="\124cff71d5ff\124Hspell:32246\124h[Jinete del viento rojo presto]\124h\124r"}
}

    local function RANK(player, faction) return player:GetReputationRank(faction) end   --> Retorna enteros: Neutral = 3 | Exaltado = 7
    local function COEF(player, faction)                                                --> Retorna 1, 0.95, 0.9, 0.85 y 0.8 según el rango de reputación.
        local percentages = {1, 1, 1, 0.95, 0.9, 0.85, 0.8} --> Coeficientes para multiplicar por el costo de las monturas y Jinete.
        return percentages[RANK(player,faction)]
    end

local function ON_LEVEL_CHANGE(e, P, previousLevel)

    if not SCRIPT_ON then return end

    local function LEARN(spell)  if not P:HasSpell(spell) then  P:LearnSpell(spell)  end end
    local function B(txt) P:SendBroadcastMessage(txt) end

    local function TIMED(Unit, spell_link) --> Para asegurarnos de mandar un mensaje al final del chat.
        local function timed(ev, d, r, O) 
            O:SendBroadcastMessage("|CFF00FF00Has aprendido "..spell_link) 
        end 
        Unit:RegisterEvent(timed, 150) 
    end

    local r, A = P:GetRaceMask(), P:IsAlliance()
    local mount_special_pala_20, mount_special_pala_40 = A and 13819 or 34769, A and 23214 or 34767 --> Asignamos los IDs del caballo Alianza u Horda.
    local message_20_pala = A and "\124cff71d5ff\124Hspell:13819\124h[Caballo de guerra]\124h\124r" or "\124cff71d5ff\124Hspell:34769\124h[Invocar caballo de guerra]\124h\124r"
    local message_40_pala = A and "\124cff71d5ff\124Hspell:23214\124h[Destrero]\124h\124r" or "\124cff71d5ff\124Hspell:34767\124h[Invocar destrero]\124h\124r"
    local message_20_warl = "\124cff71d5ff\124Hspell:5784\124h[Corcel vil]\124h\124r"
    local message_40_warl = "\124cff71d5ff\124Hspell:23161\124h[Corcel nefasto]\124h\124r"
    local message_60_drui = "\124cff71d5ff\124Hspell:33943\124h[Forma voladora]\124h\124r"
    local message_70_drui = "\124cff71d5ff\124Hspell:40120\124h[Forma de vuelo presto]\124h\124r"

    local special = { --> Solo utilizaremos para las monturas de los Paladines y Brujos nivel 20 y 40, y las formas voladores del Druida.
        Paladin = function(p,lev)
            if lev==20 then            
                local riding_Pala, mount_Pala = riding[lev][2]*COEF(p, repPerRace[lev][r]),  3500*COEF(p, repPerRace[lev][r]) --El Caballo de Paladín nivel 20, cuesta 35 de plata.
                local total = riding_Pala + mount_Pala    
                if p:GetCoinage()>= total then  --> Se accede aquí si el jugador cuenta con el dinero suficiente para aprender las dos cosas.
                    LEARN(riding[lev][1])           -- Se aprende la habilidad en Jinete
                    LEARN(mount_special_pala_20)    -- Se aprende el Caballo de Paladín nivel 20. Este ID cambia según sea Horda o Alianza.       
                    TIMED(p, riding[lev][3].." |cff00ff00por "..(riding_Pala/10000).." de oro.")    --> Mensaje de que ha aprendido el Riding
                    TIMED(p, message_20_pala.." |cff00ff00por "..(mount_Pala/100).." de plata.")    --> Mensaje de que ha aprendido la Montura
                    p:ModifyMoney(-total)
                else    --> Si el jugador no tiene el dinero para aprender las dos cosas, puede que tenga para aprender solo una.
                    if p:GetCoinage()>= riding_Pala then
                        LEARN(riding[lev][1])
                        TIMED(p, riding[lev][3].." |cff00ff00por "..(riding_Pala/10000).." de oro. |cffff0000Pero te faltó dinero para tu montura.")
                        p:ModifyMoney(-riding_Pala)
                    else
                        B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.") 
                    end                   
                end    
            end
            if lev==40 then             
                local riding_Pala, mount_Pala = riding[lev][2]*COEF(p, repPerRace[lev][r]),  3500*COEF(p, repPerRace[lev][r]) --El Caballo de Paladín nivel 40, cuesta 35 de plata.
                local total = riding_Pala + mount_Pala    
                if p:GetCoinage()>= total then 
                    LEARN(mount_special_pala_40) 
                    LEARN(riding[lev][1])
                    TIMED(p, riding[lev][3].." |cff00ff00por "..(riding_Pala/10000).." de oro.")          
                    TIMED(p, message_40_pala.." |cff00ff00por "..(mount_Pala/100).." de plata.")    
                    p:ModifyMoney(-total)
                else 
                    if p:GetCoinage()>= riding_Pala then
                        LEARN(riding[lev][1])
                        TIMED(p, riding[lev][3].." |cff00ff00por "..(riding_Pala/10000).." de oro. |cffff0000Pero te faltó dinero para tu montura.")
                        p:ModifyMoney(-riding_Pala)
                    else
                        B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.") 
                    end 
                end    
            end
        end,
        Warlock = function(p,lev)
            if lev==20 then             
                local riding_Warl, mount_Warl = riding[lev][2]*COEF(p, repPerRace[lev][r]),  10000*COEF(p, repPerRace[lev][r])--> El Corcel Vil cuesta 1 de oro.
                local total = riding_Warl + mount_Warl    
                if p:GetCoinage()>= total then 
                    LEARN(5784) 
                    LEARN(riding[lev][1])
                    TIMED(p, riding[lev][3].." |cff00ff00por "..(riding_Warl/10000).." de oro.")    
                    TIMED(p, message_20_warl.." |cff00ff00por "..(mount_Warl/10000).." de oro.") 
                    p:ModifyMoney(-total)
                else 
                    if p:GetCoinage()>= riding_Warl then
                        LEARN(riding[lev][1])
                        TIMED(p, message_20_warl.." |cff00ff00por "..(riding_Warl/10000).." de oro. |cffff0000Pero te faltó dinero para tu montura.")
                        p:ModifyMoney(-riding_Warl)
                    else
                        B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.") 
                    end 
                end    
            end
            if lev==40 then             
                local riding_Warl, mount_Warl = riding[lev][2]*COEF(p, repPerRace[lev][r]),  100000*COEF(p, repPerRace[lev][r])--> El Corcel Nefasto cuesta 10 de oro.
                local total = riding_Warl + mount_Warl    
                if p:GetCoinage()>= total then 
                    LEARN(23161) 
                    LEARN(riding[lev][1])
                    TIMED(p, riding[lev][3].." |cff00ff00por "..(riding_Warl/10000).." de oro.")    
                    TIMED(p, message_40_warl.." |cff00ff00por "..(mount_Warl/10000).." de oro.")
                    p:ModifyMoney(-total)
                else 
                    if p:GetCoinage()>= riding_Warl then
                        LEARN(riding[lev][1])
                        TIMED(p, message_40_warl.." |cff00ff00por "..(riding_Warl/10000).." de oro. |cffff0000Pero te faltó dinero para tu montura.")
                        p:ModifyMoney(-riding_Warl)
                    else
                        B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.") 
                    end
                end    
            end
        end,
        Druid = function(p,lev) 
            local AH = A and 1 or 2
            if lev==60 then
                local riding_Drui, mount_Drui = riding[lev][2]*COEF(p, repPerRace[lev][AH][1]),  34000*COEF(p, repPerRace[20][r])
                local total = riding_Drui + mount_Drui 
                if p:GetCoinage() >= total then 
                    LEARN(riding[lev][1])
                    LEARN(33943) -- Forma Voladora 
                    TIMED(p, riding[lev][3].."|cff00ff00 por "..(riding_Drui/10000).." de oro.")    
                    TIMED(p, message_60_drui.."|cff00ff00 por "..(mount_Drui/10000).." de oro.")   
                    p:ModifyMoney(-total)
                else 
                    if p:GetCoinage()>= riding_Drui then
                        LEARN(riding[lev][1])
                        TIMED(p, riding[lev][3].."|cff00ff00 por "..(riding_Drui/10000).." de oro. |cffff0000Pero te faltó dinero para tu montura.")
                        p:ModifyMoney(-riding_Drui)
                    else
                        B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.") 
                    end
                end
            end
            if lev==70 then
                local riding_Drui, mount_Drui = riding[lev][2]*COEF(p, repPerRace[lev][AH][1]),  200000*COEF(p, repPerRace[20][r])
                local total = riding_Drui + mount_Drui 
                if p:GetCoinage() >= total then 
                    LEARN(riding[lev][1])
                    LEARN(40120) -- Forma de Vuelo Presto 
                    TIMED(p, riding[lev][3].."|cff00ff00 por "..(riding_Drui/10000).." de oro.")    
                    TIMED(p, message_70_drui.."|cff00ff00 por "..(mount_Drui/10000).." de oro.")   
                    p:ModifyMoney(-total)
                else 
                    if p:GetCoinage()>= riding_Drui then
                        LEARN(riding[lev][1])
                        TIMED(p, riding[lev][3].."|cff00ff00 por "..(riding_Drui/10000).." de oro. |cffff0000Pero te faltó dinero para tu montura.")
                        p:ModifyMoney(-riding_Drui)
                    else
                        B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.") 
                    end
                end
            end
        end
    }
    
    local l, c = P:GetLevel(), P:GetClassMask()
    local CHECK_LEVEL = function(L) return L==20 or L==40 or L==60 or L==70 or L==77 end --> Estas comparaciones retornan booleanos.

    if CHECK_LEVEL(l) then

        if l==77 then --> Vuelo en clima frío ---------------------------------------------------------------------
            local COLD_FLIGHT_SPELL, COLD_FLIGHT_PRICE, COLD_FLIGHT_LINK = riding[l][1], riding[l][2], riding[l][3]
            if P:GetCoinage() >= COLD_FLIGHT_PRICE then
                LEARN(COLD_FLIGHT_SPELL)
                TIMED(P, COLD_FLIGHT_LINK.." |cff00ff00por "..(COLD_FLIGHT_PRICE/10000).." de oro.")
                P:ModifyMoney(-COLD_FLIGHT_PRICE)
            else
                B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar Vuelo en clima frío.")
            end
        end -------------------------------------------------------------------------------------------------------

        if l==20 or l==40 then

            if c==2 or c==256 then --Paladines y Brujos: Caballos 20 y 40.               
                if c==2 then special.Paladin(P,l) end
                if c==256 then special.Warlock(P,l) end
                return 
            end-----------------------------------------------------------
            
            local ridingRealPrice = riding[l][2]                    --> Precio de la habilidad en Jinete sin aplicar descuentos.
            local mountRealPrice = mount[l][r][2]                   --> Precio de la montura sin aplicar descuentos.
            local ridingDiscount = COEF(P, repPerRace[l][r])        --> Coeficiente para obtener descuento en el precio de Jinete.
            local mountDiscount = COEF(P, repPerRace[l][r])         --> Coeficiente para obtener descuento en la compra de la monutra.

            local ridingTotal = (ridingRealPrice * ridingDiscount)  --> Precio total por la habilidad en Jinete, con el descuento aplicado.
            local mountTotal = (mountRealPrice * mountDiscount)     --> Precio total por la montura, con el descuento aplicado.

            if P:GetCoinage() >= ridingTotal + mountTotal then  --> El jugador tiene el dinero suficiente
            
                local RIDING_SPELL_ID, MOUNT_SPELL_ID = riding[l][1], mount[l][r][1]
      
                LEARN(RIDING_SPELL_ID)
                LEARN(MOUNT_SPELL_ID)
                TIMED(P, riding[l][3].." |cff00ff00por "..(ridingTotal/10000).." de oro.")    --> Mensaje de que ha aprendido el Riding
                TIMED(P, link[l][r].." |cff00ff00por "..(mountTotal/10000).." de oro.")       --> Mensaje de que ha aprendido la Montura

                local total = ridingTotal + mountTotal
                P:ModifyMoney(-total)
            else --> El jugador no tiene la sumatoria de los dos precios, pero quizá pueda pagar el riding.
                
                if P:GetCoinage() >= ridingTotal then 
                    
                    local RIDING_SPELL_ID = riding[l][1]

                    LEARN(RIDING_SPELL_ID)
                    TIMED(P, riding[l][3].."|cff00ff00 por "..(ridingTotal/10000).." de oro.".." |cffff0000Pero te faltó dinero para tu montura.")
                    P:ModifyMoney(-ridingTotal)
                else
                    B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.")
                end
            end
        end
        
        if l==60 or l==70 then 

            if c==1024 then special.Druid(P,l) return end

            local F = P:IsAlliance() and 1 or 2

            local ridingRealPrice = (riding[l][2])              --> Precio de la habilidad en Jinete sin aplicar descuentos.
            local mountRealPrice = mount[l][F][2]               --> Precio de la montura sin aplicar descuentos. Solo voladoras Bastión/Thrallmar
            local ridingDiscount = COEF(P, repPerRace[l][F][1]) --> Se calcula en descuento en función de la reputación con Ventormenta/Orgrimmar
            local mountDiscount = COEF(P, repPerRace[l][F][2])  --> Se calcula en descuento en función de la reputación con Bastión/Thrallmar

            -- Al 60 y 70 cambia las reputacion con las que se obtienen descuentos
            local ridingTotal = (ridingRealPrice * ridingDiscount)    --> Reputación con Ventormenta/Orgrimmar
            local mountTotal = (mountRealPrice * mountDiscount)       --> Reputación con Bastión del Honor/Thrallmar

            if P:GetCoinage() >= ridingTotal + mountTotal then 
                --> El jugador tiene el dinero suficiente para comprar todo.
                local RIDING_SPELL_ID, MOUNT_SPELL_ID = riding[l][1], mount[l][F][1]
     
                LEARN(RIDING_SPELL_ID)
                LEARN(MOUNT_SPELL_ID)

                TIMED(P, riding[l][3].."|cff00ff00 por "..(ridingTotal/10000).." de oro.")    
                TIMED(P, link[l][F].."|cff00ff00 por "..(mountTotal/10000).." de oro.")       

                local total = ridingTotal + mountTotal
                P:ModifyMoney(-total)
            else
                --> El jugador no tiene la sumatoria de los dos valores, pero quizá pueda pagar el riding.
                if P:GetCoinage() >= ridingTotal then

                    local RIDING_SPELL_ID = riding[l][1]

                    LEARN(RIDING_SPELL_ID)
                    TIMED(P, riding[l][3].."|cff00ff00 por "..(ridingTotal/10000).." de oro.".." |cffff0000Pero te faltó dinero para tu montura.") 
                    P:ModifyMoney(-ridingTotal)
                else
                    -- Aunque tenga dinero para pagar la montura, primero debe pagar el riding.
                    B("|cff00ff00[AutoMounts]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.")
                end
            end
        end    
    end
end

local function ON_LOGIN(e,P)
    if SCRIPT_ON and SCRIPT_MESSAGE then P:SendBroadcastMessage("|cff00ff00MonturasAutomáticas|r funcionando.") end
end
RegisterPlayerEvent(13, ON_LEVEL_CHANGE)
RegisterPlayerEvent(3,  ON_LOGIN)
