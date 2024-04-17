--- STEAMODDED HEADER
--- MOD_NAME: Mor jokers
--- MOD_ID: morjkrs
--- MOD_AUTHOR: [Morpline, Blizzow]
--- MOD_DESCRIPTION: Adds mor jokers. Thanks to Blizzow for the joker code. Idk if he was the original author, but I stole it from him. 

----------------------------------------------
------------MOD CODE -------------------------


---UTILITY METHODS---
function destroyCard(self,sound)
    G.E_MANAGER:add_event(Event({
        func = function()
            play_sound(sound, math.random()*0.2 + 0.9,0.5)
            self.T.r = -0.2
            self:juice_up(0.3, 0.4)
            self.states.drag.is = true
            self.children.center.pinch.x = true
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                func = function()
                        G.jokers:remove_card(self)
                        self:remove()
                        self = nil
                    return true; end})) 
            return true
        end
    })) 
    self.gone = true
end

function shakecard(self)
    G.E_MANAGER:add_event(Event({
        func = function()
            self:juice_up(0.5, 0.5)
            return true
        end
    }))
end
function fakemessage(_message,_card,_colour)
    G.E_MANAGER:add_event(Event({ trigger = 'after',delay = 0.15,       
        func = function() card_eval_status_text(_card, 'extra', nil, nil, nil, {message = _message, colour = _colour, instant=true}); return true
        end}))
    return
end


function poll_enhancement(seed)
    local enhancements = {}
    --add all enhancements but m_stone to list
    for k, v in pairs() do
        if v.key ~= 'm_stone' then 
            enhancements[#enhancements+1] = v
        end
    end
    return pseudorandom_element(enhancements, pseudoseed(seed))
end

function poll_seal(seed)
    local seals = {}
    for k, v in pairs(G.P_SEALS) do
        seals[#seals+1] = v
    end
    return pseudorandom_element(seals, pseudoseed(seed)).key
end

function poll_FromTable(_table,seed,filter)
    local items = {}    
    for k, v in pairs(_table) do
        if v.key ~= filter then
            items[#items+1] = v
        end        
    end
    return pseudorandom_element(items, pseudoseed(seed))
end


function addjoker(joker)
    local card = create_card('Joker', G.jokers, nil, 0, nil, nil, joker, nil)
    card:add_to_deck()
    G.jokers:emplace(card)
    G.GAME.used_jokers[joker] = true
end
mpjokers = {}
mpcards = {}
function calcMPjokers()
    for k, v in pairs(G.P_CENTERS) do
        -- print("morjokers.lua","looking at "..k)
        if not (string.find(k,"j_") == nil) then
            print("morjokers.lua","adding"..k.."to mpjokers")
            table.insert(mpjokers,k)
        end
    end
end

local jokers = {
    copymachine = {
        name = "Copy Machine",
        text = {
            "Randomly copies the effects of your",
            "other {C:attention}Jokers{}"
		},
		ability = {extra={name = "Copy Machine"}},
		pos = { x = 1, y = 0 },
        rarity=1,
        cost = 6,
        blueprint_compat=true,
        eternal_compat=true,
        effect=nil,
        soul_pos=nil,
        calculate = function(self,context)
            if self.ability.set == "Joker" and not self.debuff then
                local other_joker = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == self then other_joker = G.jokers.cards[math.random(1,#G.jokers.cards)] end
                end
                if other_joker and other_joker ~= self then
                    self.ability.extra.name= other_joker.ability.name
                    context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                    context.blueprint_card = context.blueprint_card or self
                    if context.blueprint > #G.jokers.cards + 1 then return end
                    local other_joker_ret = other_joker:calculate_joker(context)
                    if other_joker_ret then 
                        other_joker_ret.card = context.blueprint_card or self
                        other_joker_ret.colour = G.C.BLUE
                        return other_joker_ret
                    end
                end
            end
        end,
        loc_def=function(self)
            return {self.ability.extra.name}
        end        
	},
    mysteryportal = {
        name = "Mystery Portal",
        text = {
            "Does something random based on other",
            "{C:attention}Jokers{}",
            "Prepare for a lot of clicking..."
		},
		ability = {extra={name = "Mystery Portal"}},
		pos = { x = 6, y = 4 },
        rarity=1,
        cost = 4,
        blueprint_compat=false,
        eternal_compat=true,
        effect=nil,
        soul_pos=nil,
        calculate = function(self,context)
            if self.ability.set == "Joker" and not self.debuff then
                local other_joker = mpjokers[math.random(1,#mpjokers)]
                -- print(" morjokers mp copying out of "..tostring(#mpjokers),other_joker)
                if other_joker then
                    -- fakemessage(G.P_CENTERS[other_joker].name,self,G.C.BLUE)
                    self.ability.extra.name= G.P_CENTERS[other_joker].name
                    context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
                    context.blueprint_card = context.blueprint_card or self
                    -- if context.blueprint > #G.jokers.cards + 1 then return end
                    oj = mpcards[other_joker]
                    if oj == nil then
                        oj = Card(0,0,0,0,self,G.P_CENTERS[other_joker])
                        -- table.insert(cards,oj)
                        mpcards[other_joker] = oj
                    end
                    local other_joker_ret = oj:calculate_joker(context)
                    
                    if other_joker_ret then 
                        other_joker_ret.card = context.blueprint_card or self
                        other_joker_ret.colour = G.C.BLUE
                        return other_joker_ret
                    end
                else
                    fakemessage("Error!",self,G.C.RED)

                end
            end
        end,
        loc_def=function(self)
            return {self.ability.extra.name}
        end        
	},
}
function SMODS.INIT.MorJokers()
    calcMPjokers()
    --Create and register jokers
    for k, v in pairs(jokers) do
        local joker = SMODS.Joker:new(v.name, k, v.ability, v.pos, { name = v.name, text = v.text }, v.rarity, v.cost, true, true, v.blueprint_compat, v.eternal_compat, v.effect, "MorJokers",v.soul_pos)
        -- SMODS.Joker:new(name, slug, config, spritePos, tloc_tx, rarity, cost, unlocked, discovered, blueprint_compat, eternal_compat, effect, atlas, soul_pos)
        joker:register()
        --added calculate function into jokers to make code cleaner
        SMODS.Jokers[joker.slug].calculate=v.calculate
        --added loc_def function into jokers to make code cleaner
        SMODS.Jokers[joker.slug].loc_def=v.loc_def
        if(v.tooltip ~= nil) then
            SMODS.Jokers[joker.slug].tooltip=v.tooltip
        end
    end
    --Create sprite atlas
    SMODS.Sprite:new("MorJokers", SMODS.findModByID("morjkrs").path, "MorJokers.png", 71, 95, "asset_atli"):register()
end	
----------------------------------------------
------------MOD CODE END----------------------
