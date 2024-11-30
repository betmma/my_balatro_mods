--- STEAMODDED HEADER
--- MOD_NAME: Betmma Voucher Pack
--- MOD_ID: BetmmaVoucherPack
--- MOD_AUTHOR: [Betmma, nicholassam6425]
--- MOD_DESCRIPTION: Adds voucher pack that allows you to redeem 1 of 3 vouchers. The code is based on Coupon Book mod made by nicholassam6425.
--- PREFIX: betmma_voucher_pack
--- DEPENDENCIES: [BetmmaVouchers]

----------------------------------------------
------------MOD CODE -------------------------
IN_SMOD1=MODDED_VERSION>='1.0.0'

    local MOD_PREFIX="betmma_voucher_pack_"
    local loc_table={}
    local dict_loc_table={}
    -- thanks to https://github.com/nicholassam6425/balatro-mods/blob/main/balamod/mods/p_coupon_book.lua
    -- Beware that while opening voucher pack G.STATE == G.STATES.PLANET_PACK.
    SMODS.current_mod=SMODS.current_mod or {}
    function SMODS.current_mod.process_loc_text()
        for k,v in pairs(loc_table) do
            G.localization.descriptions.Other[k]=v
        end
        for k,v in pairs(dict_loc_table) do
            G.localization.misc.dictionary['k_'..k]=v
        end
        G.localization.misc.dictionary.k_voucher_pack = "Voucher Pack"
        -- G.localization.descriptions.Booster=G.localization.descriptions.Booster or {}
        -- G.localization.descriptions.Booster['p_voucher_pack'] = {
        --     name='Voucher Pack???',
        --     text={"11"}
        -- }--newBoosterText
    end

    function addBooster(id, name, order, discovered, weight, kind, cost, pos, config, desc, alerted, sprite_path, sprite_name, selection_state, color)
        id = id or "p_placeholder" .. #G.P_CENTER_POOLS["Booster"] + 1
        name = name or "Placeholder Pack"
        -- pack_contents = pack_contents or function(_) end
        order = order or #G.P_CENTER_POOLS["Booster"] + 1
        discovered = discovered or true
        weight = weight or 1
        kind = kind or ""
        cost = cost or 4
        pos = pos or {x=0, y=5}
        config = config or {}
        desc = desc or {"Placeholder"}
        alerted = alerted or true
        sprite_path = sprite_path or nil
        sprite_name = sprite_name or nil
        --sprite_size = sprite_size or nil
        selection_state = selection_state or G.STATES.TAROT_PACK
        if selection_state ~= G.STATES.TAROT_PACK and selection_state ~= G.STATES.PLANET_PACK and selection_state ~= G.STATES.SPECTRAL_PACK and selection_state ~= G.STATES.STANDARD_PACK and selection_state ~= G.STATES.BUFFOON_PACK then
            sendDebugMessage(id..": selection_state incorrectly defined")
        end
        color=color or {
            color=mix_colours(G.C.SECONDARY_SET.Voucher, G.C.BLACK, 0.9),
            background_color=G.C.BLACK
        }
        G.C.VOUCHER_PACK_COLORS=G.C.VOUCHER_PACK_COLORS or {}
        G.C.VOUCHER_PACK_COLORS[id]=color
        --print(#G.C.VOUCHER_PACK_COLORS[id],#color,id)

        local modded_sprite = nil
        if sprite_path and sprite_name then
            modded_sprite = true
        else
            modded_sprite = false
        end

        local newBooster = {
            name = name,
            order = order,
            discovered = discovered,
            weight = weight,
            kind = kind,
            cost = cost,
            pos = pos,
            atlas = "Booster",
            set = "Booster",
            config = config,
            desc = desc,
            alerted = alerted,
            modded_sprite = modded_sprite,
            key = id,
            modded = true,
            selection_state = selection_state
        }

        table.insert(G.P_CENTER_POOLS["Booster"], newBooster)
        G.P_CENTERS[id] = newBooster

        --add name + description to the localization object
        local newBoosterText = {name=name, text=desc, text_parsed={}, name_parsed={}}
        for _, line in ipairs(desc) do
            newBoosterText.text_parsed[#newBoosterText.text_parsed+1] = loc_parse_string(line)
        end
        for _, line in ipairs(type(newBoosterText.name) == 'table' and newBoosterText.name or {newBooster.name}) do
            newBoosterText.name_parsed[#newBoosterText.name_parsed+1] = loc_parse_string(line)
        end
        loc_table[id]=newBoosterText
        dict_loc_table[id]=name
        G.localization.descriptions.Other[id] = newBoosterText
        G.localization.misc.dictionary['k_'..id]=name
        -- G.localization.descriptions.Booster=G.localization.descriptions.Booster or {}
        -- G.localization.descriptions.Booster[id] = {
        --     name=name,
        --     text=desc
        -- }--newBoosterText MOD_PREFIX..

        --add sprite to sprite atlas
        if sprite_name and sprite_path then
            if IN_SMOD1 then
                local atlas=SMODS.Atlas{key=id, path=sprite_name, px=71, py=95, atlas = 'ASSET_ATLAS'}
                G.P_CENTERS[id].atlas = atlas.key
            else
                SMODS.Sprite:new(id, SMODS.findModByID("BetmmaVoucherPack").path, sprite_name, 71, 95, "asset_atli"):register();
                for _i, sprite in ipairs(SMODS.Sprites) do
                    if sprite.name == G.P_CENTERS[id].key then
                        G.P_CENTERS[id].atlas = sprite.name
                    end
                end
            end
            
        else
            sendDebugMessage("Sprite not defined or incorrectly defined for "..tostring(id))
        end
        

        return newBooster, newBoosterText
    end

    local function INIT()
    
        addBooster(
            "p_voucher_pack",   --id
            "Voucher Pack",              --name
            -- pack_contents,              --pack contents
            nil,                        --order
            true,                       --discovered
            1.4,                          --weight
            "Standard",                 --kind
            12,                         --cost
            {x=0,y=0},                  --pos
            {extra = 3, choose = 1},    --config
            {"Choose {C:attention}#1#{} of up to","{C:attention}#2#{} Vouchers", "to be redeemed"}, --desc
            true,                       --alerted
            "assets",                   --sprite path
            "p_voucher_pack.png",          --sprite name
            --{px=71, py=95},             --sprite size
            G.STATES.PLANET_PACK,        --selection_state
            {color=HEX('a6009b'),background_color=HEX('b849b0')} --color
        )

        addBooster(
            "p_uncommon_voucher_pack",   --id
            "Uncommon Voucher Pack",              --name
            -- pack_contents,              --pack contents
            nil,                        --order
            true,                       --discovered
            0.6,                          --weight
            "Standard",                 --kind
            12,                         --cost
            {x=0,y=0},                  --pos
            {extra = 3, choose = 1},    --config
            {"Choose {C:attention}#1#{} of up to","{C:attention}#2#{} Uncommon Vouchers", "to be redeemed"}, --desc
            true,                       --alerted
            "assets",                   --sprite path
            "p_uncommon_voucher_pack.png",          --sprite name
            --{px=71, py=95},             --sprite size
            G.STATES.PLANET_PACK,        --selection_state
            {color=HEX('009116'),background_color=HEX('61d473')} --color
        )
        addBooster(
            "p_fusion_voucher_pack",   --id
            "Fusion Voucher Pack",              --name
            -- pack_contents,              --pack contents
            nil,                        --order
            true,                       --discovered
            0.3,                          --weight
            "Standard",                 --kind
            18,                         --cost
            {x=0,y=0},                  --pos
            {extra = 3, choose = 1},    --config
            {"Choose {C:attention}#1#{} of up to","{C:attention}#2#{} Fusion Vouchers", "to be redeemed"}, --desc
            true,                       --alerted
            "assets",                   --sprite path
            "p_fusion_voucher_pack.png",          --sprite name
            --{px=71, py=95},             --sprite size
            G.STATES.PLANET_PACK,        --selection_state
            {color=HEX('d11966'),background_color=HEX('f5a2a4')} --color
        )
    end
    -- G.STATES.VOUCHER_PACK=1337
    local ease_background_colour_blind_ref=ease_background_colour_blind
    function ease_background_colour_blind(state, blind_override)
        if G.InBetmmaVoucherPack and G.C.VOUCHER_PACK_COLORS[G.GAME.BetmmaVoucherPackKey] then -- G.C.VOUCHER_PACK_COLORS[G.GAME.BetmmaVoucherPackKey] should always have value but someone reported crash.
            ease_colour(G.C.DYN_UI.MAIN, G.C.VOUCHER_PACK_COLORS[G.GAME.BetmmaVoucherPackKey].color)
            ease_background_colour{new_colour = G.C.VOUCHER_PACK_COLORS[G.GAME.BetmmaVoucherPackKey].background_color, contrast = 3}
            return
        end
        ease_background_colour_blind_ref(state, blind_override)
    end


    local Card_open_ref= Card.open
    function Card:open()
        if self.ability.set == "Booster" and self.ability.name:find('Voucher')then
            G.InBetmmaVoucherPack=true
            G.GAME.BetmmaVoucherPackKey=self.config.center.key
            stop_use()
            G.STATE_COMPLETE = false 
            self.opening = true

            if not self.config.center.discovered then
                discover_card(self.config.center)
            end
            self.states.hover.can = false
            G.STATE = G.STATES.PLANET_PACK -- it seems extremely complex to add G.STATES.VOUCHER_PACK because PLANET_PACK, TAROT_PACK and values like those are individually considered when tackling states. In other words there don't exist a table containing all "PACK_STATES" so many functions should be changed if STATES.VOUCHER_PACK is added. The bad result is that when choosing vouchers, the bottom text will be Celestial Pack (can be changed by other ways).
            G.GAME.pack_size = self.ability.extra
            G.GAME.pack_choices = self.config.center.config.choose or 1

            if self.cost > 0 then 
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                    inc_career_stat('c_shop_dollars_spent', self.cost)
                    self:juice_up()
                return true end }))
                ease_dollars(-self.cost) 
            else
                delay(0.2)
            end

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                self:explode()
                local pack_cards = {}

                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1.3*math.sqrt(G.SETTINGS.GAMESPEED), blockable = false, blocking = false, func = function()
                    local _size = self.ability.extra
                    
                    for i = 1, _size do
                        -- local card = nil
                        -- card = create_card("Voucher", G.pack_cards, nil, nil, true, true, nil, 'voucher_pack')
                        G.GAME.voucher_pack_name=self.ability.name -- this is to tell get_next_voucher_key_ref in Betmma_Vouchers to change how to get pool
                        local voucher_key = get_next_voucher_key(true)
                        G.GAME.voucher_pack_name=nil
                        local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                    G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[voucher_key],{bypass_discovery_center = true, bypass_discovery_ui = true})
                        card.from_voucher_pack_flag=true
                        card.T.x = self.T.x
                        card.T.y = self.T.y
                        card.cost=0
                        card:start_materialize({G.C.WHITE, G.C.WHITE}, nil, 1.5*G.SETTINGS.GAMESPEED)
                        pack_cards[i] = card
                    end
                    return true
                end}))
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1.3*math.sqrt(G.SETTINGS.GAMESPEED), blockable = false, blocking = false, func = function()
                    if G.pack_cards then 
                        if G.pack_cards and G.pack_cards.VT.y < G.ROOM.T.h then 
                            for k, v in ipairs(pack_cards) do
                                G.pack_cards:emplace(v)
                            end
                            return true
                        end
                    end
                end}))

                -- hope that there will be no jokers related to voucher packs
                -- for i = 1, #G.jokers.cards do
                --     G.jokers.cards[i]:calculate_joker({open_booster = true, card = self})
                -- end

                if G.GAME.modifiers.inflation then 
                    G.GAME.inflation = G.GAME.inflation + 1
                    G.E_MANAGER:add_event(Event({func = function()
                    for k, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                    return true end }))
                end

            return true end }))
        return true
        end
    
        return Card_open_ref(self)
    end

    local create_UIBox_celestial_pack_ref=create_UIBox_celestial_pack
    function create_UIBox_celestial_pack()
        if G.InBetmmaVoucherPack and not G.GAME.BetmmaVoucherPackKey then
            G.InBetmmaVoucherPack=false
        end
        if G.InBetmmaVoucherPack and G.GAME.BetmmaVoucherPackKey then
            local _size = G.GAME.pack_size
            G.pack_cards = CardArea(
              G.ROOM.T.x + 9 + G.hand.T.x, G.hand.T.y,
              _size*G.CARD_W*1.1 + 0.5,
              1.05*G.CARD_H, 
              {card_limit = _size, type = 'consumeable', highlight_limit = 1})
          
              local t = {n=G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes={
                {n=G.UIT.R, config={align = "cl", colour = G.C.CLEAR,r=0.15, padding = 0.1, minh = 2, shadow = true}, nodes={
                  {n=G.UIT.R, config={align = "cm"}, nodes={
                  {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                    {n=G.UIT.C, config={align = "cm", r=0.2, colour = G.C.CLEAR, shadow = true}, nodes={
                      {n=G.UIT.O, config={object = G.pack_cards}},
                    }}
                  }}
                }},
                {n=G.UIT.R, config={align = "cm"}, nodes={
                }},
                {n=G.UIT.R, config={align = "tm"}, nodes={
                  {n=G.UIT.C,config={align = "tm", padding = 0.05, minw = 2.4}, nodes={}},
                  {n=G.UIT.C,config={align = "tm", padding = 0.05}, nodes={
                  UIBox_dyn_container({
                    {n=G.UIT.C, config={align = "cm", padding = 0.05, minw = 4}, nodes={
                      {n=G.UIT.R,config={align = "bm", padding = 0.05}, nodes={
                        -- only this part is modified
                        {n=G.UIT.O, config={object = DynaText({string = localize('k_'..G.GAME.BetmmaVoucherPackKey), colours = {G.C.WHITE},shadow = true, rotate = true, bump = true, spacing =2, scale = 0.7, maxw = 4, pop_in = 0.5})}}
                        --
                      }},
                      {n=G.UIT.R,config={align = "bm", padding = 0.05}, nodes={
                        {n=G.UIT.O, config={object = DynaText({string = {localize('k_choose')..' '}, colours = {G.C.WHITE},shadow = true, rotate = true, bump = true, spacing =2, scale = 0.5, pop_in = 0.7})}},
                        {n=G.UIT.O, config={object = DynaText({string = {{ref_table = G.GAME, ref_value = 'pack_choices'}}, colours = {G.C.WHITE},shadow = true, rotate = true, bump = true, spacing =2, scale = 0.5, pop_in = 0.7})}}
                      }},
                    }}
                  }),
                }},
                  {n=G.UIT.C,config={align = "tm", padding = 0.05, minw = 2.4}, nodes={
                    {n=G.UIT.R,config={minh =0.2}, nodes={}},
                    {n=G.UIT.R,config={align = "tm",padding = 0.2, minh = 1.2, minw = 1.8, r=0.15,colour = G.C.GREY, one_press = true, button = 'skip_booster', hover = true,shadow = true, func = 'can_skip_booster'}, nodes = {
                      {n=G.UIT.T, config={text = localize('b_skip'), scale = 0.5, colour = G.C.WHITE, shadow = true, focus_args = {button = 'y', orientation = 'bm'}, func = 'set_button_pip'}}
                    }}
                  }}
                }}
              }}
            }}
            return t
        else
        return create_UIBox_celestial_pack_ref()
        end
    end

    local G_FUNCS_can_skip_booster_ref=G.FUNCS.can_skip_booster
    G.FUNCS.can_skip_booster=function(e)
        if G.pack_cards and not G.pack_cards.cards then
            e.config.colour = G.C.GREY
            e.config.button = 'skip_booster'
        else
            G_FUNCS_can_skip_booster_ref(e)
        end
        if type(G.GAME.pack_size)=='number' and G.GAME.pack_size<1 then
            e.config.colour = G.C.GREY
            e.config.button = 'skip_booster'
        end
    end
        
    local generate_card_ui_ref=generate_card_ui
    function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        -- to give voucher pack correct description
        if _c.set == 'Booster' then 
            if _c.name and _c.name:find('Voucher Pack') then 
                local first_pass = nil
                if not full_UI_table then 
                    first_pass = true
                    full_UI_table = {
                        main = {},
                        info = {},
                        type = {},
                        name = nil,
                        badges = badges or {}
                    }
                end

                local desc_nodes = (not full_UI_table.name and full_UI_table.main) or full_UI_table.info
                local name_override = nil
                local info_queue = {}

                if full_UI_table.name then
                    full_UI_table.info[#full_UI_table.info+1] = {}
                    desc_nodes = full_UI_table.info[#full_UI_table.info]
                end

                if not full_UI_table.name then
                    if specific_vars and specific_vars.no_name then
                        full_UI_table.name = true
                    elseif card_type == 'Locked' then
                        full_UI_table.name = localize{type = 'name', set = 'Other', key = 'locked', nodes = {}}
                    elseif card_type == 'Undiscovered' then 
                        full_UI_table.name = localize{type = 'name', set = 'Other', key = 'undiscovered_'..(string.lower(_c.set)), name_nodes = {}}
                    elseif specific_vars and (card_type == 'Default' or card_type == 'Enhanced') then
                        if (_c.name == 'Stone Card') then full_UI_table.name = true end
                        if (specific_vars.playing_card and (_c.name ~= 'Stone Card')) then
                            full_UI_table.name = {}
                            localize{type = 'other', key = 'playing_card', set = 'Other', nodes = full_UI_table.name, vars = {localize(specific_vars.value, 'ranks'), localize(specific_vars.suit, 'suits_plural'), colours = {specific_vars.colour}}}
                            full_UI_table.name = full_UI_table.name[1]
                        end
                    elseif card_type == 'Booster' then
                        
                    else
                        full_UI_table.name = localize{type = 'name', set = _c.set, key = _c.key, nodes = full_UI_table.name}
                    end
                    full_UI_table.card_type = card_type or _c.set
                end 
                -- Actually only this part of code is added
                desc_override = _c.key; loc_vars = {_c.config.choose, _c.config.extra}
                name_override = desc_override
                full_UI_table.name = localize{type = 'name', set = 'Other', key = name_override, nodes = full_UI_table.name} 
                localize{type = 'other', key = desc_override, nodes = desc_nodes, vars = loc_vars}
                if main_end then 
                    desc_nodes[#desc_nodes+1] = main_end 
                end
                -- Other parts are copied from the original function 
            
               --Fill all remaining info if this is the main desc
                if not ((specific_vars and not specific_vars.sticker) and (card_type == 'Default' or card_type == 'Enhanced')) then
                    if desc_nodes == full_UI_table.main and not full_UI_table.name then
                        localize{type = 'name', key = _c.key, set = _c.set, nodes = full_UI_table.name} 
                        if not full_UI_table.name then full_UI_table.name = {} end
                    elseif desc_nodes ~= full_UI_table.main then 
                        desc_nodes.name = localize{type = 'name_text', key = name_override or _c.key, set = name_override and 'Other' or _c.set} 
                    end
                end
            
                if first_pass and not (_c.set == 'Edition') and badges then
                    for k, v in ipairs(badges) do
                        if v == 'foil' then info_queue[#info_queue+1] = G.P_CENTERS['e_foil'] end
                        if v == 'holographic' then info_queue[#info_queue+1] = G.P_CENTERS['e_holo'] end
                        if v == 'polychrome' then info_queue[#info_queue+1] = G.P_CENTERS['e_polychrome'] end
                        if v == 'negative' then info_queue[#info_queue+1] = G.P_CENTERS['e_negative'] end
                        if v == 'negative_consumable' then info_queue[#info_queue+1] = {key = 'e_negative_consumable', set = 'Edition', config = {extra = 1}} end
                        if v == 'gold_seal' then info_queue[#info_queue+1] = {key = 'gold_seal', set = 'Other'} end
                        if v == 'blue_seal' then info_queue[#info_queue+1] = {key = 'blue_seal', set = 'Other'} end
                        if v == 'red_seal' then info_queue[#info_queue+1] = {key = 'red_seal', set = 'Other'} end
                        if v == 'purple_seal' then info_queue[#info_queue+1] = {key = 'purple_seal', set = 'Other'} end
                        if v == 'eternal' then info_queue[#info_queue+1] = {key = 'eternal', set = 'Other'} end
                        if v == 'perishable' then info_queue[#info_queue+1] = {key = 'perishable', set = 'Other', vars = {G.GAME.perishable_rounds or 1, specific_vars.perish_tally or G.GAME.perishable_rounds}} end
                        if v == 'rental' then info_queue[#info_queue+1] = {key = 'rental', set = 'Other', vars = {G.GAME.rental_rate or 1}} end
                        if v == 'pinned_left' then info_queue[#info_queue+1] = {key = 'pinned_left', set = 'Other'} end
                    end
                end
            
                for _, v in ipairs(info_queue) do
                    generate_card_ui(v, full_UI_table)
                end
                return full_UI_table
            end
        end
        
        return generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    end

    local G_FUNCS_end_consumeable_ref=G.FUNCS.end_consumeable
    G.FUNCS.end_consumeable = function(e, delayfac)
        G.InBetmmaVoucherPack=false
        return G_FUNCS_end_consumeable_ref(e,delayfac)
    end

    local G_FUNCS_can_continue_ref=G.FUNCS.can_continue
    G.FUNCS.can_continue = function(e)
        if e.config.func then
            local _can_continue = nil
            local savefile = love.filesystem.getInfo(G.SETTINGS.profile..'/'..'save.jkr')
            if savefile then
              if not G.SAVED_GAME then 
                local saved_game=get_compressed(G.SETTINGS.profile..'/'..'save.jkr')
                if saved_game and STR_UNPACK(saved_game)==nil then
                    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                    e.config.button = nil
                    return nil
                end
              end
            end
        end
        return G_FUNCS_can_continue_ref(e)
    end

    local ease_dollars_ref = ease_dollars
    function ease_dollars(mod, instant)
        if mod==0 and G.STATE == G.STATES.PLANET_PACK then return true end
        -- to disable the +$0 effect when redeeming vouchers in a pack
        ease_dollars_ref(mod, instant)
    end
    init_localization()

    local Card_redeem_ref=Card.redeem
    function Card:redeem()
        local current_round_voucher=G.GAME.current_round.voucher
        local ret=Card_redeem_ref(self)
        if self.from_voucher_pack_flag then -- look at line 149 of this file
            G.GAME.current_round.voucher=current_round_voucher
        end
        return ret
    end

    if IN_SMOD1 then
        INIT()
    else
        SMODS['INIT']=SMODS['INIT'] or {}
        SMODS['INIT']['BetmmaVoucherPack']=function()
            INIT()
            SMODS.current_mod.process_loc_text()
        end
        
    end
----------------------------------------------
------------MOD CODE END----------------------