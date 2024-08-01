--- STEAMODDED HEADER
--- MOD_NAME: Betmma Abilities
--- MOD_ID: BetmmaAbilities
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: New type of card: Abilities
--- PREFIX: betm_abilities
--- VERSION: 1.0.2.3(20240731)
--- BADGE_COLOUR: 8D90BF

----------------------------------------------
------------MOD CODE -------------------------
--[[ todo: compatibility with hammerspace (CCD) or in consumable slots
current progress: abilities are able to cooldown everywhere, but passive calculations (using calculate function) don't work in other areas. Active abilities can work.
]]
MOD_PREFIX='betm_abilities'
USING_BETMMA_ABILITIES=true
betm_abilities={}
betm_abilities_atlases={}
function get_randomly_redeem_voucher()
    if not randomly_redeem_voucher then
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
    end
end -- randomly_redeem_voucher

do

    do
        local Card_set_ability_ref=Card.set_ability
        function Card:set_ability(center, initial, delay_sprites)
            local X, Y, W, H = self.T.x, self.T.y, self.T.w, self.T.h
            if center.set=='Ability' then
                -- self.T.w=W*34/71
                -- self.T.h=H*34/95
                self.T.w=G.ABILITY_W or 0.8
                self.T.h=G.ABILITY_H or 0.8
            end
            Card_set_ability_ref(self,center,initial,delay_sprites)
        end

        local Card_load=Card.load
        function Card:load(cardTable,other_card)
            local X, Y, W, H = self.T.x, self.T.y, self.T.w, self.T.h
            if G.P_CENTERS[cardTable.save_fields.center].set=='Ability' then
                G.P_CENTERS[cardTable.save_fields.center].load=function()
                    self.T.w=G.ABILITY_W or 0.8
                    self.T.h=G.ABILITY_H or 0.8
                end
            end

            Card_load(self,cardTable,other_card)
        end
    end -- make Abilities appear as 34*34 instead of card size 71*95

    local CardArea_draw_ref=CardArea.draw
    -- enable Ability area to draw abilities in it
    function CardArea:draw()
        CardArea_draw_ref(self) -- this should be called before drawing cards inside it otherwise the area will block the cards and you can't hover on them
        if self.config.type == 'betmma_ability' then 
            for i = 1, #self.cards do 
                if self.cards[i] ~= G.CONTROLLER.focused.target then
                    if not self.cards[i].highlighted then
                        if G.CONTROLLER.dragging.target ~= self.cards[i] then self.cards[i]:draw(v) end
                    end
                end
            end
            for i = 1, #self.cards do  
                if self.cards[i] ~= G.CONTROLLER.focused.target then
                    if self.cards[i].highlighted then
                        if G.CONTROLLER.dragging.target ~= self.cards[i] then self.cards[i]:draw(v) end
                    end
                end
            end
        end
    end

    local function cardarea_align(self,direction)
        local alignd='x'  -- align dimension
        local alignp='w'  -- align parameter (card.w)
        local alignp2='card_w' -- align parameter2 (self.card_w)
        local otherd='y'
        local otherp='h'
        if direction=='vertical' then
            alignd='y'
            alignp='h'
            alignp2='card_h'
            self.card_h=self.card_h or self.config.card_h or G.CARD_H
            -- self.T[alignp]-self[alignp2] determines the length of range of cards distributed inside. I set shop_ability.config.card_h to 0.1 to increase the range.
            otherd='x'
            otherp='w'
        end
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then 
                card.T.r = 0.1*(-#self.cards/2 - 0.5 + k)/(#self.cards)+ (G.SETTINGS.reduced_motion and 0 or 1)*0.02*math.sin(2*G.TIMERS.REAL+card.T[alignd])
                local max_cards = math.max(#self.cards, self.config.temp_limit)
                card.T[alignd] = self.T[alignd] + (self.T[alignp]-self[alignp2])*((k-1)/math.max(max_cards-1, 1) - 0.5*(#self.cards-max_cards)/math.max(max_cards-1, 1)) + 0.5*(self[alignp2] - card.T[alignp])
                if #self.cards > 2 or (#self.cards > 1 and self == G.consumeables) or (#self.cards > 1 and self.config.spread) then
                    card.T[alignd] = self.T[alignd] + (self.T[alignp]-self[alignp2])*((k-1)/(#self.cards-1)) + 0.5*(self[alignp2] - card.T[alignp])
                elseif #self.cards > 1 and self ~= G.consumeables then
                    card.T[alignd] = self.T[alignd] + (self.T[alignp]-self[alignp2])*((k - 0.5)/(#self.cards)) + 0.5*(self[alignp2] - card.T[alignp])
                else
                    card.T[alignd] = self.T[alignd] + self.T[alignp]/2 - self[alignp2]/2 + 0.5*(self[alignp2] - card.T[alignp])
                end
                local highlight_height = G.HIGHLIGHT_H/2
                if not card.highlighted then highlight_height = 0 end
                card.T[otherd] = self.T[otherd] + self.T[otherp]/2 - card.T[otherp]/2 - highlight_height+ (G.SETTINGS.reduced_motion and 0 or 1)*0.03*math.sin(0.666*G.TIMERS.REAL+card.T[alignd])
                card.T[alignd] = card.T[alignd] + card.shadow_parrallax.x/30
            end
        end
        if not G.GAME.modifiers.cry_conveyor then table.sort(self.cards, function (a, b) return a.T[alignd] + a.T[alignp]/2 - 100*(a.pinned and a.sort_id or 0) < b.T[alignd] + b.T[alignp]/2 - 100*(b.pinned and b.sort_id or 0) end) end
    end

    local CardArea_align_cards_ref=CardArea.align_cards
    -- enable Ability area to align cards in its border. Also implement vertical align for Ability shop area.
    function CardArea:align_cards()
        if self==G.betmma_abilities then
            self.T.y=self.T.y-0.04 -- dunno why abilities are slightly lower than upper border. move them up a bit
            cardarea_align(self)
            self.T.y=self.T.y+0.04
        end
        if self.config.vertical==true and self.config.type=='shop' then
            cardarea_align(self,'vertical')
            for k, card in ipairs(self.cards) do
                card.rank = k
            end
            if self.children.view_deck then
                self.children.view_deck:set_role{major = self.cards[1] or self}
            end
            return
        end
        CardArea_align_cards_ref(self)
    end

    local CardArea_can_highlight_ref=CardArea.can_highlight
    -- enable cards in Ability area to be highlighted (clicked)
    function CardArea:can_highlight(card)
        if self==G.betmma_abilities then
            return true
        end
        return CardArea_can_highlight_ref(self,card)
    end

    local CardArea_add_to_highlight_ref=CardArea.add_to_highlighted
    -- let Ability area add highlights like jokers and consumables area
    function CardArea:add_to_highlighted(card, silent)
        if self.config.type == 'betmma_ability' then
            if #self.highlighted >= self.config.highlighted_limit then 
                self:remove_from_highlighted(self.highlighted[1])
            end
            self.highlighted[#self.highlighted+1] = card
            card:highlight(true)
            if not silent then play_sound('cardSlide1') end
            return
        end
        CardArea_add_to_highlight_ref(self,card,silent)
    end

    local Card_can_sell_card_ref=Card.can_sell_card
    -- let Abilities always be sellable
    function Card:can_sell_card(context)
        if self.ability.set=='Ability' then
            return true
        end
        return Card_can_sell_card_ref(self,context)
    end

    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    -- override Ability cards UI and make use and sell buttons smaller
    function G.UIDEF.use_and_sell_buttons(card)
        if card.ability.set=='Ability' then 
            if card.area and card.area == G.pack_cards then
                return {
                n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
                    {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.3*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_select_card'}, nodes={
                    {n=G.UIT.T, config={text = localize('b_select'),colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}}
                    }},
                }}
            end -- only create SELECT if in pack
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
    -- prevent buy and use button on abilities in shop (will appear if cooldown is 0 and will crash when clicked)
    G.FUNCS.can_buy_and_use = function(e)
        G_FUNCS_can_buy_and_use_ref(e)
        if e.config.ref_table.ability.set=='Ability' then
            e.UIBox.states.visible = false
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        end
    end

    local G_FUNCS_check_for_buy_space_ref=G.FUNCS.check_for_buy_space
    G.FUNCS.check_for_buy_space = function(card)
        if card.ability.set=='Ability' then
            if #G.betmma_abilities.cards < G.betmma_abilities.config.card_limit + ((card.edition and card.edition.negative) and 1 or 0) then
                return true
            else
                return false
            end
        end
        return G_FUNCS_check_for_buy_space_ref(card)
    end
end -- Ability Area and Ability Cards preparation

do
    local end_round_ref = end_round
    -- set create_ability_shop to *defeated blind is boss blind*
    function end_round()
        if G.GAME.blind:get_type() == 'Boss' then
            G.GAME.create_ability_shop=true
        else
            G.GAME.create_ability_shop=false
        end
        end_round_ref()
    end

    local function multilines_text_ui(texts)
        local t={n=G.UIT.R, config={minh=3, align = "cm", padding = 0, r=0.2, colour = G.C.L_BLACK, emboss = 0, minw = 1}, nodes={}
            }
        for k, v in pairs(texts) do
            t.nodes[#t.nodes+1]={n=G.UIT.R, config={minh=0.4,align = "cm", colour = G.C.L_BLACK}, nodes={
                {n=G.UIT.T, config={text = v, scale = 0.6, colour = G.C.WHITE}}
            }}
        end
        return t
    end

    local G_FUNCS_skip_blind_ref=G.FUNCS.skip_blind
    -- set create_ability_shop to false when skipping blind (deal with overshopping)
    G.FUNCS.skip_blind = function(e)
        G_FUNCS_skip_blind_ref(e)
        G.GAME.create_ability_shop=false
    end
    local G_UIDEF_shop_ref= G.UIDEF.shop
    function G.UIDEF.shop()
        local t=G_UIDEF_shop_ref()
        if G.GAME.create_ability_shop then
            G.GAME.shop.ability_max=G.GAME.shop.ability_max or 2
            local abilities_w=0.8
            G.shop_abilities = CardArea(
              G.hand.T.x+0,
              G.hand.T.y+G.ROOM.T.y + 9,
              abilities_w,
              1.05*G.CARD_H, 
              {card_limit = G.GAME.shop.ability_max, type = 'shop', highlight_limit = 1, vertical=true, card_h=0.1})
            local row2=t.nodes[1].nodes[1].nodes[1].nodes[1] -- UIBox_dyn_container needs 3 nodes[1]. 4 nodes[1] is line 699
            row2=row2.nodes[3].nodes -- nodes of second row (row2.nodes[2] is an empty row)
            G.shop_vouchers.T.w=G.shop_vouchers.T.w-abilities_w -- shorten voucher area to give space to my ability area
            row2[#row2+1]={n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, emboss = 0.05, maxw = abilities_w}, nodes={
                {n=G.UIT.O, config={object = G.shop_abilities}},
            }}
            if not G.betmma_abilities then
                G.shop_vouchers.T.w=G.shop_vouchers.T.w-abilities_w
                row2[#row2].config.padding=0
                row2[#row2].config.minw=abilities_w*3.5
                row2[#row2].config.maxw=abilities_w*3.5
                row2[#row2].nodes[1]=multilines_text_ui(
                    {
                        'ability.toml',
                        'not found!',
                        'should be under',
                        'Mods/betmma_mods', 
                        '(secondary folder',
                        'where my mods are)',
                        '/lovely instead',
                        'of Mods/lovely',
                    }
                )
            end
        else
            G.shop_abilities=nil
        end
        return t
    end
end -- add Ability area in shop (only appear after a boss blind)

do
    function GET_PATH_COMPAT()
        return IN_SMOD1 and SMODS.current_mod.path or SMODS.findModByID('BetmmaVouchers').path
    end

    function betmma_load_shader(v)
        local file = NFS.read(GET_PATH_COMPAT().."/shaders/"..v..".fs")
        love.filesystem.write(v.."-temp.fs", file)
        G.SHADERS[v] = love.graphics.newShader(v.."-temp.fs")
        love.filesystem.remove(v.."-temp.fs")
    end
    betmma_load_shader('cooldown')

    local Card_draw_ref=Card.draw
    function Card:draw(layer)
        if self.ability.set=='Ability' and (self.area==G.betmma_abilities or self.area==G.jokers or self.area==G.consumeables or self.area==G.deck or self.area==G.hand) and not ability_cooled_down(self) then --if i wrote self.area~=shop_abilities then in collection menu it's still grayed
            Card_draw_ref(self,layer)
            local _send=self.ARGS.send_to_shader
            _send={betmma=true,extra={{name='percentage',val=ability_cooled_down_percentage(self)}},vanilla=_send}
            -- print(_send[1].val)
            self.children.center:draw_shader('cooldown', nil, _send)
            if self.children.front and self.ability.effect ~= 'Stone Card' then
                self.children.front:draw_shader('cooldown', nil, _send)
            end
            return
        else
            if self.stash_debuff~=nil then
                self:set_debuff(self.stash_debuff)
                self.stash_debuff=nil
            end
        end
        Card_draw_ref(self,layer)
    end
end -- Cooldown shader

do
    function update_ability_cooldown_single_area(cardarea,type,value)
        if cardarea==nil or cardarea.cards==nil then return end
        for i=1,#cardarea.cards do
            local card=cardarea.cards[i]
            if card.ability and card.ability.cooldown and card.ability.cooldown.type==type then
                card.ability.cooldown.now=card.ability.cooldown.now-value
                if card.ability.cooldown.now<0 then
                    card.ability.cooldown.now=0
                end
            end
        end
    end
    function update_ability_cooldown(type,value)
        if value==nil then value=1 end
        if G.betmma_abilities==nil then
            print("G.betmma_abilities doesn't exist! Maybe ability.toml isn't installed correctly.")
            return
        end
        update_ability_cooldown_single_area(G.betmma_abilities,type,value)
        update_ability_cooldown_single_area(G.jokers,type,value)
        update_ability_cooldown_single_area(G.consumeables,type,value)
        update_ability_cooldown_single_area(G.deck,type,value)
    end

    local ease_ante_ref=ease_ante
    -- update 'ante' cooldown
    function ease_ante(mod)
        update_ability_cooldown('ante')
        ease_ante_ref(mod)
    end

    local end_round_ref = end_round
    -- update 'round' cooldown
    function end_round()
        update_ability_cooldown('round')
        end_round_ref()
    end

    local ease_dollars_ref = ease_dollars
    -- update 'money used' and 'money gain' cooldown
    function ease_dollars(mod, instant)
        if mod<0 then
            update_ability_cooldown('money used',-mod)
        elseif mod>0 then
            update_ability_cooldown('money gain',mod)
        end
        ease_dollars_ref(mod, instant)
    end
    
    local G_FUNCS_skip_blind_ref=G.FUNCS.skip_blind
    -- update 'blind skip' cooldown
    G.FUNCS.skip_blind = function(e)
        update_ability_cooldown('blind skip')
        G_FUNCS_skip_blind_ref(e)
    end

    local G_FUNCS_play_cards_from_highlighted_ref=G.FUNCS.play_cards_from_highlighted
    -- update 'hand' cooldown
    G.FUNCS.play_cards_from_highlighted=function(e)
        G.thumb_triggered=false -- thumb can only trigger once
        update_ability_cooldown('hand')
        local ret= G_FUNCS_play_cards_from_highlighted_ref(e)
        return ret
    end
end -- update cooldown in different situations

SMODS.ConsumableType { -- Define Ability Consumable Type
    key = 'Ability',
    collection_rows = { 6,6,6,6 },
    primary_colour = G.C.CHIPS,
    secondary_colour = mix_colours(G.C.SECONDARY_SET.Voucher, G.C.MULT, 0.9),
    loc_txt = {
        collection = 'Abilities',
        name = 'Ability',
        label = 'Abililty'
    },
    shop_rate = 0.0,
    default = 'c_betm_abilities_philosophy',
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

        local sum = 0
        for j = 1, #G.your_collection do
            for i = 1, self.collection_rows[j] do
                sum = sum + 1
                local center = G.P_CENTER_POOLS[self.key][sum]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y,
                    G.CARD_W, G.CARD_H, nil, center)
                card:start_materialize(nil, i > 1 or j > 1)
                G.your_collection[j]:emplace(card)
            end
        end

        local center_options = {}
        for i = 1, math.ceil(#G.P_CENTER_POOLS[self.key] / sum) do
            table.insert(center_options,
                localize('k_page') ..
                ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#G.P_CENTER_POOLS[self.key] / sum)))
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
        if SMODS.Palettes[self.key] and #SMODS.Palettes[self.key].names > 1 then
            option_nodes[#option_nodes + 1] = create_option_cycle({
                w = 4.5,
                scale = 0.8,
                options = SMODS.Palettes[self.key].names,
                opt_callback = "update_recolor",
                current_option = G.SETTINGS.selected_colours[self.key].order,
                type = self.key
            })
        end
        local t = create_UIBox_generic_options({
            back_func = 'your_collection',
            contents = {
                { n = G.UIT.R, config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
                { n = G.UIT.R, config = { align = "cm", padding = 0 },                                                           nodes = option_nodes },
            }
        })
        return t
    end
}

local function ability_prototype(data)
    data.keep_on_use = function(self,card)
        return true
    end
    data.config.cardarea='betmma_abilities'
    data.set="Ability"
    data.pos={x=0,y=0}
    return SMODS.Consumable(data)
end

-- return first ability (card) whose key is key. If none return nil.
function has_ability(key)
    if G.betmma_abilities and G.betmma_abilities.cards then
        for i=1,#G.betmma_abilities.cards do
            -- print(G.betmma_abilities.cards[i].config.center.key)
            -- print(betm_abilities[key].key)
            if G.betmma_abilities.cards[i].config.center.key==betm_abilities[key].key then
                return G.betmma_abilities.cards[i]
            end
        end 
    end
    return nil
end 

local Card_use_consumeable_ref=Card.use_consumeable
-- add cooldown when ability is used
function Card:use_consumeable(area, copier)
    if self.ability.set=='Ability' and self.ability.cooldown and self.ability.cooldown.type~='passive' then
        self.ability.cooldown.now=self.ability.cooldown.now+self.ability.cooldown.need
    end
    Card_use_consumeable_ref(self,area,copier)
end

local function get_atlas(key)
    betm_abilities_atlases[key]=SMODS.Atlas {  
        key = key,
        px = 34,
        py = 34,
        path = 'a_'..key..'.png'
    }
end
function ability_cooled_down(self,card)
    if not card then card=self end
    if card.ability.cooldown and (card.ability.cooldown.type=='passive' or card.ability.cooldown.now<=0) then
        return true
    else
        return false
    end
end
function ability_cooled_down_percentage(card)
    if card.ability.cooldown then
        if card.ability.cooldown.type=='passive'then return 0 end
        return math.max(card.ability.cooldown.now,0)/card.ability.cooldown.need
    end
    return 0
end

do
    local key='GIL'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { --GIL
        key = key,
        loc_txt = {
            name = 'Global Interpreter Lock',
            text = {
                'If all jokers are {C:attention}Eternal{}, remove',
                '{C:attention}Eternal{} from all jokers. Otherwise,',
                'set all jokers to be {C:attention}Eternal{}.',
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = {}, cooldown={type='round', now=1, need=1} },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type}}
        end,
        can_use = ability_cooled_down,
        use = function(self,card,area,copier)
            -- pprint(card.ability.cooldown)
            local allEternal=true
            for i = 1, #G.jokers.cards do
                if not G.jokers.cards[i].ability.eternal then
                    allEternal=false
                    break
                end
            end
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i].ability.eternal=not allEternal
            end
        end,
        -- add_to_deck=ability_copy_table
    }
end --GIL
do
    local key='glitched_seed'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { --glitched seed
        key = key,
        loc_txt = {
            name = 'Glitched Seed',
            text = {
                'Next #5# {C:attention}random events',
                'are guaranteed success', 
                '(#4# times left)',
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = { value=2},cooldown={type='round', now=1, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,pseudorandom_forced_0_count,card.ability.extra.value}}
        end,
        can_use = ability_cooled_down,
        use = function(self,card,area,copier)
            pseudorandom_forced_0_count=pseudorandom_forced_0_count+card.ability.extra.value
            
        end
    }

    pseudorandom_forced_0_count=0
    local pseudorandom_ref=pseudorandom
    function pseudorandom(seed, min, max)
        if pseudorandom_forced_0_count>0 and type(seed) == 'string' and not string.match(seed,'^std') and not string.match(seed,'^soul_') and not string.match(seed,'^cry_et') and not string.match(seed,'^cry_per') and not string.match(seed,'^cry_pin') and not string.match(seed,'^cry_flip') and not string.match(seed,'^d6_joker') and not string.match(seed,'^consumable_type') and seed~='wheel' and seed~='shy_today' and seed~='certsl' and seed~='real_random'then
            pseudorandom_forced_0_count=pseudorandom_forced_0_count-1
            if min and max then
                return min
            end
            return 0
        end
        return pseudorandom_ref(seed, min, max)
    end
end --glitched seed
do
    local key='rank_bump'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { --rank bump
        key = key,
        loc_txt = {
            name = 'Rank Bump',
            text = {
                'Temporarily increase ranks of',
                'chosen cards by 1 for this hand',
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = { },cooldown={type='hand', now=2, need=2}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card)and #G.hand.highlighted>0 and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK)
        end,
        use = function(self,card,area,copier)
            
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    local card = G.hand.highlighted[i]
                    card.ability.rank_bumped=(card.ability.rank_bumped or 0)+1
                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                    local rank_suffix = card.base.id == 14 and 2 or math.min(card.base.id+1, 14)
                    if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                    elseif rank_suffix == 10 then rank_suffix = 'T'
                    elseif rank_suffix == 11 then rank_suffix = 'J'
                    elseif rank_suffix == 12 then rank_suffix = 'Q'
                    elseif rank_suffix == 13 then rank_suffix = 'K'
                    elseif rank_suffix == 14 then rank_suffix = 'A'
                    end
                    card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                return true end }))
            end  
            
        end
    }

    local function cancel_bump(area)
        for k, v in ipairs(area.cards) do
            if v.ability.rank_bumped then
                for i=1,v.ability.rank_bumped do
                    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                        local card=v
                        local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                        local rank_suffix = card.base.id == 2 and 14 or math.max(card.base.id-1, 2)
                        if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                        elseif rank_suffix == 10 then rank_suffix = 'T'
                        elseif rank_suffix == 11 then rank_suffix = 'J'
                        elseif rank_suffix == 12 then rank_suffix = 'Q'
                        elseif rank_suffix == 13 then rank_suffix = 'K'
                        elseif rank_suffix == 14 then rank_suffix = 'A'
                        end
                        card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                        v.ability.rank_bumped=nil
                    return true end }))
                end
            end
        end
    end

    local function remove_temp_antidebuff(area)
        for k,v in ipairs(area.cards) do
            v.ability.heal_ability_temp_antidebuff=nil
        end
    end

    
    local function apply_to_all_cards(func)
        func(G.play)
        func(G.hand)
        func(G.discard)
        func(G.deck)
    end
    local function all_functions_to_all_cards()
        apply_to_all_cards(cancel_bump)
        apply_to_all_cards(remove_temp_antidebuff)
    end

    local G_FUNCS_draw_from_play_to_discard_ref=G.FUNCS.draw_from_play_to_discard
    G.FUNCS.draw_from_play_to_discard = function(e)
        all_functions_to_all_cards()
        G_FUNCS_draw_from_play_to_discard_ref(e)
    end

    local G_FUNCS_discard_cards_from_highlighted=G.FUNCS.discard_cards_from_highlighted
    G.FUNCS.discard_cards_from_highlighted = function(e, hook)
        if not hook then
            all_functions_to_all_cards()
        end
        G_FUNCS_discard_cards_from_highlighted(e,hook)
    end
end --rank bump
do
    local key='cached_hand'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Cached Hand',
            text = {
                '{C:attention}Hand type{} of next hand is',
                'set to the last hand',
                'that is {C:attention}#4#',
                '(#5# hands left)',
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = { },cooldown={type='round', now=1, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,
            G.GAME.last_hand_played or 'High Card',(G.GAME.betmma_cached_hand or 0)}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK)
        end,
        use = function(self,card,area,copier)
            G.GAME.betmma_cached_hand=(G.GAME.betmma_cached_hand or 0)+1
            if #G.hand.highlighted>0 and not(G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards>0) then
                G.hand:parse_highlighted()
            end
            
        end
    }
    local G_FUNCS_evaluate_play_ref=G.FUNCS.evaluate_play
    G.FUNCS.evaluate_play=function(e)
        local ret= G_FUNCS_evaluate_play_ref(e)
        G.GAME.betmma_cached_hand=(G.GAME.betmma_cached_hand or 0)-1
        if G.GAME.betmma_cached_hand<=0 then
            G.GAME.betmma_cached_hand=0
        end
        return ret
    end

    local G_FUNCS_get_poker_hand_info_ref=G.FUNCS.get_poker_hand_info
    function G.FUNCS.get_poker_hand_info(_cards)
        local text, loc_disp_text, poker_hands, scoring_hand, disp_text=G_FUNCS_get_poker_hand_info_ref(_cards)
        if G.GAME.betmma_cached_hand and G.GAME.betmma_cached_hand>0 then
            text=G.GAME.last_hand_played or 'High Card'
            loc_disp_text=localize(text, 'poker_hands')
        end
        return text, loc_disp_text, poker_hands, scoring_hand, disp_text
    end
end --cached hand
do
    local key='heal'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Heal',
            text = {
                "Undebuff selected cards",
                "for this hand",
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = { },cooldown={type='hand', now=3, need=3}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',
            }}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and G.hand.highlighted and #G.hand.highlighted>0
        end,
        use = function(self,card,area,copier)
            for i=1,#G.hand.highlighted do
                G.hand.highlighted[i]:set_debuff(false)
                G.hand.highlighted[i].ability.heal_ability_temp_antidebuff=true
            end
            
        end
    }
end --heal
do
    local key='absorber'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Absorber',
            text = {
                "Reduce {C:blue}Hand{} to 1, and gain",
                "{X:mult,C:white}X#4#{} for each hand reduced",
                -- "Current Gain: {X:mult,C:white}X#5#{}",
                "Current Xmult: {X:mult,C:white}X#5#{}",
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = {add=0.1,value=1},cooldown={type='ante', now=1, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,
            card.ability.extra.add,card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and G and G.STATE == G.STATES.SELECTING_HAND and G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left and G.GAME.current_round.hands_left>1
        end,
        use = function(self,card,area,copier)
            card.ability.extra.value=card.ability.extra.value+card.ability.extra.add*(G.GAME.current_round.hands_left-1)
            ease_hands_played(-G.GAME.current_round.hands_left+1)
            
        end,
        calculate=function(self,card,context)
            if context.joker_main then
                -- ease_dollars(-card.ability.extra.lose)
                -- card_eval_status_text(card, 'dollars', -card.ability.extra.lose)
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.value}},
                    Xmult_mod = card.ability.extra.value
                }
            end
        end
    }
end --absorber
do
    local key='double_lift'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Double Lift',
            text = {
                "Choose {C:attention}#4#{} more card",
                "in current pack",
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = {value=1},cooldown={type='round', now=2, need=2}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and G and G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards>0
        end,
        use = function(self,card,area,copier)
            if G.GAME.pack_choices then
                G.GAME.pack_choices=G.GAME.pack_choices+1
            end
        end,
    }
end --double lift
do
    local key='recycle'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Recycle',
            text = {
                "Reduce reroll price by {C:money}$#4#{}",
                'Cooldown: {C:mult}$#1#/$#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {value=5},cooldown={type='money used', now=20, need=20}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and G and G.STATE == G.STATES.SHOP
        end,
        use = function(self,card,area,copier)
            if G.GAME.round_resets.temp_reroll_cost then
                G.GAME.round_resets.temp_reroll_cost = math.max(G.GAME.round_resets.temp_reroll_cost - G.GAME.current_round.reroll_cost, G.GAME.round_resets.temp_reroll_cost - card.ability.extra.value)
            else
                G.GAME.round_resets.temp_reroll_cost = math.max(G.GAME.round_resets.reroll_cost - G.GAME.current_round.reroll_cost, G.GAME.round_resets.reroll_cost - card.ability.extra.value)
            end
            calculate_reroll_cost(true)
            -- G.GAME.current_round.reroll_cost = math.max(0, G.GAME.current_round.reroll_cost - card.ability.extra.value)
            
        end,
    }
end --recycle
do
    local key='glyph'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Glyph',
            text = {
                "{C:attention}-#4#{} Ante, {C:money}-$#5#",
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {value=1,cost=10},cooldown={type='blind skip', now=4, need=4}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',
            card.ability.extra.value,card.ability.extra.cost}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card)
        end,
        use = function(self,card,area,copier)
            ease_ante(-card.ability.extra.value)
            ease_dollars(-card.ability.extra.cost)
        end,
    }
end --glyph
do
    local key='colour'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Colour',
            text = {
                "Create a random ability", 
                    "{C:inactive}(Must have room)",
                -- "(Cooldown is higher before first use)",
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {},cooldown={type='round', now=2, need=2}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s'}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and #G.betmma_abilities.cards < G.betmma_abilities.config.card_limit
        end,
        use = function(self,card,area,copier)
            local center=pseudorandom_element(G.P_CENTER_POOLS['Ability'],pseudoseed('abilities'))
            local card = create_card('Ability', nil, nil, nil, nil, nil, nil, 'colour')
            -- card:start_materialize()
            -- card:set_edition({negative=true}) --negative edition on abilities is buggy
            card:add_to_deck()
            G.betmma_abilities:emplace(card)
        end,
    }
end --colour
do
    local key='extract'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Extract',
            text = {
                "Downgrade current hand",
                "and create a {C:dark_edition}Negative", 
                "{C:planet}Planet{} card of it", 
                -- "(Cooldown is higher before first use)",
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {},cooldown={type='hand', now=2, need=2}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s'}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and #G.hand.highlighted>0 and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK)
        end,
        use = function(self,card,area,copier)
            local card_type = 'Planet'
            local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            
            level_up_hand(nil, text, nil, -1)
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                    if text then
                        local _planet = 0
                        for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                            if v.config.hand_type == text then
                                _planet = v.key
                            end
                        end
                        local card2 = create_card(card_type,G.consumeables, nil, nil, nil, nil, _planet, 'blusl')
                        card2:set_edition({negative=true})
                        card2:add_to_deck()
                        G.consumeables:emplace(card2)
                        G.GAME.consumeable_buffer = 0
                    end
                    return true
                end)}))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})
            -- card:start_materialize()
        end,
    }
end --extract
do
    local key='zircon'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Zircon',
            text = {
                '{C:green}#4#%{} chance to create a', 
                '{C:legendary,E:1}Legendary{} Joker, otherwise',
                'create a {C:legendary,E:1}Legendary{} Voucher',
                'Cooldown: {C:mult}#1#/#2# #3# {}'
        }
        },
        atlas = key, 
        config = {extra = {chance=50 },cooldown={type='hand', now=25, need=25}, },
        discovered = true,
        cost = 20,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',
            card.ability.extra.chance}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK)
        end,
        use = function(self,card,area,copier)
            local space_left=G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer)
            if space_left>0 and pseudorandom('zircon')<card.ability.extra.chance/100 then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('timpani')
                    local card = create_card('Joker', G.jokers, true, nil, nil, nil, nil, 'sou')
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    check_for_unlock{type = 'spawn_legendary'}
                    return true end }))
            else
                local key
                if USING_BETMMA_VOUCHERS then
                    local get_current_pool_ref=get_current_pool
                    get_current_pool=function(key)
                        return get_voucher_pool_with_filter(
                            function(card)
                                return get_rarity_card(card)==4
                            end
                        )
                    end
                    key= get_next_voucher_key_ref()
                    get_current_pool=get_current_pool_ref
                else
                    key=get_next_voucher_key()
                end
                get_randomly_redeem_voucher()
                randomly_redeem_voucher(key)
            end
            
        end
    }
end --zircon
do
    local key='rental_slot'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Rental Slot',
            text = {
                "{C:dark_edition}+#1#{} Joker Slot. Lose",
                "{C:money}$#2#{} after each round",
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=1,lose=4},cooldown={type='passive'}, },
        discovered = true,
        cost = 1,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            card.ability.extra.value,card.ability.extra.lose}}
        end,
        can_use = function(self,card)
            return false
        end,
        add_to_deck = function(self,card,area,copier)
            G.E_MANAGER:add_event(Event({func = function()
                if G.jokers then 
                    G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.value
                end
                return true end }))
        end,
        remove_from_deck = function(self,card,area,copier)
            G.E_MANAGER:add_event(Event({func = function()
                if G.jokers then 
                    G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.value
                end
                return true end }))
        end,
        calculate=function(self,card,context)
            if context.end_of_round then
                ease_dollars(-card.ability.extra.lose)
                card_eval_status_text(card, 'dollars', -card.ability.extra.lose)
            end
        end
    }
    
    local end_round_ref = end_round
    function end_round()
        if G.betmma_abilities and G.betmma_abilities.cards then
            for i=1,#G.betmma_abilities.cards do
                G.betmma_abilities.cards[i]:calculate_joker({end_of_round=true})
            end 
        end
        end_round_ref()
    end
end --rental slot
do
    local key='philosophy'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Philosophy',
            text = {
                "{C:attention}+#1#{} Ability Slot",
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=1},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return false
        end,
        add_to_deck = function(self,card,area,copier)
            G.E_MANAGER:add_event(Event({func = function()
                if G.betmma_abilities then 
                    G.betmma_abilities.config.card_limit = G.betmma_abilities.config.card_limit + card.ability.extra.value
                end
                return true end }))
        end,
        remove_from_deck = function(self,card,area,copier)
            G.E_MANAGER:add_event(Event({func = function()
                if G.betmma_abilities then 
                    G.betmma_abilities.config.card_limit = G.betmma_abilities.config.card_limit - card.ability.extra.value
                end
                return true end }))
        end,
    }
end --philosophy
do
    local key='midas_touch'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Midas Touch',
            text = {
                "Gain {C:money}$#1#{} when",
                "using an ability",
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=2},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return false
        end,
        calculate=function(self,card,context)
            if context.using_consumeable then
                local card2=context.consumeable
                if card2.ability.set=='Ability' and not(card2.ability.cooldown and card2.ability.cooldown.type=='passive') then
                    ease_dollars(card.ability.extra.value)
                    card_eval_status_text(card, 'dollars', card.ability.extra.value)
                end
            end
        end
    }
end --midas touch
do
    local key='thumb'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Thumb',
            text = {
                "If played hand has less then 5 cards,", 
                "{C:attention}+#1#{} hands per card below {C:attention}5",
                "(Capped at {C:attention}+0.80{} per hand)",
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=0.2},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return false
        end,
        calculate=function(self,card,context)
            if context.joker_main and not G.thumb_triggered then
                local card_count=#G.play.cards
                if card_count<5 then
                    G.thumb_triggered=true
                    ease_hands_played(math.min(card.ability.extra.value*(5-card_count),0.8))
                end
            end
        end
    }
end --thumb
do
    local key='shield'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Shield',
            text = { 
                "{C:attention}Hand Size{} can't", 
                "go below {C:attention}#1#",
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=6},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return false
        end,
        calculate=function(self,card,context)
        end,
    }
    local CardArea_update_ref=CardArea.update
    function CardArea:update(dt)
        CardArea_update_ref(self,dt)
        if self == G.hand then
            local shield=has_ability('shield')
            if shield~=nil and G.hand.config.card_limit<shield.ability.extra.value then
                G.hand.config.card_limit=shield.ability.extra.value
            end
        end
    end
end --shield
do
    local key='shuffle'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Shuffle',
            text = { 
                "If no cards remain, shuffle", 
                "all cards back into deck",
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=6},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return false
        end,
        calculate=function(self,card,context)
        end,
    }
end --shuffle
do
    local key='dead_branch'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Dead Branch',
            text = { 
                "When a card is {C:attention}destroyed{}, add", 
                "a random card with {C:attention}enhancement{},", 
                "{C:attention}seal{} and {C:attention}edition{} into deck",
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=6},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {
            card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return false
        end,
        calculate=function(self,card,context)
            if context.remove_playing_cards then
                for i = 1, #context.removed do
                    -- print(i)
                    card = create_card("Enhanced", G.deck, nil, nil, nil, true, nil, 'dead_branch')
                    local edition = poll_edition('std_dead_branch_edition'..G.GAME.round_resets.ante, nil,nil,true)
                    card:set_edition(edition)
                    local seal_type = pseudorandom(pseudoseed('std_dead_branch'..G.GAME.round_resets.ante))
                    card:set_seal(SMODS.Seal.rng_buffer[math.ceil(seal_type*#SMODS.Seal.rng_buffer) or 1])
                    -- std is to prevent glitched seed working
                            card:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, card)
                            G.deck:emplace(card)
                end
            end
        end,
    }
    local Card_shatter_ref=Card.shatter
    function Card:shatter()
        if (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and G and G.betmma_abilities then    
            for i = 1, #G.betmma_abilities.cards do
                G.betmma_abilities.cards[i]:calculate_joker({remove_playing_cards = true, removed = {self}})
            end
        end
        Card_shatter_ref(self)
    end
    
    local Card_start_dissolve_ref=Card.start_dissolve
    function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
        if (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and G and G.betmma_abilities then    
            for i = 1, #G.betmma_abilities.cards do
                G.betmma_abilities.cards[i]:calculate_joker({remove_playing_cards = true, removed = {self}})
            end
        end
        Card_start_dissolve_ref(self,dissolve_colours, silent, dissolve_time_fac, no_juice)
    end
    -- patching in calculating hand and using consumable doesn't work for incantation and other 2 random destroy. I gave up calling calculate_joker in ability.toml
end --dead branch 

for k,v in pairs(betm_abilities) do
    v.config.extra.local_d6_sides="cryptid compat to prevent it reset my config upon use ;( ;("
end
----------------------------------------------
------------MOD CODE END----------------------