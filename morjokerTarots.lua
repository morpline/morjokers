--- STEAMODDED HEADER
--- MOD_NAME: Mor Joker Tarots
--- MOD_ID: morjokerTarots
--- MOD_AUTHOR: [Morpline, Blizzow]
--- MOD_DESCRIPTION: Adds Tarot {C:attention}Jokers{} Crash Reports are set to Off. If you would like to send crash reports, please opt in in the Game settings.\nThese crash reports help us avoid issues like this in the future

----------------------------------------------
------------MOD CODE -------------------------

----------------------------------------------
-------------------UTIL-----------------------

function addjoker(joker,negative)
    local card = create_card('Joker', G.jokers, nil, 0, nil, nil, joker, nil)
    if negative~=nil then
        card:set_edition({negative = true})
    end
    card:add_to_deck()
    G.jokers:emplace(card)
    G.GAME.used_jokers[joker] = true
end

function fakemessage(_message,_card,_colour)
    G.E_MANAGER:add_event(Event({ trigger = 'after',delay = 0.15,       
        func = function() card_eval_status_text(_card, 'extra', nil, nil, nil, {message = _message, colour = _colour, instant=true}); return true
        end}))
    return
end


-- SMODS.Tarot:new(name, slug, config, pos, loc_txt, cost, cost_mult, effect, consumeable, discovered, atlas)

local tarots = {
    portaljar = {
        name = "Portal Jar",
        text = {
            "Creates a {C:attention}Mysterious Portal",
            "{C:red}Enjoy!",
            "{C:inactive}Will create regardless of room.",
		},
		config = {},
		pos = { x = 6, y = 5 },
        cost = 3,
        cost_mult = 1,
        effect=nil,
        consumable=true,
        discovered=true,
        can_use = function() 
            return true
        end,
        use = function(self, area, copier)
            if self.ability.name == 'Portal Jar' then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('polychrome1')
                    addjoker("j_mysteryportal")
                    self:juice_up(0.3, 0.5)
                    return true end }))
                delay(0.6)
            end
        end      
	},
    coolhat = {
        name = "Cool Hat",
        text = {
            "Upgrades any and all",
            "{C:attention}Everything Joker{} by",
            "{C:mult}+4{} Mult",
            "{C:inactive}Must have at least one"
		},
		config = {},
		pos = { x = 1, y = 3 },
        cost = 3,
        cost_mult = 1,
        effect=nil,
        consumable=true,
        discovered=true,
        can_use = function() 
            hasj = false
            for i= 1, #G.jokers.cards do
                other_joker = G.jokers.cards[i]
                print(other_joker.ability.extra.name)
                if string.match(other_joker.ability.extra.name, "everything joker") then
                    hasj = true
                end        
            end
            return hasj
        end,
        use = function(self, area, copier)
            if self.ability.name == 'Cool Hat' then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    hasj = false
                    for i= 1, #G.jokers.cards do
                        other_joker = G.jokers.cards[i]
                        if string.match(other_joker.ability.extra.name, "everything joker") then
                            other_joker.ability.extra.mult = other_joker.ability.extra.mult + 4
                        end        
                        fakemessage("Upgrade!",self,G.C.RED)
                    end
                    return true end }))
                delay(0.6)
            end
        end      
	},
}

function SMODS.INIT.MorJokerTarots()    
    G.localization.descriptions.Other["mor_"] = {
        name = "Mor",
        text = {
            "{X:white,C:red}Something",
        }
    }
    init_localization()

    for k, v in pairs(tarots) do
        local tarot = SMODS.Tarot:new(v.name, k, v.config, v.pos, { name = v.name, text = v.text }, v.cost, v.cost_mult, v.effect, v.consumable, v.discovered, "MorJokers")
        -- SMODS.Tarot:new(name, slug, config, pos, loc_txt, cost, cost_mult, effect, consumeable, discovered, atlas)
        tarot:register()
        SMODS.Tarots[tarot.slug].use=v.use
        SMODS.Tarots[tarot.slug].can_use=v.can_use
        if(v.loc_def ~= nil) then
            SMODS.Tarots[tarot.slug].loc_def=v.loc_def
        end

    end
    -- SMODS.Sprite:new("morjokerTarots", SMODS.findModByID("morjokerTarots").path, "MorJokers.png", 71, 95, "asset_atli"):register()

 

end
----------------------------------------------
------------MOD CODE END----------------------