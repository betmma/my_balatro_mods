

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
        if not self.selling and not(self.edition and self.edition.phantom) and self.ability.set=='Joker' and used_voucher('undying') then -- 'self.selling' is set in :sell_card function below to exclude sell
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

    -- SHADER TEST END.