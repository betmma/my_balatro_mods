--- STEAMODDED HEADER
--- MOD_NAME: Betmma Jokers
--- MOD_ID: BetmmaJokers
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 11 More Jokers!
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

local usingTalisman = function() return SMODS.Mods and SMODS.Mods["Talisman"] and Big and Talisman.config_file.break_infinity or false end
function TalismanCompat(num)
    local using=usingTalisman()
    if not using then return num end
    if using=='omeganum'then
        return to_big(num)
    end
    if (using==true or using=='bignumber')then
        return to_big(num)
    end
	return num
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
            "For each {C:spades}King of Spades{}, {C:diamonds}Queen of Diamonds{},",
            "{C:hearts}Jack of Hearts{} or {C:clubs}King of Clubs{} scored,",
            "generate a {C:attention}Jimbo{}",
            "{C:inactive}(No need to have room)",
        }
    },
    balatro_mobile = {
        name = "Balatro Mobile",
        text = {
            "This Joker is {C:attention}mobile{} and can be put anywhere.",
            "#2#",
            "#3#",
            -- "{C:attention}If played{} it gives {C:chips}+#1#{} chips",
            -- "and is considered as {C:attention}every suit{}.",
            "{C:inactive}(Drag it around to see its effects)",
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
    if betmma_config and not betmma_config.jokers then return end
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
            cost=4, 
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
                                if true then--createjoker==1 then
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
        balatro_mobile = SMODS.Joker{
            name="Balatro Mobile", key="balatro_mobile",
            config={extra={value=26,win_value=26*10^24,ability_price=6,cooldown_reduce=2,shop_joker_min=2,shop_joker_max=6},h_x_mult=2,h_mult=6,mobile=true,no_rank=true},
            spritePos={x=0,y=0}, 
            loc_txt="",
            rarity=2, 
            cost=6, 
            unlocked=true, 
            discovered=true, 
            blueprint_compat=true, 
            eternal_compat=true,
            loc_vars=function(self,info_queue,center)
                local effect_text=""
                local effect_text2=""
                if not G or G.in_joker_overlay_menu then
                    effect_text="But not here"
                    effect_text2=":)"
                elseif G and G.jokers==center.area then
                    effect_text="If score is larger than "..(center.ability.extra.win_value/10^24).." septillion,"
                    effect_text2="win the blind and self destruct"
                elseif G and G.consumeables==center.area then
                    effect_text="Choose 4 cards of 4 suits and ranks of Six, Eight,"
                    effect_text2="Person (face) and Ten, destroy them and gain $"..center.ability.extra.value
                elseif G and G.hand==center.area then
                    effect_text="If hold in hand,"
                    effect_text2="+"..center.ability.h_mult.." Mult and X"..center.ability.h_x_mult.." Mult"
                elseif G and G.shop_jokers==center.area then
                    effect_text="When bought, generate a joker"
                    effect_text2="whose price is between $"..center.ability.extra.shop_joker_min.." and $"..center.ability.extra.shop_joker_max
                elseif G and G.betmma_abilities==center.area then
                    effect_text="Pay $"..center.ability.extra.ability_price..", decrease cooldown of"
                    effect_text2="the ability to its right by "..center.ability.extra.cooldown_reduce.." (not impmted)"
                end
                return {vars={center.ability.extra.value,effect_text,effect_text2}}
            end,
            can_use = function(self,card)
                if card.area==G.betmma_abilities then
                    return TalismanCompat(G.GAME.dollars-G.GAME.bankrupt_at)>=TalismanCompat(card.ability.extra.ability_price)
                end
                if not(G and G.hand.highlighted and #G.hand.highlighted==4) then return false end
                local suits = {
                    ['Diamonds'] = 0,
                    ['Spades'] = 0,
                    ['Hearts'] = 0,
                    ['Clubs'] = 0
                }
                local ranks={
                    ['6']=0,
                    ['8']=0,
                    ['10']=0
                }
                local hasFace=false
                local wild=0
                for i = 1, #G.hand.highlighted do
                    if G.hand.highlighted[i].ability.name ~= 'Wild Card' and not G.hand.highlighted[i].config.center.any_suit then
                        for k, v in pairs(suits) do
                            if G.hand.highlighted[i]:is_suit(k) then suits[k] = suits[k] + 1 end
                        end
                    else
                        wild=wild+1
                    end
                    for k,v in pairs(ranks)do
                        if G.hand.highlighted[i]:get_id()==tonumber(k) then
                            ranks[k]=ranks[k]+1
                        end
                    end
                    if G.hand.highlighted[i]:is_face() then
                        hasFace=true
                    end
                end
                for i = 1, wild do
                    for k, v in pairs(suits) do
                        if suits[k]<1 then
                            suits[k] = suits[k] + 1
                            break
                        end
                    end
                end
                local can_u=true
                for k, v in pairs(suits) do
                    if v<1 then
                        can_u=false
                        break
                    end
                end
                for k, v in pairs(ranks) do
                    if v<1 then
                        can_u=false
                        break
                    end
                end
                return can_u and hasFace
            end,
            keep_on_use = function(self,card)
                return true
            end,
            use = function(self,card,area,copier)
                if card.area==G.betmma_abilities then
                    after_event(function()
                        ease_dollars(-card.ability.extra.ability_price)
                    end)
                    local index=999
                    for i=1,#G.betmma_abilities.cards do
                        if G.betmma_abilities.cards[i]==card then
                            index=i;break
                        end
                    end 
                    if index<#G.betmma_abilities.cards then
                        local right=G.betmma_abilities.cards[index+1]
                        if right.ability.cooldown and (right.ability.cooldown.type~='passive') then
                            right.ability.cooldown.now=right.ability.cooldown.now-card.ability.extra.cooldown_reduce
                            if not used_abilvoucher('cooled_below') and right.ability.cooldown.now<0 then
                                right.ability.cooldown.now=0
                            end
                        end
                    end
                    return
                end
                local destroyed_cards = {}
                for i=#G.hand.highlighted, 1, -1 do
                    destroyed_cards[#destroyed_cards+1] = G.hand.highlighted[i]
                end
                local value=card.ability.extra.value
                after_event(function()
                    ease_dollars(card.ability.extra.value)
                end)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function() 
                        for i=#G.hand.highlighted, 1, -1 do
                            local card = G.hand.highlighted[i]
                            if card.ability.name == 'Glass Card' then 
                                card:shatter()
                            else
                                card:start_dissolve(nil, i == #G.hand.highlighted)
                            end
                        end
                    return true end }))
                for i = 1, #G.jokers.cards do
                    local effects = G.jokers.cards[i]:calculate_joker({remove_playing_cards = true, removed = destroyed_cards})
                    if effects and effects.joker_repetitions then
                        rep_list = effects.joker_repetitions
                        for z=1, #rep_list do
                            if type(rep_list[z]) == 'table' and rep_list[z].repetitions then
                                for r=1, rep_list[z].repetitions do
                                    card_eval_status_text(rep_list[z].card, 'jokers', nil, nil, nil, rep_list[z])
                                    if percent then percent = percent+percent_delta end
                                    G.jokers.cards[i]:calculate_joker({remove_playing_cards = true, removed = destroyed_cards, retrigger_joker = true})
                                end
                            end
                        end
                    end
                end
            end,
            buy_from_shop=function(self,card)
                if not(#G.jokers.cards < G.jokers.config.card_limit + ((card.edition and card.edition.negative) and 1 or 0)) then
                    return 
                end
                local ret={get_current_pool('Joker')}
                local pool=ret[1]
                local new_pool={}
                local _pool_size=0
                for k,v in pairs(pool) do
                    if v~='UNAVAILABLE' then
                        local card2= G.P_CENTERS[v]
                        local cost=card2.cost
                        if card.ability.extra.shop_joker_min<=cost and cost<=card.ability.extra.shop_joker_max then
                            new_pool[#new_pool+1]=v
                            _pool_size=_pool_size+1
                        end
                    end
                end
                if _pool_size == 0 then
                    new_pool = EMPTY(G.ARGS.TEMP_POOL)
                    new_pool[#new_pool + 1] = "j_joker"
                end
                local card2 = create_card('Joker', G.jokers, nil, nil, nil, nil, pseudorandom_element(new_pool,pseudoseed('std_mobile')))
                card2:add_to_deck()
                G.jokers:emplace(card2)
            end,
            calculate=function(self,card,context)
                if context.after and TalismanCompat(G.GAME.chips+((hand_chips or 0)*(mult or 0)))>TalismanCompat(card.ability.extra.win_value) then
                    G.GAME.balatro_mobile_win=true
                    after_event(function()
                        card:start_dissolve()
                        G.GAME.blind:disable()
                        G.GAME.chips = G.GAME.blind.chips
                        -- G.STATE = G.STATES.HAND_PLAYED
                        -- G.STATE_COMPLETE = true
                        -- end_round()
                        -- after_event(function()
                            -- after_event(function()
                            -- end)
                        -- end)
                    end)
                end
                -- if context.end_of_round == true and context.game_over ==true and card.trigger_destruct==true then
                --     return {saved=true}
                -- end
            end,
            update = function(self, card)
                if card.ability.countdown and card.ability.countdown>0 then
                    card.ability.countdown=card.ability.countdown-1
                end
                card.ability.mobile=true
                if card.area~=(G and G.shop_jokers) and card.area~=(G and G.hand) and card.area~=(G and G.pack_cards) then
                    card.ability.consumeable={}
                else
                    card.ability.consumeable=nil
                end
                card.base.value='Ace'
                card.base.suit='Jimbo'
                if not G or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.HAND_PLAYED or G.STATE==G.STATES.ROUND_EVAL or G.STATE==G.STATES.MENU or card.area==G.discard or not card.states.drag.is or (card.ability.countdown and card.ability.countdown>0) or G.in_joker_overlay_menu then -- card.ability.countdown is to prevent it return to shop area after bought, but excluding shop_jokers is enough
                    return
                end
                if RIFTRAFT and RIFTRAFT.VoidCardArea and card.area==RIFTRAFT.VoidCardArea then --RiftRaft mod compatibility
                    return
                end
                local possible_areas={G.jokers, G.consumeables, G.hand, G.betmma_abilities, G.betmma_spells, G.shop_jokers}
                possible_areas=remove_nils(possible_areas)
                local card_x=card.VT.x+card.VT.w/2
                local card_y=card.VT.y+card.VT.h/2
                for i, v in ipairs(possible_areas) do
                    if v.T.x<card_x and card_x<v.T.x+v.T.w and v.T.y<card_y and card_y<v.T.y+v.T.h and (not card.area or card.area~=v) then
                        if card.area then
                            if card.area.config.type ~= 'betmma_ability' and v.config.type == 'betmma_ability' then -- big -> small
                                -- print('smaller')
                                card.T.scale = card.T.scale * 0.4
                                -- card.VT.scale = card.VT.scale * 0.4
                            elseif card.area.config.type == 'betmma_ability' and v.config.type ~= 'betmma_ability' then -- small -> big
                                -- print('bigger')
                                card.T.scale = card.T.scale * 2.5
                                -- card.VT.scale = card.VT.scale * 2.5
                            end
                            card.area:remove_card(card)
                        end
                        v:emplace(card)
                        if v==G.shop_jokers then
                            create_shop_card_ui(card)
                        end
                    end
                end
            end
        },
    }
    local CardArea_emplace_ref=CardArea.emplace
    function CardArea:emplace(card, location, stay_flipped)
        if card.ability.mobile then
            card.ability.countdown=10 -- if card is moved by program (not by player dragged) prevent being placed back
        end
        CardArea_emplace_ref(self, card, location, stay_flipped)
    end
    
    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    function G.UIDEF.use_and_sell_buttons(card)
        if card.ability.mobile and card.area and card.area==G.consumeables then 
            local sell,use
            sell = {n=G.UIT.C, config={align = "cr"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "cr",padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card'}, nodes={
                  {n=G.UIT.B, config = {w=0.1,h=0.6}},
                  {n=G.UIT.C, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                      {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                      {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
                      {n=G.UIT.T, config={ref_table = card, ref_value = 'sell_cost_label',colour = G.C.WHITE, scale = 0.55, shadow = true}}
                    }}
                  }}
                }},
              }}
              use = 
              {n=G.UIT.C, config={align = "cr"}, nodes={
                
                {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_use_consumeable'}, nodes={
                  {n=G.UIT.B, config = {w=0.1,h=0.6}},
                  {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
                }}
              }}
              local t = {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                  {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                      sell
                    }},
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                      use
                    }},
                  }},
              }}
            return t
        end
        if card.ability.mobile and card.area and card.area==G.betmma_abilities then 
            local sell = nil
            local use = nil
            sell = {n=G.UIT.R, config={align = "tr"}, nodes={
                {n=G.UIT.R, config={ref_table = card, align = "tr",padding = 0.1, r=0.08, minw = 0.7, minh = 0.9, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'sell_card', func = 'can_sell_card'}, nodes={
                --   {n=G.UIT.B, config = {w=0.1,h=0.6}},
                {n=G.UIT.C, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                    {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.3, shadow = true}},
                    {n=G.UIT.T, config={ref_table = card, ref_value = 'sell_cost_label',colour = G.C.WHITE, scale = 0.3, shadow = true}}
                    }}
                }}
                }},
            }}
            use = 
            {n=G.UIT.R, config={align = "bm"}, nodes={
                
                {n=G.UIT.R, config={ref_table = card, align = "bm",maxw = 1.25, padding = 0.1, r=0.08, minw = 0.7, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_use_consumeable'}, nodes={
                --   {n=G.UIT.B, config = {w=0.1,h=0.6}},
                {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}}
                }}
            }}
            if card.ability.cooldown and card.ability.cooldown.type=='passive' then
                use={n=G.UIT.B, config = {w=0.1,h=1}}
            end -- remove use button if this is passive ability
            local t = {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                    sell
                    }},
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                        {n=G.UIT.B, config = {w=0.1,h=1.9}}
                    }},
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                    use
                    }},
                }},
            }}
            return t
        end
        return G_UIDEF_use_and_sell_buttons_ref(card)
    end

    local G_FUNCS_buy_from_shop_ref=G.FUNCS.buy_from_shop
    G.FUNCS.buy_from_shop = function(e)
        local c1 = e.config.ref_table
        if c1.ability.mobile then
            c1.ability.consumable=nil
        end
        local ret=G_FUNCS_buy_from_shop_ref(e)
        if ret~=false and c1.ability.mobile and c1.config.center.buy_from_shop then 
            c1.config.center:buy_from_shop(c1)
        end
        return ret
    end

    
    local G_FUNCS_exit_overlay_menu_ref=G.FUNCS.exit_overlay_menu
    G.FUNCS.exit_overlay_menu = function()
        local ret=G_FUNCS_exit_overlay_menu_ref()
        G.in_joker_overlay_menu=false
    end

    local create_UIBox_your_collection_jokers_ref=create_UIBox_your_collection_jokers
    function create_UIBox_your_collection_jokers()
        local ret=create_UIBox_your_collection_jokers_ref()
        G.in_joker_overlay_menu=true
        return ret
    end
    -- local can_use_consumeable_ref=G.FUNCS.can_use_consumeable
    -- G.FUNCS.can_use_consumeable = function(e)
    --     can_use_consumeable_ref(e)
    --     local card=e.config.ref_table
    --     -- if card.config.center.can_use then
    --     --     print(card.config.center:can_use(card))
    --     -- end
    --     if card.ability.mobile and card.config.center:can_use(card) then
    --         e.config.colour = G.C.RED
    --         e.config.button = 'use_card'
    --     end
    --   end

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
        if SMODS.end_calculate_context(context) and TalismanCompat(card.ability.extra.mults) > TalismanCompat(0) then
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
if not TalismanCompat then
    local usingTalisman = function() return SMODS.Mods and SMODS.Mods["Talisman"] and Big and Talisman.config_file.break_infinity or false end

    function TalismanCompat(num)
        local using=usingTalisman()
        if not using then return num end
        if using=='omeganum'then
            return to_big(num)
        end
        if (using==true or using=='bignumber')then
            return to_big(num)
        end
        return num
    end
end

local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
    ease_dollars_ref(mod, instant)
    if mod and TalismanCompat(mod) > TalismanCompat(0) then
        local Piggy_Banks = find_joker(' Piggy Bank ')
        -- local Piggy_Bank_number = #Piggy_Banks
        --local saved_dollars = 0
        for index, card in pairs(Piggy_Banks) do
            local half = math.floor(mod/2)
            if TalismanCompat(half) > TalismanCompat(0) and not card.selling_self then
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