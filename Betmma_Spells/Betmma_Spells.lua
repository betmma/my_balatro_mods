--- STEAMODDED HEADER
--- MOD_NAME: Betmma Spells
--- MOD_ID: BetmmaSpells
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: New type of card: Spell
--- PREFIX: betm_spells
--- VERSION: 0.0.5(20240908)
--- DEPENDENCIES: [BetmmaAbilities>=1.0.3]
--- BADGE_COLOUR: 8DB09F

----------------------------------------------
------------MOD CODE -------------------------
--[[todo:
implement fusion system (if chooosing 2 spells, replace "sell" with "fuse" if fusable. fusion spells only appear in shop if you have fused it in this run)
dependencies on abilities mod:
1. make spells look smaller (betmma_smaller_sets table)
2. water spell decrease rank (betmma_bump_rank function)
]]
MOD_PREFIX='betm_spells'
USING_BETMMA_SPELLS=true
IN_SMOD1=MODDED_VERSION>='1.0.0'
betmma_spells_centers={}
betmma_spells_atlases={}
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

function SMODS.current_mod.process_loc_text()
    G.localization.misc.dictionary.b_fuse = "FUSE"
    G.localization.misc.dictionary.spell_not = "not "
    G.localization.misc.dictionary.spell_Heart = "Heart"
    G.localization.misc.dictionary.spell_Diamond = "Diamond"
    G.localization.misc.dictionary.spell_Club = "Club"
    G.localization.misc.dictionary.spell_Spade = "Spade"
    G.localization.misc.dictionary.spell_Ace = "Ace"
    G.localization.misc.dictionary.spell_Face = "Face"
    G.localization.misc.dictionary.spell_Numbered = "Numbered"

end

do
    do
        if betmma_smaller_sets then
            betmma_smaller_sets.Spell=true
        else
            betmma_smaller_sets={Spell=true}
        end
    end -- make spells appear as 34*34 (done in betmma abilities)

    
    local Card_can_sell_card_ref=Card.can_sell_card
    -- let Spells always be sellable
    function Card:can_sell_card(context)
        if self.ability.set=='Spell' then
            return true
        end
        return Card_can_sell_card_ref(self,context)
    end

    
    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    -- override Spell cards UI. make sell buttons smaller and add fuse button if 2 spells are highlighted
    function G.UIDEF.use_and_sell_buttons(card)
        if card.ability.set=='Spell' then 
            if card.area and card.area == G.pack_cards then
                return {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                    {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_select_card'}, nodes={
                    {n=G.UIT.T, config={text = localize('b_select'),colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}}
                    }},
                }}
            end -- only create SELECT if in pack
            local sell = nil
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
            local fuse = nil 
            fuse = {n=G.UIT.R, config={align = "tr"}, nodes={
                {n=G.UIT.R, config={ref_table = card, align = "tr",padding = 0.1, r=0.08, minw = 0.7, minh = 0.9, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'fuse_card', func = 'can_fuse_card'}, nodes={
                --   {n=G.UIT.B, config = {w=0.1,h=0.6}},
                {n=G.UIT.C, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                    {n=G.UIT.T, config={text = localize('b_fuse'),colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}}
                    }},
                }}
                }},
            }}
            local use={n=G.UIT.B, config = {w=0.1,h=1}}
            -- remove use button 
            local t = {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                    #G.betmma_spells.highlighted>1 and fuse or sell
                    }},
                    -- {n=G.UIT.R, config={align = 'cl'}, nodes={
                    --     {n=G.UIT.B, config = {w=0.1,h=0.1}}
                    -- }},
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                    use
                    }},

                }},
            }}
            return t
        end
        return G_UIDEF_use_and_sell_buttons_ref(card)
    end

    local G_FUNCS_can_buy_and_use_ref=G.FUNCS.can_buy_and_use
    -- prevent buy and use button on spells in shop (will appear if cooldown is 0 and will crash when clicked)
    G.FUNCS.can_buy_and_use = function(e)
        G_FUNCS_can_buy_and_use_ref(e)
        if e.config.ref_table.ability.set=='Spell' then
            e.UIBox.states.visible = false
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        end
    end
    
    G.FUNCS.can_fuse_card = function(e)
        local card_a=G.betmma_spells.highlighted[1]
        local card_b=G.betmma_spells.highlighted[2]
        local fusion=card_b and card_a.config.center.config.fuse_to[card_b.config.center.raw_key]
        if fusion then 
            e.config.colour = G.C.PURPLE
            e.config.button = 'fuse_card'  
            e.config.fusion=fusion
        else
          e.config.colour = G.C.UI.BACKGROUND_INACTIVE
          e.config.button = nil
        end
    end
    G.FUNCS.fuse_card = function(e) 
        local c1 = e.config.ref_table
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                G.betmma_spells.highlighted[1]:start_dissolve()
                G.betmma_spells.highlighted[2]:start_dissolve()
                local card = create_card('Spell', nil, nil, nil, nil, nil, e.config.fusion, 'spell')
                card:add_to_deck()
                G.betmma_spells:emplace(card)
                G.GAME.fused_spell=G.GAME.fused_spell or {}
                G.GAME.fused_spell[e.config.fusion]=true
                discover_card(card.config.center)
                return true
            end
        }))
    end

    local G_FUNCS_check_for_buy_space_ref=G.FUNCS.check_for_buy_space
    G.FUNCS.check_for_buy_space = function(card)
        if card.ability.set=='Spell' then
            if #G.betmma_spells.cards < G.betmma_spells.config.card_limit + ((card.edition and card.edition.negative) and 1 or 0) then
                return true
            else
                return false
            end
        end
        return G_FUNCS_check_for_buy_space_ref(card)
    end
end -- Spell Area and Spell Cards preparation (card size; buy, sell and fuse functionality and buttons)

SMODS.ConsumableType { -- Define Spell Consumable Type
    key = 'Spell',
    collection_rows = { 9,9,9,9 },
    primary_colour = G.C.CHIPS,
    secondary_colour = mix_colours(G.C.SECONDARY_SET.Voucher, G.C.CHIPS, 0.7),
    loc_txt = {
        collection = 'Spells',
        name = 'Spell',
        label = 'Spell',
        undiscovered = {
			name = "Not Discovered",
			text = {
				"Fuse this spell in",
                "an unseeded run to",
                "learn what it does"
			},
		},
    },
    shop_rate = 1.0,
    default = 'c_betm_spells_dark',
    create_UIBox_your_collection = function(self)
        local deck_tables = {}

        G.your_collection = {}
        for j = 1, #self.collection_rows do
            G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
                (self.collection_rows[j] + 0.25) * G.CARD_W/71*34,
                1 * G.CARD_H/95*34, -- I added /71*34 to make abilities closer
                { card_limit = self.collection_rows[j], type = 'title', highlight_limit = 0, collection = true })
            table.insert(deck_tables,
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0, no_fill = true },
                    nodes = {
                        { n = G.UIT.O, config = { object = G.your_collection[j] } }
                    }
                }
            )
        end

        local consumable_pool = {}
        if G.ACTIVE_MOD_UI then
            for _, v in ipairs(G.P_CENTER_POOLS[self.key]) do
                if v.mod and G.ACTIVE_MOD_UI.id == v.mod.id then consumable_pool[#consumable_pool+1] = v end
            end
        else
            consumable_pool = G.P_CENTER_POOLS[self.key]
        end

        local sum = 0
        for j = 1, #G.your_collection do
            for i = 1, self.collection_rows[j] do
                sum = sum + 1
                local center = consumable_pool[sum]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y,
                    G.CARD_W, G.CARD_H, nil, center)
                card:start_materialize(nil, i > 1 or j > 1)
                G.your_collection[j]:emplace(card)
            end
        end

        local center_options = {}
        for i = 1, math.ceil(#consumable_pool / sum) do
            table.insert(center_options,
                localize('k_page') ..
                ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#consumable_pool / sum)))
        end

        INIT_COLLECTION_CARD_ALERTS()
        local option_nodes = { create_option_cycle({
            options = center_options,
            w = 4.5,
            cycle_shoulders = true,
            opt_callback = 'your_collection_' .. string.lower(self.key) .. '_page',
            focus_args = { snap_to = true, nav = 'wide' },
            current_option = 1,
            colour = G.C.RED,
            no_pips = true
        }) }
        local type_buf = {}
        if G.ACTIVE_MOD_UI then
            for _, v in ipairs(SMODS.ConsumableType.obj_buffer) do
                if modsCollectionTally(G.P_CENTER_POOLS[v]).of > 0 then type_buf[#type_buf + 1] = v end
            end
        else
            type_buf = SMODS.ConsumableType.obj_buffer
        end
        local t = create_UIBox_generic_options({
            back_func = #type_buf>3 and 'your_collection_consumables' or G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or 'your_collection',
            contents = {
                { n = G.UIT.R, config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
                { n = G.UIT.R, config = { align = "cm", padding = 0 },                                                           nodes = option_nodes },
            }
        })
        return t
    end
}
local undiscovered=SMODS.Atlas {  
    key = 'undiscovered',
    px = 34,
    py = 34,
    path = 's_undiscovered.png'
}
SMODS.UndiscoveredSprite {
	key = "Spell",
	atlas = undiscovered.key,
	pos = {x = 0, y = 0},
    no_overlay=true --remove the floating circled ? sign as it's for regular card size
}

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

--copied from D6 jokers. dunno why blame Cryptid for this 
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end

local function spell_prototype(data)
    data.keep_on_use = function(self,card)
        return true
    end
    data.can_use = function(self,card)
        return false
    end
    local fused=data.config.fuse_from
    data.raw_key=data.key
    data.set="Spell"
    data.pos={x=0,y=0}
    table.insert(data.loc_txt.text,1,"{V:1}#11#{}{V:5}#15#{}{V:2}#12#{}{V:6}#16#{}{V:3}#13#{}{V:7}#17#{}{V:4}#14#{}")
    data.loc_txt.text[#data.loc_txt.text+1]='{C:attention}#18#{}/{C:attention}#19#{}'
    if fused then
        data.loc_txt.text[#data.loc_txt.text+1]='{C:inactive,s:0.8}(#21# + #22#){}'
    end
    data.loc_vars_ref=data.loc_vars
    -- add sequence loc as first line and progress as last line
    data.loc_vars = function(self, info_queue, card)
        local ret=card.config.center.loc_vars_ref(self,info_queue,card)
        ret.vars.colours={G.C.BLACK,G.C.BLACK,G.C.BLACK,G.C.BLACK,G.C.BLACK,G.C.BLACK,G.C.BLACK}
        while #ret.vars<23 do
            ret.vars[#ret.vars+1]=""
        end
        ret.vars[18]=card.ability.progress.current or 0
        ret.vars[19]=card.ability.progress.max or "?"
        if fused then
            ret.vars[21]=betmma_spells_centers[fused[1]].loc_txt.name
            ret.vars[22]=betmma_spells_centers[fused[2]].loc_txt.name
        end
        if not card.ability.progress.max then
            ret.vars[11]=card.config.center.loc_txt.before_desc
            return ret
        end
        local suits={"Heart", "Diamond", "Club", "Spade"}
        for element_index=1,card.ability.progress.max do
            local index=0
            local element=card.ability.progress.sequence[element_index]
            for k,v in pairs(suits) do
                if element.key==v then
                    index=k
                    break
                end
            end
            ret.vars[element_index+10]=(element.negative and localize('spell_not') or "")..element.text
            ret.vars.colours[element_index]=index==0 and G.C.BLACK or G.C.SUITS[suits[index]..'s']
        end
        for i = 15, 13+card.ability.progress.max do
            ret.vars[i]=", "
        end
        if card.ability.progress.max>=3 then
            ret.vars[13+card.ability.progress.max]=", then "
        end
        return ret
    end
    -- calculate cascading hint UI (drawn in card:draw)
    data.update_sequence=function(self)
        local _minh, _minw = 0.35, 0.5
        local true_current=self.ability.progress.current_with_anim
        local current=math.clamp(1,self.ability.progress.current_with_anim,self.ability.progress.max-1) -- if progress=0 display dark 0 and dark 1, if progress=max display light max-1 and light max, otherwise display light current and dark current+1
        local sequence=self.ability.progress.sequence
        local dark_colors={darken(G.C.RED,0.3),darken(G.C.GREEN,0.3)}
        local light_colors={lighten(G.C.RED,0.3),lighten(G.C.GREEN,0.3)}
        local t1 = {
            n=G.UIT.ROOT, config = {minw = 0.6, align = 'tm', colour = darken(G.C.BLACK, 0.1), shadow = true, r = 0.05, padding = 0.03, minh = 0.6}, nodes={
                {n=G.UIT.R, config={minw=0.3, minh=0.3,align = "cm", r = 0.03, padding = 0.03, colour = true_current==0 and dark_colors[sequence[current].negative and 1 or 2] or light_colors[sequence[current].negative and 1 or 2]}, nodes={
                    betmma_spell_get_UInode(sequence[current].key)
                }},
                {n=G.UIT.R, config={minw=0.3, minh=0.3,align = "cm", r = 0.03, padding = 0.03, colour = true_current<self.ability.progress.max and dark_colors[sequence[current+1].negative and 1 or 2] or light_colors[sequence[current+1].negative and 1 or 2]}, nodes={
                    betmma_spell_get_UInode(sequence[current+1].key)
                }}
              },
            }
        self.children.hintUI=UIBox{
            definition = t1,
            config = {
              align="tm",
              offset = {x=0,y=1.5},
              major = self,
              bond = 'Weak',
              parent = self
            }
        }
    end
    data.generate_sequence_ref=data.generate_sequence
    -- set current, current_with_anim, max and call update_sequence
    data.generate_sequence=function(self)
        self.config.center.generate_sequence_ref(self)
        self.ability.progress.current=0--math.floor(pseudorandom('std_a',0,2))
        self.ability.progress.current_with_anim=self.ability.progress.current
        self.ability.progress.max=#self.ability.progress.sequence
        self.config.center.update_sequence(self)
    end
    data.calculate_ref=data.calculate
    -- if individual context and current card satisfies sequence increase progress. if sequence finished call calculate_ref
    data.calculate = function(self,card,context)
        if context.individual==true and context.cardarea == G.play then
            local other=context.other_card
            local next_=card.ability.progress.current%card.ability.progress.max+1
            local current_element=card.ability.progress.sequence[next_]
            if card_satisfying_element(other,current_element) then
                local current_ref=card.ability.progress.current
                card.ability.progress.current=next_
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = ""..next_..'/'..card.ability.progress.max,})
                after_event(function()
                    card.ability.progress.current_with_anim=next_
                    card.config.center.update_sequence(card)
                end)
                if next_==card.ability.progress.max then
                    local ret= card.config.center.calculate_ref(self,card,context)
                    pprint(ret)
                    card.ability.progress.current=0 -- hover ui will display as 0/max instead of max/max when this sequence ends and cascading ui displays 0/max
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "!",})
                    after_event(function()
                        card.ability.progress.current_with_anim=0
                        card.config.center.update_sequence(card)
                    end)
                    return ret
                end
            end
        end
    end
    --e.g. dark + light -> shadow, then dark.fuse_to={light='c_betm_shadow'}
    data.config.fuse_to={}
    --shadow.fuse_from={'dark','light'}
    if fused then
        local fusion=data.config.fuse_from
        local key_a=fusion[1];local key_b=fusion[2]
        local obj_a=betmma_spells_centers[key_a]
        local obj_b=betmma_spells_centers[key_b]
        obj_a.config.fuse_to[key_b]=data.key
        obj_b.config.fuse_to[key_a]=data.key
        data.in_pool= function(center)
            return G.GAME.fused_spell and G.GAME.fused_spell[center.raw_key],{allow_duplicates=true}
        end
    else
        data.in_pool= function(center)
            return true,{allow_duplicates=true}
        end
    end
    return SMODS.Consumable(data)
end

do
    -- get sprite of lil symbols just like those in deck preview. sprites are: {Chip, Ace, Face, Numbered, Heart, Diamond, Club, Spade} (though chip isn't used as a condition)
    function betmma_spell_get_symbol_sprite(index)
        local t_s = Sprite(0,0,0.3,0.3,G.ASSET_ATLAS["ui_"..(G.SETTINGS.colourblind_option and 2 or 1)], {x=index%4, y=math.floor(index/4)})
        t_s.states.drag.can = false
        t_s.states.hover.can = false
        t_s.states.collide.can = false
        return {n=G.UIT.O, config={can_collide = false, object = t_s}}
    end

    -- if key is in 8 symbolNames return corresponding sprite, otherwise return a text UI node
    function betmma_spell_get_UInode(key)
        local symbolNames={"Chip", "Ace", "Face", "Numbered", "Heart", "Diamond", "Club", "Spade"}
        local index=0
        for k,v in pairs(symbolNames) do
            if key==v then
                index=k
                break
            end
        end
        if index==0 then -- doesn't have sprite
            return {n=G.UIT.T, config={text = ''..key,colour = G.C.BLACK, scale =0.35}} -- how to make it round???
        end
        index=index-1 -- as indexing image starts at 0
        return betmma_spell_get_symbol_sprite(index)
    end

    local Card_draw_ref=Card.draw
    -- draw cascading hint ui, also generate its sequence if not prepared (upon buying since only in spell area will it draw hint ui)
    function Card:draw(layer)
        if self.ability.set=='Spell' and (self.area==G.betmma_spells or self.area==G.jokers or self.area==G.consumeables or self.area==G.deck or self.area==G.hand) and not ability_cooled_down(self) then --will spells go to jokers or other areas?
            Card_draw_ref(self,layer)
            if self.ability.prepared==false then
                self.ability.prepared=true
                self.config.center.generate_sequence(self)
            end
            if self.children.hintUI then
                self.children.hintUI:draw()
            else
                self.config.center.update_sequence(self)
            end
            return
        end
        Card_draw_ref(self,layer)
    end
end -- draw hint ui of spells

local function get_atlas(key,type)
    local px,py,prefix
    if type==nil or type=='spell' then
        px=34
        py=34
        prefix='s_'
    elseif type=='voucher' then
        px=71
        py=95
        prefix='v_'
    end
    betmma_spells_atlases[key]=SMODS.Atlas {  
        key = key,
        px = px,
        py = py,
        path = prefix..key..'.png'
    }
end

-- simply return {key=key,negative=negative}. maybe useful in future?
function get_element_table_in_card_ability(key,negative)
    local text=localize('spell_'..key)
    return {key=key,negative=negative,text=text~="ERROR" and text or key} -- if no localization use original key (like J Q K). text is used in hover ui
end
-- element should be from get_element_table_in_card_ability function
function card_satisfying_element(card,element)
    local satisfying=false
    local suits={Heart="Hearts", Diamond="Diamonds", Club="Clubs", Spade="Spades"}
    if suits[element.key] then
        satisfying=card:is_suit(suits[element.key])
    elseif element.key=='Face' then
        satisfying=card:is_face()    
    elseif element.key=='Ace' then
        satisfying=SMODS.Ranks[card.base.value].key == 'Ace'
    elseif element.key=='Numbered' then
        satisfying=not(card:is_face() or SMODS.Ranks[card.base.value].key == 'Ace')
    elseif element.key=='K' then
        satisfying=SMODS.Ranks[card.base.value].key == 'King'
    elseif element.key=='Q' then
        satisfying=SMODS.Ranks[card.base.value].key == 'Queen'
    elseif element.key=='J' then
        satisfying=SMODS.Ranks[card.base.value].key == 'Jack'
    else
        satisfying=SMODS.Ranks[card.base.value].key == element.key
    end
    return satisfying and element.negative==false or not satisfying and element.negative==true
end
local getica=get_element_table_in_card_ability
local possible_ranks={'Ace','K','Q','J','10','9','8','7','6','5','4','3','2'}
-- e.g. current_rank='Q',delta=2 -> 'Ace'
function betmma_spell_delta_rank(current_rank,delta)
    local function next_rank(rank)
        if rank=='Ace' then return '2'
        elseif rank=='K' then return 'Ace'
        elseif rank=='Q' then return 'K'
        elseif rank=='J' then return 'Q'
        elseif rank=='10' then return 'J'
        else
            return ''..(tonumber(rank)+1)
        end
    end
    for i = 1, delta do
        current_rank=next_rank(current_rank)
    end
    return current_rank
end
-- tier 1
do
    local key='dark'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Dark',
            text = {
                '{C:chips}+#1#{} chips',
            },
            before_desc="2 different Dark suits"
        },
        atlas = key, 
        config = {extra = {value=80},progress={},prepared=false },
        discovered = true,
        cost = 4,
        loc_vars = function(self, info_queue, card)
            return {vars = {
                card.ability.extra.value
            }}
        end,
        generate_sequence = function(self)
            self.ability.progress.sequence=pseudorandom_element({
                {getica('Spade',false),getica('Club',false)},
                {getica('Club',false),getica('Spade',false)},
            })
        end,
        calculate = function(self,card,context)
            return {
                    chips = card.ability.extra.value,
                    colour = darken(G.C.MULT,0.1), --this parameter is useless lol
                    card = card
                }
        end,
    }
end --dark
do
    local key='light'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Light',
            text = {
                '{C:mult}+#1#{} Mult',
            },
            before_desc="2 different Light suits"
        },
        atlas = key, 
        config = {extra = {value=10},progress={},prepared=false },
        discovered = true,
        cost = 4,
        loc_vars = function(self, info_queue, card)
            return {vars = {
                card.ability.extra.value
            }}
        end,
        generate_sequence = function(self)
            self.ability.progress.sequence=pseudorandom_element({
                {getica('Diamond',false),getica('Heart',false)},
                {getica('Heart',false),getica('Diamond',false)},
            })
        end,
        calculate = function(self,card,context)
            return {
                    mult = card.ability.extra.value,
                    card = card
                }
        end,
    }
end --light
do
    local key='earth'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Earth',
            text = {
                '{C:money}+$#1#{}',
            },
            before_desc="2 same ranks"
        },
        atlas = key, 
        config = {extra = {value=5},progress={},prepared=false },
        discovered = true,
        cost = 4,
        loc_vars = function(self, info_queue, card)
            return {vars = {
                card.ability.extra.value
            }}
        end,
        generate_sequence = function(self)
            local rank=pseudorandom_element(possible_ranks)
            self.ability.progress.sequence=pseudorandom_element({
                {getica(rank,false),getica(rank,false)},
            })
        end,
        calculate = function(self,card,context)
            ease_dollars(card.ability.extra.value)
            return {
                message = localize('$')..card.ability.extra.value,
                colour = G.C.MONEY,
                card = card
            }
        end,
    }
end --earth
do
    local key='air'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Air',
            text = {
                '{C:green}#1# in #2#{} chance to',
                'copy second card'
            },
            before_desc="2 different ranks with gap > 4"
        },
        atlas = key, 
        config = {extra = {value=4},progress={},prepared=false },
        discovered = true,
        cost = 4,
        loc_vars = function(self, info_queue, card)
            return {vars = {
                ""..(G.GAME and G.GAME.probabilities.normal or 1),
                card.ability.extra.value
            }}
        end,
        generate_sequence = function(self)
            local rank=pseudorandom_element(possible_ranks)
            local delta=pseudorandom_element({5,6,7})
            self.ability.progress.sequence=
                {getica(rank,false),getica(betmma_spell_delta_rank(rank,delta),false)}
        end,
        calculate = function(self,card,context)
            local other=context.other_card
            if pseudorandom('betmma_spells_air')<G.GAME.probabilities.normal/card.ability.extra.value then
                after_event(function()
                    local _card = copy_card(other, nil, nil, 1)
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.hand:emplace(_card)
                    _card:start_materialize(nil, _first_dissolve)
                    local new_cards = {}
                    new_cards[#new_cards+1] = _card
                    playing_card_joker_effects(new_cards)
                end)
            end
        end,
    }
end --air
do
    local key='water'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Water',
            text = {
                '{C:attention}decrease{} rank of', 
                'second card by 1'
            },
            before_desc="2 decreasing ranks x and x-1"
        },
        atlas = key, 
        config = {extra = {value=4},progress={},prepared=false },
        discovered = true,
        cost = 4,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            }}
        end,
        generate_sequence = function(self)
            local rank=pseudorandom_element(possible_ranks)
            local delta=12
            self.ability.progress.sequence=
                {getica(rank,false),getica(betmma_spell_delta_rank(rank,delta),false)}
        end,
        calculate = function(self,card,context)
            local other=context.other_card
            after_event(function()
                betmma_bump_rank(other,-1,false)
            end)
        end,
    }
end --water
do
    local key='fire'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Fire',
            text = {
                '{C:attention}destroy{} the second card'
            },
            before_desc="2 increasing ranks x and x+1"
        },
        atlas = key, 
        config = {extra = {value=4},progress={},prepared=false },
        discovered = true,
        cost = 4,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            }}
        end,
        generate_sequence = function(self)
            local rank=pseudorandom_element(possible_ranks)
            local delta=1
            self.ability.progress.sequence=
                {getica(rank,false),getica(betmma_spell_delta_rank(rank,delta),false)}
        end,
        calculate = function(self,card,context)
            local other=context.other_card
            after_event(function()
                other:start_dissolve()
            end)
        end,
    }
end --fire
-- tier 2
do
    local key='shadow'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Shadow',
            text = {
                '{X:mult,C:white}X#1#{} Mult'
            },
            before_desc="1 Dark suit and 1 Light suit"
        },
        atlas = key, 
        config = {extra = {value=1.25},fuse_from={'dark','light'},progress={},prepared=false },
        discovered = false,
        cost = 5,
        loc_vars = function(self, info_queue, card)
            return {vars = {
                card.ability.extra.value
            }}
        end,
        generate_sequence = function(self)
            self.ability.progress.sequence={
                getica(pseudorandom_element({'Spade','Club'}),false),
                getica(pseudorandom_element({'Heart','Diamond'}),false),
            }
        end,
        calculate = function(self,card,context)
            return {
                x_mult = card.ability.extra.value,
                card = card
            }
        end,
    }
end --shadow
do
    local key='abyss'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Abyss',
            text = {
                '{C:chips}+#1#*a{} chips where a',
                'equals rank of third card'
            },
            before_desc="2 ranks x, x-1, and a Dark suit"
        },
        atlas = key, 
        config = {extra = {value=30},fuse_from={'dark','water'},progress={},prepared=false },
        discovered = false,
        cost = 5,
        loc_vars = function(self, info_queue, card)
            return {vars = {
                card.ability.extra.value
            }}
        end,
        generate_sequence = function(self)
            local rank=pseudorandom_element(possible_ranks)
            local delta=12
            self.ability.progress.sequence={
                getica(rank,false),
                getica(betmma_spell_delta_rank(rank,delta),false),
                getica(pseudorandom_element({'Spade','Club'}),false),
            }
        end,
        calculate = function(self,card,context)
            local other=context.other_card
            return {
                chips = card.ability.extra.value*(other.base.nominal or 1),
                card = card
            }
        end,
    }
end --abyss
-- tier 3
do
    local key='ripple'
    get_atlas(key)
    betmma_spells_centers[key]=spell_prototype { 
        key = key,
        loc_txt = {
            name = 'Ripple',
            text = {
                '{X:mult,C:white}X#1#{} Mult'
            },
            before_desc="3 ranks x, x-1 and x"
        },
        atlas = key, 
        config = {extra = {value=2},fuse_from={'shadow','water'},progress={},prepared=false },
        discovered = false,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {
                card.ability.extra.value
            }}
        end,
        generate_sequence = function(self)
            local rank=pseudorandom_element(possible_ranks)
            local delta=12
            self.ability.progress.sequence={
                getica(rank,false),
                getica(betmma_spell_delta_rank(rank,delta),false),
                getica(rank,false),
            }
        end,
        calculate = function(self,card,context)
            return {
                x_mult = card.ability.extra.value,
                card = card
            }
        end,
    }
end --ripple
----------------------------------------------
------------MOD CODE END----------------------