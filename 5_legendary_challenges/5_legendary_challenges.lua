--- STEAMODDED HEADER
--- MOD_NAME: 5 legendary challenges
--- MOD_ID: legendaryChallenges
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 5 more challenges, each featuring a legendary joker.

----------------------------------------------
------------MOD CODE -------------------------

IN_SMOD1=MODDED_VERSION>='1.0.0'
SMODS.current_mod=SMODS.current_mod or {}

function SMODS.current_mod.process_loc_text()
    G.localization.misc.challenge_names.c_mod_destroyer = "Destroyer"
    G.localization.misc.v_text.ch_c_faster_scaling = {
        "Required score scales extremely faster for each {C:attention}Ante"
    }
    G.localization.misc.challenge_names.c_mod_gottagofast = "Gotta Go Fast"
    G.localization.misc.challenge_names.c_mod_bankrupt = "Bankrupt"
    G.localization.misc.challenge_names.c_mod_antiMedusa = "Anti-Medusa"
    G.localization.misc.challenge_names.c_mod_overpoweredboss = "Overpowered Boss"
    -- ".misc.v_text" comes from the structure in en-us.lua
    G.localization.misc.v_text.ch_c_all_bosses_have_flint_ability = {
        "All {C:attention}Boss Blinds{} halve your {C:blue}base chips{} and {C:red}multi{}"
    }
end

local function INIT()

    -- the challenge table is in challenges.lua
    table.insert(G.CHALLENGES,1,{
        name = "Destroyer",
        id = 'c_mod_destroyer',
        rules = {
            custom = {
            },
            modifiers = {
                {id = 'joker_slots', value = 4},
            }
        },
        jokers = {
            {id = 'j_caino', eternal = true}, -- id of jokers can be looked up in game.lua at line ~500
            {id = 'j_pareidolia', eternal = true},
            {id = 'j_sixth_sense', eternal = true},
        },
        consumeables = {
        },
        vouchers = {
            {id = 'v_directors_cut'},
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                {id = 'j_trading'},
                {id = 'c_hanged_man'},
                {id = 'c_familiar'},
                {id = 'c_grim'},
                {id = 'c_incantation'},
                {id = 'c_immolate'},
            },
            banned_tags = {
            },
            banned_other = {
            }
        }
    })


    table.insert(G.CHALLENGES,2,{
        name = "Gotta Go Fast",
        id = 'c_mod_gottagofast',
        rules = {
            custom = {
                {id = 'faster_scaling'}, -- scaling is an existing modifier, but it only includes scaling = 1, 2 or 3, so I need this faster_scaling custom rule
            },
            modifiers = {
                {id = 'dollars', value = 10},
            }
        },
        jokers = {
            {id = 'j_triboulet'},
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
            },
            banned_tags = {
            },
            banned_other = {
            }
        }
    })

    table.insert(G.CHALLENGES,3,{
        name = "Bankrupt",
        id = 'c_mod_bankrupt',
        rules = {
            custom = {
                {id = 'discard_cost', value = 10},
            },
            modifiers = {
                {id = 'dollars', value = 100},
            }
        },
        jokers = {
            {id = 'j_yorick', eternal = true},
        },
        consumeables = {
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
            },
            banned_tags = {
            },
            banned_other = {
            }
        }
    })


    table.insert(G.CHALLENGES,4,{
        name = "Anti-Medusa",
        id = "c_mod_antiMedusa",
		
        rules = {
            custom = {
            },
            modifiers = {
                {id = 'consumable_slots', value = 0},
            }
        },
        jokers = {
            {id = 'j_perkeo', eternal = true},
        },
        consumeables = {
            {id = 'c_empress'},
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
            cards = {{s='D',r='2',e='m_stone',},{s='D',r='3',e='m_stone',},{s='D',r='4',e='m_stone',},{s='D',r='5',e='m_stone',},{s='D',r='6',e='m_stone',},{s='D',r='7',e='m_stone',},{s='D',r='8',e='m_stone',},{s='D',r='9',e='m_stone',},{s='D',r='T',e='m_stone',},{s='D',r='J',e='m_stone',},{s='D',r='Q',e='m_stone',},{s='D',r='K',e='m_stone',},{s='D',r='A',e='m_stone',},{s='C',r='2',e='m_stone',},{s='C',r='3',e='m_stone',},{s='C',r='4',e='m_stone',},{s='C',r='5',e='m_stone',},{s='C',r='6',e='m_stone',},{s='C',r='7',e='m_stone',},{s='C',r='8',e='m_stone',},{s='C',r='9',e='m_stone',},{s='C',r='T',e='m_stone',},{s='C',r='J',e='m_stone',},{s='C',r='Q',e='m_stone',},{s='C',r='K',e='m_stone',},{s='C',r='A',e='m_stone',},{s='H',r='2',e='m_stone',},{s='H',r='3',e='m_stone',},{s='H',r='4',e='m_stone',},{s='H',r='5',e='m_stone',},{s='H',r='6',e='m_stone',},{s='H',r='7',e='m_stone',},{s='H',r='8',e='m_stone',},{s='H',r='9',e='m_stone',},{s='H',r='T',e='m_stone',},{s='H',r='J',e='m_stone',},{s='H',r='Q',e='m_stone',},{s='H',r='K',e='m_stone',},{s='H',r='A',e='m_stone',},{s='S',r='2',e='m_stone',},{s='S',r='3',e='m_stone',},{s='S',r='4',e='m_stone',},{s='S',r='5',e='m_stone',},{s='S',r='6',e='m_stone',},{s='S',r='7',e='m_stone',},{s='S',r='8',e='m_stone',},{s='S',r='9',e='m_stone',},{s='S',r='T',e='m_stone',},{s='S',r='J',e='m_stone',},{s='S',r='Q',e='m_stone',},{s='S',r='K',e='m_stone',},{s='S',r='A',e='m_stone',},        }
        },
        restrictions = {
            banned_cards = {
                {id = 'c_fool'},
                {id = 'c_high_priestess'},
                {id = 'c_emperor'},
            },
            banned_tags = {
            },
            banned_other = {
            }
        }
    })


    
    table.insert(G.CHALLENGES,5,{
        name = "Overpowered Boss",
        id = 'c_mod_overpoweredboss',
        rules = {
            custom = {
                {id = 'all_bosses_have_flint_ability'},
                {id = 'no_reward'},
                {id = 'no_extra_hand_money'},
                {id = 'no_interest'},
            },
            modifiers = {
                {id = 'dollars', value = 20},
            }
        },
        jokers = {
            {id = 'j_matador', edition = 'negative', eternal = true},
        },
        consumeables = {
            {id = 'c_soul', edition = 'negative'}, -- however the negative edition doesn't work
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck'
        },
        restrictions = {
            banned_cards = {
                {id = 'j_caino'},
                {id = 'j_triboulet'},
                {id = 'j_yorick'},
                {id = 'j_perkeo'},
                {id = 'v_seed_money'},
                {id = 'v_money_tree'},
                {id = 'j_to_the_moon'},
                {id = 'j_rocket'},
                {id = 'j_golden'},
                {id = 'j_satellite'},
            },
            banned_tags = {
                {id = 'tag_investment'},
                {id = 'tag_handy'},
                {id = 'tag_garbage'},
                {id = 'tag_economy'},
                {id = 'tag_skip'},
            },
            banned_other = {
            }
        }
    })

        -- update localization
        init_localization()
end



--[[ how to inject into a function:
local something_ref = something -- copy the original function
function something(original parameters) -- replace the function
    do your things -- this is what you inject into this function
    return something_ref(original parameters) -- keep the original functionality unchanged
end
for class methods it is slightly different. The following code is examples of a nonclass function and a class method.
]]

local get_blind_amount_ref = get_blind_amount
function get_blind_amount(ante)
    local k = 0.75
    if G.GAME.modifiers.faster_scaling == true then
        local amounts = {
            300,  1500, 8000,  50000,  300000,  2000000,   35000000,  500000000
        }
        if ante < 1 then return 100 end
        if ante <= 8 then return amounts[ante] end
        local a, b, c, d = amounts[8],1.6,ante-8, 1 + 0.2*(ante-8)
        local amount = math.floor(a*(b+(k*c)^d)^c)
        amount = amount - amount%(10^math.floor(math.log10(amount)-1))
        return amount
    end
    return get_blind_amount_ref(ante)
end

local Blind_modify_hand_ref = Blind.modify_hand -- notice that the copied function is not a class method, and the . is replaced by _
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips)
  if G.GAME.modifiers.all_bosses_have_flint_ability == true and self.name ~= "Small Blind" and self.name ~= "Big Blind" and self.disabled == false then
    self.triggered = true
    if self.name == "The Flint" then -- double flint effect
        return math.max(math.floor(mult*0.25 + 0.75), 1), math.max(math.floor(hand_chips*0.25 + 0.75), 0), true
    end
    return math.max(math.floor(mult*0.5 + 0.5), 1), math.max(math.floor(hand_chips*0.5 + 0.5), 0), true
  end
  return Blind_modify_hand_ref(self, cards, poker_hands, text, mult, hand_chips) -- notice the "self" parameter, it's a must because Blind:modify_hand is a class method, while Blind_modify_hand_ref is not
end
INIT()
SMODS.current_mod.process_loc_text()
if IN_SMOD1 then
    
else
    
end
----------------------------------------------
------------MOD CODE END----------------------
