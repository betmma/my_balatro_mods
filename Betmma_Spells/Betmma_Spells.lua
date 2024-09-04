--- STEAMODDED HEADER
--- MOD_NAME: Betmma Spells
--- MOD_ID: BetmmaSpells
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: New type of card: Spell
--- PREFIX: betm_spells
--- VERSION: 0.0.2(20240905)
--- DEPENDENCIES: [BetmmaAbilities>=1.0.3]
--- BADGE_COLOUR: 8DB09F

----------------------------------------------
------------MOD CODE -------------------------

MOD_PREFIX='betm_spells'
USING_BETMMA_SPELLS=true
IN_SMOD1=MODDED_VERSION>='1.0.0'
betmma_spells_objs={}
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
    -- override Spell cards UI and make use and sell buttons smaller
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
            
            local use={n=G.UIT.B, config = {w=0.1,h=1}}
            -- remove use button 
            local t = {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                {n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                    {n=G.UIT.R, config={align = 'cl'}, nodes={
                    sell
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
end -- Spell Area and Spell Cards preparation

SMODS.ConsumableType { -- Define Spell Consumable Type
    key = 'Spell',
    collection_rows = { 9,9,9,9 },
    primary_colour = G.C.CHIPS,
    secondary_colour = mix_colours(G.C.SECONDARY_SET.Voucher, G.C.CHIPS, 0.7),
    loc_txt = {
        collection = 'Spells',
        name = 'Spell',
        label = 'Spell'
    },
    shop_rate = 0.0,
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
    data.set="Spell"
    data.pos={x=0,y=0}
    table.insert(data.loc_txt.text,1,"{V:1}#11#{}{C:attention}#15#{}{V:2}#12#{}{C:attention}#16#{}{V:3}#13#{}{C:attention}#17#{}{V:4}#14#{}")
    data.loc_txt.text[#data.loc_txt.text+1]='{C:attention}#18#{}/{C:attention}#19#{}'
    data.loc_vars_ref=data.loc_vars
    data.loc_vars = function(self, info_queue, card)
        local ret=card.config.center.loc_vars_ref(self,info_queue,card)
        ret.vars.colours={G.C.BLACK,G.C.BLACK,G.C.BLACK,G.C.BLACK}
        while #ret.vars<20 do
            ret.vars[#ret.vars+1]=""
        end
        ret.vars[18]=card.ability.progress.current or 0
        ret.vars[19]=card.ability.progress.max or "?"
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
            ret.vars[i]=" -> "
        end
        return ret
    end
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
    data.generate_sequence=function(self)
        self.config.center.generate_sequence_ref(self)
        self.ability.progress.current=0--math.floor(pseudorandom('std_a',0,2))
        self.ability.progress.current_with_anim=self.ability.progress.current
        self.ability.progress.max=#self.ability.progress.sequence
        self.config.center.update_sequence(self)
    end
    data.calculate_ref=data.calculate
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
    -- draw cascading hint ui
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
    return {key=key,negative=negative,text=text~="ERROR" and text or key} -- if no localization use original key (like J Q K)
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
do
    local key='dark'
    get_atlas(key)
    betmma_spells_objs[key]=spell_prototype { 
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
        can_use = function(self,card)
            return false
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
    betmma_spells_objs[key]=spell_prototype { 
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
        can_use = function(self,card)
            return false
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
----------------------------------------------
------------MOD CODE END----------------------