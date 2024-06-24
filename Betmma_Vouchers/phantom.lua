

    -- THIS IS FOR SHADER TEST.
    betmma_shaders = {'phantom'}
    for _, v in pairs(betmma_shaders) do
        local file = NFS.read(GET_PATH_COMPAT().."/shaders/"..v..".fs")
        love.filesystem.write(v.."-temp.fs", file)
        G.SHADERS[v] = love.graphics.newShader(v.."-temp.fs")
        love.filesystem.remove(v.."-temp.fs")
    end
    local edition=SMODS.Edition{
        key='phantom',
        loc_txt={
            name = 'Phantom',
            text = {
                "{C:dark_edition}+1{} Joker Slot. {C:red}Can't trigger.",
                "When destroyed, lose {C:dark_edition}Phantom{}",
                "and {C:attention}duplicate{} itself twice"
            }
        },
        shader='phantom'
    }
    edition.key='e_phantom'
    edition.shader='phantom' -- I hate mod prefix ;(
    edition.extra_cost=-10

    local Card_set_edition_ref=Card.set_edition
    function Card:set_edition(edition, immediate, silent)
        Card_set_edition_ref(self,edition,immediate,silent)
        if edition and edition.phantom then
            self.edition = nil
            -- sendDebugMessage(tprint(self.edition))
            if not self.edition then
                -- print(edition.key)
                -- print(edition.card_limit)
                self.edition = {}
                if self.added_to_deck then --Need to override if adding phantom to an existing joker
                    if self.ability.consumeable then
                        G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
                    else
                        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                    end
                end
            end
            self.edition.phantom = true
            self.edition.type = 'phantom'
            self.edition.card_limit=1
        end
    end

    local Card_calculate_joker_ref=Card.calculate_joker
    function Card:calculate_joker(context)
        if self.edition and self.edition.phantom then return nil end
        return Card_calculate_joker_ref(self,context)
    end

    -- Card:add_to_deck and remove_from_deck is done by SMOD by setting card_limit

    local Card_start_dissolve_ref=Card.start_dissolve
    function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
        if not self.selling and not(self.edition and self.edition.phantom) and self.ability.set=='Joker' and used_voucher('undying') then -- 'not(#dissolve_colours==1 and dissolve_colours[1]==G.C.GOLD)' is to exclude sell
            local card = copy_card(self, nil, nil, nil, true)
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_undying')})
            card.getting_sliced=false
            card:set_edition({phantom=true})
            card:add_to_deck()
            G.jokers:emplace(card)
        end
        if not self.selling and self.edition and self.edition.phantom and self.ability.set=='Joker' then
            for i=1,2 do
                if #G.jokers.cards <= G.jokers.config.card_limit -1 then  -- -1 is because this card isn't removed yet and still adds 1 joker slot
                    local card = copy_card(self, nil, nil, nil, self.edition and self.edition.phantom)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                    card.getting_sliced=false
                    card:add_to_deck()
                    G.jokers:emplace(card)
                else
                    card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
                end
            end
        end
        Card_start_dissolve_ref(self,dissolve_colours, silent, dissolve_time_fac, no_juice)
    end

    local Card_sell_card_ref=Card.sell_card
    function Card:sell_card()
        if self.edition and self.edition.phantom then
            local rarity=self.config.center.rarity
            --print(rarity)
            local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        if jokers_to_create==0 then
                            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
                        end
                        for i = 1, jokers_to_create do
                            local card = create_card('Joker', G.jokers, rarity, 0, nil, nil, nil, 'BetmmaAssigningRarity')
                            card:add_to_deck()
                            G.jokers:emplace(card)
                            card:start_materialize()
                            G.GAME.joker_buffer = 0
                            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reincarnate'), colour = G.C.BLUE})
                        end
                        return true
                    end}))   

        end
        self.selling=true
        Card_sell_card_ref(self)
    end

    function testShader(self) -- called in lovely patch
        self.children.center:draw_shader('phantom', nil, self.ARGS.send_to_shader)
        if self.children.front and self.ability.effect ~= 'Stone Card' then
            self.children.front:draw_shader('phantom', nil, self.ARGS.send_to_shader)
        end
    end
    -- local Card_draw_ref=Card.draw
    -- function Card:draw(layer)
    --     self.edition=self.edition or {}
    --     self.edition.phantom=true
    --     Card_draw_ref(self,layer)
    -- end

    function Card:drawff(layer) -- useless now
        layer = layer or 'both'
    
        self.hover_tilt = 1
        
        if not self.states.visible then return end
        
        if (layer == 'shadow' or layer == 'both') then
            self.ARGS.send_to_shader = self.ARGS.send_to_shader or {}
            self.ARGS.send_to_shader[1] = math.min(self.VT.r*3, 1) + G.TIMERS.REAL/(28) + (self.juice and self.juice.r*20 or 0) + self.tilt_var.amt
            self.ARGS.send_to_shader[2] = G.TIMERS.REAL
    
            for k, v in pairs(self.children) do
                v.VT.scale = self.VT.scale
            end
        end
    
        G.shared_shadow = self.sprite_facing == 'front' and self.children.center or self.children.back

    
        --Draw the shadow
        -- if not self.no_shadow and G.SETTINGS.GRAPHICS.shadows == 'On' and((layer == 'shadow' or layer == 'both') and (self.ability.effect ~= 'Glass Card' and not self.greyed) and ((self.area and self.area ~= G.discard and self.area.config.type ~= 'deck') or not self.area or self.states.drag.is)) then
        --     self.shadow_height = 0*(0.08 + 0.4*math.sqrt(self.velocity.x^2)) + ((((self.highlighted and self.area == G.play) or self.states.drag.is) and 0.35) or (self.area and self.area.config.type == 'title_2') and 0.04 or 0.1)
        --     G.shared_shadow:draw_shader('dissolve', self.shadow_height)
        -- end
    
        if (layer == 'card' or layer == 'both') and self.area ~= G.hand then 
            if self.children.focused_ui then self.children.focused_ui:draw() end
        end
        
        if (layer == 'card' or layer == 'both') then
            -- for all hover/tilting:
            self.tilt_var = self.tilt_var or {mx = 0, my = 0, dx = self.tilt_var.dx or 0, dy = self.tilt_var.dy or 0, amt = 0}
            local tilt_factor = 0.3
            if self.states.focus.is then
                self.tilt_var.mx, self.tilt_var.my = G.CONTROLLER.cursor_position.x + self.tilt_var.dx*self.T.w*G.TILESCALE*G.TILESIZE, G.CONTROLLER.cursor_position.y + self.tilt_var.dy*self.T.h*G.TILESCALE*G.TILESIZE
                self.tilt_var.amt = math.abs(self.hover_offset.y + self.hover_offset.x - 1 + self.tilt_var.dx + self.tilt_var.dy - 1)*tilt_factor
            elseif self.states.hover.is then
                self.tilt_var.mx, self.tilt_var.my = G.CONTROLLER.cursor_position.x, G.CONTROLLER.cursor_position.y
                self.tilt_var.amt = math.abs(self.hover_offset.y + self.hover_offset.x - 1)*tilt_factor
            elseif self.ambient_tilt then
                local tilt_angle = G.TIMERS.REAL*(1.56 + (self.ID/1.14212)%1) + self.ID/1.35122
                self.tilt_var.mx = ((0.5 + 0.5*self.ambient_tilt*math.cos(tilt_angle))*self.VT.w+self.VT.x+G.ROOM.T.x)*G.TILESIZE*G.TILESCALE
                self.tilt_var.my = ((0.5 + 0.5*self.ambient_tilt*math.sin(tilt_angle))*self.VT.h+self.VT.y+G.ROOM.T.y)*G.TILESIZE*G.TILESCALE
                self.tilt_var.amt = self.ambient_tilt*(0.5+math.cos(tilt_angle))*tilt_factor
            end
            --Any particles
            if self.children.particles then self.children.particles:draw() end
    
            --Draw any tags/buttons
            if self.children.price then self.children.price:draw() end
            if self.children.buy_button then
                if self.highlighted then
                    self.children.buy_button.states.visible = true
                    self.children.buy_button:draw()
                    if self.children.buy_and_use_button then 
                        self.children.buy_and_use_button:draw()
                    end
                else
                    self.children.buy_button.states.visible = false
                end
            end
            if self.children.use_button and self.highlighted then self.children.use_button:draw() end
    

            if self.vortex then
                if self.facing == 'back' then 
                    self.children.back:draw_shader('vortex')
                else
                    self.children.center:draw_shader('vortex')
                    if self.children.front then 
                        self.children.front:draw_shader('vortex')
                    end
                end
    
                love.graphics.setShader()
            elseif self.sprite_facing == 'front' then 
                -- delete this part makes it transparent
                -- --Draw the main part of the card
                -- if (self.edition and self.edition.negative) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
                --     self.children.center:draw_shader('negative', nil, self.ARGS.send_to_shader)
                --     if self.children.front and self.ability.effect ~= 'Stone Card' then
                --         self.children.front:draw_shader('negative', nil, self.ARGS.send_to_shader)
                --     end
                -- elseif not self.greyed then
                --     self.children.center:draw_shader('dissolve')
                --     --If the card has a front, draw that next
                --     if self.children.front and self.ability.effect ~= 'Stone Card' then
                --         self.children.front:draw_shader('dissolve')
                --     end
                -- end
    
                if 1 then
                    testShader(self)
                    -- if (layer == 'card' or layer == 'both') and self.area == G.hand then 
                    --     if self.children.focused_ui then self.children.focused_ui:draw() end
                    -- end
            
                    -- add_to_drawhash(self)
                    -- self:draw_boundingrect()
                    -- return
                end
                --If the card is not yet discovered
                if not self.config.center.discovered and (self.ability.consumeable or self.config.center.unlocked) and not self.config.center.demo and not self.bypass_discovery_center then
                    local shared_sprite = (self.ability.set == 'Edition' or self.ability.set == 'Joker') and G.shared_undiscovered_joker or G.shared_undiscovered_tarot
                    local scale_mod = -0.05 + 0.05*math.sin(1.8*G.TIMERS.REAL)
                    local rotate_mod = 0.03*math.sin(1.219*G.TIMERS.REAL)
    
                    shared_sprite.role.draw_major = self
                    shared_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                end
    
                if self.ability.name == 'Invisible Joker' and (self.config.center.discovered or self.bypass_discovery_center) then
                    self.children.center:draw_shader('voucher', nil, self.ARGS.send_to_shader)
                end
                
                --If the card has any edition/seal, add that here
                if self.edition or self.seal or self.ability.eternal or self.ability.rental or self.ability.perishable or self.sticker or self.ability.set == 'Spectral' or self.debuff or self.greyed or self.ability.name == 'The Soul' or self.ability.set == 'Voucher' or self.ability.set == 'Booster' or self.config.center.soul_pos or self.config.center.demo then
                    if (self.ability.set == 'Voucher' or self.config.center.demo) and (self.ability.name ~= 'Antimatter' or not (self.config.center.discovered or self.bypass_discovery_center)) then
                        self.children.center:draw_shader('voucher', nil, self.ARGS.send_to_shader)
                    end
                    if self.ability.set == 'Booster' or self.ability.set == 'Spectral' then
                        self.children.center:draw_shader('booster', nil, self.ARGS.send_to_shader)
                    end
                    if self.edition and self.edition.holo then
                        self.children.center:draw_shader('holo', nil, self.ARGS.send_to_shader)
                        if self.children.front and self.ability.effect ~= 'Stone Card' then
                            self.children.front:draw_shader('holo', nil, self.ARGS.send_to_shader)
                        end
                    end
                    if self.edition and self.edition.foil then
                        self.children.center:draw_shader('foil', nil, self.ARGS.send_to_shader)
                        if self.children.front and self.ability.effect ~= 'Stone Card' then
                            self.children.front:draw_shader('foil', nil, self.ARGS.send_to_shader)
                        end
                    end
                    if self.edition and self.edition.polychrome then
                        self.children.center:draw_shader('polychrome', nil, self.ARGS.send_to_shader)
                        if self.children.front and self.ability.effect ~= 'Stone Card' then
                            self.children.front:draw_shader('polychrome', nil, self.ARGS.send_to_shader)
                        end
                    end
                    if (self.edition and self.edition.negative) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
                        self.children.center:draw_shader('negative_shine', nil, self.ARGS.send_to_shader)
                    end
                    if self.seal then
                        G.shared_seals[self.seal].role.draw_major = self
                        G.shared_seals[self.seal]:draw_shader('dissolve', nil, nil, nil, self.children.center)
                        if self.seal == 'Gold' then G.shared_seals[self.seal]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center) end
                    end
                    if self.ability.eternal then
                        G.shared_sticker_eternal.role.draw_major = self
                        G.shared_sticker_eternal:draw_shader('dissolve', nil, nil, nil, self.children.center)
                        G.shared_sticker_eternal:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
                    end
                    if self.ability.perishable then
                        G.shared_sticker_perishable.role.draw_major = self
                        G.shared_sticker_perishable:draw_shader('dissolve', nil, nil, nil, self.children.center)
                        G.shared_sticker_perishable:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
                    end
                    if self.ability.rental then
                        G.shared_sticker_rental.role.draw_major = self
                        G.shared_sticker_rental:draw_shader('dissolve', nil, nil, nil, self.children.center)
                        G.shared_sticker_rental:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
                    end
                    if self.sticker and G.shared_stickers[self.sticker] then
                        G.shared_stickers[self.sticker].role.draw_major = self
                        G.shared_stickers[self.sticker]:draw_shader('dissolve', nil, nil, nil, self.children.center)
                        G.shared_stickers[self.sticker]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
                    end
    
                    if self.ability.name == 'The Soul' and (self.config.center.discovered or self.bypass_discovery_center) then
                        local scale_mod = 0.05 + 0.05*math.sin(1.8*G.TIMERS.REAL) + 0.07*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
                        local rotate_mod = 0.1*math.sin(1.219*G.TIMERS.REAL) + 0.07*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2
        
                        G.shared_soul.role.draw_major = self
                        G.shared_soul:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
                        G.shared_soul:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                    end
    
                    if self.config.center.soul_pos and (self.config.center.discovered or self.bypass_discovery_center) then
                        local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
                        local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2
        
                        if self.ability.name == 'Hologram' then
                            self.hover_tilt = self.hover_tilt*1.5
                            self.children.floating_sprite:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil, self.children.center, 2*scale_mod, 2*rotate_mod)
                            self.hover_tilt = self.hover_tilt/1.5
                        else
                            self.children.floating_sprite:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
                            self.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                        end
                        
                    end
                    if self.debuff then
                        self.children.center:draw_shader('debuff', nil, self.ARGS.send_to_shader)
                        if self.children.front and self.ability.effect ~= 'Stone Card' then
                            self.children.front:draw_shader('debuff', nil, self.ARGS.send_to_shader)
                        end
                    end
                    if self.greyed then
                        self.children.center:draw_shader('played', nil, self.ARGS.send_to_shader)
                        if self.children.front and self.ability.effect ~= 'Stone Card' then
                            self.children.front:draw_shader('played', nil, self.ARGS.send_to_shader)
                        end
                    end
                end 
            elseif self.sprite_facing == 'back' then
                local overlay = G.C.WHITE
                if self.area and self.area.config.type == 'deck' and self.rank > 3 then
                    self.back_overlay = self.back_overlay or {}
                    self.back_overlay[1] = 0.5 + ((#self.area.cards - self.rank)%7)/50
                    self.back_overlay[2] = 0.5 + ((#self.area.cards - self.rank)%7)/50
                    self.back_overlay[3] = 0.5 + ((#self.area.cards - self.rank)%7)/50
                    self.back_overlay[4] = 1
                    overlay = self.back_overlay
                end
    
                if self.area and self.area.config.type == 'deck' then
                    self.children.back:draw(overlay)
                else
                    self.children.back:draw_shader('dissolve')
                end
    
                if self.sticker and G.shared_stickers[self.sticker] then
                    G.shared_stickers[self.sticker].role.draw_major = self
                    G.shared_stickers[self.sticker]:draw_shader('dissolve', nil, nil, true, self.children.center)
                    if self.sticker == 'Gold' then G.shared_stickers[self.sticker]:draw_shader('voucher', nil, self.ARGS.send_to_shader, true, self.children.center) end
                end
            end
    
            for k, v in pairs(self.children) do
                if k ~= 'focused_ui' and k ~= "front" and k ~= "back" and k ~= "soul_parts" and k ~= "center" and k ~= 'floating_sprite' and k~= "shadow" and k~= "use_button" and k ~= 'buy_button' and k ~= 'buy_and_use_button' and k~= "debuff" and k ~= 'price' and k~= 'particles' and k ~= 'h_popup' then v:draw() end
            end
    
            if (layer == 'card' or layer == 'both') and self.area == G.hand then 
                if self.children.focused_ui then self.children.focused_ui:draw() end
            end
    
            add_to_drawhash(self)
            self:draw_boundingrect()
        end
    end
    -- SHADER TEST END.