--- STEAMODDED HEADER
--- MOD_NAME: Betmma Vouchers
--- MOD_ID: BetmmaVouchers
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 46 Vouchers and 21 Fusion Vouchers! v2.1.5.1
--- PREFIX: betm_vouchers
--- VERSION: 2.1.5.1(20240627)
--- BADGE_COLOUR: ED40BF

----------------------------------------------
------------MOD CODE -------------------------
-- thanks to Denverplays2, RenSixx, KEKC, Zahrizi, Sameone and other discord users for their ideas
-- ideas:
-- peek the first card in packs (impractical?) / skipped packs get 50% refund (someone's joker has done it)
-- Global Interpreter Lock: set all jokers to eternal / not eternal, once per round (more like an ability that is used manually)
-- suspended process: if this ability is on, round won't end until you run out of hands
-- sold jokers become a tag that replaces the next joker appearing in shop (also an ability)
-- complete a quest to get a soul
-- fusion vouchers:
-- Forbidden Word: Fusion voucher and joker may appear in the store.  Forbidden magic: Purchased fusion Joker and voucher give things related to their fusion
-- Randomize Lucky Card effects (+Chip, Mult, xMult, money, copy first card played, generate consumable, generate joker (oops all 6 maybe), comsumable slot, joker slot, random tag, enhance jokers, enhance cards, retrigger ...)
-- (upgraded of above) if probabilities in lucky card, that is written as A in B, satisfies A>B, this can trigger more than 1 time
-- Magic Trick + Reroll Surplus: return all cards to deck if deck has no cards
-- Overstock + Reroll Surplus could make it so that whenever you buy something, it's automatically replaced with a card of the same type
-- enhancements can stack
-- give $1 per 10 cards left when round ends
-- Grand Finale: if no cards left when round ends, gives $10
-- money grabber + gold coin :
--[[
Tier 1 Voucher: Bargain Aisle: One random item in the shop will be free per shop, persists between rerolls.

Tier 2 Voucher: Clearance Aisle: 3 random items in the shop will be free per shop, persists between rerolls.

Fusion Voucher: Giveaway Search (Reroll Glut + Clearance Aisle): Each shop reroll that you do will add +1 random free item to that shop. 
]]
--sendDebugMessage(tprint(table))
IN_SMOD1=MODDED_VERSION>='1.0.0'
local JOKER_MOD_PREFIX=IN_SMOD1 and "betm_jokers_"or ''
MOD_PREFIX=IN_SMOD1 and 'betm_vouchers_' or ''
MOD_PREFIX_V='v_'..MOD_PREFIX
MOD_PREFIX_V_LEN=string.len(MOD_PREFIX_V)

-- Config: DISABLE UNWANTED VOUCHERS HERE
config = {
    -- normal vouchers
    v_oversupply=true,
    v_oversupply_plus=true,
    v_gold_coin=true,
    v_gold_bar=true,
    v_abstract_art=true,
    v_mondrian=true,
    v_round_up=true,
    v_round_up_plus=true,
    v_event_horizon=true,
    v_engulfer=true,
    v_target=true,
    v_bulls_eye=true,
    v_voucher_bundle=true,
    v_voucher_bulk=true,
    v_skip=true,
    v_skipper=true,
    v_scrawl=true,
    v_scribble=true,
    v_reserve_area=true,
    v_reserve_area_plus=true,
    v_overkill=true,
    v_big_blast=true,
    v_3d_boosters=true,
    v_4d_boosters=true,
    v_b1g50=true,
    v_b1g1=true,
    v_collector=true,
    v_connoisseur=true,
    v_flipped_card=true,
    v_double_flipped_card=true,
    v_prologue=true,
    v_epilogue=true,
    v_bonus_plus=true,
    v_mult_plus=true,
    v_omnicard=true,
    v_bulletproof=true,
    v_cash_clutch=true,
    v_inflation=true,
    v_eternity=true,
    v_half_life=true,
    v_debt_burden=true,
    v_bobby_pin=true,
    v_stow=true,
    v_stash=true,
    v_undying=true,
    v_reincarnate=true,
    -- fusion vouchers
    v_gold_round_up=true,
    v_overshopping=true,
    v_reroll_cut=true,
    v_vanish_magic=true,
    v_darkness=true,
    v_double_planet=true,
    v_trash_picker=true,
    v_money_target=true,
    v_art_gallery=true,
    v_b1ginf=true,
    v_slate=true,
    v_gilded_glider=true,
    v_mirror=true,
    v_real_random=true,
    v_4d_vouchers=true,
    v_recycle_area=true,
    v_chaos=true,
    v_heat_death=true,
    v_deep_roots=true,
    v_solar_system=true,
    v_forbidden_area=true,
}
if not IN_SMOD1 then
    config.v_undying=false
    config.v_reincarnate=false
end

-- example: if used_voucher('slate') then ... end 
-- setting it to global is for lovely patches
function used_voucher(raw_key)
    return G.GAME.used_vouchers[MOD_PREFIX_V..raw_key]
end
-- example: get_voucher('slate').config.extra
local function get_voucher(raw_key)
    return G.P_CENTERS[MOD_PREFIX_V..raw_key]
end

local function get_rarity(raw_key)
    local card= G.P_CENTERS[raw_key]
    return card and card.config and card.config.rarity or 1
end
-- example: handle_atlas('slate') loads 'v_slate.png' and assign it
local function handle_atlas(raw_key,this_v)
    if IN_SMOD1 then
        local key='v_'..raw_key
        SMODS.Atlas{key=key, path=key..".png", px=71, py=95}
        key = MOD_PREFIX .. key
        this_v.atlas=key
    else
        local id=raw_key
        SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register()
    end
end

local function handle_register(this_v)
    if not IN_SMOD1 then
        this_v:register()
    end
end

local fusion_voucher_weight=4
-- set default weight of fusion vouchers to 4
if IN_SMOD1 then
    local SMODS_Center_inject=SMODS.Center.inject
    SMODS.Center.inject =function(self)
        -- print(SMODS.current_mod+"....."+self.set)
        if self.key:find(MOD_PREFIX_V) and self.set=='Voucher'then
            if not config['v_'..self.key:sub(MOD_PREFIX_V_LEN+1,-1)] then return false end
            self.mod_name='Betmma Vouchers'
            if self.requires and #self.requires>1 and not self.config.weight then 
                self.config.weight=fusion_voucher_weight
            end
        end
        SMODS_Center_inject(self)
    end
else
    local SMODS_Voucher_register=SMODS.Voucher.register
    function SMODS.Voucher:register()
        if SMODS._MOD_NAME=='Betmma Vouchers' then
            if not config[self.slug] then return false end
            if self.loc_vars then
                self.loc_def=function(self2)
                    local loc_vars=self.loc_vars
                    return self.loc_vars(self2,nil,{ability=self2.config}).vars
                end
            end
            if self.requires and #self.requires>1 then 
                self.config.weight=fusion_voucher_weight
            end
        end
        SMODS_Voucher_register(self)
    end
end


SMODS_Voucher_ref=SMODS.Voucher -- 0.9.8 compat thing
SMODS_Voucher_fake=function(table)
    if IN_SMOD1 then
        return SMODS_Voucher_ref(table)
    else
        local this_v= SMODS_Voucher_ref:new(table.name,table.key,
        table.config,
        table.pos,table.loc_txt,
        table.cost,table.unlocked,table.discovered,table.available,
        table.requires)
        this_v.rarity=table.rarity
        return this_v
    end
end

real_random_data={}
SMODS.current_mod=SMODS.current_mod or {}
function SMODS.current_mod.process_loc_text()
    G.localization.misc.dictionary["k_fusion_voucher"] = "Fusion Voucher"
    G.localization.misc.challenge_names.c_mod_testvoucher = "TestVoucher"
    G.localization.misc.dictionary.k_event_horizon_generate = "Event Horizon!"
    G.localization.misc.dictionary.k_engulfer_generate = "Engulfer!"
    G.localization.misc.dictionary.k_target_generate = "Target!"
    G.localization.misc.dictionary.k_bulls_eye_generate = "Bull's Eye!"
    G.localization.misc.dictionary.b_reserve = "RESERVE"
    G.localization.misc.dictionary.k_transfer_ability = "Transfer!"
    G.localization.misc.dictionary.k_overkill_edition = "Overkill!"
    G.localization.misc.dictionary.k_big_blast_edition = "Big Blast!"
    G.localization.misc.dictionary.b_flip_hand = "Flip"
    G.localization.misc.dictionary.k_bulletproof = "Bulletproof!"
    G.localization.misc.dictionary.b_vanish = "VANISH"
    G.localization.misc.dictionary.k_heat_death="Heat Death!"
    G.localization.misc.dictionary.k_undying="Undying!"
    G.localization.misc.dictionary.k_reincarnate="Reincarnate!"
    G.localization.misc.dictionary.k_solar_system="Solar System!"
    G.localization.misc.dictionary.over_retriggered = "Over-retriggered: "
    for k,v in pairs(real_random_data) do
        G.localization.descriptions.Enhanced['real_random_'..k] =v 
    end
    G.localization.descriptions.Enhanced.ellipsis={text={'{C:inactive}(#1# abilities omitted)'}}
    G.localization.descriptions.Enhanced.multiples={text={'{C:inactive}(X#1#)'}}
end

local usingTalisman = function() return SMODS.Mods and SMODS.Mods["Talisman"] and Big and true or false end
local usingCryptid=SMODS.Mods and SMODS.Mods["Cryptid"] or false

function TalismanCompat(num)
	return usingTalisman() and Big:new(num) or num
end

local function get_plain_text_from_localize(final_line)
    local ret=''
    for k,v in pairs(final_line) do
        local config=v.config
        if config.text then ret=ret..config.text..''
        elseif v.nodes then ret=ret..v.nodes[1].config.text..''
        else ret=ret..config.object.config.string[1]..''
        end
    end
    return ret
end

-- return index of obj in array. If not found return -1.
local function get_index_in_array(array,obj)
    local index=1
    while array[index]~=obj and index<=#array do
        index=index+1
    end
    if index<=#array then
        return index
    end
    return -1
end

do -- randomly create card function series
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
    function randomly_create_joker(jokers_to_create,tag,message,extra)
        extra=extra or {}
        G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
        G.E_MANAGER:add_event(Event({
            func = function() 
                for i = 1, jokers_to_create do
                    local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, tag)
                    card:add_to_deck()
                    if extra.edition~=nil then
                        card:set_edition(extra.edition,true,false)
                    end
                    G.jokers:emplace(card)
                    card:start_materialize()
                    G.GAME.joker_buffer = 0
                
                    if message~=nil then
                        card_eval_status_text(card,'jokers',nil,nil,nil,{message=message})
                    end
                end
                return true
            end}))   
    end
    function randomly_create_consumable(card_type,tag,message,extra)
        extra=extra or {}
        
        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit or extra and extra.edition and extra.edition.negative then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                        local card = create_card(card_type,G.consumeables, nil, nil, nil, nil, extra.forced_key or nil, tag)
                        card:add_to_deck()
                        if extra.edition~=nil then
                            card:set_edition(extra.edition,true,false)
                        end
                        if extra.eternal~=nil then
                            card.ability.eternal=extra.eternal
                        end
                        if extra.perishable~=nil then
                            card.ability.perishable = extra.perishable
                            if tag=='v_epilogue' then
                                card.ability.perish_tally=get_voucher('epilogue').config.extra
                            else card.ability.perish_tally = G.GAME.perishable_rounds
                            end
                        end
                        if extra.extra_ability~=nil then
                            card.ability[extra.extra_ability]=true
                        end
                        card.ability.BetmmaVouchers=true
                        -- G.jokers:emplace(card)
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        if message~=nil then
                            card_eval_status_text(card,'extra',nil,nil,nil,{message=message})
                        end
                    return true
                end)}))
        end
    end
    function randomly_create_spectral(tag,message,extra)
        return randomly_create_consumable('Spectral',tag,message,extra)
    end
    function randomly_create_tarot(tag,message,extra)
        return randomly_create_consumable('Tarot',tag,message,extra)
    end
    function randomly_create_planet(tag,message,extra)
        return randomly_create_consumable('Planet',tag,message,extra)
    end
end


local function get_weight(v)
    local _type=type(v)

    if _type~='table' and _type~='string' then return 1 end
    -- if _type=='table' and v.name == "Ace of Spades"then return 9999 end
    if _type=='string' then
        if G.P_CENTERS[v] then
            v=G.P_CENTERS[v]
        end
    end
    if v.weight then return v.weight end
    if v.config and v.config.weight then return v.config.weight end
    return 1
end

local function pseudorandom_element_weighted(_t, seed)
    if seed then math.randomseed(seed) end
    -- local keys = {}
    -- for k, v in pairs(_t) do
    --     keys[#keys+1] = {k = k,v = v}
    -- end
  
    -- if keys[1] and keys[1].v and type(keys[1].v) == 'table' and keys[1].v.sort_id then
    --   table.sort(keys, function (a, b) return a.v.sort_id < b.v.sort_id end)
    -- else
    --   table.sort(keys, function (a, b) return a.k < b.k end)
    -- end
    local _type
    local cume, it, center, center_key = 0, 0, nil, nil
    for k, v in pairs(_t) do
        _type=type(v)
        if (_type~='table') or (not G.GAME.banned_keys[v.key]) then cume = cume + get_weight(v) end
    end
    local poll = pseudorandom(pseudoseed((seed or 'weighted_random')..G.GAME.round_resets.ante))*cume
    
    for k, v in pairs(_t) do
        if (_type~='table') or (not G.GAME.banned_keys[v.key]) then 
            it = it + get_weight(v) 
            if it >= poll and it - get_weight(v) <= poll then center = v; center_key=k; break end
        end
    end
    if center == nil then center.a() end
    return center,center_key
end

local ability_names={'mult','h_mult','h_x_mult','h_dollars','p_dollars','t_mult','t_chips','h_size','d_size','bonus'}
-- for cards whose ability is changed, load ability values to config.center so that these can be displayed in hover ui. Note that after doing this config.center is no longer the same in G.P_CENTERS so this function should be used as little as possible
local function load_ability_to_center(card)
    card.config.center=copy_table(card.config.center)
    for k,v in pairs(ability_names) do
        card.config.center.config[v]=card.ability[v] or 0
    end
    card.config.center.config.Xmult=card.ability.x_mult
    if used_voucher('real_random')then
        card.config.center.real_random_abilities=card.ability.real_random_abilities
    end
end
-- the reverse verion of the function above
local function load_center_to_ability(card)
    card.config.center=copy_table(card.config.center)
    for k,v in pairs(ability_names) do
        card.ability[v]=card.config.center.config[v] or 0
    end
    card.ability.x_mult=card.config.center.config.Xmult
    if used_voucher('real_random')then
        card.ability.real_random_abilities=card.config.center.real_random_abilities
    end
end
-- return (a or default_value)+(b or default_value)
local function safe_add(a,b,default_value)
    return (a or default_value)+(b or default_value)
end


-- I don't know why there are so many reports about housing choice causing get_straight and get_X_same such function to crash, it seems that some card's rank becomes nil and someone has guessed about voucher created has no rank but created card won't come into played hands. Anyway I should try this
    local Card_get_id_ref=Card.get_id
    function Card:get_id()
        local ret=Card_get_id_ref(self)
        return ret or -math.random(100,1000000)
    end

function GET_PATH_COMPAT()
    return IN_SMOD1 and SMODS.current_mod.path or SMODS.findModByID('BetmmaVouchers').path
end

local function INIT()
    if config.v_undying or config.v_reincarnate then
        local PATH=GET_PATH_COMPAT()
        NFS.load(PATH .. "phantom.lua")()
    end

--- deal with enhances effect changes when saving & loading
do
    local enhanced_prototype_centers = {}

    function setup_consumables()
        -- Save vanilla enhanced centers
        enhanced_prototype_centers.m_bonus = G.P_CENTERS.m_bonus.config.bonus
        enhanced_prototype_centers.m_mult = G.P_CENTERS.m_mult.config.mult
        enhanced_prototype_centers.m_glass = G.P_CENTERS.m_glass.config.Xmult
        enhanced_prototype_centers.m_steel = G.P_CENTERS.m_steel.config.h_x_mult
        enhanced_prototype_centers.m_stone = G.P_CENTERS.m_stone.config.bonus
        enhanced_prototype_centers.m_gold = G.P_CENTERS.m_gold.config.h_dollars
    end


    -- Restore vanilla enhancements
    local Game_delete_run_ref = Game.delete_run
    function Game.delete_run(self)

        G.P_CENTERS.m_bonus.config.bonus = enhanced_prototype_centers.m_bonus
        G.P_CENTERS.m_mult.config.mult = enhanced_prototype_centers.m_mult
        G.P_CENTERS.m_glass.config.Xmult = enhanced_prototype_centers.m_glass
        G.P_CENTERS.m_steel.config.h_x_mult = enhanced_prototype_centers.m_steel
        G.P_CENTERS.m_stone.config.bonus = enhanced_prototype_centers.m_stone
        G.P_CENTERS.m_gold.config.h_dollars = enhanced_prototype_centers.m_gold


        Game_delete_run_ref(self)
    end

    -- Restore enhanced cards effect changes
    local Game_start_run_ref = Game.start_run
    function Game.start_run(self, args)

        G.P_CENTERS.m_bonus.config.bonus = enhanced_prototype_centers.m_bonus
        G.P_CENTERS.m_mult.config.mult = enhanced_prototype_centers.m_mult
        G.P_CENTERS.m_glass.config.Xmult = enhanced_prototype_centers.m_glass
        G.P_CENTERS.m_steel.config.h_x_mult = enhanced_prototype_centers.m_steel
        G.P_CENTERS.m_stone.config.bonus = enhanced_prototype_centers.m_stone
        G.P_CENTERS.m_gold.config.h_dollars = enhanced_prototype_centers.m_gold

        Game_start_run_ref(self, args)

        local saveTable = args and args.savetext or nil
        if saveTable then -- without this, vouchers given at the start of the run (in challenge) will be calculated twice
            if used_voucher('bonus_plus') then
                G.P_CENTERS.m_bonus.config.bonus=G.P_CENTERS.m_bonus.config.bonus+get_voucher('bonus_plus').config.extra
                for k, v in pairs(G.playing_cards) do
                    if v.config.center_key == 'm_bonus' then v:set_ability(G.P_CENTERS['m_bonus']) end
                end
            end
            if used_voucher('mult_plus') then
                G.P_CENTERS.m_mult.config.mult=G.P_CENTERS.m_mult.config.mult+get_voucher('mult_plus').config.extra
                for k, v in pairs(G.playing_cards) do
                    if v.config.center_key == 'm_mult' then v:set_ability(G.P_CENTERS['m_mult']) end
                end
            end
            if used_voucher('slate') then
                G.P_CENTERS.m_stone.config.bonus=G.P_CENTERS.m_stone.config.bonus+get_voucher('slate').config.extra
                for k, v in pairs(G.playing_cards) do
                    if v.config.center_key == 'm_stone' then v:set_ability(G.P_CENTERS['m_stone']) end
                end
            end
            if used_voucher('bulletproof') then
                for k, v in pairs(G.playing_cards) do
                    if v.config.center_key == 'm_glass' and v.config.center.config.Xmult~=v.ability.x_mult then 
                        v.config.center=copy_table(v.config.center)
                        v.config.center.config.Xmult=v.ability.x_mult
                        -- if the x_mult has been decreased, change the number on hover UI from m_glass value to x_mult
                    end
                end
            end
            
            if used_voucher('real_random') then
                for k, v in pairs(G.playing_cards) do
                    if v.ability.real_random_abilities then 
                        v.config.center=copy_table(v.config.center)
                        v.config.center.real_random_abilities=v.ability.real_random_abilities
                        -- restore random abilities from v.ability (lucky card or got random ability from lucky card)
                    end
                end
            end

            if used_voucher('chaos') then
                for k,v in pairs(G.playing_cards) do
                    if v.ability.set=='Enhanced'then
                        load_ability_to_center(v)
                    end
                end
            end
        end

    end
end --


    setup_consumables()
    RARITY_VOUCHER_PROBABILITY={1,2,4,20}
    local function normalize_rarity(rarity)
        if not rarity then return 1 end
        return math.max(1,math.min(math.ceil(rarity),#RARITY_VOUCHER_PROBABILITY))
    end
    local get_current_pool_ref=get_current_pool
    function get_current_pool(_type, _rarity, _legendary, _append)
        if _type=='Voucher'then _append='lol' end -- MathIsFun will do something to prevent crash with Deck of Equilibrium when _append has value
        local ret={get_current_pool_ref(_type, _rarity, _legendary, _append)}
        if _type=='Voucher' then
            local pool=ret[1]
            local new_pool={}
            local _pool_size=0
            for k,v in pairs(pool) do
                if v~='UNAVAILABLE' then
                    local card= G.P_CENTERS[v]
                    local rarity=card.config and normalize_rarity(card.config.rarity)
                    if (pseudorandom(v) < 1/RARITY_VOUCHER_PROBABILITY[rarity]) then
                        new_pool[#new_pool+1]=v
                        _pool_size=_pool_size+1
                    end
                else
                    new_pool[#new_pool+1]=v
                end
            end
            if _pool_size == 0 then
                new_pool = EMPTY(G.ARGS.TEMP_POOL)
                new_pool[#new_pool + 1] = "v_blank"
            end
            ret[1]=new_pool
            return unpack(ret)
        end
        return unpack(ret)
    end

    local get_current_pool_copy=get_current_pool -- this is because when the following function is called get_current_pool has been replaced to itself
    local function get_specific_rarity_vouchers_pool(rarity)
        local pool,pool_key=get_current_pool_ref('Voucher')
        local new_pool={}
        local _pool_size=0
        for k,v in pairs(pool) do
            if v~='UNAVAILABLE' then
                local card= G.P_CENTERS[v]
                local card_rarity=card.config and normalize_rarity(card.config.rarity)
                if card_rarity==rarity then
                    new_pool[#new_pool+1]=v
                    _pool_size=_pool_size+1
                end
            end
        end
        if _pool_size == 0 then
            return get_current_pool_copy('Voucher')
        end
        return new_pool,pool_key
    end

    local function get_voucher_pool_with_filter_and_reqs(func)
        -- func should take in G.P_CENTERS[key] and return a boolean
        local pool,pool_key=get_current_pool_ref('Voucher')
        local new_pool={}
        local _pool_size=0
        for k,v in pairs(pool) do
            if v~='UNAVAILABLE' then
                local card= G.P_CENTERS[v]
                if func(card) then
                    new_pool[#new_pool+1]=v
                    _pool_size=_pool_size+1
                end
            end
        end
        if _pool_size == 0 then
            return get_current_pool_copy('Voucher')
        end
        return new_pool,pool_key
    end

    local function get_voucher_pool_with_filter(func)
        -- func should take in G.P_CENTERS[key] and return a boolean
        local _starting_pool, _pool_key = G.P_CENTER_POOLS['Voucher'], 'Voucher'
        local _pool=EMPTY(G.ARGS.TEMP_POOL)
        local _pool_size=0
        for k, v in ipairs(_starting_pool) do
            if func(v) and not G.GAME.banned_keys[v.key] then 
                -- don't check for requires
                _pool[#_pool + 1] = v.key
                _pool_size = _pool_size + 1
            end
        end
        if _pool_size == 0 then
            return get_current_pool_copy('Voucher')
        end
        return _pool,_pool_key
    end

    local get_next_voucher_key_ref=get_next_voucher_key
    function get_next_voucher_key(_from_tag)
        -- local _pool, _pool_key = get_current_pool('Voucher')
        -- this pool contains strings
        local pseudorandom_element_ref=pseudorandom_element
        pseudorandom_element=pseudorandom_element_weighted
        local get_current_pool_ref=get_current_pool
        local ret
        if G.GAME.voucher_pack_name and G.GAME.voucher_pack_name:find('Uncommon') then
            get_current_pool=function(key)
                return get_specific_rarity_vouchers_pool(2)
            end
        elseif G.GAME.voucher_pack_name and G.GAME.voucher_pack_name=='Fusion Voucher Pack' then
            get_current_pool= function(key)
                return get_voucher_pool_with_filter_and_reqs(
                    function(card)
                        return card and card.requires and #card.requires>1
                    end
                )
            end
        end
        ret= get_next_voucher_key_ref(_from_tag)
        
        get_current_pool=get_current_pool_ref
        pseudorandom_element=pseudorandom_element_ref
        return ret
    end


do
    local oversupply_loc_txt = {
        name = "Oversupply",
        text = {
            "Gain {C:attention}1{} {C:attention}Voucher Tag{}",
            "after beating boss blind"
        }
    }
    --function SMODS.Voucher{name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_oversupply = SMODS.Voucher{
        name="Oversupply", key="oversupply",
        config={},
        pos={x=0,y=0}, loc_txt=oversupply_loc_txt,
        cost=10, unlocked=true,discovered=true, available=true,
    }
    local id='oversupply'
    local this_v=v_oversupply
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)
    -- SMODS.Sprite:new("v_oversupply", SMODS.findModByID("BetmmaVouchers").path, "v_oversupply.png", 71, 95, "asset_atli"):register();
    -- v_oversupply:register()
    
    local oversupply_plus_loc_txt = {
        name = "Oversupply Plus",
        text = {
            "Gain {C:attention}1{} {C:attention}Voucher Tag{}",
            "after beating every blind"
            -- if you have both, after beating boss blind you gain only 1 voucher tag
        }
    }
    local v_oversupply_plus = SMODS.Voucher{
            name="Oversupply Plus", key="oversupply_plus",
            config={},
            pos={x=0,y=0}, loc_txt=oversupply_plus_loc_txt,
            cost=10, unlocked=true,discovered=true, available=true, requires={MOD_PREFIX_V..'oversupply'}
    }
    local id='oversupply_plus'
    local this_v=v_oversupply_plus
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)
    -- SMODS.Sprite:new("v_oversupply_plus", SMODS.findModByID("BetmmaVouchers").path, "v_oversupply_plus.png", 71, 95, "asset_atli"):register();
    -- v_oversupply_plus:register()
    -- The v.redeem function mentioned in voucher.lua of steamodded 0.9.5 is bugged when the voucher is given at the beginning of the game (such as challenge or some decks), and also it's not capable of making not one-time effects.
    local end_round_ref = end_round
    function end_round()
        if used_voucher('oversupply') and G.GAME.blind:get_type() == 'Boss' or used_voucher('oversupply_plus') then
            add_tag(Tag('tag_voucher'))
        end
        end_round_ref()
    end


end -- oversupply
do 
    local name="Gold Coin"
    local id="gold_coin"
    local gold_coin_loc_txt = {
        name = name,
        text = {
            "Gain {C:money}$#1#{} immediately.",
            "{C:attention}Small Blind{} gives",
            "no reward money",
            -- yes it literally does nothing bad after white stake
        }
    }
    --function SMODS.Voucher{name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_gold_coin = SMODS.Voucher{
        name=name, key=id,
        config={extra=11},
        pos={x=0,y=0}, loc_txt=gold_coin_loc_txt,
        cost=1, unlocked=true, discovered=true, available=true
    }
    local this_v=v_gold_coin
    handle_atlas(id,this_v)
    -- SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_gold_coin.png", 71, 95, "asset_atli"):register();
    -- v_gold_coin:register()
    v_gold_coin.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Gold Bar"
    local id="gold_bar"
    local gold_bar_loc_txt = {
        name = name,
        text = {
            "Gain {C:money}$#1#{} immediately.",
            "{C:attention}Big Blind{} gives",
            "no reward money",
        }
    }
    --function SMODS.Voucher{name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_gold_bar = SMODS.Voucher{
        name=name, key=id,
        config={extra=16},
        pos={x=0,y=0}, loc_txt=gold_bar_loc_txt,
        cost=1, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'gold_coin'}
    }
    local this_v=v_gold_bar
    handle_atlas(id,this_v)
    -- SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_gold_bar.png", 71, 95, "asset_atli"):register();
    -- v_gold_bar:register()
    v_gold_bar.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Gold Coin' or center_table.name == 'Gold Bar' then
            ease_dollars(center_table.extra)
        end
        if center_table.name == 'Gold Coin' then
            G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
            G.GAME.modifiers.no_blind_reward.Small = true
        end
        if center_table.name == 'Gold Bar' then
            G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
            G.GAME.modifiers.no_blind_reward.Big = true
        end
        Card_apply_to_run_ref(self, center)
    end



end -- gold coin
do 
    
    local name="Abstract Art"
    local id="abstract_art"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}+#1#{} Ante to win,",
            "{C:blue}+#1#{} hand and",
            "{C:red}+#1#{} discard per round"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Mondrian"
    local id="mondrian"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}+#1#{} Ante to win,",
            "{C:attention}+#1#{} Joker slot"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'abstract_art'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Abstract Art' then
            ease_ante_to_win(center_table.extra)
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + center_table.extra
            ease_hands_played(center_table.extra)
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + center_table.extra
            ease_discard(center_table.extra)
        end
        if center_table.name == 'Mondrian' then
            ease_ante_to_win(center_table.extra)
            G.E_MANAGER:add_event(Event({func = function()
                if G.jokers then 
                    G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                end
                return true end }))
        end
        Card_apply_to_run_ref(self, center)
    end


    function ease_ante_to_win(mod)
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
              local ante_UI = G.hand_text_area.ante
              mod = mod or 0
              local text = '+'
              local col = G.C.IMPORTANT
              if mod < 0 then
                  text = '-'
                  col = G.C.RED
              end
              ante_UI.config.object:update()
              --If this line is written in the apply_to_run function above, the ante to win number will increase before the animation begins
              G.GAME.win_ante=G.GAME.win_ante+mod
              G.HUD:recalculate()
              --Popup text next to the chips in UI showing number of chips gained/lost
              attention_text({
                text = text..tostring(math.abs(mod)),
                scale = 1, 
                hold = 0.7,
                cover = ante_UI.parent,
                cover_colour = col,
                align = 'cm',
                })
              --Play a chip sound
              play_sound('highlight2', 0.685, 0.2)
              play_sound('generic1')
              return true
          end
        }))
    end

    
end -- abstract art
do 

    local name="Round Up"
    local id="round_up"
    local loc_txt = {
        name = name,
        text = {
            "{C:blue}Chips{} always round up",
            "to nearest tens",
            "when calculating hands"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    
    local name="Round Up Plus"
    local id="round_up_plus"
    local loc_txt = {
        name = name,
        text = {
            "{C:red}Mult{} always round up",
            "to nearest tens",
            "when calculating hands"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=5},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'round_up'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local mod_chips_ref=mod_chips
    function mod_chips(_chips)
        if used_voucher('round_up') then
          _chips = usingTalisman() and (_chips / Big:new(10)):ceil() * Big:new(10) or math.ceil(_chips/10)*10
        end
        return mod_chips_ref(_chips)
    end
    local mod_mult_ref=mod_mult
    function mod_mult(_mult)
        if used_voucher('round_up_plus') then
            _mult= usingTalisman() and (_mult / Big:new(10)):ceil() * Big:new(10) or math.ceil(_mult/10)*10
        end
        return mod_mult_ref(_mult)
    end


end -- round up
do 
    
    local name="Event Horizon"
    local id="event_horizon"
    local loc_txt = {
        name = name,
        text = {
            "{C:green}#1# in #2#{} chance to",
            "create a {C:spectral}Black Hole{} card",
            "when opening a planet pack.",
            "Create {C:attention}2{} random",
            "{C:dark_edition}Negative{} {C:planet}Planet{} cards now",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=4},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={""..(G.GAME and G.GAME.probabilities.normal or 1),center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Engulfer"
    local id="engulfer"
    local loc_txt = {
        name = name,
        text = {
            "{C:green}#1# in #2#{} chance to",
            "create a {C:spectral}Black Hole{} card",
            "when using a planet card.",
            "Create a {C:spectral}Black Hole{} now",
            "{C:inactive}(Must have room)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=5,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'event_horizon'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={""..(G.GAME and G.GAME.probabilities.normal or 1),center.ability.extra}}
    end
    handle_register(this_v)

    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Event Horizon' then
            
            for i = 1, 2 do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    if 1 then
                        play_sound('timpani')
                        local card = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'Event Horizon')
                        card:set_edition({negative=true},true,false)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                    return true end }))
            end
        end
        if center_table.name == 'Engulfer' then
            create_black_hole()
        end
        Card_apply_to_run_ref(self, center)
    end

    local Card_open_ref=Card.open
    function Card:open()
        if self.ability.set == "Booster" and self.ability.name:find('Celestial') and used_voucher('event_horizon') and
        pseudorandom('event_horizon') < G.GAME.probabilities.normal/get_voucher('event_horizon').config.extra then
            create_black_hole(localize("k_event_horizon_generate"))
        end
        return Card_open_ref(self)
    end

    local G_FUNCS_use_card_ref = G.FUNCS.use_card
    G.FUNCS.use_card =function(e, mute, nosave)
        local card = e.config.ref_table
        if card.ability.consumeable then
            if (card.ability.set == 'Planet' or card.ability.set == "Planet_dx") and used_voucher('engulfer') and pseudorandom('engulfer') < G.GAME.probabilities.normal/get_voucher('engulfer').config.extra then
                create_black_hole(localize("k_engulfer_generate"))
            end
        end
        G_FUNCS_use_card_ref(e, mute, nosave)
    end
    function create_black_hole(message)
        if #G.consumeables.cards + G.GAME.consumeable_buffer >= G.consumeables.config.card_limit then return end
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.0,
            func = (function()
                    local card = create_card('Planet',G.consumeables, nil, nil, nil, nil, 'c_black_hole', 'v_event_horizon_or_v_engulfer')
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                    if message~=nil then
                        card_eval_status_text(card,'extra',nil,nil,nil,{message=message})
                    end
                    return true
                    end)}))
    end

end -- event horizon
do 

    
    local name="Target"
    local id="target"
    local loc_txt = {
        name = name,
        text = {
            "If chips scored are under",
            "{C:attention}#1#%{} of required chips",
            "at end of round,",
            "create a random {C:attention}Joker{} card",
            "{C:inactive}(Must have room)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=120},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Bull's Eye"
    local id="bulls_eye"
    local loc_txt = {
        name = name,
        text = {
            "If chips scored are under",
            "{C:attention}#1#%{} of required chips",
            "at end of round,",
            "create a random",
            "{C:dark_edition}Negative{} {C:attention}Joker{} card"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=105},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'target'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local end_round_ref=end_round
    function end_round()
		local zero = TalismanCompat(0)
        if used_voucher('target') and G.GAME.chips - G.GAME.blind.chips >= zero and G.GAME.chips*TalismanCompat(100) - G.GAME.blind.chips*TalismanCompat(get_voucher('target').config.extra) <= zero then
            if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                randomly_create_joker(jokers_to_create,'target',localize("k_target_generate"))
            end
        end
        if used_voucher('bulls_eye') and G.GAME.chips - G.GAME.blind.chips >= zero and G.GAME.chips*TalismanCompat(100) - G.GAME.blind.chips*TalismanCompat(get_voucher('bulls_eye').config.extra) <= zero then
            randomly_create_joker(1,'target',localize("k_bulls_eye_generate"),{edition={negative=true}})
        end

        end_round_ref()
    end



end -- target
do 

    local name="Voucher Bundle"
    local id="voucher_bundle"
    local loc_txt = {
        name = name,
        text = {
            "Gives {C:attention}#1#{} random vouchers"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=2,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=15, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Voucher Bulk"
    local id="voucher_bulk"
    local loc_txt = {
        name = name,
        text = {
            "Gives {C:attention}#1#{} random vouchers"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=4,rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=25, unlocked=true, discovered=true, available=true,
        requires={MOD_PREFIX_V..'voucher_bundle'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)
        
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Voucher Bundle' then
            for i=1, get_voucher('voucher_bundle').config.extra do
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    delay =  0,
                    func = function() 
                        randomly_redeem_voucher()
                        return true
                    end}))   
            end
        end
        if center_table.name == 'Voucher Bulk' then
            for i=1, get_voucher('voucher_bulk').config.extra do
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    delay =  0,
                    func = function() 
                        randomly_redeem_voucher()
                        return true
                    end}))   
            end
        end
        Card_apply_to_run_ref(self, center)
    end
    -- local Card_redeem_ref = Card.redeem
    -- function Card:redeem() -- use redeem instead of apply to run because redeem happens before modification of used_vouchers
        
    --     local center_table = {
    --         name = self.ability.name,
    --         extra = self.ability.extra
    --     }
    --     if center_table.name == 'Voucher Bundle' then
    --         for i=1, get_voucher('voucher_bundle').config.extra do
    --             G.E_MANAGER:add_event(Event({
    --                 trigger = 'before',
    --                 delay =  0,
    --                 func = function() 
    --                     randomly_redeem_voucher()
    --                     return true
    --                 end}))   
    --         end
    --     end
    --     if center_table.name == 'Voucher Bulk' then
    --         for i=1, get_voucher('voucher_bulk').config.extra do
    --             G.E_MANAGER:add_event(Event({
    --                 trigger = 'before',
    --                 delay =  0,
    --                 func = function() 
    --                     randomly_redeem_voucher()
    --                     return true
    --                 end}))   
    --         end
    --     end

    
    --     Card_redeem_ref(self)
    -- end
    -- local time=0

end -- voucher bundle
do 

    local name="Skip"
    local id="skip"
    local loc_txt = {
        name = name,
        text = {
            "Earn {C:money}$#1#{} when skipping blind"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=4},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Skipper"
    local id="skipper"
    local loc_txt = {
        name = name,
        text = {
            "Get a {C:attention}Double Tag{} when skipping blind"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'skip'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}--{center.ability.extra}
    end
    handle_register(this_v)

    local G_FUNCS_skip_blind_ref=G.FUNCS.skip_blind
    G.FUNCS.skip_blind=function(e)
        if used_voucher('skip') then
            ease_dollars(get_voucher('skip').config.extra)
        end
        if used_voucher('skipper') then
            add_tag(Tag('tag_double'))
        end
        return G_FUNCS_skip_blind_ref(e)
    end

    
end -- skip
do 
        
    local name="Scrawl"
    local id="scrawl"
    local loc_txt = {
        name = name,
        text = {
            "Gives {C:money}$#1#{} for each joker you have,",
            "then randomly create {C:attention}Jokers{}",
            "until joker slots are full"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Scribble"
    local id="scribble"
    local loc_txt = {
        name = name,
        text = {
            "Randomly create {C:attention}#1#{}",
            "{C:dark_edition}Negative{} {C:spectral}Spectral{} cards"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'scrawl'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)
    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Scrawl' then
            ease_dollars(get_voucher('scrawl').config.extra*#G.jokers.cards)
            randomly_create_joker(math.ceil(G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer)),nil,nil)
        end
        if center_table.name == 'Scribble' then
            for i=1, get_voucher('scribble').config.extra do
                randomly_create_spectral(nil,nil,{edition={negative=true}})
            end
        end
        Card_apply_to_run_ref(self, center)
    end

    
end -- scrawl
do 

    local name="Reserve Area"
    local id="reserve_area"
    local loc_txt = {
        name = name,
        text = {
            "You can reserve {C:tarot}Tarot{}",
            "cards instead of using them",
            "when opening a {C:tarot}Tarot Pack{}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}--{center.ability.extra}
    end
    handle_register(this_v)

    
    local name="Reserve Area Plus"
    local id="reserve_area_plus"
    local loc_txt = {
        name = name,
        text = {
            "You can reserve {C:spectral}Spectral{}",
            "cards instead of using them",
            "when opening a {C:spectral}Spectral Pack{}.",
            "Also get an {C:attention}Ethereal Tag{} now"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'reserve_area'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}--{center.ability.extra}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Reserve Area Plus' then
            
            add_tag(Tag('tag_ethereal'))
            -- G.E_MANAGER:add_event(Event({
            --     trigger = 'before',
            --     delay =  0,
            --     func = function() 
                    -- local key = 'p_spectral_mega_1'
                    -- local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                    -- G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    -- card.cost = 0
                    -- G.FUNCS.use_card({config = {ref_table = card}})
                    -- card:start_materialize()
                    -- return true
                -- end}))   
            
            -- Unfortunately I failed to directly open a spectral pack
        end
        Card_apply_to_run_ref(self, center)
    end

    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    function G.UIDEF.use_and_sell_buttons(card)
        if (card.area == G.pack_cards and G.pack_cards) and card.ability.consumeable then --Add a use button
            if G.STATE == G.STATES.TAROT_PACK and used_voucher('reserve_area') or G.STATE == G.STATES.SPECTRAL_PACK and used_voucher('reserve_area_plus') then
                return {
                    n=G.UIT.ROOT, config = {padding = -0.1,  colour = G.C.CLEAR}, nodes={
                      {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, minh = 0.7*card.T.h, maxw = 0.7*card.T.w - 0.15, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_use_consumeable'}, nodes={
                        {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
                      }},
                      {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.1*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'Do you know that this parameter does nothing?', func = 'can_reserve_card'}, nodes={
                        {n=G.UIT.T, config={text = localize('b_reserve'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
                      }},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      -- I can't explain it
                  }}
            end
        end
        return G_UIDEF_use_and_sell_buttons_ref(card)
    end
    G.FUNCS.can_reserve_card = function(e)
        if #G.consumeables.cards < G.consumeables.config.card_limit then 
            e.config.colour = G.C.GREEN
            e.config.button = 'reserve_card' 
        elseif #G.jokers.cards<G.jokers.config.card_limit and used_voucher('forbidden_area') then
            e.config.colour = G.C.GREEN
            e.config.button = 'reserve_card_to_joker_slot' 
        else
          e.config.colour = G.C.UI.BACKGROUND_INACTIVE
          e.config.button = nil
        end
    end
    G.FUNCS.reserve_card = function(e) -- only works for consumeables
        local c1 = e.config.ref_table
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
              c1.area:remove_card(c1)
              c1:add_to_deck()
              if c1.children.price then c1.children.price:remove() end
              c1.children.price = nil
              if c1.children.buy_button then c1.children.buy_button:remove() end
              c1.children.buy_button = nil
              remove_nils(c1.children)
              G.consumeables:emplace(c1)
              G.GAME.pack_choices = G.GAME.pack_choices - 1
              if G.GAME.pack_choices <= 0 then
                G.FUNCS.end_consumeable(nil, delay_fac)
              end
              return true
            end
        }))
    end
    G.FUNCS.reserve_card_to_joker_slot = function(e) -- only works for consumeables
        local c1 = e.config.ref_table
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
              c1.area:remove_card(c1)
              c1:add_to_deck()
              if c1.children.price then c1.children.price:remove() end
              c1.children.price = nil
              if c1.children.buy_button then c1.children.buy_button:remove() end
              c1.children.buy_button = nil
              remove_nils(c1.children)
              G.jokers:emplace(c1)
              G.GAME.pack_choices = G.GAME.pack_choices - 1
              if G.GAME.pack_choices <= 0 then
                G.FUNCS.end_consumeable(nil, delay_fac)
              end
              return true
            end
        }))
    end

    -- local G_UIDEF_card_focus_ui_ref=G.UIDEF.card_focus_ui
    -- function G.UIDEF.card_focus_ui(card)
    -- I suspect that this function does nothing too
    -- because replacing it with empty function seems do no harm

end -- reserve area
do 

    local name="Overkill"
    local id="overkill"
    local loc_txt = {
        name = name,
        text = {
            "If chips scored are above",
            "{C:attention}#1#%{} of required chips",
            "at end of round, add",
            "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{}, or",
            "{C:dark_edition}Polychrome{} edition",
            "to a random {C:attention}Joker"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=300},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true,rarity=2
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    local name="Big Blast"
    local id="big_blast"
    local loc_txt = {
        name = name,
        text = {
            "If chips scored are above",
            "{X:mult,C:white}X#1#{} of required chips",
            "at end of round, add",
            "{C:dark_edition}Negative{} edition to a",
            "random {C:attention}Joker{}, and",
            "increase the target amount",
            "{C:inactive}(This Negative can override){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra={multiplier=5,increase=2},rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'overkill'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        if not center then center={ability=this_v.config} end
        local count=G and G.GAME and G.GAME.v_big_blast_count or 0
        return {vars={center.ability.extra.multiplier*center.ability.extra.increase^(count*(count+1))}}
    end
    handle_register(this_v)
    local v_big_blast=this_v
    local end_round_ref=end_round
    function end_round()
		--compatibility fix for Talisman
		local zero = TalismanCompat(0)
        if used_voucher('overkill') and G.GAME.chips - G.GAME.blind.chips >= zero and G.GAME.chips * TalismanCompat(100) - G.GAME.blind.chips * TalismanCompat(get_voucher('overkill').config.extra) >= zero then
            local temp_pool={}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and (not v.edition) then
                    table.insert(temp_pool, v)
                end
            end
            if #temp_pool>0 then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    local eligible_card = pseudorandom_element(temp_pool, pseudoseed('v_overkill'))
                    local edition = nil
                    edition = poll_edition('wheel_of_fortune', nil, true, true)
                    -- I think using 'wheel_of_fortune' here is ok
                    eligible_card:set_edition(edition, true)
                    check_for_unlock({type = 'have_edition'})
                    
                    card_eval_status_text(eligible_card,'jokers',nil,nil,nil,{message=localize("k_overkill_edition")})
                return true end }))
            end
        end
        if used_voucher('big_blast') and G.GAME.chips - G.GAME.blind.chips >= zero and G.GAME.chips - G.GAME.blind.chips * TalismanCompat(v_big_blast:loc_vars().vars[1]) >= zero then

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    
                local temp_pool={}
                for k, v in pairs(G.jokers.cards) do
                    if v.ability.set == 'Joker' and not (v.edition and v.edition.negative)then 
                        table.insert(temp_pool, v)
                    end
                end
                -- put calculation of temp_pool inside this event because otherwise if v_overkill set an edition it happens 0.4s later, but this temp_pool is calculated at now, potentially causing selecting the same joker
                if #temp_pool>0 then
                    local eligible_card = pseudorandom_element(temp_pool, pseudoseed('v_big_blast'))
                    local edition = nil
                    edition = {negative = true}
                    eligible_card:set_edition(edition, true)
                    check_for_unlock({type = 'have_edition'})
                    card_eval_status_text(eligible_card,'jokers',nil,nil,nil,{message=localize("k_big_blast_edition")})
                end
            return true end }))
            G.GAME.v_big_blast_count=(G.GAME.v_big_blast_count or 0)+1
            
        end

        end_round_ref()
    end


end -- overkill
do 

    local name="3D Boosters"
    local id="3d_boosters"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}+1{} Booster Pack",
            "available in shop"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}--{center.ability.extra}
    end
    handle_register(this_v)
    
    local name="4D Boosters"
    local id="4d_boosters"
    local loc_txt = {
        name = name,
        text = {
            "Rerolls apply to",
            "{C:attention}Booster Packs{}, but",
            "rerolled packs cost",
            "{C:attention}$#1#{} more"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=3,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'3d_boosters'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)
    function get_booster_pack_max()
        local value=2
        if used_voucher('3d_boosters') then value=value+1 end
        return value
    end
    local G_FUNCS_cash_out_ref=G.FUNCS.cash_out
    G.FUNCS.cash_out=function (e)
        G_FUNCS_cash_out_ref(e)
        if used_voucher('3d_boosters') and not ((G.GAME.miser or G.GAME.final_trident) and not G.GAME.blind.disabled and not next(find_joker('Chicot'))) then -- prevent reroll if shop is skipped by Miser or Trident boss in Bunco mod
            my_reroll_shop(get_booster_pack_max()-2,0)
        end
    end
    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == '3D Boosters'then
            if G.shop_booster then
                my_reroll_shop(get_booster_pack_max(),0)
            end
        end
        Card_apply_to_run_ref(self, center)
    end
    local G_FUNCS_reroll_shop_ref=G.FUNCS.reroll_shop
    function G.FUNCS.reroll_shop(e)
        G_FUNCS_reroll_shop_ref(e)
        if used_voucher('4d_boosters') then
            my_reroll_shop(get_booster_pack_max(),get_voucher('4d_boosters').config.extra)
        end
    end
    function my_reroll_shop(num,price_mod)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                if not (G.GAME.current_round and G.GAME.current_round.used_packs and G.shop_booster and G.shop_booster.cards) then
                    return true
                end
                for i = #G.shop_booster.cards,1, -1 do
                    local c = G.shop_booster:remove_card(G.shop_booster.cards[i])
                    c:remove()
                    c = nil
                end
        
                --save_run()
        
                play_sound('coin2')
                play_sound('other1')
                
                for i = 1, num - #G.shop_booster.cards do
                    G.GAME.current_round.used_packs = G.GAME.current_round.used_packs or {}
                    G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key 
                    local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(card, 'Booster', G.shop_booster)
                    card.cost=card.cost+price_mod
                    card.ability.booster_pos = i
                    card:start_materialize()
                    G.shop_booster:emplace(card)
                end
            return true
            end
        }))
        G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
        
    end


end -- 3d boosters
do 


    local name="B1G50%"
    local id="b1g50"
    local loc_txt = {
        name = name,
        text = {
            "When you redeem a {C:attention}Voucher{},",
            "have {C:green}#1#%{} chance to redeem",
            "a {C:attention}higher tier{} Voucher",
            "and pay half the price",
            "{C:inactive}(This chance can't be doubled){}",
            "{C:inactive}(B1G series can't give legendaries){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra={chance=50}},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra.chance}}
    end
    handle_register(this_v)

    
    local name="B1G1"
    local id="b1g1"
    local loc_txt = {
        name = name,
        text = {
            "When you redeem a",
            "{C:attention}Voucher{}, always redeem",
            "a {C:attention}higher tier{} Voucher",
            "and pay the price"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=10,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'b1g50'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

        
    local Card_redeem_ref = Card.redeem
    function Card:redeem() -- use redeem instead of apply to run because redeem happens before modification of used_vouchers
        if not G.GAME.block_b1g1 and (used_voucher('b1g50') and pseudorandom('b1g1')*100 < get_voucher('b1g50').config.extra.chance  or used_voucher('b1g1')) or used_voucher('b1ginf') then
            local lose_percent=50
            if used_voucher('b1g1') then 
                lose_percent=100
            end
            -- lose=math.max(1, math.floor((lose+0.5)*(100-G.GAME.discount_percent)/100)) -- liquidation
            local center_table = {
                name = self.ability.name,
                extra = self.ability.extra
            }
            local vouchers_to_get={}
            for i,v in pairs(G.P_CENTER_POOLS.Voucher) do
                local unredeemed_vouchers={}
                if v.requires and not G.GAME.used_vouchers[v.key]then
                    for i,vv in ipairs(v.requires)do
                        if not G.GAME.used_vouchers[vv] then 
                            table.insert(unredeemed_vouchers,vv)
                        end
                    end
                end
                local only_need=G.P_CENTERS[unredeemed_vouchers[1]]
                if #unredeemed_vouchers==1 and not only_need then
                    print("This voucher key: "..unredeemed_vouchers[1].." is not in G.P_CENTERS!")
                elseif #unredeemed_vouchers==1 and only_need.name==center_table.name and get_rarity(v)~=4 then
                    table.insert(vouchers_to_get,v)
                    if not used_voucher('b1ginf') then break end 
                end
            end
            if #vouchers_to_get>0 then
                Card_redeem_ref(self)
                for i,v in pairs(vouchers_to_get) do
                    local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                    G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, v,{bypass_discovery_center = true, bypass_discovery_ui = true})
                    --create_shop_card_ui(card, 'Voucher', G.shop_vouchers)
                    card:start_materialize()
                    G.play:emplace(card)
                    card.cost=math.ceil(card.cost*lose_percent/100)
                    card.shop_voucher=false -- this doesn't help keeping current_round_voucher i guess
                    local current_round_voucher=G.GAME.current_round.voucher
                    
                    if not used_voucher('b1ginf') then 
                        G.GAME.block_b1g1=true -- can only get 1 extra
                    end 
                    card:redeem()
                    G.GAME.block_b1g1=false

                    G.GAME.current_round.voucher=current_round_voucher -- keep the shop voucher unchanged since the voucher may be from voucher pack or other non-shop source
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
                return -- exit the whole function as Card_redeem_ref has been called
            end
        end
        Card_redeem_ref(self)
    end
    
end -- b1g50
do 

    local name="Collector"
    local id="collector"
    local loc_txt = {
        name = name,
        text = {
            "Each {C:attention}Voucher{} redeemed reduces",
            "Blind requirement by {C:attention}#1#%{}",
            "{C:inactive}(multiplicative){}"
            -- just because modifying get_blind_amount(ante) is easier than
            -- adding mult to score
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=4},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)
    
    local name="Connoisseur"
    local id="connoisseur"
    local loc_txt = {
        name = name,
        text = {
            "If you have more than",
            "{C:money}$#1#/(Vouchers Redeemed + 1){}",
            "that is {C:money}$#2#{}, redeeming",
            "a voucher gives {C:dark_edition}Antimatter{}",
            "and lets the money requirement {C:red}X#3#{}"
            
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra={base=400,multiplier=5},rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'collector'}
    }
    this_v.loc_vars = function(self, info_queue, center)
        if not center then center={ability=this_v.config} end
        local count=G and G.GAME and G.GAME.v_connoisseur_count or 0
        local redeemed=G and G.GAME and G.GAME.vouchers_bought or 0
        return {vars={center.ability.extra.base*center.ability.extra.multiplier^(count),
        math.ceil(center.ability.extra.base/(redeemed+1)*center.ability.extra.multiplier^(count)),center.ability.extra.multiplier}}
    end
    handle_atlas(id,this_v)
    handle_register(this_v)
    local v_connoisseur=this_v

    local get_blind_amount_ref=get_blind_amount
    function get_blind_amount(ante)
        amount=get_blind_amount_ref(ante)
        if used_voucher('collector') then
            amount=amount*TalismanCompat((1-get_voucher('collector').config.extra/100)^(G.GAME.vouchers_bought or 0))
        end
        return amount
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        G.GAME.vouchers_bought=(G.GAME.vouchers_bought or 0)+1
        if center_table.name ~= 'Antimatter'then
            if used_voucher('connoisseur') and G.GAME.dollars>=v_connoisseur:loc_vars().vars[2] then
                G.GAME.v_connoisseur_count= (G.GAME.v_connoisseur_count or 0)+1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    --blockable = false,
                    --blocking = false,
                    delay =  0,
                    func = function() 
                        --ease_dollars(-v_connoisseur:loc_vars().vars[1])
                        -- the description doesn't say you will pay that amount, so don't ease_dollars feels right lol
                        randomly_redeem_voucher("v_antimatter")
                        
                        return true
                    end}))   
            end
        end
        Card_apply_to_run_ref(self, center)
    end

end -- collector
do 

    local name="Flipped Card"
    local id="flipped_card"
    local loc_txt = {
        name = name,
        text = {
            "You can {C:attention}flip{} up to #1# cards",
            "once before playing each hand.",
            "{C:attention}Flipped{} cards will return",
            "to your hand after they are played"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=3,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)
    
    local name="Double Flipped Card"
    local id="double_flipped_card"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}Flipped{} cards are",
            "held in hand when scoring and",
            "can trigger hold-in-hand effects"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'flipped_card'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)
    
    local create_UIBox_buttons_ref=create_UIBox_buttons
    function create_UIBox_buttons()
        local ret=create_UIBox_buttons_ref()
        local text_scale=0.45
        local button_height=1.3
        if (used_voucher('flipped_card') or used_voucher('double_flipped_card')) then
            local flip_button={n=G.UIT.C, config={id = 'flip_button', align = "tm", minw = 2.5, padding = 0.3, r = 0.1, hover = true, colour = G.C.PURPLE, button = "this is another useless parameter", one_press = true, shadow = true, func = 'can_flip'}, nodes={
                {n=G.UIT.R, config={align = "bcm", padding = 0}, nodes={
                {n=G.UIT.T, config={text = localize('b_flip_hand'), scale = text_scale, colour = G.C.UI.TEXT_LIGHT, focus_args = {button = 'x', orientation = 'bm'}, func = 'set_button_pip'}}
                }},
            }}
            table.insert(ret.nodes,flip_button)
        end
        return ret
    end

    local G_FUNCS_play_cards_from_highlighted_ref=G.FUNCS.play_cards_from_highlighted
    G.FUNCS.play_cards_from_highlighted=function(e)
        for i=1, #G.hand.highlighted do
            G.hand.highlighted[i].facing_ref=G.hand.highlighted[i].facing
        end
        -- when played all cards will be face up so its facing status before playing should be saved elsewhere
        G.GAME.current_round.flips_left=1
        local ret= G_FUNCS_play_cards_from_highlighted_ref(e)
        return ret
    end

    local new_round_ref=new_round
    function new_round()
        G.GAME.current_round.flips_left=1
        new_round_ref()
    end

    G.FUNCS.can_flip=function(e)
        if #G.hand.highlighted <= 0 or #G.hand.highlighted > get_voucher('flipped_card').config.extra or G.GAME.current_round.flips_left <= 0 then 
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.PURPLE
            e.config.button = 'flip_cards_from_highlighted'
        end
    end
    
    G.FUNCS.flip_cards_from_highlighted=function(e)
        stop_use()
        G.CONTROLLER.interrupt.focus = true
        G.CONTROLLER:save_cardarea_focus('hand')
        for i=1, #G.hand.highlighted do
            G.hand.highlighted[i]:flip()
        end
        G.GAME.current_round.flips_left=(G.GAME.current_round.flips_left or 1)-1
    end


    local G_FUNCS_draw_from_play_to_discard_ref=G.FUNCS.draw_from_play_to_discard
    G.FUNCS.draw_from_play_to_discard = function(e)
        if (used_voucher('flipped_card') and not used_voucher('double_flipped_card')) then
            local play_count = #G.play.cards --G.GAME.scoring_hand --G.GAME.scoring_hand is stored in eval_hand by me
            local it = 1
            local flag=false
            for k, v in ipairs(G.play.cards) do
                if v.facing_ref=='back' and (not v.shattered) and (not v.destroyed) and (not v.debuff)then
                    draw_card(G.play,G.hand, it*100/play_count,'down', false, v)
                    v.facing_ref=v.facing
                    it = it + 1
                    flag=true
                end
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()     
                G_FUNCS_draw_from_play_to_discard_ref(e)
            return true end)
          }))
       
    end

    local eval_card_ref=eval_card
    function eval_card(card, context) -- debuffed card won't call this
        local ret = eval_card_ref(card,context)
        G.GAME.scoring_hand=context.scoring_hand
        if context.cardarea == G.play and not context.repetition_only and (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and used_voucher('double_flipped_card') and card.facing_ref=='back' then
            if (not card.shattered) and (not card.destroyed) then 
                draw_card_immediately(G.play,G.hand, 0.1,'down', false, card)
                card.facing_ref=card.facing
            end
        end
        return ret
    end
    
    function draw_card_immediately(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
        -- the value of hand is calculated immediately, and the animation takes time. The vanilla draw_card includes add_event which isn't immediate, but in eval_card we need to immediately move the double_flipped_card to hand so that in following calculation G.hand will include these cards.
        percent = percent or 50
        delay = delay or 0.1 
        if dir == 'down' then 
            percent = 1-percent
        end
        sort = sort or false
        local drawn = nil
        if card then 
            if from then card = from:remove_card(card) end
            if card then drawn = true end
            local stay_flipped = G.GAME and G.GAME.blind and G.GAME.blind:stay_flipped(to, card)
            if G.GAME.modifiers.flipped_cards and to == G.hand then
                if pseudorandom(pseudoseed('flipped_card')) < 1/G.GAME.modifiers.flipped_cards then
                    stay_flipped = true
                end
            end
            to:emplace(card, nil, stay_flipped)
        else
            if to:draw_card_from(from, stay_flipped, discarded_only) then drawn = true end
        end
        if not mute and drawn then
            if from == G.deck or from == G.hand or from == G.play or from == G.jokers or from == G.consumeables or from == G.discard then
                G.VIBRATION = G.VIBRATION + 0.6
            end
            play_sound('card1', 0.85 + percent*0.2/100, 0.6*(vol or 1))
        end
        if sort then
            to:sort()
        end
        return true
    end


end -- flipped card
do 

    local name="Prologue"
    local id="prologue"
    local loc_txt = {
        name = name,
        text = {
            "When blind begins, create",
            "an {C:attention}Eternal{} {C:tarot}Tarot{} card.",
            "This card disappears when a",
            "new Prologue card is created",
            "{C:inactive}(Must have room)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local name="Epilogue"
    local id="epilogue"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}+1{} consumable slot.",
            "When blind ends, create an",
            "{C:attention}Eternal{} {C:spectral}Spectral{} card.",
            "This card disappears when a",
            "new Epilogue card is created",
            "{C:inactive}(Must have room)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'prologue'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Epilogue' then
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
        end
        Card_apply_to_run_ref(self, center)
    end

    local new_round_ref=new_round
    function new_round()
        if used_voucher('prologue') then
            for i=1,#G.consumeables.cards do
                if G.consumeables.cards[i].ability.v_prologue then
                    G.consumeables.cards[i]:start_dissolve(nil,nil)
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = (function() randomly_create_tarot('v_prologue',nil,{eternal=true,extra_ability='v_prologue'}) return true end)
            }))
        end
        return new_round_ref()
    end

    local end_round_ref = end_round
    function end_round()
        for i=1,#G.consumeables.cards do
            if G.consumeables.cards[i].ability.v_epilogue then
                G.consumeables.cards[i]:start_dissolve(nil,nil)
            end
        end
        if used_voucher('epilogue') then
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = (function() randomly_create_spectral('v_epilogue',nil,{eternal=true,extra_ability='v_epilogue'}) return true end)
            }))
            --,edition={negative=true}
        end
        end_round_ref()
    end
end -- prologue
do 

    local name="Bonus+"
    local id="bonus_plus"
    local loc_txt = {
        name = name,
        text = {
            "Permanently increases",
            "{C:blue}Bonus Card{} bonus",
            "by {C:blue}+#1#{} extra chips",
            "{C:inactive}(e.g. +30 -> +#2#){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=30},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra,center.ability.extra+30}}
    end
    handle_register(this_v)

    local name="Mult+"
    local id="mult_plus"
    local loc_txt = {
        name = name,
        text = {
            "Permanently increases",
            "{C:red}Mult cards{} bonus",
            "by {C:red}+#1#{} Mult",
            "{C:inactive}(e.g. +4 -> +#2#){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=8},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'bonus_plus'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra,center.ability.extra+4}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Bonus+' then
            G.P_CENTERS.m_bonus.config.bonus=G.P_CENTERS.m_bonus.config.bonus+get_voucher('bonus_plus').config.extra
            for k, v in pairs(G.playing_cards) do
                if v.config.center_key == 'm_bonus' then v:set_ability(G.P_CENTERS['m_bonus']) end
            end
        
        end
        if center_table.name == 'Mult+' then
            G.P_CENTERS.m_mult.config.mult=G.P_CENTERS.m_mult.config.mult+get_voucher('mult_plus').config.extra
            for k, v in pairs(G.playing_cards) do
                if v.config.center_key == 'm_mult' then v:set_ability(G.P_CENTERS['m_mult']) end
            end
        end
        Card_apply_to_run_ref(self, center)
    end

end -- bonus+
do 

    local name="Omnicard"
    local id="omnicard"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}Wild Cards{} can't be",
            "debuffed. Retrigger",
            "all {C:attention}Wild Cards{}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local name="Bulletproof"
    local id="bulletproof"
    local loc_txt = {
        name = name,
        text = {
            -- "{C:attention}Glass Cards{} can",
            -- "break #1# times"
            "{C:attention}Glass Cards{} lose {X:mult,C:white}X#1#{}",
            "instead of breaking.",
            "They break when",
            "they reach {X:mult,C:white}X#2#{}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra={lose=0.1,lower_bound=1.5},rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'omnicard'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra.lose,center.ability.extra.lower_bound}}
    end
    handle_register(this_v)

    local Card_set_debuff=Card.set_debuff
    function Card:set_debuff(should_debuff)
        if used_voucher('omnicard') and self.config and self.config.center_key=='m_wild' then
            should_debuff=false
            if self.params.debuff_by_curse then -- DX tarots mod curses that still debuff when should_debuff is false
                self.params.debuff_by_curse=false
            end
        end
        Card_set_debuff(self,should_debuff)
    end

    local Card_calculate_seal_ref=Card.calculate_seal
    function Card:calculate_seal(context)
        local ret=Card_calculate_seal_ref(self,context)
        if context.repetition and used_voucher('omnicard') and self.config and self.config.center_key=='m_wild' then
            if ret then
                ret.repetitions=ret.repetitions+1
            else
                ret={
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    card = self
                }
            end
        end
        return ret
    end

    local Card_shatter_ref=Card.shatter
    function Card:shatter()
        if used_voucher('bulletproof') and self.ability.name == 'Glass Card' and self.ability.x_mult-get_voucher('bulletproof').config.extra.lose>get_voucher('bulletproof').config.extra.lower_bound then
            self.ability.breaking_count=(self.ability.breaking_count or 0)+1
            self.ability.x_mult=self.ability.x_mult-get_voucher('bulletproof').config.extra.lose
            --print(G.P_CENTERS.m_glass.config.Xmult,self.ability.x_mult)
            self.config.center=copy_table(self.config.center) -- prevent modifying value of G.P_CENTERS.m_glass
            self.config.center.config.Xmult=self.ability.x_mult--self.config.center.config.Xmult-get_voucher('bulletproof').config.extra.lose
            self.shattered=false
            self.destroyed=false
            card_eval_status_text(self,'extra',nil,nil,nil,{message=localize('k_bulletproof')})
            card_eval_status_text(self,'extra',nil,nil,nil,{message=localize{type='variable',key='a_xmult_minus',vars={get_voucher('bulletproof').config.extra.lose}},colour=G.C.RED})
            Card_shatter_not_remove(self)
            return
        end
        Card_shatter_ref(self)
    end
    
    function Card_shatter_not_remove(self)
        local dissolve_time = 0.7
        -- self.dissolve = 0
        self.dissolve_colours = {{1,1,1,0.8}}
        -- self:juice_up()
        local childParts = Particles(0, 0, 0,0, {
            timer_type = 'TOTAL',
            timer = 0.007*dissolve_time,
            scale = 0.3,
            speed = 4,
            lifespan = 0.5*dissolve_time,
            attach = self,
            colours = self.dissolve_colours,
            fill = true
        })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            blockable = false,
            delay =  0.5*dissolve_time,
            func = (function() childParts:fade(0.15*dissolve_time) return true end)
        }))
        G.E_MANAGER:add_event(Event({
            blockable = false,
            func = (function()
                    play_sound('glass'..math.random(1, 6), math.random()*0.2 + 0.9,0.5)
                    play_sound('generic1', math.random()*0.2 + 0.9,0.5)
                return true end)
        }))
        -- G.E_MANAGER:add_event(Event({
        --     trigger = 'ease',
        --     blockable = false,
        --     ref_table = self,
        --     ref_value = 'dissolve',
        --     ease_to = 1,
        --     delay =  0.5*dissolve_time,
        --     func = (function(t) return t end)
        -- }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            blockable = false,
            delay =  0.55*dissolve_time,
            func = (function()  return true end)
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            blockable = false,
            delay =  0.51*dissolve_time,
        }))
    end
end -- omnicard
do 

    local name="Cash Clutch"
    local id="cash_clutch"
    local loc_txt = {
        name = name,
        text = {
            "At end of each Round,",
            "earn extra {C:money}$#1#{}",
            "per remaining {C:blue}Hand",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local name="Inflation"
    local id="inflation"
    local loc_txt = {
        name = name,
        text = {
            "At end of each Round,",
            "earn extra {C:money}$#1#{}",
            "per remaining {C:blue}Hand",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'cash_clutch'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Cash Clutch' or center_table.name=='Inflation' then
            G.GAME.modifiers.money_per_hand = (G.GAME.modifiers.money_per_hand or 1) +center_table.extra
            if used_voucher('trash_picker') then
                G.GAME.modifiers.money_per_discard = (G.GAME.modifiers.money_per_discard or 0) +center_table.extra
            end
        end
        Card_apply_to_run_ref(self, center)
    end

end -- Cash Clutch
do 

    local name="Eternity"
    local id="eternity"
    local loc_txt = {
        name = name,
        text = {
            "Shop can have {C:attention}Eternal{} Jokers.",
            "{C:inactive,s:0.8}(Can't be sold or destroyed)",
            "{C:attention}Eternal{} Jokers have {C:green}#1#%{}",
            "chance to be {C:dark_edition}Negative{}",
            "{C:inactive}(This chance can't be doubled){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=2.5,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={100/center.ability.extra}}
    end
    handle_register(this_v)

    local name="Half-life"
    local id="half_life"
    local loc_txt = {
        name = name,
        text = {
            "Shop can have {C:attention}Perishable{} Jokers.",
            "{C:inactive,s:0.8}(Debuffed after 5 Rounds)",
            "{C:attention}Perishable{} Jokers only",
            "take up {C:attention}#1#{} Joker slots",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=0.5,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'eternity'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    -- get the amount of extra joker slot by half-life jokers 
    -- WARNING: implement of half-life is NOT setting perishable jokers to only take up 0.5 joker slots, instead it's setting perishable jokers to add 0.5 joker slots like negative edition. With this the display of joker area UI will be like 5/5.5 which wasn't I want, so I modified the CardArea:update to reduce card count by the function value. At other situations the game always use #G.jokers.cards so this does no harm. For joker limit it's not practical to directly decrease it since it's the real value, so I stored the modified value in self.config.card_limit_ref and used a lovely patch to let the ui use this value if the cardarea is joker area and half_life has been redeemed.
    local function get_half_life_delta()
        if not G.jokers.cards or not used_voucher('half_life')then return 0 end
        local ret=0
        local delta_value=get_voucher('half_life').config.extra
        for i=1,#G.jokers.cards do
            if G.jokers.cards[i].ability.perishable and not G.jokers.cards[i].debuff then
                ret=ret+delta_value
            end
        end
        return ret
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Eternity' then
            G.GAME.modifiers.enable_eternals_in_shop=true
        end
        if center_table.name == 'Half-life' then
            G.GAME.modifiers.enable_perishables_in_shop=true
            G.jokers.config.card_limit = G.jokers.config.card_limit +get_half_life_delta()
        end

        Card_apply_to_run_ref(self, center)
    end

    local create_card_ref=create_card
    function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        local card=create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        if used_voucher('eternity') and _type == 'Joker' and ((area == G.shop_jokers) or (area == G.pack_cards)) and card.ability.eternal then
            if pseudorandom('eternity')<1/get_voucher('eternity').config.extra then
                card:set_edition{negative=true}
            end
        end
        return card
    end

    local Card_add_to_deck_ref=Card.add_to_deck
    function Card:add_to_deck(from_debuff)
        if not self.added_to_deck and self.ability.perishable and used_voucher('half_life') and not self.ability.consumeable then
            G.jokers.config.card_limit = G.jokers.config.card_limit + get_voucher('half_life').config.extra
        end
        Card_add_to_deck_ref(self,from_debuff)
    end
    local Card_remove_from_deck_ref=Card.remove_from_deck
    function Card:remove_from_deck(from_debuff)
        if self.added_to_deck and self.ability.perishable and used_voucher('half_life') and not self.ability.consumeable then
            G.jokers.config.card_limit = G.jokers.config.card_limit - get_voucher('half_life').config.extra
        end
        Card_remove_from_deck_ref(self,from_debuff)
    end

    local CardArea_update_ref=CardArea.update
    function CardArea:update(dt)
        CardArea_update_ref(self,dt)
        if self==G.jokers and used_voucher('half_life')then
            local delta=get_half_life_delta()
            self.config.card_count=self.config.card_count-delta
            self.config.card_limit_ref=self.config.card_limit-delta
        end
    end

    local CardArea_draw_ref=CardArea.draw
    function CardArea:draw()
        CardArea_draw_ref(self)
    end
end -- eternity
do 
    local name="Debt Burden"
    local id="debt_burden"
    local loc_txt = {
        name = name,
        text = {
            "Shop can have {C:attention}Rental{} Jokers.",
            "{C:inactive,s:0.8}(Costs {C:money,s:0.8}$3{C:inactive,s:0.8} per round only if you",
            "{C:attention,s:0.8}aren't in debt before round ends{C:inactive,s:0.8})",
            "Each {C:attention}Rental{} Joker increases",
            "debt limit by {C:red}-$#1#{}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=10,rarity=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local name="Bobby Pin"
    local id="bobby_pin"
    local loc_txt = {
        name = name,
        text = {
            "Shop can have {C:attention}Pinned{} Jokers.",
            "{C:inactive,s:0.8}(Stays pinned to the leftmost position)",
            "Each {C:attention}Pinned{} Joker copies",
            "ability of {C:attention}Joker{} to the right",
            "if itself {C:attention}isn't triggered{}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'debt_burden'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    -- should change rental side ui

    local function get_debt_burden_delta()
        if not G.jokers.cards or not used_voucher('debt_burden')then return 0 end
        local ret=0
        local delta_value=get_voucher('debt_burden').config.extra
        for i=1,#G.jokers.cards do
            if G.jokers.cards[i].ability.rental and not G.jokers.cards[i].debuff then
                ret=ret+delta_value
            end
        end
        return ret
    end
    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Debt Burden' then
            G.GAME.modifiers.enable_rentals_in_shop=true
            G.GAME.bankrupt_at = G.GAME.bankrupt_at - get_debt_burden_delta()
        end
        if center_table.name == 'Bobby Pin' then
            G.GAME.modifiers.cry_enable_pinned_in_shop=true
        end

        Card_apply_to_run_ref(self, center)
    end

    local Card_calculate_rental_ref=Card.calculate_rental
    function Card:calculate_rental()
        if used_voucher('debt_burden') and G.GAME.dollars<0 then
            return
        end
        Card_calculate_rental_ref(self)
    end
    
    local Card_add_to_deck_ref=Card.add_to_deck
    function Card:add_to_deck(from_debuff)
        if not self.added_to_deck and self.ability.rental and used_voucher('debt_burden') and not self.ability.consumeable then
            G.GAME.bankrupt_at = G.GAME.bankrupt_at - get_voucher('debt_burden').config.extra
        end
        Card_add_to_deck_ref(self,from_debuff)
    end
    local Card_remove_from_deck_ref=Card.remove_from_deck
    function Card:remove_from_deck(from_debuff)
        if self.added_to_deck and self.ability.rental and used_voucher('debt_burden') and not self.ability.consumeable then
            G.GAME.bankrupt_at = G.GAME.bankrupt_at + get_voucher('debt_burden').config.extra
        end
        Card_remove_from_deck_ref(self,from_debuff)
    end

    local create_card_ref=create_card
    function create_card(_type, area, legendary, _rarity, 
        skip_materialize, soulable, forced_key, key_append)
        local card=create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        if not usingCryptid and G.GAME.modifiers.cry_enable_pinned_in_shop then
            if _type == 'Joker' and ((area == G.shop_jokers) or (area == G.pack_cards)) and pseudorandom('cry_pin'..(key_append or '')..G.GAME.round_resets.ante) > 0.7 then
                card.pinned = true
            end
        end
        return card
    end

    local Card_calculate_joker_ref=Card.calculate_joker
    function Card:calculate_joker(context)
        local ret=Card_calculate_joker_ref(self,context)
        if self.ability.set=='Joker' and not self.debuff and self.pinned and used_voucher('bobby_pin') and ret==nil then
            local other_joker = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == self then other_joker = G.jokers.cards[i+1] end
            end
            if other_joker and other_joker ~= self then
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
        return ret
    end




end -- debt burden
do 
    local name="Stow"
    local id="stow"
    local loc_txt = {
        name = name,
        text = {
            "{C:dark_edition}+#1#{} Joker Slot.",
            "Leftmost joker is debuffed",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1,rarity=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local name="Stash"
    local id="stash"
    local loc_txt = {
        name = name,
        text = {
            "{C:dark_edition}+#1#{} Joker Slot.",
            "Rightmost joker is debuffed",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1,rarity=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'stow'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)
    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Stow' or center_table.name == 'Stash' then
            G.E_MANAGER:add_event(Event({func = function()
                if G.jokers then 
                    G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                end
                return true end }))
        end
        Card_apply_to_run_ref(self, center)
    end
    local function is_hidden(joker)
        if not (G and G.jokers and G.jokers.cards)then return end
        local index=get_index_in_array(G.jokers.cards,joker)
        if index==1 and used_voucher('stow') or index==#G.jokers.cards and used_voucher('stash') then
            return true
        end
        return false
    end
    local Card_draw_ref=Card.draw
    function Card:draw(layer)
        if is_hidden(self)then
            Card_draw_ref(self,layer)
            self.children.center:draw_shader('debuff', nil, self.ARGS.send_to_shader)
            if self.children.front and self.ability.effect ~= 'Stone Card' then
                self.children.front:draw_shader('debuff', nil, self.ARGS.send_to_shader)
            end
            return
        end
        Card_draw_ref(self,layer)
    end
    local Card_calculate_joker_ref=Card.calculate_joker
    function Card:calculate_joker(context)
        if is_hidden(self)then
            return nil
        end
        return Card_calculate_joker_ref(self,context)
    end

end -- stow
do 
    local name="Undying"
    local id="undying"
    local loc_txt = {
        name = name,
        text = {
            "When a non-{C:dark_edition}Phantom{} Joker is",
            "destroyed, create a {C:dark_edition}Phantom{} copy",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local name="Reincarnate"
    local id="reincarnate"
    local loc_txt = {
        name = name,
        text = {
            "When a {C:dark_edition}Phantom{} Joker is sold,",
            "create a joker of same {C:attention}rarity{}",
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1,rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'undying'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)
    
    -- Phantom and its calculation are in phantom.lua

end -- undying


    -- ################
    -- fusion vouchers!
do
    if not G.ARGS.LOC_COLOURS then loc_colour() end
    if not G.ARGS.LOC_COLOURS["fusion"] then G.ARGS.LOC_COLOURS["fusion"] = HEX("F7D762") end
    local card_h_popupref = G.UIDEF.card_h_popup
    function G.UIDEF.card_h_popup(card)
        local retval = card_h_popupref(card)
        if not card.config.center or -- no center
        (card.config.center.unlocked == false and not card.bypass_lock) or -- locked card
        card.debuff or -- debuffed card
        (not card.config.center.discovered and ((card.area ~= G.jokers and card.area ~= G.consumeables and card.area) or not card.area)) -- undiscovered card
        then return retval end
        if card.ability.set=='Voucher' and card.config.center.mod_name=='Betmma Vouchers' and card.config.center.requires and #card.config.center.requires>1 then
            local ret=retval.nodes[1].nodes[1].nodes[1].nodes
            ret[#ret].nodes[1].nodes[1].nodes[2].config.object:remove()
            ret[#ret].nodes[1] = create_badge(localize('k_fusion_voucher'), loc_colour("fusion", nil), nil, 1.2)
        end
        if card.ability.set=='Voucher' then
            local index=card.config and card.config.center and card.config.center.config and card.config.center.config.rarity or 1
            index=normalize_rarity(index)
            local card_type=({localize('k_common'), localize('k_uncommon'), localize('k_rare'), localize('k_legendary')})[index]
            local ret=retval.nodes[1].nodes[1].nodes[1].nodes
            table.insert(ret[#ret].nodes,2,create_badge(card_type,G.C.RARITY[index],nil,1.2))
        end

        return retval
    end
end -- add Fusion Voucher badge for fusions and rarity badge for all vouchers

do 
    local name="Gold Round Up"
    local id="gold_round_up"
    local loc_txt = {
        name = name,
        text = {
            "Your {C:money}money{} always rounds up",
            "to nearest even number",
            "{C:inactive}(Round Up + Gold Coin){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'round_up',MOD_PREFIX_V..'gold_coin'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)
    local ease_dollars_ref = ease_dollars
    function ease_dollars(mod, instant)
        if used_voucher('gold_round_up') then
            local original=G.GAME.dollars+mod
            local new=math.ceil(original)
            if new % 2 == 1 then
                new=new+1
            end
            mod=mod+(new-original)
        end
        ease_dollars_ref(mod, instant)
    end

end -- gold round up
do 

    local name="Overshopping"
    local id="overshopping"
    local loc_txt = {
        name = name,
        text = {
            "You can shop",
            "after skipping blinds",
            "{C:inactive}(Overstock + Oversupply)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_overstock_norm',MOD_PREFIX_V..'oversupply'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)
    
    local G_FUNCS_skip_blind_ref=G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        G_FUNCS_skip_blind_ref(e)
        if used_voucher('overshopping') then
            --stop_use()
            -- from G.FUNCS.select_blind
            G.blind_select:remove()
            G.blind_prompt_box:remove()
            -- from cash_out()
            G.STATE = G.STATES.SHOP
            G.GAME.shop_free = nil
            G.GAME.shop_d6ed = nil
            G.STATE_COMPLETE = false
            G.GAME.current_round.reroll_cost_increase = 0
            -- from new_round()
            G.GAME.current_round.used_packs = {}
            local chaos = find_joker('Chaos the Clown')
            G.GAME.current_round.free_rerolls = #chaos
            calculate_reroll_cost(true)
            
            if used_voucher('3d_boosters') then
                my_reroll_shop(get_booster_pack_max()-2,0)
            end
            G:update_shop(dt)
        end
    end

end -- overshopping
do 
    local name="Reroll Cut"
    local id="reroll_cut"
    local loc_txt = {
        name = name,
        text = {
            "Rerolling boss blind",
            "also rerolls tags, and",
            "gives a random tag",
            "{C:inactive}(Director's Cut + Reroll Surplus)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_directors_cut','v_reroll_surplus'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local G_FUNC_reroll_boss_ref =  G.FUNCS.reroll_boss
    G.FUNCS.reroll_boss = function(e) 
        if G.STATE~=G.STATES.BLIND_SELECT then return end
        G_FUNC_reroll_boss_ref(e)
        
        if used_voucher('reroll_cut') then -- adding a pack tag when in a pack causes double pack and will crash
            stop_use()
            if G.GAME.round_resets.blind_states.Small ~= 'Defeated' then 
                G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
                --create_UIBox_blind_choice('Small', true)
            end
            if G.GAME.round_resets.blind_states.Big ~= 'Defeated' then 
                G.GAME.round_resets.blind_tags.Big = get_next_tag_key()
                --create_UIBox_blind_choice('Big', true)
            end
            local random_tag_key = get_next_tag_key()
            while random_tag_key == 'tag_boss' do -- reroll boss tag will cause double blind select box
                random_tag_key = get_next_tag_key()
            end
            if not G.GAME.orbital_choices[G.GAME.round_resets.ante][type] then -- orbital tag
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
            
                G.GAME.orbital_choices[G.GAME.round_resets.ante]['Small'] = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
              end
            local random_tag=Tag(random_tag_key,false,'Small')
        
            if G.blind_select then G.blind_select:remove()end
            G.blind_prompt_box:remove()
            G.blind_select = nil
            G.STATE_COMPLETE=false
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = (function() 
                    
                add_tag(random_tag)
                    return true end)
            }))
            --create_UIBox_blind_select()
        end
    end
end -- reroll cut
do 
    local name="Vanish Magic"
    local id="vanish_magic"
    local loc_txt = {
        name = name,
        text = {
            "You can make playing cards",
            "in the shop vanish and",
            "earn {C:money}$#1#{} for each",
            "{C:inactive}(Magic Trick + Blank)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_magic_trick','v_blank'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    G.FUNCS.vanish_card = function(e)
        local card = e.config.ref_table
        card:start_dissolve(nil,nil)
        ease_dollars(get_voucher('vanish_magic').config.extra)
    end
    
    G.FUNCS.can_vanish_card = function(e)
        e.config.colour = G.C.DARK_EDITION
        e.config.button = 'vanish_card'
    end

    local Card_highlight_ref=Card.highlight
    function Card:highlight(is_higlighted)
        if self.area and self.area.config.type == 'shop' and (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and used_voucher('vanish_magic') then
            -- if self.children.use_button then
            -- self.children.use_button:remove()
            -- self.children.use_button = nil
            -- end
            if 1 then
                local x_off = (self.ability.consumeable and -0.1 or 0)
                self.children.buy_button = UIBox{
                    definition = G.UIDEF.use_and_sell_buttons(self), 
                    config = {align=
                            ((self.area == G.jokers) or (self.area == G.consumeables)) and "cr" or
                            "bmi"
                        , offset = 
                            ((self.area == G.jokers) or (self.area == G.consumeables)) and {x=x_off - 0.4,y=0} or
                            {x=0,y=0.65},
                        parent =self}
                }
                local tst=self.children
            end
            --create_shop_card_ui(self)
            --return Card_highlight_ref(self,is_higlighted)
        end
        return Card_highlight_ref(self,is_higlighted)
    end

    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    function G.UIDEF.use_and_sell_buttons(card)
        local retval = G_UIDEF_use_and_sell_buttons_ref(card)
        if card.area and card.area.config.type == 'shop' and (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and used_voucher('vanish_magic') then
            local buy={
            n=G.UIT.R, config = {ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.GOLD, shadow = true, r = 0.08, minh = 0.94, func = 'can_buy', one_press = true, button = 'buy_from_shop', hover = true}, nodes={
                {n=G.UIT.T, config={text = localize('b_buy'),colour = G.C.WHITE, scale = 0.5}}
            }}
            local vanish = 
            {n=G.UIT.R, config={align = "bm"}, nodes={
            
            {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.GOLD, one_press = true, button = 'useless parameter lol', func = 'can_vanish_card'}, nodes={
                {n=G.UIT.B, config = {w=0.1,h=0.6}},
                {n=G.UIT.C, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                        {n=G.UIT.T, config={text = localize('b_vanish'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.T, config={text = '+'..localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
                        {n=G.UIT.T, config={ref_table = get_voucher('vanish_magic').config, ref_value = 'extra',colour = G.C.WHITE, scale = 0.55, shadow = true}}
                    }}
                }}
            }}
            }}
            retval.nodes[1].nodes[2].config.padding=-0.1
            retval.nodes[1].nodes[2].nodes = retval.nodes[1].nodes[2].nodes or {}
            table.insert(retval.nodes[1].nodes[2].nodes, buy)
            table.insert(retval.nodes[1].nodes[2].nodes, vanish)
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            return retval
        end
        return retval
    end
    
end -- vanish magic
do 
    local name="Darkness"
    local id="darkness"
    local loc_txt = {
        name = name,
        text = {
            "{C:dark_edition}Negative{} cards",
            "appear {C:attention}#1#X{} more often",
            "{C:inactive}(Glow Up + Antimatter)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=4},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_glow_up','v_antimatter'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local poll_edition_ref=poll_edition
    function poll_edition(_key, _mod, _no_neg, _guaranteed)
        _mod=_mod or 1
        if used_voucher('darkness') then
            local ret=poll_edition_ref(_key, _mod*(get_voucher('darkness').config.extra-1), _no_neg, _guaranteed)
            if ret and ret.negative then
                return ret
            end
        end
        return poll_edition_ref(_key, _mod, _no_neg, _guaranteed)
    end

end -- darkness
do
    local name="Double Planet"
    local id="double_planet"
    local loc_txt = {
        name = name,
        text = {
            "Create a random {C:planet}Planet{} card",
            "when buying a Planet card",
            "{C:inactive}(Must have room)",
            "{C:inactive}(Planet Merchant + B1G50%)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_planet_merchant',MOD_PREFIX_V..'b1g50'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local G_FUNCS_buy_from_shop_ref=G.FUNCS.buy_from_shop
    G.FUNCS.buy_from_shop = function(e)
        local c1 = e.config.ref_table
        local ret=G_FUNCS_buy_from_shop_ref(e)
        if c1.ability.consumeable and (c1.config.center.set == 'Planet' or c1.config.center.set =="Planet_dx") and ret~=false and used_voucher('double_planet') and #G.consumeables.cards + G.GAME.consumeable_buffer + 1 < G.consumeables.config.card_limit then -- "Planet_dx" is for deluxe consumable mod, +1 is because buy_from_shop adds a card in an event that is executed after this code
            randomly_create_planet('v_double_planet','Double Planet!',nil)
        end
    end
end -- double planet
do
    local name="Trash Picker"
    local id="trash_picker"
    local loc_txt = {
        name = name,
        text = {
            "{C:blue}+#1#{} hand and {C:red}+#1#{} discard per round.",
            "You can spend 1 hand to discard if",
            "no discards left. {C:red}Discards{} {C:money}earn{}",
            "as much as {C:blue}Hands{} after rounds",
            "{C:inactive}(Grabber + Wasteful)"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_grabber','v_wasteful'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Trash Picker' then
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + center_table.extra
            ease_hands_played(center_table.extra)
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + center_table.extra
            ease_discard(center_table.extra)
            G.GAME.modifiers.money_per_discard = G.GAME.modifiers.money_per_hand or 1
        end
        Card_apply_to_run_ref(self, center)
    end
    
    local G_FUNCS_can_discard_ref=G.FUNCS.can_discard
    G.FUNCS.can_discard = function(e)
        G_FUNCS_can_discard_ref(e)
        if G.GAME.current_round.discards_left <= 0 and #G.hand.highlighted > 0 and used_voucher('trash_picker') and G.GAME.current_round.hands_left>1 then
            e.config.colour = G.C.RED
            e.config.button = 'discard_cards_from_highlighted'
        end
    end

    local G_FUNCS_discard_cards_from_highlighted_ref = G.FUNCS.discard_cards_from_highlighted 
    G.FUNCS.discard_cards_from_highlighted = function(e, hook)
        G_FUNCS_discard_cards_from_highlighted_ref(e,hook)
        if not hook and used_voucher('trash_picker') and G.GAME.current_round.discards_left <= 0 then ease_hands_played(-1) end
    end
end -- trash picker
do
    local name="Money Target"
    local id="money_target"
    local loc_txt = {
        name = name,
        text = {
            "Earn double {C:money}interest{}", 
            "at end of round if your",
            "money is multiples of 5",
            "{C:inactive}(Seed Money + Target){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_seed_money',MOD_PREFIX_V..'target'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local G_FUNCS_evaluate_round_ref=G.FUNCS.evaluate_round
    G.FUNCS.evaluate_round = function()
        G.GAME.interest_amount_ref=G.GAME.interest_amount
        --print("interest_ref",G.GAME.interest_amount_ref)
        G.GAME.v_money_target_triggered=false
        if used_voucher('money_target') and G.GAME.dollars%5==0 then
            G.GAME.v_money_target_triggered=true
            G.GAME.interest_amount=G.GAME.interest_amount*get_voucher('money_target').config.extra
        end
        --print("interest",G.GAME.interest_amount)
        G_FUNCS_evaluate_round_ref()
    end

    
    local G_FUNCS_cash_out_ref=G.FUNCS.cash_out
    G.FUNCS.cash_out=function (e)
        if used_voucher('money_target') and G.GAME.v_money_target_triggered then
            local delta= G.GAME.interest_amount-G.GAME.interest_amount_ref*get_voucher('money_target').config.extra -- if delta ~= 0 then jokers adding amount were sold between evaluate_round and cash_out
            --print("delta",delta)
            G.GAME.interest_amount=G.GAME.interest_amount_ref+delta
        end
        G_FUNCS_cash_out_ref(e)
    end
end -- money target
do
    local name="Art Gallery"
    local id="art_gallery"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}+#1#{} Ante to win.",
            "When {C:attention}Boss Blind{} is defeated,", 
            "randomly get one of the following:",
            "{C:blue}+#1#{} hand, {C:red}+#1#{} discard or {C:attention}-#1#{} Ante",
            "{C:inactive}(Hieroglyph + Abstract Art){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_hieroglyph',MOD_PREFIX_V..'abstract_art'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Art Gallery' then
            ease_ante_to_win(center_table.extra)
        end
        Card_apply_to_run_ref(self, center)
    end

    local end_round_ref = end_round
    function end_round()
        if used_voucher('art_gallery') and G.GAME.blind:get_type() == 'Boss' then
            end_round_ref()
            local random_number=pseudorandom('v_art_gallery')
            local value=get_voucher('art_gallery').config.extra
            if random_number < 1/3 then
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + value
                ease_hands_played(value)
            elseif random_number < 2/3 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + value
                ease_discard(value)
            else
                ease_ante(-value)
                G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
                G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante-value
            end
            return
        end
        end_round_ref()
    end
end -- art gallery
do
    local name="B1Ginf"
    local id="b1ginf"
    local loc_txt = {
        name = name,
        text = {
            "When you redeem a",
            "{C:attention}Voucher{}, always redeem",
            "all {C:attention}higher tier{} Vouchers",
            "and pay their prices",
            "{C:inactive}(Collector + B1G1){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'collector',MOD_PREFIX_V..'b1g1'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v) -- the effect is written in b1g50 code
end -- b1ginf
do
    local name="Slate"
    local id="slate"
    local loc_txt = {
        name = name,
        text = {
            "Permanently increases {C:attention}Stone Card{}",
            "bonus by {C:blue}+#1#{} extra chips.",
            "{C:attention}Stone Cards{} don't occupy", 
            "space when played",
            "{C:inactive}(Petroglyph + Bonus+){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=100},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_petroglyph',MOD_PREFIX_V..'bonus_plus'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Slate' then
            G.P_CENTERS.m_stone.config.bonus=G.P_CENTERS.m_stone.config.bonus+get_voucher('slate').config.extra
            for k, v in pairs(G.playing_cards) do
                if v.config.center_key == 'm_stone' then v:set_ability(G.P_CENTERS['m_stone']) end
            end
        end
        Card_apply_to_run_ref(self, center)
    end

    local G_FUNCS_can_play_ref=G.FUNCS.can_play
    G.FUNCS.can_play = function(e)
        G_FUNCS_can_play_ref(e)
        if used_voucher('slate') then
            local stone=0
            for k, val in ipairs(G.hand.highlighted) do
                if val.ability.name == 'Stone Card' then stone=stone + 1 end
            end
            if not G.GAME.blind.block_play and #G.hand.highlighted >0 and #G.hand.highlighted<=5+stone then
                e.config.colour = G.C.BLUE
                e.config.button = 'play_cards_from_highlighted'
            end
        end
    end

    local CardArea_add_to_highlighted_ref=CardArea.add_to_highlighted
    function CardArea:add_to_highlighted(card, silent)
        if used_voucher('slate') and self.config.type ~='shop' and self.config.type ~='joker' and self.config.type ~='consumeable' then
            local stone=0
            for k, val in ipairs(self.highlighted) do
                if val.ability.name == 'Stone Card' then stone=stone + 1 end
            end
            if #self.highlighted < stone+self.config.highlighted_limit or card.ability.name=='Stone Card' then
                self.highlighted[#self.highlighted+1] = card
                card:highlight(true)
                if not silent then play_sound('cardSlide1') end
                self:parse_highlighted()
                return
            end
        end
        CardArea_add_to_highlighted_ref(self,card,silent)
    end

    -- local G_FUNCS_draw_from_deck_to_hand_ref=G.FUNCS.draw_from_deck_to_hand
    -- G.FUNCS.draw_from_deck_to_hand = function(e) -- failed :(
        
    --     G_FUNCS_draw_from_deck_to_hand_ref(e)
    --     if used_voucher('slate') then
    --         delay(1.51)
    --         local stone=0
    --         for k, val in ipairs(G.hand.cards) do
    --             if val.ability.name == 'Stone Card' then stone=stone + 1 end
    --         end
    --         print('fhkkc',#G.hand.cards)
    --         local deck_cards=#G.deck.cards
    --         local hand_cards=#G.hand.cards
    --         while deck_cards>0 and G.hand.config.card_limit+stone - hand_cards>0 do
    --             draw_card(G.deck,G.hand, 0,'up', true)
    --             hand_cards=hand_cards+1
    --             deck_cards=deck_cards-1
    --         end
    --     end
    -- end

end -- slate
do
    local name="Gilded Glider"
    local id="gilded_glider"
    local loc_txt = {
        name = name,
        text = {
            "When a {C:attention}Gold Card{} gives money, if",
            "the card to its right isn't enhanced,",
            "transfer the {C:attention}Gold Card{} enhancement", 
            "from this card to that card",
            "{C:inactive}(Gold Bar + Bonus+){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'gold_bar',MOD_PREFIX_V..'bonus_plus'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local Card_get_end_of_round_effect_ref=Card.get_end_of_round_effect
    function Card:get_end_of_round_effect(context)
        local ret=Card_get_end_of_round_effect_ref(self,context)
        if used_voucher('gilded_glider') and self.config.center_key=='m_gold' then
            local index=1
            while G.hand.cards[index]~=self and index<=#G.hand.cards do
                index=index+1
            end
            if index<#G.hand.cards then
                local right_card=G.hand.cards[index+1]
                if right_card.config.center_key=='c_base' then
                    self:set_ability(G.P_CENTERS['c_base'],nil,true)
                    right_card:set_ability(G.P_CENTERS['m_gold'],nil,true)
                end
            end
        end
        return ret
    end

end -- gilded glider
do
    local name="Mirror"
    local id="mirror"
    local loc_txt = {
        name = name,
        text = {
            "When a {C:attention}Steel Card{} scores,",
            "the card to its right",
            "triggers one more time", 
            "{C:inactive}(Flipped Card + Omnicard){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=2},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'flipped_card',MOD_PREFIX_V..'omnicard'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    OVER_RETRIGGER_LIMIT=50

    local eval_card_ref=eval_card
    function eval_card(card, context)
        local ret=eval_card_ref(card, context)
        if used_voucher('mirror') and not context.repetition_only and context.cardarea == G.play and card.config.center_key=='m_steel' then -- this is scoring calculation
            local index=1
            while G.play.cards[index]~=card and index<=#G.play.cards do
                index=index+1
            end
            if index<#G.play.cards then
                local right_card=G.play.cards[index+1]
                right_card.ability.temp_repetition=(right_card.ability.temp_repetition or 0)+1
            end
        end
        if context.repetition_only  and card.ability.temp_repetition then -- if this is the red seal calculation, add temp repetition 
            card.ability.over_retriggered_ratio=1
            if not ret.seals then ret.seals={
                message = localize('k_again_ex'),
                repetitions = card.ability.temp_repetition,
                card = card
            }
            else ret.seals.repetitions=ret.seals.repetitions+card.ability.temp_repetition
            end
            if ret.seals.repetitions>OVER_RETRIGGER_LIMIT then
                card.ability.over_retriggered_ratio=ret.seals.repetitions/OVER_RETRIGGER_LIMIT
                ret.seals.repetitions=OVER_RETRIGGER_LIMIT
                card_eval_status_text(card,'extra',nil,nil,nil,{message=localize('over_retriggered')..tostring(card.ability.over_retriggered_ratio)})
            end
            card.ability.temp_repetition=0
        end
        return ret
    end

end -- mirror
do
    local name="Real Random"
    local id="real_random"
    local loc_txt = {
        name = name,
        text = {
            "Randomize {C:attention}Lucky Card{} effects.",
            "Create a negative {C:attention}Magician{}",
            "when blind begins",
            "{C:inactive}(Crystal Ball + Omnicard){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra={ability=3},rarity=4},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_crystal_ball',MOD_PREFIX_V..'omnicard'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    REAL_RANDOM_COLLAPSE_AMOUNT=10
    --[[
        card.ability.real_random_abilities is a table, whose elements are 
        {
            num=*number of abilities*
            values={
                chip={
                    num=*number of chips abilities*
                    values={
                        if less than 10 (REAL_RANDOM_COLLAPSE_AMOUNT) abilities, this maybe a table of loc_vars if the chance of this type of ability is fixed when generating. loc_vars is like {*value*,*chance*}. Other wise values is empty
                    }
                },
                mult={
                    ...
                },
                ...
            chip, mult are keys in real_random_data
            }
        }
        if more or equal than 10, values of abilities aren't stored so same type of abilities are collapsed into a number:
        {
            num=...,
            values={
                chip={num=*number*,values=*meaningless*},
                mult={num=*number*,values=*meaningless*},
                ...
            }
        }
    ]]
    
    local new_round_ref=new_round
    function new_round()
        if used_voucher('real_random') then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = (function() randomly_create_tarot('v_prologue',nil,{forced_key='c_magician',edition={negative=true}}) return true end)
            }))
        end
        return new_round_ref()
    end

    local copy_card_ref=copy_card
    function copy_card(other, new_card, card_scale, playing_card, strip_edition)
        new_card=copy_card_ref(other, new_card, card_scale, playing_card, strip_edition)
        if used_voucher('real_random') and new_card.config.center.effect=='Lucky Card' then
            new_card.config.center_key=other.config.center_key
            --print(new_card.config.center_key)
        end
        if used_voucher('chaos') then -- copy_card calls Card:set_ability and after this copy_card overrides card.ability which causes ability not equal to config.center. so load center to ability
            load_center_to_ability(new_card)
        end
        return new_card
    end

    function log_random(lower, upper)
        -- Generate a uniform random number between 0 and 1
        local u = pseudorandom('real_random')
        
        -- Transform the uniform random number to follow a logarithmic distribution
        local v = lower * math.exp(u * math.log(upper / lower))
        
        return v
    end

    function real_random_loc_def(center,key,loc_vars)
        -- center: card.config.center
        -- key: like chip in real_random_data
        -- loc_vars: optional

        local ability_data=real_random_data[key]
        if ability_data.chance_range then --chance has been randomly chosen so just return the existing value
            if ability_data.chance_range[1]==ability_data.chance_range[2] then
                return {
                    ability_data.base_value_function(ability_data.chance_range[1]),
                    ability_data.chance_range[1] --chance is actually fixed
                }
            end
            return loc_vars
        else --chance is a function that should be calculated real-time taking in this card and returning a value
            local chance=ability_data.chance_function(center)   
            return{
                ability_data.base_value_function(chance),
                math.ceil(chance)
            }
        end
        
    end

    function real_random_get_random_ability()
        -- return {key=*key*, maybe loc_vars={value,chance} for chance-fixed type of abilities}
        local _,random_ability_key=pseudorandom_element_weighted(real_random_data,pseudoseed('real_random'))
        local ability_data=real_random_data[random_ability_key]
        local ability={key=random_ability_key}
        if ability_data.chance_range and ability_data.chance_range[1]~=ability_data.chance_range[2] then --chance is randomly chosen between ranges that won't change
            local chance_range=ability_data.chance_range
            local chance=log_random(chance_range[1],chance_range[2])
            ability.loc_vars={
                    ability_data.base_value_function(chance),
                    math.ceil(chance)
                }
        end --chance is a function taking in this card and returning a value or the random range upper bound equals lower bound so is fixed and no need to store.
        return ability
    end

    function real_random_add_ability_to_card(card,ability)
        --ability must be in the same form as generated from real_random_get_random_ability (key=, [loc_vars=])
        local abilities=card.config.center.real_random_abilities or real_random_empty_abilities_table()
        abilities.num=abilities.num+1
        local key=ability.key
        local target=abilities.values[key]
        target.num=target.num+1
        if ability.loc_vars and target.num<REAL_RANDOM_COLLAPSE_AMOUNT then
            target.values[#target.values+1]=ability.loc_vars
        end
        
    end

    function real_random_empty_abilities_table()
        local ret={num=0,values={}}
        for k,v in pairs(real_random_data) do
            ret.values[k]={num=0,values={}}
        end
        return ret
    end

    function real_random_add_abilities_to_card(v,times)
        -- v:card
        v.config.center=copy_table(v.config.center)
        if not v.config.center.real_random_abilities then
            v.config.center.real_random_abilities=real_random_empty_abilities_table()
        end
        for i=1,(times or get_voucher('real_random').config.extra.ability) do
            local ability=real_random_get_random_ability()
            real_random_add_ability_to_card(v,ability)
        end
        
        v.ability.real_random_abilities=v.config.center.real_random_abilities
    end

    function real_random_merge_two_abilities(abilitiesA,abilitiesB)
        -- add all abilities in abilities to cardA
        local abiB=abilitiesB
        if not abiB then return abilitiesA end
        if not abilitiesA then
            abilitiesA=real_random_empty_abilities_table()
        end
        local abiA=abilitiesA
        for key,v in pairs(abiB.values) do
            abiA.num=abiA.num+v.num
            abiA.values[key].num=abiA.values[key].num+v.num
            if v.num<=REAL_RANDOM_COLLAPSE_AMOUNT and #v.values>0 then
                local ability=abiA.values[key].values
                for kk,vv in pairs(v.values) do
                    ability[#ability+1]=vv
                end
            end
        end
        return abiA
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Real Random' then
            for k, v in pairs(G.playing_cards) do
                if v.config.center_key == 'm_lucky' and not (v.config and v.config.center and v.config.center.real_random_abilities) then 
                    real_random_add_abilities_to_card(v)
                end
            end
        end
        Card_apply_to_run_ref(self, center)
    end

    local Card_set_ability_ref=Card.set_ability
    function Card:set_ability(center, initial, delay_sprites)
        Card_set_ability_ref(self,center,initial,delay_sprites)
        if used_voucher('real_random') and center==G.P_CENTERS['m_lucky'] and not self.config.center.real_random_abilities then
            real_random_add_abilities_to_card(self)
        end
    end

    local function get_real_random_ability_average(center,key)
        -- center: card.config.center
        local data=real_random_data[key]
        if not data then return 0 end
        local chance=0
        if data.chance_range then
            local lower=data.chance_range[1]
            local upper=data.chance_range[2]
            chance=lower * math.exp(0.5 * math.log(upper / lower))
        else
            chance=data.chance_function(center)
        end
        if key=='x_mult' then
            return math.exp(math.log(data.base_value_function(chance))*math.min(1,G.GAME.probabilities.normal/chance))
        end
        return data.base_value_function(chance)*math.min(1,G.GAME.probabilities.normal/chance)
    end

    local function calc_function_template(card,key,func)
        --[[func: a function that takes in card and number of ability triggered. e.g. 
            func(card,times) 
                if times<REAL_RANDOM_COLLAPSE_AMOUNT then 
                    for i=1,times do randomly_redeem_voucher() end
                else 
                    randomly_redeem_voucher_large_number(times)
                end
            ]]
        local loc_vars=real_random_loc_def(card.config.center,key)
        local dynamic_chance=loc_vars==nil
        local ability=card.config.center.real_random_abilities.values[key]
        local over_retriggered=card.ability.over_retriggered_ratio and card.ability.over_retriggered_ratio>1 and card.ability.over_retriggered_ratio or 1
        if ability.num<REAL_RANDOM_COLLAPSE_AMOUNT then
            for i = 1,ability.num do
                if dynamic_chance then
                    loc_vars=real_random_loc_def(card.config.center,key,ability.values[i])
                end
                if pseudorandom(key) < G.GAME.probabilities.normal/loc_vars[2] then
                    card.lucky_trigger = true
                    func(card,loc_vars[1]*over_retriggered)
                end
            end
        else
            local ret=math.floor(get_real_random_ability_average(card.config.center,key)*over_retriggered)
            if ret>0 then
                card.lucky_trigger = true
                func(card,ret)
            end
        end
    end

    real_random_data={
        chip={
            chance_range={1,15},
            base_value_function=function(chance)
                return 25*math.ceil(chance^1.2)
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for {C:chips}+#2#{} Chips"
            }
        },
        mult={
            chance_range={1,15},
            base_value_function=function(chance)
                return 4*math.ceil(chance^1.2)
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for {C:mult}+#2#{} Mult"
            }
        },
        x_mult={
            chance_range={4,30},
            base_value_function=function(chance)
                return math.ceil(chance^1.2)/10+1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for {X:red,C:white}X#2#{} Mult"
            }
        },
        dollars={
            chance_range={10,50},
            base_value_function=function(chance)
                return math.ceil(chance^1.2)
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "to win {C:money}$#2#"
            }
        },
        joker_slot={
            weight=0.15,
            chance_range={777,777},
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for {C:attention}+#2#{} Joker slot"
            },
            calc_function=function(card)
                local key='joker_slot'
                local function func(card,times)
                    G.E_MANAGER:add_event(Event({func = function()
                        if G.jokers then 
                            G.jokers.config.card_limit = G.jokers.config.card_limit + times
                        end
                    return true end }))
                end
                calc_function_template(card,key,func)
            end
        },
        consumable_slot={
            weight=0.15,
            chance_range={177,177},
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for {C:attention}+#2#{} Consumable slot"
            },
            calc_function=function(card)
                local key='consumable_slot'
                local function func(card,times)
                    G.E_MANAGER:add_event(Event({func = function()
                        if G.consumeables then 
                            G.consumeables.config.card_limit = G.consumeables.config.card_limit + times
                        end
                    return true end }))
                end
                calc_function_template(card,key,func)
            end
        },
        random_voucher={
            weight=0.15,
            chance_range={77,77},
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for a random {C:attention}Voucher{}"
            },
            calc_function=function(card)
                local key='random_voucher'
                local function func(card,times)
                    for i=1,times do
                        randomly_redeem_voucher()
                    end
                end
                calc_function_template(card,key,func)
            end
        },
        random_negative_joker={
            weight=0.15,
            chance_range={77,77},
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for a random {C:dark_edition}negative{} {C:attention}Joker{}"
            },
            calc_function=function(card)
                local key='random_negative_joker'
                local function func(card,times)
                    for i=1,times do
                        randomly_create_joker(times,'random_negative_joker',nil,{edition={negative=true}})
                    end
                end
                calc_function_template(card,key,func)
            end
        },
        new_ability={
            weight=0.15,
            chance_function=function(center)
                local abilities=center.real_random_abilities
                return math.max((center.real_random_abilities.num-1)^2,8)
            end,
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for a new ability"
            },
            calc_function=function(card)
                local key='new_ability'
                local function func(card,times)
                    real_random_add_abilities_to_card(card,times)
                end
                calc_function_template(card,key,func)
            end
        },
        double_probability={
            weight=0.1,
            chance_function=function(center)
                return math.ceil(4.938*(G.GAME.probabilities.normal+0.5)^2)
            end,
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "to double all probabilities"
            },
            calc_function=function(card)
                local key='double_probability'
                local function func(card,times)
                    for k, v in pairs(G.GAME.probabilities) do -- are there really other probabilities?
                        G.GAME.probabilities[k] = v*2^times
                    end
                end
                calc_function_template(card,key,func)
            end
        },
        random_tag={
            weight=0.25,
            chance_range={7,7},
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "for a random {C:attention}tag{}"
            },
            calc_function=function(card)
                local key='random_tag'
                local function func(card,times)
                    local random_tag_key = get_next_tag_key()
                    local random_tag=Tag(random_tag_key,false,'Small')
                    
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        func = function()
                            for i=1,times do
                                add_tag(random_tag)
                            end
                    return true end }))
                end
                calc_function_template(card,key,func)
            end
        },
        retrigger_next={
            weight=0.1,
            chance_range={3,25},
            base_value_function=function(chance)
                return math.max(math.ceil(math.log(chance))-1,1)
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "to retrigger the card",
                "to its right {C:attention}#2#{} times"
            },
            calc_function=function(card)
                local key='retrigger_next'
                local function func(card,times)
                    local index=1
                    while G.play.cards[index]~=card and index<=#G.play.cards do
                        index=index+1
                    end
                    if index<#G.play.cards then
                        local right_card=G.play.cards[index+1]
                        right_card.ability.temp_repetition=(right_card.ability.temp_repetition or 0)+times
                    end
                end
                calc_function_template(card,key,func)
            end
        },
        hand_size={
            weight=0.15,
            chance_function=function(center)
                return math.ceil(2.5*(math.max(G.hand.config.card_limit,8)-4)^2.5)
            end,
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "to {C:attention}+#2#{} hand size"
            },
            calc_function=function(card)
                local key='hand_size'
                local function func(card,times)
                    G.hand:change_size(times)
                end
                calc_function_template(card,key,func)
            end
        },
        transfer_ability={
            weight=0.05,
            chance_range={77,77},
            base_value_function=function(chance)
                return 1
            end,
            text={
                "{C:green}#1# in #3#{} chance",
                "to add an ability",
                "to the card to its right"
            },
            calc_function=function(card)
                local key='transfer_ability'
                local function func(card,times)
                    --if times<REAL_RANDOM_COLLAPSE_AMOUNT then
                    local index=1
                    while G.play.cards[index]~=card and index<=#G.play.cards do
                        index=index+1
                    end
                    if index<#G.play.cards then
                        local right_card=G.play.cards[index+1]
                        real_random_add_abilities_to_card(right_card,times)
                    end
                end
                calc_function_template(card,key,func)
            end
        }
    }
    -- for k,v in pairs(real_random_data) do
    --     G.localization.descriptions.Enhanced['real_random_'..k] =v 
    -- end

    local G_FUNCS_exit_overlay_menu_ref=G.FUNCS.exit_overlay_menu
    G.FUNCS.exit_overlay_menu = function()
        local ret=G_FUNCS_exit_overlay_menu_ref()
        G.in_overlay_menu=false
    end

    local create_UIBox_your_collection_enhancements_ref=create_UIBox_your_collection_enhancements
    function create_UIBox_your_collection_enhancements(exit)
        local ret=create_UIBox_your_collection_enhancements_ref(exit)
        G.in_overlay_menu=true
        return ret
    end

    local localize_ref=localize
    function localize(args, misc_cat)
        if args.key=='m_lucky' and G and G.GAME and used_voucher('real_random') and args.type == 'descriptions' and not args.loc_vars and args~=G.P_CENTERS.m_lucky then return end
        return localize_ref(args,misc_cat)
    end

    local generate_card_ui_ref=generate_card_ui
    function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        if G and G.GAME and used_voucher('real_random') and (_c.effect == 'Lucky Card' or _c.real_random_abilities) then --_c is card.config.center. "and specific_vars" is to exclude side tooltip of lucky card
            local using_info=false
            if full_UI_table and full_UI_table.name then using_info=true
            end
            local _c_effect_ref=_c.effect
            if _c.effect=='Lucky Card' then 
                _c.effect='Lucky Card???' -- to make loc_vars sent to localize become empty thus removing the original lucky card description with overridden localize function above
            end
            local full_UI_table=generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
            _c.effect=_c_effect_ref
            local main=(not using_info and full_UI_table.main) or full_UI_table.info
            if using_info then
                --full_UI_table.info[#full_UI_table.info+1] = {} this is to replace the empty info tab so don't add a new tab
                main = full_UI_table.info[#full_UI_table.info]
            end
            --local main_last=main[#main]
            -- if _c.effect == 'Lucky Card' then
            --     for i=1,4 do
            --         table.remove(main,#main)-- the description of vanilla lucky card is 4 lines but if there is extra line under them this causes problem
            --     end
            -- end
            if _c.real_random_abilities and not(G.in_overlay_menu) and not using_info then
                local abilities=_c.real_random_abilities
                local ability_num=abilities.num
                -- if ability_num<20 then
                    -- local flag=false
                    for key,v in pairs(abilities.values) do
                        -- if k>6 then 
                        --     flag=true    
                        --     break
                        -- end
                        if #v.values==0 and v.num>0 then
                            -- #v.values==0 means it's calculated realtime so every ability for this card is same, so it can be displayed as (Xn)
                            local loc_vars=copy_table(real_random_loc_def(_c,key))
                            --print(loc_vars[1],v.key,_c.set)
                            table.insert(loc_vars,1,G.GAME.probabilities.normal)
                            localize{type = 'descriptions', key = 'real_random_'..key, set ='Enhanced', nodes = main, vars = loc_vars}
                            if v.num>1 then
                                localize{type = 'descriptions', key = 'multiples', set ='Enhanced', nodes = main, vars = {v.num}}
                            end
                        elseif v.num>0 then
                            for i=1,math.min(2+(v.num==3 and 1 or 0),v.num) do
                                local loc_vars=copy_table(real_random_loc_def(_c,key,v.values[i]))
                                --print(loc_vars[1],v.key,_c.set)
                                table.insert(loc_vars,1,G.GAME.probabilities.normal)
                                localize{type = 'descriptions', key = 'real_random_'..key, set ='Enhanced', nodes = main, vars = loc_vars}
                            end
                            if v.num>3 then
                                localize{type = 'descriptions', key = 'ellipsis', set ='Enhanced', nodes = main, vars = {v.num-2}}
                            end
                        end
                        
                    end
                    -- if flag then
                    --     localize{type = 'descriptions', key = 'ellipsis', set ='Enhanced', nodes = main, vars = {ability_num-6}}
                    -- end
                -- end
                
            else --misprint effect
                local strings={}
                for i=1,20 do
                    local ability=real_random_get_random_ability()
                    local loc_vars=copy_table(real_random_loc_def({real_random_abilities={num=3,values={chip={num=1,values={ability.loc_vars}}}}},ability.key,ability.loc_vars))
                    table.insert(loc_vars,1,G.GAME.probabilities.normal)
                    localize{type = 'descriptions', key = 'real_random_'..ability.key, set = 'Enhanced', nodes = strings, vars = loc_vars}
                end
                for k,v in pairs(strings) do
                    strings[k]=get_plain_text_from_localize(strings[k])
                end
                
                main_start = {
                    {n=G.UIT.O, config={object = DynaText({string = strings,
                    colours = {G.C.DARK_EDITION},pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.2011, scale = 0.32, min_cycle_time = 0})}},
                }
                main[#main+1]=main_start
            end
            return full_UI_table
        end
        local full_UI_table=generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        return full_UI_table
    end

    local get_chip_bonus_ref=Card.get_chip_bonus
    function Card:get_chip_bonus()
        local ret=get_chip_bonus_ref(self)
        if used_voucher('real_random') and not self.debuff and self.config.center.real_random_abilities then
            local key='chip'
            local num= self.config.center.real_random_abilities.values[key].num
            if num<REAL_RANDOM_COLLAPSE_AMOUNT then
                for k,v in pairs(self.config.center.real_random_abilities.values[key].values) do
                    local loc_vars=real_random_loc_def(self.config.center,key,v)
                    if pseudorandom('lucky_'..key) < G.GAME.probabilities.normal/loc_vars[2] then
                        self.lucky_trigger = true
                        ret=ret+loc_vars[1]
                    end
                end
            else
                self.lucky_trigger = true
                ret=ret+get_real_random_ability_average(self.config.center,key)*num
            end
            
        end
        if self.ability.over_retriggered_ratio and self.ability.over_retriggered_ratio>1 then
            ret=ret*self.ability.over_retriggered_ratio
        end
        return ret
    end
    
    local get_chip_mult_ref=Card.get_chip_mult
    function Card:get_chip_mult()
        local ret=get_chip_mult_ref(self)
        if used_voucher('real_random') and not self.debuff and self.config.center.real_random_abilities then
            if self.ability.effect == 'Lucky Card' then ret=0 end -- to override the original lucky card mult
            local key='mult'
            local num= self.config.center.real_random_abilities.values[key].num
            if num<REAL_RANDOM_COLLAPSE_AMOUNT then
                for k,v in pairs(self.config.center.real_random_abilities.values[key].values) do
                    local loc_vars=real_random_loc_def(self.config.center,key,v)
                    if pseudorandom('lucky_'..key) < G.GAME.probabilities.normal/loc_vars[2] then
                        self.lucky_trigger = true
                        ret=ret+loc_vars[1]
                    end
                end
            else
                self.lucky_trigger = true
                ret=ret+get_real_random_ability_average(self.config.center,key)*num
            end
        end
        if self.ability.over_retriggered_ratio and self.ability.over_retriggered_ratio>1 then
            ret=ret*self.ability.over_retriggered_ratio
        end
        return ret
    end

    local get_chip_x_mult_ref=Card.get_chip_x_mult
    function Card:get_chip_x_mult(context)
        local ret=get_chip_x_mult_ref(self,context)
        if used_voucher('real_random') and not self.debuff and self.config.center.real_random_abilities then
            if not ret or ret==0 then ret=1 end
            local key='x_mult'
            local num= self.config.center.real_random_abilities.values[key].num
            if num<REAL_RANDOM_COLLAPSE_AMOUNT then
                for k,v in pairs(self.config.center.real_random_abilities.values[key].values) do
                    local loc_vars=real_random_loc_def(self.config.center,key,v)
                    if pseudorandom('lucky_'..key) < G.GAME.probabilities.normal/loc_vars[2] then
                        self.lucky_trigger = true
                        ret=ret*loc_vars[1]
                    end
                end
            else
                self.lucky_trigger = true
                ret=ret*get_real_random_ability_average(self.config.center,key)^num
            end
            if ret==1 then ret=0 end
        end
        if self.ability.over_retriggered_ratio and self.ability.over_retriggered_ratio>1 then
            ret=TalismanCompat(ret)^TalismanCompat(self.ability.over_retriggered_ratio)
        end
        return ret
    end

    local get_p_dollars_ref=Card.get_p_dollars
    function Card:get_p_dollars(context) -- vanilla function modify dollar_buffer so I just don't execute vanilla function (though I don't clearly know what dollar_buffer does)
        if used_voucher('real_random') and not self.debuff and self.config.center.real_random_abilities then
            local ret=0
            if self.seal == 'Gold' then
                ret = ret +  3
            end
            
            local key='dollars'
            local num= self.config.center.real_random_abilities.values[key].num
            if num<REAL_RANDOM_COLLAPSE_AMOUNT then
                for k,v in pairs(self.config.center.real_random_abilities.values[key].values) do
                    local loc_vars=real_random_loc_def(self.config.center,key,v)
                    if pseudorandom('lucky_'..key) < G.GAME.probabilities.normal/loc_vars[2] then
                        self.lucky_trigger = true
                        ret=ret+loc_vars[1]
                    end
                end
            else
                self.lucky_trigger = true
                ret=ret+get_real_random_ability_average(self.config.center,key)*num
            end
            
            if ret > 0 then 
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + ret
                G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
            end
            if self.ability.over_retriggered_ratio and self.ability.over_retriggered_ratio>1 then
                ret=ret*self.ability.over_retriggered_ratio
            end
            return ret
        end
        local ret=get_p_dollars_ref(self)
        if self.ability.over_retriggered_ratio and self.ability.over_retriggered_ratio>1 then
            ret=ret*self.ability.over_retriggered_ratio
        end
        return ret
    end

    local eval_card_ref=eval_card
    function eval_card(card, context) --other abilities
        local ret=eval_card_ref(card,context)
        if context.cardarea == G.play and not context.repetition_only and used_voucher('real_random') and not card.debuff and card.config.center.real_random_abilities then
            -- local abilities=card.config.center.real_random_abilities
            -- local abilities_ref=copy_table(card.config.center.real_random_abilities)
            for key,value in pairs(real_random_data) do
                if value.calc_function then
                    value.calc_function(card)
                end
            end
        end
        return ret
    end
end -- real random
do
    local name="4D Vouchers"
    local id="4d_vouchers"
    local loc_txt = {
        name = name,
        text = {
            "Rerolls apply to {C:attention}Vouchers{},",
            "but rerolled Vouchers",
            "cost {C:attention}$#1#{} more",
            "{C:inactive}(4D Boosters + Oversupply){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=2,rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'4d_boosters',MOD_PREFIX_V..'oversupply'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    
    function get_voucher_max()
        local value=1
        return value
    end
    
    local G_FUNCS_reroll_shop_ref=G.FUNCS.reroll_shop
    function G.FUNCS.reroll_shop(e)
        G_FUNCS_reroll_shop_ref(e)
        if used_voucher('4d_vouchers') then
            my_reroll_shop_voucher(get_voucher('4d_vouchers').config.extra)
        end
    end
    function my_reroll_shop_voucher(price_mod)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                if not (G.shop_vouchers and G.shop_vouchers.cards) then
                    return true
                end
                local num=math.max(get_voucher_max(),#G.shop_vouchers.cards)
                for i = #G.shop_vouchers.cards,1, -1 do
                    local c = G.shop_vouchers:remove_card(G.shop_vouchers.cards[i])
                    c:remove()
                    c = nil
                end
        
                --save_run()
        
                play_sound('coin2')
                play_sound('other1')
                
                for i = 1, num - #G.shop_vouchers.cards do
                    G.GAME.current_round.voucher=get_next_voucher_key()
                    if G.GAME.current_round.voucher and G.P_CENTERS[G.GAME.current_round.voucher] then
                        local card = Card(G.shop_vouchers.T.x + G.shop_vouchers.T.w/2,
                        G.shop_vouchers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.voucher],{bypass_discovery_center = true, bypass_discovery_ui = true})
                        card.shop_voucher = true
                        card.cost=card.cost+price_mod
                        create_shop_card_ui(card, 'Voucher', G.shop_vouchers)
                        card:start_materialize()
                        G.shop_vouchers:emplace(card)
                    end
                end
            return true
            end
        }))
        G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
        
    end


end -- 4d vouchers
do
    local name="Recycle Area"
    local id="recycle_area"
    local loc_txt = {
        name = name,
        text = {
            "You can {C:red}discard",
            "your hand once when",
            "opening a {C:tarot}Tarot Pack{}",
            "or {C:spectral}Spectral Pack{}",
            "{C:inactive}(Reserve Area + Wasteful){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'reserve_area','v_wasteful'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local create_UIBox_spectral_pack_ref=create_UIBox_spectral_pack
    function create_UIBox_spectral_pack()
        local t=create_UIBox_spectral_pack_ref()
        if used_voucher('recycle_area') then
            local new={n=G.UIT.C,config={align = "tm",padding = 0.2, minh = 1.2, minw = 1.8, r=0.15,colour = G.C.RED, one_press = true, button = 'uselessLOL discard_booster', hover = true,shadow = true, func = 'can_discard_booster'}, nodes = {
                {n=G.UIT.T, config={text = localize('b_discard'), scale = 0.5, colour = G.C.WHITE, shadow = true, focus_args = {button = 'y', orientation = 'bm'}, func = 'set_button_pip'}}
              }}
            table.insert(t.nodes[1].nodes[3].nodes[3].nodes,2,new)
        end
        return t
    end
    local create_UIBox_arcana_pack_ref=create_UIBox_arcana_pack
    function create_UIBox_arcana_pack()
        local t=create_UIBox_arcana_pack_ref()
        if used_voucher('recycle_area') then
            local new={n=G.UIT.C,config={align = "tm",padding = 0.2, minh = 1.2, minw = 1.8, r=0.15,colour = G.C.RED, one_press = true, button = 'uselessLOL discard_booster', hover = true,shadow = true, func = 'can_discard_booster'}, nodes = {
                {n=G.UIT.T, config={text = localize('b_discard'), scale = 0.5, colour = G.C.WHITE, shadow = true, focus_args = {button = 'y', orientation = 'bm'}, func = 'set_button_pip'}}
              }}
            table.insert(t.nodes[1].nodes[3].nodes[3].nodes,2,new)
        end
        return t
    end

    G.FUNCS.discard_booster=function()
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay =  0,
            func = function() 
                G.FUNCS.draw_from_hand_to_discard()
                return true
            end}))  
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay =  0,
            func = function() 
                local hand_space = math.min(#G.deck.cards, #G.hand.cards)
                
                for i=1, hand_space do --draw cards from deckL
                    draw_card(G.deck,G.hand, i*100/hand_space,'up',true)
                end
                return true
            end}))  
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay =  0,
            func = function() 
                G.FUNCS.draw_from_discard_to_deck()
                return true
            end}))  
        return true
        
    end

    G.FUNCS.can_discard_booster=function(e)
        if #G.hand.cards>0 then
            e.config.colour = G.C.RED
            e.config.button='discard_booster'
        else
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        end
    end


end -- recycle area
do
    local name="Chaos"
    local id="chaos"
    local loc_txt = {
        name = name,
        text = {
            "Same kind of",
            "{C:attention}Enhancements{} can stack",
            "{C:inactive}(Collector + Abstract Art){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=4},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'collector',MOD_PREFIX_V..'abstract_art'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local function add_center_to_ability(card,name,center,default_value)
        if name=='h_x_mult' then
            local new_value=(card.ability[name]or 1)*(center.config[name]or 1)
            if new_value==1 then new_value=0 end
            card.ability[name]=new_value

        else
            card.ability[name]=safe_add(card.ability[name],center.config[name],default_value)
        end
    end

    local Card_set_ability_ref=Card.set_ability
    function Card:set_ability(center, initial, delay_sprites)
        local old_center = self.config.center
        --if(self.ability)then print(used_voucher('chaos')) end
        if used_voucher('chaos')and self.ability and self.ability.name==center.name and self.ability.set=='Enhanced' and old_center then
            Card_set_ability_ref(self,center,initial,delay_sprites)
            for k,v in pairs(ability_names) do
                add_center_to_ability(self,v,old_center,0)
            end
            self.ability.x_mult=(self.ability.x_mult or 1)*(old_center.config.Xmult or 1)or 1
            if used_voucher('real_random') and old_center.real_random_abilities then
                self.ability.real_random_abilities=real_random_merge_two_abilities(self.ability.real_random_abilities,old_center.real_random_abilities)
            end
            load_ability_to_center(self)
            --print(self.ability.bonus)
            return
        end
        Card_set_ability_ref(self,center,initial,delay_sprites)
    end


end -- chaos
do
    local name="Heat Death"
    local id="heat_death"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}Eternal{} and {C:attention}Perishable{} can stack.",
            "Such Joker gives {C:dark_edition}+#1#{} Joker slot",
            "when {C:attention}debuffed{} by Perishable",
            "{C:inactive}(Eternity + Half-life){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={extra=1,rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'eternity',MOD_PREFIX_V..'half_life'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={center.ability.extra}}
    end
    handle_register(this_v)

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Heat Death' then
            G.GAME.modifiers.cry_eternal_perishable_compat=true
        end

        Card_apply_to_run_ref(self, center)
    end

    local create_card_ref=create_card
    function create_card(_type, area, legendary, _rarity, 
        skip_materialize, soulable, forced_key, key_append)
        local card=create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        if not usingCryptid and G.GAME.modifiers.cry_eternal_perishable_compat then
            if _type == 'Joker' and ((area == G.shop_jokers) or (area == G.pack_cards)) and card.ability.eternal and not card.ability.perishable and pseudorandom('cry_per'..(key_append or '')..G.GAME.round_resets.ante) > 0.7 then
                card.ability.perishable = true
                card.ability.perish_tally = G.GAME.perishable_rounds
            end
            if _type == 'Joker' and ((area == G.shop_jokers) or (area == G.pack_cards)) and not card.ability.eternal and card.ability.perishable and pseudorandom('cry_per'..(key_append or '')..G.GAME.round_resets.ante) > 0.7 then
                card.ability.eternal = true
            end
        end
        return card
    end

    local Card_set_debuff_ref=Card.set_debuff
    function Card:set_debuff(should_debuff)
        if self.ability.perishable and self.ability.perish_tally <= 0 and self.ability.eternal and used_voucher('heat_death') and not self.ability.heat_deathed then
            self.ability.heat_deathed=true
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_heat_death'),colour = G.C.FILTER, delay = 0.45})
            G.jokers.config.card_limit = G.jokers.config.card_limit + get_voucher('heat_death').config.extra
        end
        Card_set_debuff_ref(self,should_debuff)
    end
end -- heat death
do
    local name="Deep Roots"
    local id="deep_roots"
    local loc_txt = {
        name = name,
        text = {
            "You earn {C:money}interest{} based on",
            "the {C:attention}absolute value{} of your money",
            "{C:inactive}(Seed Money + Debt Burden){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=1},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_seed_money',MOD_PREFIX_V..'debt_burden'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)
    local G_FUNCS_evaluate_round_ref=G.FUNCS.evaluate_round
    G.FUNCS.evaluate_round = function()
        if used_voucher('deep_roots') and G.GAME.dollars<0 then
            G.GAME.dollars=-G.GAME.dollars
            G_FUNCS_evaluate_round_ref()
            G.GAME.dollars=-G.GAME.dollars
            return
        end
        G_FUNCS_evaluate_round_ref()
    end
end -- deep roots
do
    local name="Solar System"
    local id="solar_system"
    local loc_txt = {
        name = name,
        text = {
            "Retrigger {C:planet}Planet Card{} once",
            "per {C:planet}Planet Card{} held,",
            "including the using one",
            "{C:inactive}(Planet Merchant + Event Horizon){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={'v_planet_merchant',MOD_PREFIX_V..'event_horizon'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local function is_planet(card)
        return card.ability and card.ability.consumeable and (card.ability.consumeable.hand_type or card.ability.consumeable.hand_types) -- hand_types is for cryptid planets
    end

    local update_hand_text_ref=update_hand_text
    function update_hand_text(config, vals)
        if G.betmma_solar_system_times then
            config.delay=(config.delay or 0.8)/(1+G.betmma_solar_system_times)
        end
        update_hand_text_ref(config,vals)
    end

    local level_up_hand_ref=level_up_hand
    function level_up_hand(card,hand,instant,amount)
        -- TarotDX forgot to add the second level for DX planets when instant is true LOL
            amount = amount or 1
            if instant and card and card.ability and card.ability.set and card.ability.set == "Planet_dx" then    
                G.GAME.hands[hand].level = math.max(0, G.GAME.hands[hand].level + amount)
                G.GAME.hands[hand].mult = math.max(G.GAME.hands[hand].mult + G.GAME.hands[hand].l_mult*(amount), 1)
                G.GAME.hands[hand].chips = math.max(G.GAME.hands[hand].chips + G.GAME.hands[hand].l_chips*(amount), 0)
            end
        
        level_up_hand_ref(card,hand,instant,amount)
    end

    local level_up_hand_ref=level_up_hand
    function level_up_hand(card, hand, instant, amount)
        if G.betmma_solar_system_times then
            instant=true
            level_up_hand_ref(card,hand,instant,amount)
            if G.betmma_solar_system_times > 9 then
                return
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2/(1+G.betmma_solar_system_times), func = function()
                play_sound('tarot1')
                if card then card:juice_up(0.8, 0.5) end
                G.TAROT_INTERRUPT_PULSE = true
                return true end }))
            update_hand_text({delay = 0}, {mult = G.GAME.hands[hand].mult, StatusText = true})
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9/(1+G.betmma_solar_system_times), func = function()
                play_sound('tarot1')
                if card then card:juice_up(0.8, 0.5) end
                return true end }))
            update_hand_text({delay = 0}, {chips = G.GAME.hands[hand].chips, StatusText = true})
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9/(1+G.betmma_solar_system_times), func = function()
                play_sound('tarot1')
                if card then card:juice_up(0.8, 0.5) end
                G.TAROT_INTERRUPT_PULSE = nil
                return true end }))
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level=G.GAME.hands[hand].level})
            delay(1.3/(1+G.betmma_solar_system_times))
            return
        end
        level_up_hand_ref(card,hand,instant,amount)
    end

    local Card_use_consumeable_ref=Card.use_consumeable
    function Card:use_consumeable(area, copier)
        Card_use_consumeable_ref(self,area,copier)
        if used_voucher('solar_system') and is_planet(self) and not self.solar_system_retriggered then
            G.betmma_solar_system_times=1
            self.solar_system_retriggered=true
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_solar_system')})
            Card_use_consumeable_ref(self,area,copier) -- extra 1 time for "including the using one"
            for i = 1, #G.consumeables.cards do
                local card=G.consumeables.cards[i]
                if is_planet(card) then
                    G.betmma_solar_system_times=G.betmma_solar_system_times+1
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_solar_system')})
                    Card_use_consumeable_ref(self,area,copier)
                end
            end
            self.solar_system_retriggered=false
            G.betmma_solar_system_times=nil
        end
    end

end -- solar system
do
    local name="Forbidden Area"
    local id="forbidden_area"
    local loc_txt = {
        name = name,
        text = {
            "When no consumable slot left,",
            "buying a {C:attention}Consumable{} card moves it to",
            "{C:attention}Joker area{} and it acts like a Joker",
            "{C:inactive}(Reserve Area + Undying){}"
        }
    }
    local this_v = SMODS.Voucher{
        name=name, key=id,
        config={rarity=3},
        pos={x=0,y=0}, loc_txt=loc_txt,
        cost=10, unlocked=true, discovered=true, available=true, requires={MOD_PREFIX_V..'reserve_area',MOD_PREFIX_V..'undying'}
    }
    handle_atlas(id,this_v)
    this_v.loc_vars = function(self, info_queue, center)
        return {vars={}}
    end
    handle_register(this_v)

    local G_FUNCS_check_for_buy_space_ref=G.FUNCS.check_for_buy_space
    G.FUNCS.check_for_buy_space = function(card)
        if (card.ability.consumeable and not(#G.consumeables.cards < G.consumeables.config.card_limit + ((card.edition and card.edition.negative) and 1 or 0))) and used_voucher('forbidden_area') and (#G.jokers.cards < G.jokers.config.card_limit + ((card.edition and card.edition.negative) and 1 or 0))then
            card.betmma_forbidden_area_bought=true
            return true
        end
        local ret=G_FUNCS_check_for_buy_space_ref(card)
        return ret
    end

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

    function mark_highlighted_cards()
        for i=1,#G.hand.highlighted do
            G.hand.highlighted[i].betmma_highlight_marked=true
        end
    end

    function restore_highlighted_cards()
        local count=0
        for i=1,#G.hand.cards do
            if G.hand.cards[i].betmma_highlight_marked and not G.hand.cards[i].highlighted then
                G.hand:add_to_highlighted(G.hand.cards[i])
                count=count+1
            elseif G.hand.cards[i].highlighted then
                count=count+1
            end
        end
        return count
    end

    function unmark_highlighted_cards()
        for i=1,#G.hand.cards do
            G.hand.cards[i].betmma_highlight_marked=false
        end
    end

    local Card_set_ability_ref=Card.set_ability
    function Card:set_ability(center, initial, delay_sprites)
        local highlight_marked=self.betmma_highlight_marked
        Card_set_ability_ref(self,center,initial,delay_sprites)
        if highlight_marked then
            self.betmma_highlight_marked=true
        end
    end

    local copy_card_ref=copy_card
    function copy_card(other, new_card, card_scale, playing_card, strip_edition)
        local ret=copy_card_ref(other, new_card, card_scale, playing_card, strip_edition)
        if other.betmma_highlight_marked then
            ret.betmma_highlight_marked=true
        end
        return ret
    end

    function recursion_play_cards(max_index,now_index) -- Localthunk only uses nested events. I use recursive events instead :smiling_imp:
        if now_index>max_index then
            after_event(function()   
                print('end')
                G_FUNCS_play_cards_from_highlighted_ref(e)
                unmark_highlighted_cards()
                G.hand.config.highlighted_limit=5
            end)
            return
        end
        local self=G.jokers.cards[now_index]
        if self==nil then return end -- jokers have been changed due to ankh or hex or other things. Must stop function imemdiately
        if self.ability.consumeable and not self.debuff then
            after_event(function()
                local keep_on_use=self.config.center.keep_on_use
                local max_highlighted=self.ability.consumeable.max_highlighted
                local mod_num=self.ability.consumeable.mod_num
                local used=false
                if not self.config.center.keep_on_use then
                    self.config.center.keep_on_use=function(center,card)return true end -- SMOD supports keep on use by setting this function
                end
                if max_highlighted then
                    self.ability.consumeable.max_highlighted=999
                    self.ability.consumeable.mod_num=999
                end
                if self:can_use_consumeable(nil,true) then
                    G.FUNCS.use_card({config={ref_table=self}})
                    used=true
                end
                self.ability.consumeable.max_highlighted=max_highlighted
                self.ability.consumeable.mod_num=mod_num
                self.config.center.keep_on_use=keep_on_use
                
                after_event(function()
                    local count=used and restore_highlighted_cards() or 1
                    -- for i=1,#G.hand.cards do
                    --     if G.hand.cards[i].betmma_highlight_marked then
                    --         print(i,"index")
                    --     end
                    -- end
                    -- print(#G.hand.highlighted)
                    if count>0 then
                        after_event(function()
                            recursion_play_cards(max_index,now_index+1)
                        end)
                    end
                end)
            end)
            return
        end
        after_event(function()
            recursion_play_cards(max_index,now_index+1)
        end)
    end

    G_FUNCS_play_cards_from_highlighted_ref=G.FUNCS.play_cards_from_highlighted
    G.FUNCS.play_cards_from_highlighted = function(e)
        if used_voucher('forbidden_area') then
            G.hand.config.highlighted_limit=999
            mark_highlighted_cards()
            recursion_play_cards(#G.jokers.cards,1)
        else
            G_FUNCS_play_cards_from_highlighted_ref(e)
        end
    end
    -- local Card_calculate_joker_ref=Card.calculate_joker
    -- function Card:calculate_joker(context)
    --     return Card_calculate_joker_ref(self,context)
    -- end

end -- forbidden area

    -- this challenge is only for test
    -- table.insert(G.CHALLENGES,1,{
    --     name = "TestVoucher",
    --     id = 'c_mod_testvoucher',
    --     rules = {
    --         custom = {
    --         },
    --         modifiers = {
    --             {id = 'dollars', value = 2000},
    --         }
    --     },
    --     jokers = {
    --         --{id = 'j_jjookkeerr'},
    --         -- {id = 'j_ascension'},
    --         -- {id = 'j_sock_and_buskin'},
    --         -- {id = 'j_sock_and_buskin'},
    --         -- {id = 'j_oops'},
    --         -- {id = 'j_oops'},
    --         -- {id = 'j_oops'},
    --         -- {id = 'j_oops'},
    --         -- {id = 'j_oops'},
    --         -- {id = 'j_oops'},
    --         {id = 'j_baron', },
    --         {id = 'j_mime', },
    --         {id = 'j_cry_universum', },
    --         -- {id = 'j_madness', eternal = true},
    --         {id = JOKER_MOD_PREFIX..'j_jimbow'},--, edition='phantom'},
    --         {id = 'j_ceremonial', pinned = true},
    --     },
    --     consumeables = {
    --         -- {id = 'c_cryptid'},
    --         --{id = 'c_devil_cu'},
    --         -- {id = 'c_death'},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --         {id='c_pluto',negative=true},
    --     },
    --     vouchers = {
    --         {id = MOD_PREFIX_V.. 'trash_picker'},
    --         {id = MOD_PREFIX_V.. 'solar_system'},
    --         {id = MOD_PREFIX_V.. '3d_boosters'},
    --         {id = MOD_PREFIX_V.. '4d_boosters'},
    --         {id = MOD_PREFIX_V.. 'real_random'},
    --         {id = 'v_paint_brush'},
    --         -- {id = 'v_liquidation'},
    --         {id = MOD_PREFIX_V.. 'overshopping'},
    --         {id = MOD_PREFIX_V.. 'forbidden_area'},
    --         {id = MOD_PREFIX_V.. 'reserve_area_plus'},
    --         {id = MOD_PREFIX_V.. 'reserve_area'},
    --         -- {id = MOD_PREFIX_V.. 'undying'},
    --         -- {id = MOD_PREFIX_V.. 'reincarnate'},
    --         --{id = MOD_PREFIX_V.. 'chaos'},
    --         {id = 'v_retcon'},
    --         -- {id = 'v_event_horizon'},
    --     },
    --     deck = {
    --         type = 'Challenge Deck',
    --         cards = {{s='D',r='2',e='m_lucky',g='Red'},{s='D',r='3',e='m_glass',g='Red'},{s='D',r='4',e='m_glass',g='Red'},{s='D',r='5',e='m_glass',g='Red'},{s='D',r='6',e='m_glass',g='Red'},{s='D',r='7',e='m_lucky',},{s='D',r='7',e='m_lucky',},{s='D',r='7',e='m_lucky',},{s='D',r='8',e='m_lucky',},{s='D',r='9',e='m_lucky',},{s='D',r='T',e='m_lucky',},{s='D',r='J',e='m_glass',},{s='D',r='Q',e='m_lucky',g='Red'},{s='D',r='K',e='m_wild',g='Red'},{s='D',r='K',e='m_wild',g='Red'},{s='D',r='Q',e='m_steel',g='Red'},{s='D',r='K',e='m_steel',g='Red'},{s='D',r='K',e='m_steel',g='Red'},{s='D',r='K',e='m_steel',g='Red',d='negative'},}
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
    init_localization()
end
if IN_SMOD1 then
    INIT()
else
    SMODS['INIT']=SMODS['INIT'] or {}
    SMODS['INIT']['BetmmaVouchers']=function()
        SMODS.Voucher=SMODS_Voucher_fake
        INIT()
        SMODS.Voucher=SMODS_Voucher_ref
        SMODS.current_mod.process_loc_text()
    end
    
end
----------------------------------------------
------------MOD CODE END----------------------