--- STEAMODDED HEADER
--- MOD_NAME: Betmma Abilities
--- MOD_ID: BetmmaAbilities
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: New type of card: Abilities
--- PREFIX: betm_abilities
--- VERSION: 0.0.1
--- BADGE_COLOUR: 8D90BF

----------------------------------------------
------------MOD CODE -------------------------
MOD_PREFIX='betm_abilities'
USING_BETMMA_ABILITIES=true
betm_abilities={}
betm_abilities_atlases={}

do

    do
        local Card_set_ability_ref=Card.set_ability
        function Card:set_ability(center, initial, delay_sprites)
            local X, Y, W, H = self.T.x, self.T.y, self.T.w, self.T.h
            if center.set=='Ability' then
                self.T.w=W*34/71
                self.T.h=H*34/95
            end
            Card_set_ability_ref(self,center,initial,delay_sprites)
        end

        local Card_load=Card.load
        function Card:load(cardTable,other_card)
            local X, Y, W, H = self.T.x, self.T.y, self.T.w, self.T.h
            if G.P_CENTERS[cardTable.save_fields.center].set=='Ability' then
                G.P_CENTERS[cardTable.save_fields.center].load=function()
                    self.T.w=W*34/71
                    self.T.h=H*34/95
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

    local CardArea_align_cards_ref=CardArea.align_cards
    -- enable Ability area to align cards in its border
    function CardArea:align_cards()
        if self==G.betmma_abilities then
            for k, card in ipairs(self.cards) do
                if not card.states.drag.is then 
                    card.T.r = 0.1*(-#self.cards/2 - 0.5 + k)/(#self.cards)+ (G.SETTINGS.reduced_motion and 0 or 1)*0.02*math.sin(2*G.TIMERS.REAL+card.T.x)
                    local max_cards = math.max(#self.cards, self.config.temp_limit)
                    card.T.x = self.T.x + (self.T.w-self.card_w)*((k-1)/math.max(max_cards-1, 1) - 0.5*(#self.cards-max_cards)/math.max(max_cards-1, 1)) + 0.5*(self.card_w - card.T.w)
                    if #self.cards > 2 or (#self.cards > 1 and self == G.consumeables) or (#self.cards > 1 and self.config.spread) then
                        card.T.x = self.T.x + (self.T.w-self.card_w)*((k-1)/(#self.cards-1)) + 0.5*(self.card_w - card.T.w)
                    elseif #self.cards > 1 and self ~= G.consumeables then
                        card.T.x = self.T.x + (self.T.w-self.card_w)*((k - 0.5)/(#self.cards)) + 0.5*(self.card_w - card.T.w)
                    else
                        card.T.x = self.T.x + self.T.w/2 - self.card_w/2 + 0.5*(self.card_w - card.T.w)
                    end
                    local highlight_height = G.HIGHLIGHT_H/2
                    if not card.highlighted then highlight_height = 0 end
                    card.T.y = self.T.y + self.T.h/2 - card.T.h/2 - highlight_height+ (G.SETTINGS.reduced_motion and 0 or 1)*0.03*math.sin(0.666*G.TIMERS.REAL+card.T.x)
                    card.T.x = card.T.x + card.shadow_parrallax.x/30
                end
            end
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
    function Card:can_sell_card(context)
        if self.ability.set=='Ability' then
            return true
        end
        return Card_can_sell_card_ref(self,context)
    end

    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    function G.UIDEF.use_and_sell_buttons(card)
        if card.ability.set=='Ability' then -- override Ability cards UI and make buttons smaller
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
end -- Ability Area preparation

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
        if self.ability.set=='Ability' and self.area==G.betmma_abilities and not ability_cooled_down(self) then
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
    function update_ability_cooldown(type)
        if G.betmma_abilities==nil then
            print("G.betmma_abilities doesn't exist! Maybe ability.toml isn't installed correctly.")
            return
        end
        for i = 1,#G.betmma_abilities.cards do
            local card=G.betmma_abilities.cards[i]
            if card.ability.cooldown.type==type then
                card.ability.cooldown.now=card.ability.cooldown.now-1
                if card.ability.cooldown.now<0 then
                    card.ability.cooldown.now=0
                end
            end
        end
    end

    local end_round_ref = end_round
    -- update 'round' cooldown
    function end_round()
        update_ability_cooldown('round')
        end_round_ref()
    end

    local G_FUNCS_play_cards_from_highlighted_ref=G.FUNCS.play_cards_from_highlighted
    -- update 'hand' cooldown
    G.FUNCS.play_cards_from_highlighted=function(e)
        update_ability_cooldown('hand')
        local ret= G_FUNCS_play_cards_from_highlighted_ref(e)
        return ret
    end
end -- update cooldown in different situations

SMODS.ConsumableType { -- Define Ability Consumable Type
    key = 'Ability',
    collection_rows = { 6,4 },
    primary_colour = G.C.CHIPS,
    secondary_colour = mix_colours(G.C.SECONDARY_SET.Voucher, G.C.MULT, 0.9),
    loc_txt = {
        collection = 'Abilities',
        name = 'Ability',
        label = 'Abililty'
    },
    shop_rate = 0.1,
    default = 'c_betm_abilities_GIL'
}

function ability_copy_table(card)
    if card.ability.cooldown.now ==nil then
        card.ability=copy_table(card.ability)
        card.ability.cooldown.now=card.ability.cooldown.need
    end
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
    ability_copy_table(card)
    if card.ability.cooldown and card.ability.cooldown.now<=0 then
        return true
    else
        return false
    end
end
function ability_cooled_down_percentage(card)
    ability_copy_table(card)
    if card.ability.cooldown then
        return math.max(card.ability.cooldown.now,0)/card.ability.cooldown.need
    end
    return 0
end

do
    local key='GIL'
    get_atlas(key)
    betm_abilities[key]=SMODS.Consumable { --GIL
        key = key,
        loc_txt = {
            name = 'Global Interpreter Lock',
            text = {
                'If all jokers are {C:attention}Eternal{}, remove',
                '{C:attention}Eternal{} from all jokers. Otherwise,',
                'set all jokers to be {C:attention}Eternal{}.',
                'Cooldown: {C:mult}#1#/#2# #3# left{}'
        }
        },
        set = 'Ability',
        pos = {x = 0,y = 0}, 
        atlas = key, 
        config = {extra = {}, cooldown={type='round', now=nil, need=1} },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            ability_copy_table(card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type}}
        end,
        keep_on_use = function(self,card)
            return true
        end,
        can_use = ability_cooled_down,
        use = function(self,card,area,copier)
            -- pprint(card.ability.cooldown)
            ability_copy_table(card)
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
            -- card.ability.cooldown.now=card.ability.cooldown.now+card.ability.cooldown.need
        end,
        -- add_to_deck=ability_copy_table
    }
end --GIL

do
    local key='glitched_seed'
    get_atlas(key)
    betm_abilities[key]=SMODS.Consumable { --glitched seed
        key = key,
        loc_txt = {
            name = 'Glitched Seed',
            text = {
                'Next #5# {C:attention}random events',
                'are guaranteed success', 
                '(#4# times left)',
                'Cooldown: {C:mult}#1#/#2# #3# left{}'
        }
        },
        set = 'Ability',
        pos = {x = 0,y = 0}, 
        atlas = key, 
        config = {extra = { value=2},cooldown={type='round', now=nil, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            ability_copy_table(card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type..'s',pseudorandom_forced_0_count,card.ability.extra.value}}
        end,
        keep_on_use = function(self,card)
            return true
        end,
        can_use = ability_cooled_down,
        use = function(self,card,area,copier)
            ability_copy_table(card)
            pseudorandom_forced_0_count=pseudorandom_forced_0_count+card.ability.extra.value
            -- card.ability.cooldown.now=card.ability.cooldown.now+card.ability.cooldown.need
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
    betm_abilities[key]=SMODS.Consumable { --rank bump
        key = key,
        loc_txt = {
            name = 'Rank Bump',
            text = {
                'Temporarily increase ranks of',
                'chosen cards by 1 for this hand',
                'Cooldown: {C:mult}#1#/#2# #3# left{}'
        }
        },
        set = 'Ability',
        pos = {x = 0,y = 0}, 
        atlas = key, 
        config = {extra = { },cooldown={type='hand', now=nil, need=2}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            ability_copy_table(card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,}}
        end,
        keep_on_use = function(self,card)
            return true
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card)and #G.hand.highlighted>0 and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK)
        end,
        use = function(self,card,area,copier)
            ability_copy_table(card)
            
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
            -- card.ability.cooldown.now=card.ability.cooldown.now+card.ability.cooldown.need
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

    local function cancel_bump_all()
        cancel_bump(G.play)
        cancel_bump(G.hand)
        cancel_bump(G.discard)
        cancel_bump(G.deck)
    end

    local G_FUNCS_draw_from_play_to_discard_ref=G.FUNCS.draw_from_play_to_discard
    G.FUNCS.draw_from_play_to_discard = function(e)
        cancel_bump_all()
        G_FUNCS_draw_from_play_to_discard_ref(e)
    end

    local G_FUNCS_discard_cards_from_highlighted=G.FUNCS.discard_cards_from_highlighted
    G.FUNCS.discard_cards_from_highlighted = function(e, hook)
        if not hook then
            cancel_bump_all()
        end
        G_FUNCS_discard_cards_from_highlighted(e,hook)
    end
end --rank bump

do
    local key='cached_hand'
    get_atlas(key)
    betm_abilities[key]=SMODS.Consumable { --rank bump
        key = key,
        loc_txt = {
            name = 'Cached Hand',
            text = {
                '{C:attention}Hand type{} of next hand is',
                'set to the last hand',
                'that is {C:attention}#4#',
                '(#5# hands left)',
                'Cooldown: {C:mult}#1#/#2# #3# left{}'
        }
        },
        set = 'Ability',
        pos = {x = 0,y = 0}, 
        atlas = key, 
        config = {extra = { },cooldown={type='round', now=nil, need=1}, },
        discovered = true,
        cost = 6,
        loc_vars = function(self, info_queue, card)
            ability_copy_table(card)
            return {vars = {card.ability.cooldown.now,card.ability.cooldown.need,card.ability.cooldown.type,
            G.GAME.last_hand_played or 'High Card',(G.GAME.betmma_cached_hand or 0)}}
        end,
        keep_on_use = function(self,card)
            return true
        end,
        can_use = function(self,card)
            return ability_cooled_down(self,card) and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK)
        end,
        use = function(self,card,area,copier)
            ability_copy_table(card)
            G.GAME.betmma_cached_hand=(G.GAME.betmma_cached_hand or 0)+1
            if #G.hand.highlighted>0 and not(G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards>0) then
                G.hand:parse_highlighted()
            end
            -- card.ability.cooldown.now=card.ability.cooldown.now+card.ability.cooldown.need
        end
    }
    local G_FUNCS_evaluate_play_ref=G.FUNCS.evaluate_play
    -- update 'hand' cooldown
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
----------------------------------------------
------------MOD CODE END----------------------