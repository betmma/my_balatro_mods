--- STEAMODDED HEADER
--- MOD_NAME: Betmma Jokers
--- MOD_ID: BetmmaJokers
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 5 More Jokers!

----------------------------------------------
------------MOD CODE -------------------------



function SMODS.INIT.BetmmaJokers()
    
    local localization = {
        jjookkeerr = {
            name = "JJookkeerr",
            text = {
                "Jokers with \"Joker\"",
                "in their names",
                "each gives {X:mult,C:white} X#1# {} Mult",
                -- if I count right there are 24 common, 6 uncommon and 3 rare jokers that satisfy this condition
            }
        },
        ascension = {
            name = "Ascension",
            text = {
                "Increase the tier of",
                "played poker hand by 1 ",
                "(e.g. High Card counts as One Pair)",
                -- How the poker hand "contained" is calculated should be clarified:
                -- If you play a Straight Flush, originally it contains Straight Flush, Flush, Straight and High Card. After triggering ascension it is counted as 5oak and contains 5oak, Straight Flush, Flush, Straight and High Card. Though a real 5oak contains 4oak and 3oak, this 5oak from ascension doesn't contain them.
            }
        },
        hasty = {
            name = "Hasty Joker",
            text = {
                "Earn {C:money}$#1#{} if round",
            "ends after first hand",
            }
        },
        errorr = {
            name = "ERRORR",
            text = {
                "Discarded cards have",
            "{C:green}#1# in #2#{} chance to",
            "become random rank"
            }
        },
        piggy_bank = {
            name = "Piggy Bank",
            text = {
                "Put half of earned dollars",
                "into it and gain {C:red}+#2#{} Mult",
                "for each dollar",
                "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)"
                -- dollar in it adds to its sold price
            }
        }
    }

    --[[SMODS.Joker:new(
        name, slug,
        config,
        spritePos, loc_txt,
        rarity, cost, unlocked, discovered, blueprint_compat, eternal_compat
    )
    ]]

    local jokers = {
        jjookkeerr = SMODS.Joker:new(
            "JJookkeerr", "",
            {extra=1.5},
            {x=0,y=0}, "",
            2, 6, true, true, true, true
        ),
        ascension = SMODS.Joker:new(
            "Ascension", "",
            {},
            {x=0,y=0}, "",
            2, 6, true, true, true, true
        ),
        hasty = SMODS.Joker:new(
            "Hasty Joker", "",
            {extra=8},
            {x=0,y=0}, "",
            1, 5, true, true, false, true
        ),
        errorr = SMODS.Joker:new(
            "ERRORR", "",
            {
                extra={odds = 3}
            },
            {x=0,y=0}, "",
            3, 8, true, true, false, true
        ),
        piggy_bank = SMODS.Joker:new(
            "Piggy Bank", "",
            {
                extra={mults = 0, mult_mod = 1}
            },
            {x=0,y=0}, "",
            1, 5, true, true, true, true
        ),
    }

    -- Blacklist individual Jokers here
    local jokerBlacklists = {
        jjookkeerr = false,
        ascension = false
    }
    -- this challenge is only for test
    -- table.insert(G.CHALLENGES,#G.CHALLENGES+1,{
    --     name = "TestJoker",
    --     id = 'c_mod_testjoker',
    --     rules = {
    --         custom = {
    --         },
    --         modifiers = {
    --             {id = 'dollars', value = 10},
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
    --         {id = 'v_directors_cut'},
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
    -- G.localization.misc.challenge_names.c_mod_testjoker = "TestJoker"
    -- Localization
    init_localization()

    -- Add Jokers to center
    for k, v in pairs(jokers) do
        if not jokerBlacklists[k] then
            v.slug = "j_" .. k
            v.loc_txt = localization[k]
            v.spritePos = { x = 0, y = 0 }
            v:register()
            SMODS.Sprite:new(v.slug, SMODS.findModByID("BetmmaJokers").path, v.slug..".png", 71, 95, "asset_atli"):register()
        end
    end

    --- Joker abilities ---
    SMODS.Jokers.j_jjookkeerr.calculate = function(self, context)
        if context.other_joker and context.other_joker ~= self then
            if string.match(context.other_joker.ability.name, "Joker") then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_joker:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                return {
                    message = localize{type='variable',key='a_xmult',vars={self.ability.extra}},
                    Xmult_mod = self.ability.extra
                }
            end
        end
    end

    SMODS.Jokers.j_errorr.calculate = function(self, context)
        if context.discard and not context.other_card.debuff and
        pseudorandom('errorr') < G.GAME.probabilities.normal/self.ability.extra.odds then -- the argument of pseudorandom is hashed and only for random seed, so every string is ok
            local card=context.other_card
            local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
            local rank_suffix = {'2','3','4','5','6','7','8','9','T','J','Q','K','A'}
            local rand = math.floor(pseudorandom('rank')*13+1)
            card:set_base(G.P_CARDS[suit_prefix..rank_suffix[rand]])
            return {
                message = localize('k_errorr'),
                card = card,
                colour = G.C.CHIPS
            }
        end
    end
    G.localization.misc.dictionary.k_errorr = "Rank Changed!"

    SMODS.Jokers.j_piggy_bank.calculate = function(self, context)
        if SMODS.end_calculate_context(context) and self.ability.extra.mults > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={self.ability.extra.mults}},
                mult_mod = self.ability.extra.mults, 
                colour = G.C.MULT
            }
        end
        if context.selling_self then
            self.selling_self = true
        end
    end

    
end

local poker_hand_list = {
    "Flush Five",
    "Flush House",
    "Five of a Kind",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card",
}

-- Ascension
local evaluate_poker_hand_ref = evaluate_poker_hand
function evaluate_poker_hand(hand)
    local ret = evaluate_poker_hand_ref(hand)
    local Ascension_number = #find_joker('Ascension')
    for i = 1, Ascension_number, 1 do
        if next(ret[poker_hand_list[1]]) then break end -- Already getting the biggest hand
        for poker_hand_index = 2, #poker_hand_list, 1 do
            if next(ret[poker_hand_list[poker_hand_index]]) then 
                ret[poker_hand_list[poker_hand_index-1]]=ret[poker_hand_list[poker_hand_index]] -- Increase the tier of maximum hand by 1
                break
            end
        end
    end
    return ret
end

-- Hasty Joker
local calculate_dollar_bonus_ref = Card.calculate_dollar_bonus
function Card:calculate_dollar_bonus()
    if self.debuff then return end
    if self.ability.set == "Joker" then
        if self.ability.name == 'Hasty Joker' and G.GAME.current_round.hands_played == 1 then
            return self.ability.extra
        end
    end
    return calculate_dollar_bonus_ref(self)
end

-- Piggy Bank
local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
    ease_dollars_ref(mod, instant)
    if mod > 0 then
        local Piggy_Banks = find_joker('Piggy Bank')
        -- local Piggy_Bank_number = #Piggy_Banks
        --local saved_dollars = 0
        for index, card in pairs(Piggy_Banks) do
            local half = math.floor(mod/2)
            if half > 0 and not card.selling_self then
                delay(1)
                ease_dollars_ref(-half, false) 
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up(0.5, 0.5)
                        return true
                    end
                })) 
                mod = mod - half
                card.ability.extra.mults = card.ability.extra.mults + card.ability.extra.mult_mod * half
                card.ability.extra_value = card.ability.extra_value + half
                card:set_cost()
            end
        end
    end

end

-- UIBox garbage / Copied from LushMod. Thanks luscious!
local generate_UIBox_ability_tableref = Card.generate_UIBox_ability_table
function Card.generate_UIBox_ability_table(self)
    local card_type, hide_desc = self.ability.set or "None", nil
    local loc_vars = nil
    local main_start, main_end = nil, nil
    local no_badge = nil

    if self.config.center.unlocked == false and not self.bypass_lock then    -- For everyting that is locked
    elseif card_type == 'Undiscovered' and not self.bypass_discovery_ui then -- Any Joker or tarot/planet/voucher that is not yet discovered
    elseif self.debuff then
    elseif card_type == 'Default' or card_type == 'Enhanced' then
    elseif self.ability.set == 'Joker' then
        local customJoker = false

        if self.ability.name == 'JJookkeerr' or self.ability.name == 'Ascension' or self.ability.name == 'Hasty Joker' or self.ability.name == 'ERRORR' or self.ability.name == 'Piggy Bank'then
            customJoker = true
        end

        if self.ability.name == 'JJookkeerr' or self.ability.name == 'Hasty Joker'then
            loc_vars = {self.ability.extra}
        elseif self.ability.name == 'ERRORR' then loc_vars = {''..(G.GAME and G.GAME.probabilities.normal or 1), self.ability.extra.odds}
        elseif self.ability.name == 'Piggy Bank' then loc_vars = {self.ability.extra.mults, self.ability.extra.mult_mod}
        end
        if customJoker then
            local badges = {}
            if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or self.debuff then
                badges.card_type = card_type
            end
            if self.ability.set == 'Joker' and self.bypass_discovery_ui and (not no_badge) then
                badges.force_rarity = true
            end
            if self.edition then
                if self.edition.type == 'negative' and self.ability.consumeable then
                    badges[#badges + 1] = 'negative_consumable'
                else
                    badges[#badges + 1] = (self.edition.type == 'holo' and 'holographic' or self.edition.type)
                end
            end
            if self.seal then
                badges[#badges + 1] = string.lower(self.seal) .. '_seal'
            end
            if self.ability.eternal then
                badges[#badges + 1] = 'eternal'
            end
            if self.pinned then
                badges[#badges + 1] = 'pinned_left'
            end

            if self.sticker then
                loc_vars = loc_vars or {};
                loc_vars.sticker = self.sticker
            end

            local center = self.config.center
            return generate_card_ui(center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)
        end
    end
    return generate_UIBox_ability_tableref(self)
end



----------------------------------------------
------------MOD CODE END----------------------