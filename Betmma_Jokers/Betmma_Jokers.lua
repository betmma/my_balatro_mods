--- STEAMODDED HEADER
--- MOD_NAME: Betmma Jokers
--- MOD_ID: BetmmaJokers
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 9 More Jokers!
--- PREFIX: betm_jokers

----------------------------------------------
------------MOD CODE -------------------------

IN_SMOD1=MODDED_VERSION>='1.0.0'
SMODS_Joker_ref=SMODS.Joker
local Jokers={}
SMODS_Joker_fake=function(table)
    if IN_SMOD1 then
        return SMODS_Joker_ref(table)
    else
        local this_j= SMODS_Joker_ref:new(table.name,table.key,
        table.config,
        table.pos,table.loc_txt,table.rarity,
        table.cost,table.unlocked,table.discovered,
        table.blueprint_compat, table.eternal_compat)
        this_j.loc_vars=table.loc_vars
        if this_j.loc_vars then
            this_j.loc_def=function(self2)
                return this_j.loc_vars(self2,nil,self2).vars
            end
        end
        this_j.calculate=table.calculate
        Jokers[#Jokers+1]=this_j
        return this_j
    end
end


do
    if after_event==nil then
        function after_event(func)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blockable=true,
                blocking=true,
                delay=0.1,
                func = (function()
                    func()
                    return true
                end)
            }))
        end
    end
end -- add after_event function

local MOD_PREFIX="betm_jokers_"
SMODS.current_mod=SMODS.current_mod or {}
function SMODS.current_mod.process_loc_text()
    G.localization.misc.dictionary.k_errorr = "Rank Changed!"
    G.localization.misc.challenge_names.c_mod_testjoker = "TestJoker"
    G.localization.misc.contexts={
        ['end_of_round'] = "when round ends",
        ['discard'] = "when you discard",
        ['debuffed_hand'] = "when hand is debuffed",
        ['using_consumeable'] = "when using consumable",
        ['remove_playing_cards'] = "when removing playing cards",
        -- ['cards_destroyed'] = "when destroying card during a hand", -- destroying_card is true for every card played to test if a joker can destroy it lol and i'm not sure what does cards_destroyed do. It seems only counts cards destroyed when calculating a hand but in a latest test it doesn't trigger on mosb and even glass cards breaking. just remove it then
        ['setting_blind'] = "when setting blind",
        ['first_hand_drawn'] = "when first hand drawn",
        ['playing_card_added'] = "when playing card added",
        ['skipping_booster'] = "when skipping booster",
        ['skip_blind'] = "when skipping blind",
        ['ending_shop'] = "when shop ends",
        ['reroll_shop'] = "when rerolling shop",
        ['selling_card'] = "when selling card",
        ['buying_card'] = "when buying card",
        ['open_booster'] = "when opening booster"
    }
end
local loc_text=SMODS.current_mod.process_loc_text

-- you can disable joker here
jokerBlacklists={}


    
local localization = {
    jjookkeerr = {
        name = "JJookkeerr",
        text = {
            "Jokers with \"Joker\"",
            "in their name",
            "each give {X:mult,C:white} X#1# {} Mult",
            -- if I count right there are 24 common, 6 uncommon and 3 rare jokers that satisfy this condition
        }
    },
    ascension = {
        name = "Ascension",
        text = {
            "Played poker hand counts",
            "as next higher poker hand",
            "(ex. High Card counts as One Pair)",
            -- How the poker hand "contained" is calculated should be clarified:
            -- If you play a Straight Flush, originally it contains Straight Flush, Flush, Straight and High Card. After triggering ascension it is counted as 5oak and contains 5oak, Straight Flush, Flush, Straight and High Card. Though a real 5oak contains 4oak and 3oak, this 5oak from ascension doesn't contain them.
        }
    },
    hasty = {
        name = "Hasty Joker",
        text = {
            "Earn {C:money}$#1#{} if round",
            "ends after first hand",
        }
    },
    errorr = {
        name = "ERRORR",
        text = {
            "Discarded cards have a",
            "{C:green}#1# in #2#{} chance to",
            "become random rank"
        }
    },
    piggy_bank = {
        name = " Piggy Bank ",
        text = {
            "Put half of earned money",
            "into this Joker",
            "{C:red}+#2#{} Mult for",
            "each {C:money}$1{} inside",
            "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)"
            -- dollar in it adds to its sold price
        }
    },
    housing_choice = {
        name = "Housing Choice",
        text = {
            "Once per Ante, get a random",
            "{C:attention}Voucher{} if played hand",
            "contains a {C:attention}Full House{}",
            "{C:inactive}(#1#)"
        }
    },
    jimbow = {
        name = "Jimbow",
        text = {
            "This Joker gains {C:chips}+#2#{}",
            "Chips {C:attention}#3#{},",
            "context changes when achieved",
            "{C:inactive}(Currently {C:chips}#1#{C:inactive} Chips)",
            
        }
    },
    gameplay_update = {
        name = "Gameplay Update",
        text = {
            "If played hand has exactly",
            "{C:attention}2 Diamonds{}, {C:attention}0 Spades{},",
            "{C:attention}2 Hearts{} or {C:attention}5 Clubs{},",
            "increase value of joker to its right",
            "by {C:attention}#1#% for each condition satisfied",
        }
    },
    flying_cards = {
        name = "Flying Cards",
        text = {
            "This Joker gains {X:mult,C:white} X(n+#2#)^-#1# {} Mult",
            "per {C:attention}card{} scored or discarded, where",
            "{C:attention}n{} equals number of cards left in deck",
            -- "{C:inactive}(if no cards left n is considered 1)",
            "{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)",
        }
    },
    friends_of_jimbo = {
        name = "Friends of Jimbo",
        text = {
            "For each {C:attention}King of Spades{}, {C:attention}Queen of Diamonds{},",
            "{C:attention}Jack of Hearts{} or {C:attention}King of Clubs{} scored,",
            "generate a {C:attention}Jimbo{}",
            "{C:inactive}(Must have room)",
        }
    },
}

--[[SMODS.Joker:new(
    name, slug,
    config,
    spritePos, loc_txt,
    rarity, cost, unlocked, discovered, blueprint_compat, eternal_compat
)
]]
function betmma_inc_joker_value(self,multi)
    G.E_MANAGER:add_event(Event({func = function()
        local possibleKeys={'bonus','h_mult','mult','t_mult','h_dollars','x_mult','extra_value','h_size','perma_bonus','p_dollars','h_x_mult','t_chips','d_size'}
        local self_ability=self.ability
        -- pprint(sliced_ability)
        -- pprint(self_ability)
        for k, v in pairs(possibleKeys) do
            if self_ability[v] and (self_ability[v]~=(v=='x_mult' and 1 or 0)) then
                self_ability[v]=self_ability[v]*multi
            end
        end
        if self_ability.extra then
            if type(self_ability.extra)=='table' then
                for k, v in pairs(self_ability.extra) do
                    if type(v)=='number' then
                        self_ability.extra[k]=self_ability.extra[k]*multi
                    end
                end
            elseif type(self_ability.extra)=='number' then
                self_ability.extra=self_ability.extra*multi
            end
        end
        self:juice_up(0.8, 0.8)
    return true end }))
    card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.RED, no_juice = true})
end
local function INIT()
    local jokers = {
        jjookkeerr = SMODS.Joker{
            name="JJookkeerr", key="jjookkeerr",
            config={extra=1.5},
            spritePos={x=0,y=0}, loc_txt="",
            rarity=2, cost=6, unlocked=true, discovered=true, blueprint_compat=true, eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra}}
            end
        },
        ascension = SMODS.Joker{
            name="Ascension", key="ascension",
            config={},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=2, 
            cost=6, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true
        },
        hasty = SMODS.Joker{
            name="Hasty Joker", key="hasty",
            config={extra=8},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=1, 
            cost=5, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=false, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra}}
            end
        },
        errorr = SMODS.Joker{
            name="ERRORR", key="errorr",
            config={extra={odds=3}},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=3, 
            cost=8, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=false, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={''..(G.GAME and G.GAME.probabilities.normal or 1), center.ability.extra.odds}}
            end
        },
        piggy_bank = SMODS.Joker{
            name=" Piggy Bank ", key="piggy_bank",
            config={extra={mults=0, mult_mod=1}},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=2, 
            cost=6, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra.mults, center.ability.extra.mult_mod}}
            end
        },
        housing_choice = SMODS.Joker{
            name="Housing Choice", key="housing_choice",
            config={extra={triggered=false}},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=2, 
            cost=6, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=false, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra.triggered and "inactive" or "active"}}
            end,
            calculate=function(self,card,context)
                if context.cardarea==G.jokers and context.before and not context.blueprint and next(context.poker_hands["Full House"]) and not card.ability.extra.triggered then
                    card.ability.extra.triggered=true
                    randomly_redeem_voucher()
                end
            end
        },
        jimbow = SMODS.Joker{
            name="Jimbow", key="jimbow",
            config={extra={chips=0,chip_mod=15,context=nil}},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=1, 
            cost=2, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                if center.ability.extra.context==nil then
                    center.ability.extra.context=select(2,pseudorandom_element(G.localization.misc.contexts,pseudoseed('jimbow')))
                end
                return {vars={center.ability.extra.chips,center.ability.extra.chip_mod,localize(center.ability.extra.context,'contexts')}}
            end,
            calculate=function(self,card,context)
                if card.ability.extra.context==nil then
                    card.ability.extra.context=select(2,pseudorandom_element(G.localization.misc.contexts,pseudoseed('jimbow')))
                end
                if not context.repetition and context[card.ability.extra.context] then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
                    card.ability.extra.context=select(2,pseudorandom_element(G.localization.misc.contexts,pseudoseed('jimbow')))
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.CHIPS})
                    -- return {
                    --     message = localize('k_upgrade_ex'),
                    --     colour = G.C.CHIPS,
                    --     card = card
                    -- }
                end
                if not context.repetition and SMODS.end_calculate_context(context) then
                    return {
                        message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                        chip_mod = card.ability.extra.chips, 
                        colour = G.C.CHIPS
                    }
                end
            end
        },
        gameplay_update = SMODS.Joker{
            name="Gameplay Update", key="gameplay_update",
            config={extra=2},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=3, 
            cost=10, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra}}
            end,
            calculate=function(self,card,context)
                if context.joker_main then
                    local my_pos = nil
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i] == card then my_pos = i; break end
                    end
                    if my_pos>=#G.jokers.cards then
                        return
                    end
                    local suits = {
                        ['Diamonds'] = 0,
                        ['Spades'] = 0,
                        ['Hearts'] = 0,
                        ['Clubs'] = 0
                    }
                    local suits_need={
                        ['Diamonds'] = 2,
                        ['Spades'] = 0,
                        ['Hearts'] = 2,
                        ['Clubs'] = 5
                    }
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i].ability.name ~= 'Wild Card' and not context.scoring_hand[i].config.center.any_suit then
                            for k, v in pairs(suits) do
                                if context.scoring_hand[i]:is_suit(k) then suits[k] = suits[k] + 1 end
                            end
                        end
                    end
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i].ability.name == 'Wild Card' or context.scoring_hand[i].config.center.any_suit then
                            for k, v in pairs(suits) do
                                if context.scoring_hand[i]:is_suit(k) and suits[k]<suits_need[k] then
                                    suits[k] = suits[k] + 1
                                end
                            end
                        end
                    end
                    for k, v in pairs(suits) do
                        -- print('suits '..k.." "..v..' '..suits_need[k])
                        if suits[k]==suits_need[k] then
                            betmma_inc_joker_value(G.jokers.cards[my_pos+1],(100+card.ability.extra)/100)
                        end
                    end
                end
            end
        },
        flying_cards = SMODS.Joker{
            name="Flying Cards", key="flying_cards",
            config={extra={power=2,add=2},x_mult=1},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=2, 
            cost=8, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={center.ability.extra.power,center.ability.extra.add,center.ability.x_mult,}}
            end,
            calculate=function(self,card,context)
                if context.discard or context.individual and context.cardarea == G.play then
                    local n=#G.deck.cards
                    card.ability.x_mult=card.ability.x_mult+(n+card.ability.extra.add)^(-card.ability.extra.power)
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.MULT})
                end
            end
        },
        friends_of_jimbo = SMODS.Joker{
            name="Friends of Jimbo", key="friends_of_jimbo",
            config={},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=1, 
            cost=3, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                return {vars={}}
            end,
            calculate=function(self,card,context)
                if context.individual and context.cardarea == G.play then
                    local card=context.other_card
                    local matches={{suit="Spades",rank=13},
                                    {suit="Diamonds",rank=12},
                                    {suit="Hearts",rank=11},
                                    {suit="Clubs",rank=13},}
                    for k, v in pairs(matches) do
                        if card:is_suit(v.suit) and card:get_id()==v.rank then
                            after_event(function()
                                local createjoker = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                                G.GAME.joker_buffer = G.GAME.joker_buffer + createjoker
                                if createjoker==1 then
                                    local card2 = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_joker')
                                    card2:add_to_deck()
                                    G.jokers:emplace(card2)
                                end
                                G.GAME.joker_buffer = 0
                            end)
                        end
                    end
                end
            end
        },
    }


    -- this challenge is only for test
    -- table.insert(G.CHALLENGES,1,{
    --     name = "TestJoker",
    --     id = 'c_mod_testjoker',
    --     rules = {
    --         custom = {
    --         },
    --         modifiers = {
    --             {id = 'dollars', value = 10},
    --         }
    --     },
    --     jokers = {
    --         {id = MOD_PREFIX..'j_jjookkeerr'},
    --         {id = MOD_PREFIX..'j_ascension'},
    --         {id = MOD_PREFIX..'j_hasty'},
    --         {id = MOD_PREFIX..'j_errorr'},
    --         {id = MOD_PREFIX..'j_piggy_bank'},
    --         {id = MOD_PREFIX..'j_piggy_bank'},
    --         {id = MOD_PREFIX..'j_housing_choice'},
    --     },
    --     consumeables = {
    --         {id = 'c_temperance'},
    --     },
    --     vouchers = {
    --         {id = 'v_directors_cut'},
    --     },
    --     deck = {
    --         type = 'Challenge Deck',
    --         --cards = {{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},}
    --     },
    --     restrictions = {
    --         banned_cards = {
    --         },
    --         banned_tags = {
    --         },
    --         banned_other = {
    --         }
    --     }
    -- })
    -- Localization
    init_localization()

    -- Add Jokers to center
    for k, v in pairs(jokers) do
        if jokerBlacklists[k]~=true then
            if IN_SMOD1 then
                v.loc_txt = localization[k]
                --v.spritePos = { x = 0, y = 0 }
                --v:register()
                v.key = "j_" .. k
                SMODS.Atlas{key=v.key, path=v.key..".png", px=71, py=95}
                v.key = MOD_PREFIX .. v.key
                v.atlas=v.key
            else
                v.slug = "j_" .. k
                v.loc_txt = localization[k]
                v.spritePos = { x = 0, y = 0 }
                v:register()
                SMODS.Sprite:new(v.slug, SMODS.findModByID("BetmmaJokers").path, v.slug..".png", 71, 95, "asset_atli"):register()
            end
        end
    end

    --- Joker abilities ---
    jokers.jjookkeerr.calculate = function(self, card, context)
        if context.other_joker and context.other_joker ~= card and not context.other_joker.debuff then
            if context.other_joker.ability.name and string.match(context.other_joker.ability.name, "Joker") then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_joker:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
                    Xmult_mod = card.ability.extra
                }
            end
        end
    end

    jokers.errorr.calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff and
        pseudorandom('errorr') < G.GAME.probabilities.normal/card.ability.extra.odds then -- the argument of pseudorandom is hashed and only for random seed, so every string is ok
            local card=context.other_card
            local suit_prefix
            if IN_SMOD1 then
                suit_prefix = SMODS.Suits[card.base.suit].card_key
            else
                suit_prefix = string.sub(card.base.suit, 1, 1)
            end
            local rank_suffix
            if IN_SMOD1 then
                rank_suffix = pseudorandom_element(SMODS.Ranks, pseudoseed('rank')).card_key
            else
                local ranks = {'2','3','4','5','6','7','8','9','T','J','Q','K','A'}
                local rand = math.floor(pseudorandom('rank')*13+1)
                rank_suffix = ranks[rand]
            end
            card:set_base(G.P_CARDS[suit_prefix..'_'..rank_suffix])
            return {
                message = localize('k_errorr'),
                card = card,
                colour = G.C.CHIPS
            }
        end
    end

    jokers.piggy_bank.calculate = function(self, card, context)
        if SMODS.end_calculate_context(context) and card.ability.extra.mults > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra.mults}},
                mult_mod = card.ability.extra.mults, 
                colour = G.C.MULT
            }
        end
        if context.selling_self then
            card.selling_self = true
        end
    end


end


local poker_hand_list = {
    "Flush Five",
    "Flush House",
    "Five of a Kind",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card",
}

-- Ascension
local evaluate_poker_hand_ref = evaluate_poker_hand
function evaluate_poker_hand(hand)
    local ret = evaluate_poker_hand_ref(hand)
    local Ascension_number = #find_joker('Ascension')
    for i = 1, Ascension_number, 1 do
        if next(ret[poker_hand_list[1]]) then break end -- Already getting the biggest hand
        for poker_hand_index = 2, #poker_hand_list, 1 do
            if next(ret[poker_hand_list[poker_hand_index]]) then 
                ret[poker_hand_list[poker_hand_index-1]]=ret[poker_hand_list[poker_hand_index]] -- Increase the tier of maximum hand by 1
                break
            end
        end
    end
    return ret
end

-- Hasty Joker
local calculate_dollar_bonus_ref = Card.calculate_dollar_bonus
function Card:calculate_dollar_bonus()
    if self.debuff then return end
    if self.ability.set == "Joker" then
        if self.ability.name == 'Hasty Joker' and G.GAME.current_round.hands_played == 1 then
            return self.ability.extra
        end
    end
    return calculate_dollar_bonus_ref(self)
end

--  Piggy Bank 
local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
    ease_dollars_ref(mod, instant)
    if mod and mod > 0 then
        local Piggy_Banks = find_joker(' Piggy Bank ')
        -- local Piggy_Bank_number = #Piggy_Banks
        --local saved_dollars = 0
        for index, card in pairs(Piggy_Banks) do
            local half = math.floor(mod/2)
            if half > 0 and not card.selling_self then
                delay(1)
                ease_dollars_ref(-half, false) 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                mod = mod - half
                card.ability.extra.mults = card.ability.extra.mults + card.ability.extra.mult_mod * half
                card.ability.extra_value = card.ability.extra_value + half
                card:set_cost()
            end
        end
    end

end

-- Housing Choice update status
local ease_ante_ref=ease_ante
function ease_ante(mod)
    ease_ante_ref(mod)
    local jokers = find_joker('Housing Choice')
    for k,joker in pairs(jokers) do
        joker.ability.extra.triggered=false
    end
end



if not SMODS.end_calculate_context then
    function SMODS.end_calculate_context(c)
        return c.joker_main
    end
end

function randomly_redeem_voucher(no_random_please) -- xD
    -- local voucher_key = time==0 and "v_voucher_bulk" or get_next_voucher_key(true)
    -- time=1
    local area
    if G.STATE == G.STATES.HAND_PLAYED then
        if not G.redeemed_vouchers_during_hand then
            -- may need repositioning
            G.redeemed_vouchers_during_hand = CardArea(
                G.play.T.x, G.play.T.y, G.play.T.w, G.play.T.h, 
                {type = 'play', card_limit = 5})
        end
        area = G.redeemed_vouchers_during_hand
    else
        area = G.play
    end
    local voucher_key = no_random_please or get_next_voucher_key(true)
    local card = Card(area.T.x + area.T.w/2 - G.CARD_W/2,
    area.T.y + area.T.h/2-G.CARD_H/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[voucher_key],{bypass_discovery_center = true, bypass_discovery_ui = true})
    card:start_materialize()
    area:emplace(card)
    card.cost=0
    card.shop_voucher=false
    local current_round_voucher=G.GAME.current_round.voucher
    card:redeem()
    G.GAME.current_round.voucher=current_round_voucher -- keep the shop voucher unchanged since the voucher bulk may be from voucher pack or other non-shop source
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        --blockable = false,
        --blocking = false,
        delay =  0,
        func = function() 
            card:start_dissolve()
            return true
        end}))   
end

if IN_SMOD1 then
    INIT()
else
    SMODS['INIT']=SMODS['INIT'] or {}
    SMODS['INIT']['BetmmaJokers']=function()
        SMODS.Joker=SMODS_Joker_fake
        INIT()
        SMODS.Joker=SMODS_Joker_ref
        loc_text()
        for k,v in pairs(Jokers) do
            
            if type(v.calculate)=='function' then
                v.calculate_ref=v.calculate
                v.calculate=function(card, context)
                    return v.calculate_ref(card,card,context)
                end
            end
        end
    end
end

-- JokerDisplay Support
if IN_SMOD1 and _G["JokerDisplay"] then
    NFS.load(SMODS.current_mod.path .. "jokerdisplay_integration.lua")()
end
----------------------------------------------
------------MOD CODE END----------------------