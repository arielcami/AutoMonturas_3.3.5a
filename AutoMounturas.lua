--[[
    Ariel Camilo - Agosto 2023

    --> El script realiza el cobro de la habilidad en jinete y la montura, y enseña las spells.
    --> Para todo cobro, se calcula la reputación del jugador con la facción que vende la montura o la equitación, para aplicar el descuento correspondiente.
    --> Para calcular el descuento de las dos primeras monturas, se toma en cuenta la reputación "natural" del jugador, ej: Gnomo: Exiliados de Gnomeregan, Trol: Trols Lanza Negra.
    --> Para el descuento en el vuelo se calcula la reputación con Ventormenta/Orgrimmar, y para la montura Bastión del Honor/Thrallmar. Esto solo se hace al nivel 60 y 70.
    --> En todo caso, el jugador terminará pagando siempre lo mínimo posible.
    --> Casos especiales:
        Druida: Al nivel 60 y 70, se aprenden las formas voladoras, pero como estas spells se aprenden con el entrenador, se calcula el descuento con Darnassus/Cima del trueno.
        Paladín: Al 20 y al 40, el paladín aprende sus caballos, importante saber que estos caballos cuestan 35 de plata cada uno.
        Brujo: A diferencia del paladín, los caballos del brujo cuestan 1 y 10 de oro respectivamente.
]]

-- Control 
local SCRIPT_ON         =   true    --> Enciende/Apaga el Script
local SCRIPT_MESSAGE    =   true    --> Mensaje al logear.
local CHARGE_FOR_SPELL  =   true    --> Decide si se realiza el cobro por las Spells. 'false' para que sean gratis.

local links = {
    -- Habilidad de Equitación
    [33388] = "\124cff71d5ff\124Hspell:33388\124h[Aprendiz jinete]\124h\124r",   
    [33391] = "\124cff71d5ff\124Hspell:33391\124h[Oficial jinete]\124h\124r", 
    [34090] = "\124cff71d5ff\124Hspell:34090\124h[Experto jinete]\124h\124r",
    [34091] = "\124cff71d5ff\124Hspell:34091\124h[Artesano jinete]\124h\124r",
    [54197] = "\124cff71d5ff\124Hspell:54197\124h[Vuelo en clima frío]\124h\124r",
    -- Monturas Terrestres
    [23227] = "\124cff71d5ff\124Hspell:23227\124h[Palomino presto]\124h\124r",
    [458]   = "\124cff71d5ff\124Hspell:458\124h[Caballo marrón]\124h\124r",
    [13819] = "\124cff71d5ff\124Hspell:13819\124h[Caballo de guerra]\124h\124r",
    [23214] = "\124cff71d5ff\124Hspell:23214\124h[Destrero]\124h\124r",
    [5784]  = "\124cff71d5ff\124Hspell:5784\124h[Corcel vil]\124h\124r",
    [23161] = "\124cff71d5ff\124Hspell:23161\124h[Corcel nefasto]\124h\124r",
    [6777] = "\124cff71d5ff\124Hspell:6777\124h[Carnero gris]\124h\124r",
    [23239] = "\124cff71d5ff\124Hspell:23239\124h[Carnero gris presto]\124h\124r",
    [10793] = "\124cff71d5ff\124Hspell:10793\124h[Sable de la noche rayado]\124h\124r",
    [23338] = "\124cff71d5ff\124Hspell:23338\124h[Sable de la Tempestad presto]\124h\124r",
    [33943] = "\124cff71d5ff\124Hspell:33943\124h[Forma voladora]\124h\124r",
    [40120] = "\124cff71d5ff\124Hspell:40120\124h[Forma de vuelo presto]\124h\124r",
    [10969] = "\124cff71d5ff\124Hspell:10969\124h[Mecazancudo azul]\124h\124r",
    [23223] = "\124cff71d5ff\124Hspell:23223\124h[Mecazancudo blanco presto]\124h\124r",
    [34406] = "\124cff71d5ff\124Hspell:34406\124h[Elekk marrón]\124h\124r",
    [35714] = "\124cff71d5ff\124Hspell:35714\124h[Gran elekk morado]\124h\124r",
    [580]   = "\124cff71d5ff\124Hspell:580\124h[Lobo gris]\124h\124r",
    [23252] = "\124cff71d5ff\124Hspell:23252\124h[Lobo grisáceo presto]\124h\124r",
    [17462] = "\124cff71d5ff\124Hspell:17462\124h[Caballo esquelético rojo]\124h\124r",
    [17465] = "\124cff71d5ff\124Hspell:17465\124h[Caballo de guerra esquelético verde]\124h\124r",
    [18990] = "\124cff71d5ff\124Hspell:18990\124h[Kodo marrón]\124h\124r",
    [23249] = "\124cff71d5ff\124Hspell:23249\124h[Gran kodo marrón]\124h\124r",
    [8395] = "\124cff71d5ff\124Hspell:8395\124h[Raptor esmeralda]\124h\124r",
    [23243] = "\124cff71d5ff\124Hspell:23243\124h[Raptor naranja presto]\124h\124r",
    [34769] = "\124cff71d5ff\124Hspell:34769\124h[Invocar caballo de guerra]\124h\124r",
    [34767] = "\124cff71d5ff\124Hspell:34767\124h[Invocar destrero]\124h\124r",
    [35022] = "\124cff71d5ff\124Hspell:35022\124h[Halcón zancudo negro]\124h\124r",
    [35027] = "\124cff71d5ff\124Hspell:35027\124h[Halcón zancudo morado presto]\124h\124r",
    -- Monturas Voladoras
    [32235] = "\124cff71d5ff\124Hspell:32235\124h[Grifo dorado]\124h\124r",
    [32242] = "\124cff71d5ff\124Hspell:32242\124h[Grifo azul presto]\124h\124r",
    [32243] = "\124cff71d5ff\124Hspell:32243\124h[Jinete del viento leonado]\124h\124r",
    [32246] = "\124cff71d5ff\124Hspell:32246\124h[Jinete del viento rojo presto]\124h\124r"}

    local function RANK (p,f) return p:GetReputationRank(f) end --> Retorna enteros: Neutral = 3 | Exaltado = 7
    
    local function COEF (p,f)                 
        local mult = {1, 1, 1, 0.95, 0.9, 0.85, 0.8}    --> Coeficientes para multiplicar por el costo de las monturas y Jinete.
        return mult[RANK(p,f)]          --> Retorna 1, 0.95, 0.9, 0.85 y 0.8 según el rango de reputación.
    end

    local function LEVEL_ADD(l)
        local amount = 0
        if l==40 then amount=6 end      --> Al nivel 40, se saltan 6 espacios al leer las columnas den la DB.
        if l==60 then amount=12 end     --> Se saltan 12 espacios al nivel 60.
        if l==70 then amount=18 end     --> Se saltan 18 espacios al nivel 70.
        return amount
    end

local function ON_LEVEL_CHANGE(e, P, previousLevel)         
    
    if not SCRIPT_ON then return end

    local function LEARN(spell)  if not P:HasSpell(spell) then  P:LearnSpell(spell)  end end
    local function B(txt) P:SendBroadcastMessage(txt) end

    local function TIMED(Unit, sp_link) --> Para asegurarnos de mandar un mensaje al final del chat.
        local function timed(ev, d, r, O) 
            O:SendBroadcastMessage("|CFF00FF00[|cffffffffAutoMounts|cff00ff00]: Has aprendido "..sp_link) 
        end 
        Unit:RegisterEvent(timed, 150) 
    end

    local CHECK_LEVEL = function(L) return L==20 or L==40 or L==60 or L==70 or L==77 end --> Estas comparaciones retornan booleanos.

    if CHECK_LEVEL(P:GetLevel()) then

        local R, C, L = P:GetRaceMask(), P:GetClassMask(), P:GetLevel()
        local sql = string.format("SELECT * FROM auto_mounts WHERE player_race = %d AND player_class = %d", R, C)

        if L==77 then 
            if CHARGE_FOR_SPELL then
                if P:GetCoinage() >= 10000000 then 
                    LEARN(54197)
                    TIMED(P, links[54197].." |cff00ff00por 1000 de oro.")
                    P:ModifyMoney(-10000000)
                else 
                    B("|cff00ff00[|cffffffffAutoMounts|cff00ff00]: |cffff0000No tienes dinero para entrenar Vuelo en clima frío.")
                end
            else
                LEARN(54197)
                TIMED(P, links[54197])
            end
            return
        end

        local DB = WorldDBQuery(sql)     
        -- Cositas que traemos desde la Base de Datos --
        local ridingSpell   = DB:GetUInt16(2 + LEVEL_ADD(L)) --> Aquí se leen diferentes columnas de acuerdo al nivel.
        local mountSpell    = DB:GetUInt16(3 + LEVEL_ADD(L))
        local ridingPrice   = DB:GetUInt32(4 + LEVEL_ADD(L))
        local mountPrice    = DB:GetUInt32(5 + LEVEL_ADD(L))
        local reqRepRiding  = DB:GetUInt16(6 + LEVEL_ADD(L))
        local reqRepMount   = DB:GetUInt16(7 + LEVEL_ADD(L))
        -- Calculamos los descuentos, en caso de aplicar --
        local ridingDiscount = ridingPrice * COEF(P, reqRepRiding)  --> Coeficiente para obtener descuento en el precio de Jinete.
        local mountDiscount = mountPrice * COEF(P, reqRepMount)     --> Coeficiente para obtener descuento en la compra de la monutra.
        local total = ridingDiscount + mountDiscount

        if CHARGE_FOR_SPELL then
            if P:GetCoinage() >= total then 
                LEARN(ridingSpell)
                LEARN(mountSpell)
                TIMED(P, links[ridingSpell].." |cff00ff00por "..(ridingDiscount/10000).." de oro.")    --> Mensaje de que ha aprendido el Riding
                if mountDiscount >= 10000 then 
                    TIMED(P, links[mountSpell].." |cff00ff00por "..(mountDiscount/10000).." de oro.")  --> Mensaje de que ha aprendido la Montura
                else -- Si la montura costó menos de 1 oro.
                    TIMED(P, links[mountSpell].." |cff00ff00por "..(mountDiscount/100).." de plata.")  --> Mensaje de que ha aprendido la Montura
                end
                P:ModifyMoney(-total)
            else
                if P:GetCoinage() >= ridingDiscount then     
                    LEARN(ridingSpell)
                    TIMED(P, links[ridingSpell].."|cff00ff00 por "..(ridingDiscount/10000).." de oro.".." |cffff0000Pero te faltó dinero para tu montura.")
                    P:ModifyMoney(-ridingDiscount)
                else
                    B("|cff00ff00[|cffffffffAutoMounts|cff00ff00]: |cffff0000No tienes dinero para entrenar equitación ni comprar la montura.")
                end
            end
        else 
            LEARN(ridingSpell)
            LEARN(mountSpell)
            TIMED(P, links[ridingSpell]) 
            TIMED(P, links[mountSpell]) 
        end
    end
end
RegisterPlayerEvent(13, ON_LEVEL_CHANGE)

local function ON_LOGIN(e,P)
    if SCRIPT_ON and SCRIPT_MESSAGE then P:SendBroadcastMessage("|cff00ff00MonturasAutomáticas|r funcionando.") end
end
RegisterPlayerEvent(3,  ON_LOGIN)
