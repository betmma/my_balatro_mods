

    -- THIS IS FOR SHADER TEST.
    betmma_shaders = {'phantom','tentacle'}
    local editions={
        {
            loc_txt={
                name = 'Phantom',
                text = {
                    "{C:dark_edition}+1{} Joker Slot", 
                    "{C:red}50% chance to trigger",
                    -- "When destroyed, lose {C:dark_edition}Phantom{}",
                    -- "and {C:attention}duplicate{} itself twice"
                }
            },
            extra_cost=-10,
            config={card_limit=1}
        },
        {
            loc_txt={
                name = 'Tentacle',
                text = {
                    "When {C:attention}Blind{} is selected,",
                    "destroy Joker to the",
                    "right and add its value",
                    "to this joker's value",
                    --"{C:dark_edition}Tentacle{}.",
                }
            },
        }
    }
    e_='e_'
    MOD_PREFIX_E=e_..MOD_PREFIX
    betmma_extra_data.labels={}
    for i, v in pairs(betmma_shaders) do
        local file = NFS.read(GET_PATH_COMPAT().."/shaders/"..v..".fs")
        love.filesystem.write(v.."-temp.fs", file)
        G.SHADERS[v] = love.graphics.newShader(v.."-temp.fs")
        love.filesystem.remove(v.."-temp.fs")
        local edition_data=editions[i]
        -- sendDebugMessage(tprint(edition_data))
        edition_data.key=e_..v
        edition_data.shader=v
        edition_data.omit_mod_prefix=true
        edition_data.loc_txt.label=edition_data.loc_txt.name
        local edition=SMODS.Edition(edition_data)
        edition.key=e_..v
        edition.shader=v
        SMODS.Centers[e_..v]=edition
        SMODS.Centers[MOD_PREFIX_E..v]=nil
        -- betmma_extra_data.labels[v]=edition_data.loc_txt.name
        -- --G.localization.descriptions[v]=edition_data.loc_txt.name
    end


    -- local lo=localize
    -- function localize(args, misc_cat)
    --     local ret=lo(args, misc_cat)
    --     if ret=='ERROR' then
    --         print(args,misc_cat)
    --         -- sendDebugMessage(tprint(G.localization.misc.labels))
    --         if args and (type(args)=='table') then
    --             sendDebugMessage(tprint(args))
    --         end
    --     end
    --     -- print(ret)
    --     return ret
    -- end


    function get_betmma_shaders(card)
        if card.edition==nil then
            return nil--'tentacle'
        else
            for k, v in pairs(betmma_shaders) do
                if card.edition[v] or card.edition.type==v then
                    return v
                end
            end
        end
        return nil
    end

    function draw_betmma_shaders(self) -- called in lovely patch
        local shader=get_betmma_shaders(self)
        if not shader then return end
        self.children.center:draw_shader(shader, nil, self.ARGS.send_to_shader)
        if self.children.front and self.ability.effect ~= 'Stone Card' then
            self.children.front:draw_shader(shader, nil, self.ARGS.send_to_shader)
        end
    end

    local Card_calculate_joker_ref=Card.calculate_joker
    function Card:calculate_joker(context)
        if self.edition and self.edition.phantom then 
            if pseudorandom('phantom'..(self.ability.name or ""))<0.5 then
                return nil
            end
        end
        return Card_calculate_joker_ref(self,context)
    end

    -- Card:add_to_deck and remove_from_deck is done by SMOD by setting card_limit

    local Card_start_dissolve_ref=Card.start_dissolve
    function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
        if not self.selling and not(self.edition and self.edition.phantom) and self.ability.set=='Joker' and self.added_to_deck and used_voucher('undying') then -- 'self.selling' is set in :sell_card function below to exclude sell
            local card = copy_card(self, nil, nil, nil, true)
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_undying')})
            card.getting_sliced=false
            card:set_edition({phantom=true})
            card:add_to_deck()
            G.jokers:emplace(card)
        end
        -- if not self.selling and self.edition and self.edition.phantom and self.ability.set=='Joker' then -- duplicate twice effect is discarded
        --     for i=1,2 do
        --         if #G.jokers.cards <= G.jokers.config.card_limit -1 then  -- -1 is because this card isn't removed yet and still adds 1 joker slot
        --             local card = copy_card(self, nil, nil, nil, self.edition and self.edition.phantom)
        --             card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
        --             card.getting_sliced=false
        --             card:add_to_deck()
        --             G.jokers:emplace(card)
        --         else
        --             card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
        --         end
        --     end
        -- end
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
                        if G.P_JOKER_RARITY_POOLS[rarity]==nil then
                            return true
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
    -- local Card_draw_ref=Card.draw
    -- function Card:draw(layer)
    --     self.edition=self.edition or {}
    --     self.edition.phantom=true
    --     Card_draw_ref(self,layer)
    -- end

    -- SHADER TEST END.