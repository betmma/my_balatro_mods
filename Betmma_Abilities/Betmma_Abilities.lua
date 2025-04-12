--- STEAMODDED HEADER
--- MOD_NAME: Betmma Abilities
--- MOD_ID: BetmmaAbilities
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: New type of card: Abilities
--- PREFIX: betm_abilities
--- VERSION: 1.0.3.18(20250412)
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA-0410b]
--- BADGE_COLOUR: 8D90BF

----------------------------------------------
------------MOD CODE -------------------------
--[[ todo: compatibility with hammerspace (CCD) or in consumable slots
current progress: abilities are able to cooldown everywhere, but passive calculations (using calculate function) don't work in other areas. Active abilities can work.
    discard unselected cards
]]
MOD_PREFIX='betm_abilities'
CONFIG_ALLOWING_ABILITIES=not betmma_config or betmma_config.abilities
USING_BETMMA_ABILITIES=CONFIG_ALLOWING_ABILITIES
if CONFIG_ALLOWING_ABILITIES then
IN_SMOD1=MODDED_VERSION>='1.0.0'
betm_abilities={}
betm_abilities_atlases={}
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
    G.localization.misc.dictionary.k_decay = "Decay!"
    G.localization.misc.dictionary.k_echo = "Echo!"
    G.localization.misc.dictionary.b_move_consumeable = "MOVE"
    
end

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
        if betmma_smaller_sets then
            betmma_smaller_sets.Ability=true
        else
            betmma_smaller_sets={Ability=true}
        end
        local Card_set_ability_ref=Card.set_ability
        function Card:set_ability(center, initial, delay_sprites)
            local X, Y, W, H = self.T.x, self.T.y, self.T.w, self.T.h
            if center and betmma_smaller_sets and betmma_smaller_sets[center.set] then
                -- self.T.w=W*34/71
                -- self.T.h=H*34/95
                -- self.T.w=G.ABILITY_W or 0.8
                -- self.T.h=G.ABILITY_H or 0.8 -- latest (around 20250411) makes this method not work
                center.display_size={h=34*0.8,w=34*0.8}
            end
            Card_set_ability_ref(self,center,initial,delay_sprites)
        end

        local Card_load=Card.load
        function Card:load(cardTable,other_card)
            local X, Y, W, H = self.T.x, self.T.y, self.T.w, self.T.h
            if betmma_smaller_sets and betmma_smaller_sets[G.P_CENTERS[cardTable.save_fields.center].set] then -- if crash here, it means G.P_CENTERS[cardTable.save_fields.center] is nil, which means can't find data of a saved card (probably deleted mod) and not my fault. without this line it still crashes in original card:load
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
        local draw_layers = self.ARGS.draw_layers or self.config.draw_layers or {'shadow', 'card'}
        for k, v in ipairs(draw_layers) do
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
        if self.config.type == 'betmma_ability' then
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
        if self.config.type == 'betmma_ability' then
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

    -- move button to move misplaced abilities to Ability area
    G.FUNCS.can_move_consumeable = function(e)
        local card=G.consumeables.highlighted[1]
        if not (card and (card.ability.set=='Ability' and G.betmma_abilities.config.card_limit>#G.betmma_abilities.cards) or (card.ability.set=='Spell' and G.betmma_spells.config.card_limit>#G.betmma_spells.cards)) then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.ORANGE
            e.config.button = 'move_consumeable'
        end
    end
    G.FUNCS.move_consumeable = function(e) 
        local c1 = e.config.ref_table
        c1.area:remove_from_highlighted(c1)
        c1.area:remove_card(c1)
        if c1.ability.set=='Ability' then
            G.betmma_abilities:emplace(c1)
        elseif c1.ability.set=='Spell' then
            G.betmma_spells:emplace(c1)
        end
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
            if card.area and card.area == G.consumeables then
                local move={n=G.UIT.R, config={align = "bm"}, nodes={
                    {n=G.UIT.R, config={ref_table = card, align = "br",maxw = 1.25, padding = 0.1, r=0.08, minw = 0.9, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'move_card', func = 'can_move_consumeable'}, nodes={
                    --   {n=G.UIT.B, config = {w=0.1,h=0.6}},
                    {n=G.UIT.T, config={text = localize('b_move_consumeable'),colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}}
                    }}
                }}
                t.nodes[1].nodes[1].nodes[3]=
                {n=G.UIT.R, config={align = 'cl'}, nodes={
                    move
                }}
                -- t.nodes[2]={n=G.UIT.C, config={padding = 0.15, align = 'cl'}, nodes={
                --     {n=G.UIT.R, config={align = 'cl'}, nodes={
                --     move
                --     }},
                -- }}
            end
            return t
        end
        return G_UIDEF_use_and_sell_buttons_ref(card)
    end
    
    local G_UIDEF_card_focus_ui_ref=G.UIDEF.card_focus_ui
    -- add use and sell buttons to Abilities for controller
    function G.UIDEF.card_focus_ui(card)
        local base_background=G_UIDEF_card_focus_ui_ref(card)
        local card_width = card.T.w + (card.ability.consumeable and -0.1 or card.ability.set == 'Voucher' and -0.16 or 0)
        local base_attach = base_background:get_UIE_by_ID('ATTACH_TO_ME')
        if card.ability.set=='Ability' and card.area and card.area ~= G.pack_cards and card.area~=G.shop_abilities then
            base_attach.children.use = G.UIDEF.card_focus_button{
              card = card, parent = base_attach, type = 'use',
              func = 'can_use_consumeable', button = 'use_card', card_width = card_width
            }
            base_attach.children.sell = G.UIDEF.card_focus_button{
              card = card, parent = base_attach, type = 'sell',
              func = 'can_sell_card', button = 'sell_card', card_width = card_width
            }
        end
        return base_background
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
    -- check for betmma.abilities card limit when buying from shop
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

    local G_UIDEF_card_focus_ui_ref=G.UIDEF.card_focus_ui
    -- add buy button to abilities in shop for controller
    function G.UIDEF.card_focus_ui(card)
        local base_background=G_UIDEF_card_focus_ui_ref(card)
        local card_width = card.T.w + (card.ability.consumeable and -0.1 or card.ability.set == 'Voucher' and -0.16 or 0)
        local base_attach = base_background:get_UIE_by_ID('ATTACH_TO_ME')
        if G.shop_abilities and card.area==G.shop_abilities then
            local buy_and_use = nil
            if card.ability.consumeable then 
                base_attach.children.buy_and_use = G.UIDEF.card_focus_button{
                    card = card, parent = base_attach, type = 'buy_and_use',
                    func = 'can_buy_and_use', button = 'buy_from_shop', card_width = card_width
                }
                buy_and_use = true
            end
            base_attach.children.buy = G.UIDEF.card_focus_button{
            card = card, parent = base_attach, type = 'buy',
            func = 'can_buy', button = 'buy_from_shop', card_width = card_width, buy_and_use = buy_and_use
            }
        end
        return base_background
    end
end -- add Ability area in shop (only appear after a boss blind)

do
    function GET_PATH_COMPAT()
        return IN_SMOD1 and SMODS.current_mod.path or SMODS.findModByID('BetmmaAbilities').path
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
                if not used_abilvoucher('cooled_below') and TalismanCompat(card.ability.cooldown.now)<TalismanCompat(0) then
                    card.ability.cooldown.now=0
                end
            end
        end
    end
    function update_ability_cooldown(type,value)
        if G.betmma_abilities==nil then
            print("G.betmma_abilities doesn't exist! Maybe ability.toml isn't installed correctly.")
            return
        end
        if value==nil then value=1 end
        if G.GAME.cooldown_mult~=nil then
            value=value*G.GAME.cooldown_mult
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
    -- update 'money spent' and 'money gain' cooldown
    function ease_dollars(mod, instant)
        if mod and TalismanCompat(mod)<TalismanCompat(0) then
            update_ability_cooldown('money spent',-mod)
        elseif mod and TalismanCompat(mod)>TalismanCompat(0) then
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

    
    local Card_use_consumeable_ref=Card.use_consumeable
    -- update 'consumables used' cooldown
    function Card:use_consumeable(area, copier)
        update_ability_cooldown('consumables used')
        Card_use_consumeable_ref(self,area,copier)
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

SMODS.ConsumableType { -- Define Ability Consumable Type
    key = 'Ability',
    collection_rows = { 9,9,9,9 },
    primary_colour = G.C.CHIPS,
    secondary_colour = mix_colours(G.C.SECONDARY_SET.Voucher, G.C.MULT, 0.9),
    loc_txt = {
        collection = 'Abilities',
        name = 'Ability',
        label = 'Abililty'
    },
    shop_rate = BETMMA_DEBUGGING and 0.0 or 0.0,
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
local function ability_prototype(data)
    if not CONFIG_ALLOWING_ABILITIES  then return end
    data.keep_on_use = function(self,card)
        return true
    end
    data.config.cardarea='betmma_abilities'
    data.set="Ability"
    data.pos={x=0,y=0}
    return SMODS.Consumable(data)
end
betmma_abilities_ability_prototype=ability_prototype

-- return first ability (card) whose key is key (e.g. 'shield'). If none return nil. Search in ability slots, consumable slots and deck.
function has_ability(key)
    local ret=find_abilities(key)
    if #ret>=1 then
        return ret[1]
    end
    return nil
end 

-- return a table including ability cards whose key is key. If none return empty table. Search in ability slots, consumable slots and deck.
function find_abilities(key)
    local ret={}
    if G.betmma_abilities and G.betmma_abilities.cards then
        for i=1,#G.betmma_abilities.cards do
            if G.betmma_abilities.cards[i].config.center.key==betm_abilities[key].key then
                table.insert(ret,G.betmma_abilities.cards[i])
            end
        end 
        for i=1,#G.consumeables.cards do
            if G.consumeables.cards[i].config.center.key==betm_abilities[key].key then
                table.insert(ret,G.consumeables.cards[i])
            end
        end 
        for i=1,#G.deck.cards do
            if G.deck.cards[i].config.center.key==betm_abilities[key].key then
                table.insert(ret,G.deck.cards[i])
            end
        end 
    end
    return ret
end

local Card_use_consumeable_ref=Card.use_consumeable
-- add cooldown when ability is used
function Card:use_consumeable(area, copier)
    if self.ability.set=='Ability' and self.ability.cooldown and self.ability.cooldown.type~='passive' then
        self.ability.cooldown.now=self.ability.cooldown.now+self.ability.cooldown.need
    end
    Card_use_consumeable_ref(self,area,copier)
end

local function get_atlas(key,type)
    local px,py,prefix
    if type==nil or type=='ability' then
        px=34
        py=34
        prefix='a_'
    elseif type=='voucher' then
        px=71
        py=95
        prefix='v_'
    end
    betm_abilities_atlases[key]=SMODS.Atlas {  
        key = key,
        px = px,
        py = py,
        path = prefix..key..'.png'
    }
end
betmma_abilities_get_atlas=get_atlas
function ability_cooled_down(self,card)
    if not card then card=self end
    if card.ability.cooldown and (card.ability.cooldown.type=='passive' or TalismanCompat(card.ability.cooldown.now)<=TalismanCompat(0)) then
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
                'Cooldown: {C:mult}#1#/#2# #3#{}'
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
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = { value=2},cooldown={type='round', now=1, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            if G and not 
            G.GAME.pseudorandom_forced_0_count then
                G.GAME.pseudorandom_forced_0_count=0
            end
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,G and G.GAME.pseudorandom_forced_0_count or 0,card.ability.extra.value}}
        end,
        can_use = ability_cooled_down,
        use = function(self,card,area,copier)
            G.GAME.pseudorandom_forced_0_count=G.GAME.pseudorandom_forced_0_count+card.ability.extra.value
            
        end
    }

    local pseudorandom_ref=pseudorandom
    function pseudorandom(seed, min, max)
        if G.GAME.pseudorandom_forced_0_count and G.GAME.pseudorandom_forced_0_count>0 and type(seed) == 'string' and not string.match(seed,'^std') and not string.match(seed,'^soul_') and not string.match(seed,'^cry_et') and not string.match(seed,'^cry_bp') and not string.match(seed,'^cry_vet') and not string.match(seed,'^cry_per') and not string.match(seed,'^cry_pin') and not string.match(seed,'^cry_flip') and not string.match(seed,'^d6_joker') and not string.match(seed,'^consumable_type') and not string.match(seed,'^edi') and not string.match(seed,'^rarity') and not string.match(seed,'^virtual') and not string.match(seed,'^breaking') and seed~='wheel' and seed~='shy_today' and seed~='certsl' and seed~='real_random' and seed~='confusion_side'then
            print(seed)
            G.GAME.pseudorandom_forced_0_count=G.GAME.pseudorandom_forced_0_count-1
            if min and max then
                return min
            end
            return 0
        end
        return pseudorandom_ref(seed, min, max)
    end

    -- Prevent inheriting forced_0_count
    local Game_start_run_ref = Game.start_run
    function Game.start_run(self, args)
        G.GAME.pseudorandom_forced_0_count=0
        Game_start_run_ref(self, args)
    end
end --glitched seed
do
    local function inc_or_dec_rank(card,dec)
        local suit_data = SMODS.Suits[card.base.suit]
        local suit_prefix = suit_data.card_key..'_' -- to be compatible with modded suits
        -- local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
        local rank_suffix = card.base.id == 14 and 2 or math.min(card.base.id+1, 14)
        if dec then
            rank_suffix= card.base.id == 2 and 14 or math.max(card.base.id-1, 2)
        end
        if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
        elseif rank_suffix == 10 then rank_suffix = 'T'
        elseif rank_suffix == 11 then rank_suffix = 'J'
        elseif rank_suffix == 12 then rank_suffix = 'Q'
        elseif rank_suffix == 13 then rank_suffix = 'K'
        elseif rank_suffix == 14 then rank_suffix = 'A'
        end
        card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
    end
    function betmma_bump_rank(card,amount,temp)
        if temp then
            card.ability.rank_bumped=(card.ability.rank_bumped or 0)+amount
        end
        for i = 1, math.abs(amount) do
            inc_or_dec_rank(card,amount<0)
        end
    end
    local key='rank_bump'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { --rank bump
        key = key,
        loc_txt = {
            name = 'Rank Bump',
            text = {
                'Temporarily increase ranks of',
                'chosen cards by 1 for this hand',
                'Cooldown: {C:mult}#1#/#2# #3#{}'
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
                    betmma_bump_rank(G.hand.highlighted[i],1,true)
                return true end }))
            end  
            
        end
    }

    local function cancel_bump(area)
        for k, v in ipairs(area.cards) do
            if v.ability.rank_bumped then
                for i=1,math.abs(v.ability.rank_bumped) do
                    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                        local card=v
                        inc_or_dec_rank(card,v.ability.rank_bumped>0)
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
    local key='variable'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Variable',
            text = {
                "Select {C:attention}some{} cards, let {C:attention}X{}",
                'be the rank of {C:attention}rightmost card{}, then',
                'increase ranks of other cards by {C:attention}X{}',
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = { },cooldown={type='hand', now=3, need=3}, },
        discovered = true,
        cost = 10,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card)and #G.hand.highlighted>1 
        end,
        use = function(self,card,area,copier)
            local rightmost = G.hand.highlighted[1]
            for i=2, #G.hand.highlighted do if G.hand.highlighted[i].T.x > rightmost.T.x then rightmost = G.hand.highlighted[i] end end
            local rank=rightmost.base.id
            for i=1,rank do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    for i=1, #G.hand.highlighted do
                        if G.hand.highlighted[i]~=rightmost then                        
                            betmma_bump_rank(G.hand.highlighted[i],1,false)
                        end
                    end  
                return true end }))
            end
        end
    }
end --variable
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
                'Cooldown: {C:mult}#1#/#2# #3#{}'
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
                'Cooldown: {C:mult}#1#/#2# #3#{}'
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
                G.hand.highlighted[i].debuff=false
                G.hand.highlighted[i].debuffed_by_blind = false
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
                'Cooldown: {C:mult}#1#/#2# #3#{}'
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
            if context.joker_main and card.ability.extra.value>1 then
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
                'Cooldown: {C:mult}#1#/#2# #3#{}'
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
        config = {extra = {value=5},cooldown={type='money spent', now=20, need=20}, },
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
                -- "Downgrade current hand",
                "Create a {C:dark_edition}Negative {C:planet}Planet{}", 
                "card of current hand", 
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
            
            -- level_up_hand(nil, text, nil, -0.5)
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
    local key='endoplasm'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Endoplasm',
            text = { 
                "Set a random {C:attention}consumable{}",
                "to be {C:dark_edition}Negative{}", 
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {},cooldown={type='consumables used', now=5, need=5}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and #G.consumeables.cards>0
        end,
        use = function(self,card,area,copier)
            local index=math.ceil(pseudorandom('std_endoplasm')*#G.consumeables.cards)
            G.consumeables.cards[index]:set_edition({negative=true})
        end,
    }
end --endoplasm
do
    local key='pay2win'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Pay2Win',
            text = { 
                "Pay {C:money}$#1#{} to let blind size {X:mult,C:white}X#2#{C:attention}",
                "and increase price by {C:money}$#3#{}", 
                "price resets when round ends",
                'Cooldown: None'
        }
        },
        atlas = key, 
        config = {extra = {cost_base=2,cost=2,increment=1,value=80},cooldown={type='none', now=0, need=0}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            local value=card.ability.extra.value
            value=math.ceil(math.min(value,95))
            return {vars = {card.ability.extra.cost,value/100,card.ability.extra.increment}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and G and G.STATE == G.STATES.SELECTING_HAND and G.GAME and G.GAME.current_round and TalismanCompat(G.GAME.dollars-G.GAME.bankrupt_at)>=TalismanCompat(card.ability.extra.cost)
        end,
        use = function(self,card,area,copier)
            local value=card.ability.extra.value
            value=math.ceil(math.min(value,95))
            after_event(function()
                ease_dollars(-card.ability.extra.cost)
                card.ability.extra.cost=card.ability.extra.cost+card.ability.extra.increment
                G.GAME.blind:wiggle()
                G.GAME.blind.chips=TalismanCompat(G.GAME.blind.chips)*value/100 -- if current hand ends the round the displayed blind chips won't change and I don't know why
                -- pprint(G.GAME.blind.chips)
                after_event(function()
                    after_event(function() -- two layers is a must to wait for vanilla functions execution and prevent drawing cards back after round ends
                        if TalismanCompat(G.GAME.chips) >= TalismanCompat(G.GAME.blind.chips) then -- i don't know why it won't trigger winning. i remember it does that before
                            G.STATE = G.STATES.HAND_PLAYED
                            G.STATE_COMPLETE = true
                            end_round()
                        end
                    end)
                end)
            end)
        end,
        calculate=function(self,card,context)
            if context.end_of_round and card.ability.extra.cost~=card.ability.extra.cost_base then 
                card.ability.extra.cost=card.ability.extra.cost_base
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset')})
            end
        end
    }
end --pay2win
do
    local key='number'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Number',
            text = { 
                "Select a {C:attention}Numbered{} card to be",
                "destroyed and draw {C:attention}X{} cards",
                "where {C:attention}X{} equals to its rank", 
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {},cooldown={type='hand', now=3, need=3}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s'}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and G.hand.highlighted and #G.hand.highlighted==1 and G.hand.highlighted[1].base.face_nominal==0 and type(G.hand.highlighted[1].base.nominal)=='number'
        end,
        use = function(self,card,area,copier)
            local destroyed_cards = {}
            for i=#G.hand.highlighted, 1, -1 do
                destroyed_cards[#destroyed_cards+1] = G.hand.highlighted[i]
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function() 
                    for i=#G.hand.highlighted, 1, -1 do
                        local card = G.hand.highlighted[i]
                        local hand_space = math.min(#G.deck.cards, card.base.nominal)
                        if card.ability.name == 'Glass Card' then 
                            card:shatter()
                        else
                            card:start_dissolve(nil, i == #G.hand.highlighted)
                        end
                        for i=1, hand_space do --draw cards from deckL
                            draw_card(G.deck,G.hand, i*100/hand_space,'up',true)
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
    }
end --number
do
    local key='fog'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Fog',
            text = { 
                "During current round, {X:mult,C:white}X#4#{} Mult",
                "but cards are drawn {C:attention}face down",
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {value=2},cooldown={type='hand', now=2, need=2}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK)
        end,
        use = function(self,card,area,copier)
            G.GAME.betmma_fog=true
            G.GAME.modifiers.prev_flipped_cards = G.GAME.modifiers.flipped_cards
            G.GAME.modifiers.flipped_cards = 1
        end,
        calculate=function(self,card,context)
            if context.joker_main and G.GAME.betmma_fog and card.ability.extra.value>1 then
                -- ease_dollars(-card.ability.extra.lose)
                -- card_eval_status_text(card, 'dollars', -card.ability.extra.lose)
                return {
                    card=card,
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.value}},
                    Xmult_mod = card.ability.extra.value
                }
            end
        end
    }
    local end_round_ref = end_round
    function end_round()
        G.GAME.betmma_fog=nil
        if G.GAME.modifiers.flipped_cards==1 then
            G.GAME.modifiers.flipped_cards=G.GAME.modifiers.prev_flipped_cards
        end
        end_round_ref()
    end
end --fog
do
    local key='antinomy'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Antinomy',
            text = { 
                "Create a temporary {C:dark_edition}Negative {C:attention}eternal{}",
                "copy of selected joker for this round",
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {value=2},cooldown={type='ante', now=1, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and #G.jokers.highlighted == 1
        end,
        use = function(self,card,area,copier) -- thanks to Antimony code from Codex Arcanum
            G.jokers.config.antinomy_betmma = G.jokers.config.antinomy_betmma or {} --removing code is in echo ability
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                local chosen_joker = G.jokers.highlighted[1]
                local card = copy_card(chosen_joker, nil, nil, nil, chosen_joker.edition and chosen_joker.edition.negative)
                card:set_edition({negative = true}, true)
                card:set_eternal(true)
                if card.ability.invis_rounds then card.ability.invis_rounds = 0 end
                card:add_to_deck()
                G.jokers:emplace(card)
                table.insert(G.jokers.config.antinomy_betmma, card.unique_val)
            return true end }))
        end
    }
end --antinomy
do
    local key='enhancer'
    get_atlas(key)
    local attention_text_ref=attention_text
    -- fix card_eval_status_text crash (cuz it calls attention_text which assumes args.major is a moveable)
    function attention_text(args)
        if args and args.major and args.major.real_parent then
            args.major = args.major.real_parent
        end
        return attention_text_ref(args)
    end
    local function create_fake_card(center,real_card)
        local fake_card = setmetatable({
            T={x=0,y=0,w=71,h=95},
            original_T={x=0,y=0,w=71,h=95},
            config={center=center},
            params={},
            set_sprites=function()end,
            base={nominal=0},  -- get_chip_bonus will use base.nominal
            real_parent=real_card,
            start_dissolve=function(fake_card)
                if fake_card.real_parent then
                    fake_card.real_parent:start_dissolve()
                end
            end,
            juice_up=function(self, scale, rot_amount)
                if not self.real_parent then return end
                self.real_parent:juice_up(scale, rot_amount)
            end
        },Card)
        if SMODS.Mods['Cryptid'] then
            fake_card.get_gameset=cry_get_gameset
        end
        -- fake_card has function so can't be saved, but fake_card.ability.extra needs to be saved to track variables used
        Card.set_ability(fake_card, center, true) -- initial is true to prevent calling G.GAME.blind:debuff_card

        if real_card then
            real_card.betmma_enhancement_fake_card = fake_card
        end
        return fake_card
    end
    -- if _center is nil, enhancement is random. otherwise consider it as a key or a center in P_CENTERS. If restore_extra is true, restore fake_card.ability.extra from card.ability.betmma_enhancement_extra
    local function betmma_enhance_joker(card, _center, restore_extra)
        local enhancement, center
        if _center==nil then
            enhancement=SMODS.poll_enhancement{guaranteed=true}
            center=G.P_CENTERS[enhancement]
        elseif type(_center)=='string' then
            enhancement=_center
            center=G.P_CENTERS[_center]
        else
            enhancement=_center.key
            center=_center
        end
        card.ability.betmma_enhancement=enhancement
        card.ability.betmma_enhancement_atlas = center.atlas or 'centers'
        local fake_card = create_fake_card(center,card)
        if restore_extra then
            fake_card.ability.extra=card.ability.betmma_enhancement_extra -- restore fake_card.ability.extra
        else
            card.ability.betmma_enhancement_extra=fake_card.ability.extra
        end
    end
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Enhancer',
            text = { 
                "Enhance selected joker randomly",
                -- "copy of selected joker for this round",
                'Cooldown: {C:mult}#1#/#2# #3#{}'
        }
        },
        atlas = key, 
        config = {extra = {value=2},cooldown={type='round', now=1, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,card.ability.extra.value}}
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and #G.jokers.highlighted == 1
        end,
        use = function(self,card,area,copier) 
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                local chosen_joker = G.jokers.highlighted[1]
                betmma_enhance_joker(chosen_joker)
                -- local enhancement=SMODS.poll_enhancement{guaranteed=true}
                -- chosen_joker.ability.betmma_enhancement=enhancement
                -- local center=G.P_CENTERS[enhancement]
                -- chosen_joker.ability.betmma_enhancement_atlas = center.atlas or 'centers'
                -- local fake_card = create_fake_card(center)
                -- chosen_joker.betmma_enhancement_fake_card = fake_card
                -- chosen_joker.ability.betmma_enhancement_extra=fake_card.ability.extra
                
            return true end }))
        end
    }
    function Card:calculate_enhancement_betmma(context)
        if self.debuff or self.ability.set ~= 'Joker' then return nil end
        local center = G.P_CENTERS[self.ability.betmma_enhancement]
        if not center then return nil end
        if not self.betmma_enhancement_fake_card then -- this is after load a game when fake_card is not saved and needs restoring fake_card.ability.extra
            betmma_enhance_joker(self, center, true)
            -- local fake_card = create_fake_card(center)
            -- self.betmma_enhancement_fake_card = fake_card
            -- fake_card.ability.extra=self.ability.betmma_enhancement_extra -- restore fake_card.ability.extra
        end
        local fake_card = self.betmma_enhancement_fake_card
        if center.calculate and type(center.calculate) == 'function' and context.joker_main then -- mod enhancements. If not limit to joker_main, each card scoring and unhighlighting will trigger enhancement effect
            local effect={}
            context.cardarea=G.play -- pretend it's a card in play area
            local o = center:calculate(fake_card, context, effect) -- not use self here
            if o then return o end
            return effect -- huh why cryptid uses such way
        end
        local ret={}
        if context.joker_main then
            ret.chips=Card.get_chip_bonus(fake_card)--center.config.bonus
            ret.mult=Card.get_chip_mult(fake_card)
            ret.x_mult=Card.get_chip_x_mult(fake_card)
            ret.h_x_mult=Card.get_chip_h_x_mult(fake_card)
            ret.p_dollars=Card.get_p_dollars(fake_card)
            if SMODS.has_enhancement(fake_card, 'm_glass') and pseudorandom('glass') < G.GAME.probabilities.normal/(fake_card.ability.name == 'Glass Card' and fake_card.ability.extra or G.P_CENTERS.m_glass.config.extra) then 
                after_event(function()
                    self:shatter()
                end)
            end
        elseif context.end_of_round and context.cardarea == G.jokers then 
            ret.h_dollars=center.config.h_dollars
        else
            return
        end
        for k,v in pairs(ret) do
            if v==0 then
                ret[k]=nil
            end
        end
        return ret
    end
    local calculate_joker_ref = Card.calculate_joker
    function Card:calculate_joker(context)
        local card_is_suit_ref,restore_card_is_suit
        local card_get_id_ref,restore_card_get_id
        if self.ability.betmma_enhancement then
            card_is_suit_ref=Card.is_suit
            card_get_id_ref=Card.get_id
            if self.ability.betmma_enhancement=='m_wild' then -- let wild joker always succeed when testing suit
                Card.is_suit=function(card)
                    return true
                end
                restore_card_is_suit=true
            elseif self.ability.betmma_enhancement=='m_stone' then -- let stone joker always fail when testing suit or rank
                Card.is_suit=function(card)
                    return false
                end
                restore_card_is_suit=true
                Card.get_id=function(card)
                    return -math.random(100, 1000000)
                end
                restore_card_get_id=true
            end
        end
        local ret = calculate_joker_ref(self, context)
        if restore_card_is_suit then
            Card.is_suit=card_is_suit_ref
        end
        if restore_card_get_id then
            Card.get_id=card_get_id_ref
        end
        return ret
    end
    local Card_set_ability_ref = Card.set_ability
    function Card:set_ability(center, initial, delay_sprites) -- when using tarot to enhance joker
        if self.ability and self.ability.set=='Joker' and center.set=='Enhanced' then
            betmma_enhance_joker(self, center)
            return
        end
        local ret=Card_set_ability_ref(self, center, initial, delay_sprites)

        return ret
    end
end --enhancer
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
                'Cooldown: {C:mult}#1#/#2# #3#{}'
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
            if context.end_of_round and context.main_eval then
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
                "If played hand has less than 5 cards,", 
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
                    playing_card_joker_effects({card})
                end
            end
        end,
    }
    -- local Card_shatter_ref=Card.shatter
    -- function Card:shatter()
    --     if (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and G and G.betmma_abilities then    
    --         for i = 1, #G.betmma_abilities.cards do
    --             G.betmma_abilities.cards[i]:calculate_joker({remove_playing_cards = true, removed = {self}})
    --         end
    --     end
    --     Card_shatter_ref(self)
    -- end
    
    -- local Card_start_dissolve_ref=Card.start_dissolve
    -- function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
    --     if (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and G and G.betmma_abilities then    
    --         for i = 1, #G.betmma_abilities.cards do
    --             G.betmma_abilities.cards[i]:calculate_joker({remove_playing_cards = true, removed = {self}})
    --         end
    --     end
    --     Card_start_dissolve_ref(self,dissolve_colours, silent, dissolve_time_fac, no_juice)
    -- end
    -- patching in calculating hand and using consumable doesn't work for incantation and other 2 random destroy. I gave up calling calculate_joker in ability.toml
    -- better calc calls calculate_joker so above is redundant
end --dead branch 
do
    local key='decay'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Decay',
            text = { 
                "{X:mult,C:white}X#2#{C:attention} blind size{} if played hand", 
                "scores {C:attention}less then #1#% of blind{}", 
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {value=50,range=5},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            local value=card.ability.extra.value
            value=math.ceil(math.min(value,95))
            local range=card.ability.extra.range
            range=math.ceil(math.min(range,95))
            return {vars = {
            range,(value)/100}}
        end,
        can_use = function(self,card)
            return false
        end,
        calculate=function(self,card,context)
            local value=card.ability.extra.value
            value=math.ceil(math.min(value,95))
            local range=card.ability.extra.range
            range=math.ceil(math.min(range,95))
            if context.after then 
                local chips_this_hand = TalismanCompat(hand_chips*mult) or TalismanCompat(0)
                if chips_this_hand <= TalismanCompat(G.GAME.blind.chips) * range/100 then
                    after_event(function()
                        G.GAME.blind:wiggle()
                        G.GAME.blind.chips=TalismanCompat(G.GAME.blind.chips)*value/100 -- if current hand ends the round the displayed blind chips won't change and I don't know why
                        -- pprint(G.GAME.blind.chips)
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_decay')})
                    end)
                end
            end
        end,
    }
    local SMODS_get_card_areas_ref=SMODS.get_card_areas
    function SMODS.get_card_areas(_type, _context)
        local ret=SMODS_get_card_areas_ref(_type, _context)
        if _type=='jokers' and G.betmma_abilities and G.betmma_abilities.cards then
            table.insert(ret, G.betmma_abilities)
        end
        return ret 
    end
end --decay
do
    local key='echo'
    get_atlas(key)
    betm_abilities[key]=ability_prototype { 
        key = key,
        loc_txt = {
            name = 'Echo',
            text = { 
                "When {C:attention}first card{} of hand scores, put", 
                "a temporary {C:dark_edition}Negative{} copy into hand", 
                '{C:blue}Passive{}'
        }
        },
        atlas = key, 
        config = {extra = {},cooldown={type='passive'}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            return {vars = {}}
        end,
        can_use = function(self,card)
            return false
        end,
        calculate=function(self,card,context)
        end,
    }
    
    --Code copied from TWEWY which was copied from Codex Arcanum
    local update_round_evalref = Game.update_round_eval
    function Game:update_round_eval(dt)
        update_round_evalref(self, dt)
        if G.deck.config.wonderMagnum_betmma then
            local _first_dissolve = false
            for _, wax_id in ipairs(G.deck.config.wonderMagnum_betmma) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == wax_id then
                        card:start_dissolve(nil, _first_dissolve)
                        _first_dissolve = true
                    end
                end
            end
            G.deck.config.wonderMagnum_betmma = {}
        end
        if G.jokers.config.antinomy_betmma then
            local _first_dissolve = false
            for _, wax_id in ipairs(G.jokers.config.antinomy_betmma) do
                for k, joker in ipairs(G.jokers.cards) do
                    if joker.unique_val == wax_id then
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                          G.jokers:remove_card(joker)
                          joker:remove()
                          joker = nil
                        return true; end})) 
                    end
                end
            end
            G.jokers.config.antinomy_betmma = {}
        end
    end

    local eval_card_ref=eval_card
    function eval_card(card, context)
        local ret={eval_card_ref(card, context)}
        if G.play.cards[1]==card and not context.repetition_only and context.cardarea == G.play and context.main_scoring  then
            local find=find_abilities('echo')
            for i=1,#find do
                G.deck.config.wonderMagnum_betmma = G.deck.config.wonderMagnum_betmma or {}
                card_eval_status_text(find[i], 'extra', nil, nil, nil, {message = localize('k_echo')})
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                    local _card = copy_card(card, nil, nil, 1)
                    _card:set_edition({negative=true})
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.hand:emplace(_card)
                    _card:start_materialize(nil, _first_dissolve)
                    table.insert(G.deck.config.wonderMagnum_betmma, _card.unique_val)
                    local new_cards = {}
                    new_cards[#new_cards+1] = _card
                    playing_card_joker_effects(new_cards)
                return true end }))
                
            end
        end
        return unpack(ret)
    end
end --echo

for k,v in pairs(betm_abilities) do
    v.config.extra.local_d6_sides="cryptid compat to prevent it reset my config upon use ;( ;("
end


-- vouchers --
betm_abilvouchers={}
local function voucher_prototype(data)
    if not CONFIG_ALLOWING_ABILITIES then return end
    data.unlocked=true
    data.discovered=true
    data.available=true
    data.pos={x=0,y=0}
    data.atlas=data.key
    get_atlas(data.key,'voucher')
    data.cost=data.cost or 10
    local raw_key=data.key
    local obj=SMODS.Voucher(data)
    betm_abilvouchers[raw_key]=obj
    return obj
end
function get_betmma_abilvouchers_key(voucher_raw_key)
    return betm_abilvouchers[voucher_raw_key] and betm_abilvouchers[voucher_raw_key].key
end
function used_abilvoucher(raw_key)
    return G.GAME.used_vouchers[get_betmma_abilvouchers_key(raw_key)]
end
do
    voucher_prototype{
        key='able',
        loc_txt = {
            name = 'Able',
            text = { 
                "{C:attention}+#1#{} Ability Slot",
            }
        },
        config={extra=1},
        loc_vars = function(self, info_queue, center)
            return {vars={center.ability.extra}}
        end,
        redeem=function(self,card)
            G.E_MANAGER:add_event(Event({func = function()
                if G.betmma_abilities then 
                    G.betmma_abilities.config.card_limit = G.betmma_abilities.config.card_limit + self.config.extra
                end
                return true end }))
        end
    }
    voucher_prototype{
        key='capable',
        loc_txt = {
            name = 'Capable',
            text = { 
                "{C:attention}+#1#{} Ability Slot",
            }
        },
        config={extra=1},
        loc_vars = function(self, info_queue, center)
            return {vars={center.ability.extra}}
        end,
        redeem=function(self,card)
            G.E_MANAGER:add_event(Event({func = function()
                if G.betmma_abilities then 
                    G.betmma_abilities.config.card_limit = G.betmma_abilities.config.card_limit + self.config.extra
                end
                return true end }))
        end,
        requires={get_betmma_abilvouchers_key('able')}
    }
end --able/capable
do
    voucher_prototype{
        key='cooled_down',
        loc_txt = {
            name = 'Cooled Down',
            text = { 
                "Abilities cool down",
                "{C:green}#1#%{} faster"
            }
        },
        config={extra=50},
        loc_vars = function(self, info_queue, center)
            return {vars={center.ability.extra}}
        end,
        redeem=function(self,card)
            G.GAME.cooldown_mult=(G.GAME.cooldown_mult or 1)*((100+self.config.extra)/100)
        end
    }
    voucher_prototype{
        key='cooled_below',
        loc_txt = {
            name = 'Cooled Below',
            text = { 
                "Abilities can cool down",
                "into {C:attention}negative values",
                "{C:inactive}(e.g. -2/1 round)"
            }
        },
        config={extra=1},
        loc_vars = function(self, info_queue, center)
            return {vars={center.ability.extra}}
        end,
        redeem=function(self,card)
        end,
        requires={get_betmma_abilvouchers_key('cooled_down')}
    }
end --cooled down/cooled below
end
----------------------------------------------
------------MOD CODE END----------------------