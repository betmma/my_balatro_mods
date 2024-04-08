--- STEAMODDED HEADER
--- MOD_NAME: Betmma Vouchers
--- MOD_ID: BetmmaVouchers
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 16 More Vouchers!

----------------------------------------------
------------MOD CODE -------------------------
function SMODS.INIT.BetmmaVouchers()
    local oversupply_loc_txt = {
        name = "Oversupply",
        text = {
            "Gain {C:attention}1{} {C:attention}Voucher Tag{}",
            "after beating boss blind"
        }
    }
    --function SMODS.Voucher:new(name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_oversupply = SMODS.Voucher:new(
        "Oversupply", "oversupply",
        {},
        {x=0,y=0}, oversupply_loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_oversupply", SMODS.findModByID("BetmmaVouchers").path, "v_oversupply.png", 71, 95, "asset_atli"):register();
    v_oversupply:register()

    
    local oversupply_plus_loc_txt = {
        name = "Oversupply Plus",
        text = {
            "Gain {C:attention}1{} {C:attention}Voucher Tag{}",
            "after beating every blind"
            -- if you have both, after beating boss blind you gain only 1 voucher tag
        }
    }
    local v_oversupply_plus = SMODS.Voucher:new(
            "Oversupply Plus", "oversupply_plus",
            {},
            {x=0,y=0}, oversupply_plus_loc_txt,
            10, true, true, true, {'v_oversupply'}
        )
    SMODS.Sprite:new("v_oversupply_plus", SMODS.findModByID("BetmmaVouchers").path, "v_oversupply_plus.png", 71, 95, "asset_atli"):register();
    v_oversupply_plus:register()
    -- The v.redeem function mentioned in voucher.lua of steamodded 0.9.5 is bugged when the voucher is given at the beginning of the game (such as challenge or some decks), and also it's not capable of making not one-time effects.
    local end_round_ref = end_round
    function end_round()
        if G.GAME.used_vouchers.v_oversupply and G.GAME.blind:get_type() == 'Boss' or G.GAME.used_vouchers.v_oversupply_plus then
            add_tag(Tag('tag_voucher'))
        end
        end_round_ref()
    end

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
    --function SMODS.Voucher:new(name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_gold_coin = SMODS.Voucher:new(
        name, id,
        {extra=20},
        {x=0,y=0}, gold_coin_loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_gold_coin.png", 71, 95, "asset_atli"):register();
    v_gold_coin:register()
    v_gold_coin.loc_def = function(self)
        return {self.config.extra}
    end

    
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
    --function SMODS.Voucher:new(name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_gold_bar = SMODS.Voucher:new(
        name, id,
        {extra=25},
        {x=0,y=0}, gold_bar_loc_txt,
        10, true, true, true, {'v_gold_coin'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_gold_bar.png", 71, 95, "asset_atli"):register();
    v_gold_bar:register()
    v_gold_bar.loc_def = function(self)
        return {self.config.extra}
    end

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
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=1},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Mondrian"
    local id="mondrian"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}+#1#{} Ante to win,",
            "{C:attention}+#1#{} Joker slot"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=1},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_abstract_art'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

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
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return nil
    end

    
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
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=5},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_round_up'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local mod_chips_ref=mod_chips
    function mod_chips(_chips)
        if G.GAME.used_vouchers.v_round_up then
          _chips = math.ceil(_chips/10)*10
        end
        return mod_chips_ref(_chips)
    end
    local mod_mult_ref=mod_mult
    function mod_mult(_mult)
        if G.GAME.used_vouchers.v_round_up_plus then
            _mult=math.ceil(_mult/10)*10
        end
        return mod_mult_ref(_mult)
    end

    
    
    local name="Event Horizon"
    local id="event_horizon"
    local loc_txt = {
        name = name,
        text = {
            "{C:green}#1# in #2#{} chance to",
            "create a {C:spectral}Black Hole{} card",
            "when buying a planet pack,",
            "create a {C:spectral}Black Hole{} now",
            "{C:inactive}(Must have room)"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {""..(G.GAME and G.GAME.probabilities.normal or 1),self.config.extra}
    end

    
    local name="Engulfer"
    local id="engulfer"
    local loc_txt = {
        name = name,
        text = {
            "{C:green}#1# in #2#{} chance to",
            "create a {C:spectral}Black Hole{} card",
            "when using a planet card,",
            "create a {C:spectral}Black Hole{} now",
            "{C:inactive}(Must have room)"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=5},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_event_horizon'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {""..(G.GAME and G.GAME.probabilities.normal or 1),self.config.extra}
    end

    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Event Horizon' or center_table.name == 'Engulfer' then
            create_black_hole()
        end
        Card_apply_to_run_ref(self, center)
    end

    local Card_open_ref=Card.open
    function Card:open()
        if self.ability.set == "Booster" and self.ability.name:find('Celestial') and G.GAME.used_vouchers.v_event_horizon and
        pseudorandom('event_horizon') < G.GAME.probabilities.normal/G.P_CENTERS.v_event_horizon.config.extra then
            create_black_hole()
        end
        return Card_open_ref(self)
    end

    local G_FUNCS_use_card_ref = G.FUNCS.use_card
    G.FUNCS.use_card =function(e, mute, nosave)
        local card = e.config.ref_table
        if card.ability.consumeable then
            if card.ability.set == 'Planet' and G.GAME.used_vouchers.v_engulfer and pseudorandom('engulfer') < G.GAME.probabilities.normal/G.P_CENTERS.v_engulfer.config.extra then
                create_black_hole()
            end
        end
        G_FUNCS_use_card_ref(e, mute, nosave)
    end

    function create_black_hole()
        if #G.consumeables.cards + G.GAME.consumeable_buffer > G.consumeables.config.card_limit then return end
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.0,
            func = (function()
                    local card = create_card('Planet',G.consumeables, nil, nil, nil, nil, 'c_black_hole', 'v_event_horizon_or_v_engulfer')
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                    return true
                    end)}))
    end


    
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
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=120},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Bull's Eye"
    local id="bulls_eye"
    local loc_txt = {
        name = name,
        text = {
            "If chips scored are under",
            "{C:attention}#1#%{} of required chips",
            "at end of round,",
            "create a {C:spectral}Spectral{} card",
            "{C:inactive}(Must have room)"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=105},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_target'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local end_round_ref=end_round
    function end_round()

        if G.GAME.used_vouchers.v_target and G.GAME.chips - G.GAME.blind.chips >= 0 and G.GAME.chips*100 - G.GAME.blind.chips*G.P_CENTERS.v_target.config.extra <= 0 then
            if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        for i = 1, jokers_to_create do
                            local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'target')
                            card:add_to_deck()
                            G.jokers:emplace(card)
                            card:start_materialize()
                            G.GAME.joker_buffer = 0
                            card_eval_status_text(card,'jokers',nil,nil,nil,{message=localize("k_target_generate")})
                        end
                        return true
                    end}))   
            end
        end
        if G.GAME.used_vouchers.v_bulls_eye and G.GAME.chips - G.GAME.blind.chips >= 0 and G.GAME.chips*100 - G.GAME.blind.chips*G.P_CENTERS.v_bulls_eye.config.extra <= 0 then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                            local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'bulls_eye')
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            G.GAME.consumeable_buffer = 0
                            card_eval_status_text(card,'extra',nil,nil,nil,{message=localize("k_bulls_eye_generate")})
                        return true
                    end)}))
            end
        end

        end_round_ref()
    end

    G.localization.misc.dictionary.k_target_generate = "Target!"
    G.localization.misc.dictionary.k_bulls_eye_generate = "Bull's Eye!"


    
    local name="Voucher Pack"
    local id="voucher_pack"
    local loc_txt = {
        name = name,
        text = {
            "Gives {C:Attention}#1#{} random vouchers"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=2},
        {x=0,y=0}, loc_txt,
        15, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Voucher Bulk"
    local id="voucher_bulk"
    local loc_txt = {
        name = name,
        text = {
            "Gives {C:Attention}#1#{} random vouchers"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        25, true, true, true, {'v_voucher_pack'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end
        
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Voucher Pack' then
            for i=1, G.P_CENTERS.v_voucher_pack.config.extra do
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay =  0,
                    func = function() 
                        randomly_redeem_voucher()
                        return true
                    end}))   
            end
        end
        if center_table.name == 'Voucher Bulk' then
            for i=1, G.P_CENTERS.v_voucher_bulk.config.extra do
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay =  0,
                    func = function() 
                        randomly_redeem_voucher()
                        return true
                    end}))   
            end
        end
        Card_apply_to_run_ref(self, center)
    end

    function randomly_redeem_voucher()
        local voucher_key = get_next_voucher_key(true)
        local card = Card(0.5,0.5, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[voucher_key],{bypass_discovery_center = true, bypass_discovery_ui = true})
        --create_shop_card_ui(card, 'Voucher', G.shop_vouchers)
        card:start_materialize()
        G.play:emplace(card)
        card.cost=0
        card.shop_voucher=false
        card:redeem()
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

        
    local name="Skip"
    local id="skip"
    local loc_txt = {
        name = name,
        text = {
            "Earn {C:money}$#1#{} when skipping blind"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        15, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Skipper"
    local id="skipper"
    local loc_txt = {
        name = name,
        text = {
            "Get a {C:attention}Double Tag{} when skipping blind"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        25, true, true, true, {'v_skip'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}--{self.config.extra}
    end

    local G_FUNCS_skip_blind_ref=G.FUNCS.skip_blind
    G.FUNCS.skip_blind=function(e)
        if G.GAME.used_vouchers.v_skip then
            ease_dollars(G.P_CENTERS.v_skip.config.extra)
        end
        if G.GAME.used_vouchers.v_skipper then
            add_tag(Tag('tag_double'))
        end
        return G_FUNCS_skip_blind_ref(e)
    end

    -- this challenge is only for test
    -- table.insert(G.CHALLENGES,1,{
    --     name = "TestVoucher",
    --     id = 'c_mod_testvoucher',
    --     rules = {
    --         custom = {
    --         },
    --         modifiers = {
    --             {id = 'dollars', value = 4},
    --         }
    --     },
    --     jokers = {
    --         {id = 'j_jjookkeerr'},
    --         {id = 'j_ascension'},
    --         {id = 'j_hasty'},
    --         {id = 'j_errorr'},
    --         {id = 'j_piggy_bank'},
    --         {id = 'j_piggy_bank'},
    --         {id = 'j_piggy_bank'},
    --     },
    --     consumeables = {
    --         {id = 'c_temperance'},
    --     },
    --     vouchers = {
    --         {id = 'v_skip'},
    --         {id = 'v_skipper'},
    --         -- {id = 'v_voucher_bulk'},
    --         -- {id = 'v_voucher_pack'},
    --     },
    --     deck = {
    --         type = 'Challenge Deck',
    --         --cards = {{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},{s='D',r='A'},}
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
    -- G.localization.misc.challenge_names.c_mod_testvoucher = "TestVoucher"
    init_localization()
end
----------------------------------------------
------------MOD CODE END----------------------