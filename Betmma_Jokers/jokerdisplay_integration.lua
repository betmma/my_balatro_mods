------------------------------
-- JokerDisplay Integration --
------------------------------

local jd_def = JokerDisplay.Definitions

jd_def['betm_jokers_j_jjookkeerr'] = { -- JJookkeerr
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "count",          colour = G.C.ORANGE },
        { text = "x" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.GREEN },
        { text = ")" },
    },
    calc_function = function(card)
        local count = 0
        if G.jokers then
            for k, v in ipairs(G.jokers.cards) do
                if v.ability.name and string.match(v.ability.name, "Joker") then
                    count = count + 1
                end
            end
        end
        card.joker_display_values.count = count
        card.joker_display_values.localized_text = localize("k_joker")
    end,
    mod_function = function(card, mod_joker)
        return { x_mult = (string.match(card.ability.name, "Joker") and mod_joker.ability.extra or nil) }
    end
}

jd_def['betm_jokers_j_ascension'] = { -- Ascension

}

jd_def['betm_jokers_j_hasty'] = { -- Hasty Joker
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        card.joker_display_values.dollars = (G.GAME and G.GAME.current_round.hands_played <= 1) and 8 or 0
    end
}

jd_def['betm_jokers_j_errorr'] = { -- ERRORR
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values",                                      ref_value = "odds" },
            { text = " in " },
            { ref_table = "card.ability.extra",                                      ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
    end
}

jd_def['betm_jokers_j_piggy_bank'] = { -- Piggy Bank
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mults" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def['betm_jokers_j_housing_choice'] = { -- Housing Choice
    reminder_text = {
        { text = '(' },
        { ref_table = 'card.joker_display_values', ref_value = 'text',  colour = G.C.ORANGE },
        { text = ')' },
    },
    calc_function = function(card)
        card.joker_display_values.text = not card.ability.extra.triggered and localize("Full House", 'poker_hands') or
        "-"
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children[2] then
            reminder_text.children[2].config.colour = not card.ability.extra.triggered and G.C.ORANGE or
            G.C.UI.TEXT_INACTIVE
        end
        return false
    end
}

jd_def['betm_jokers_j_jimbow'] = { -- Jimbow
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    reminder_text = {
        { text = '(' },
        { ref_table = "card.joker_display_values", ref_value = "context", colour = G.C.ORANGE },
        { text = ')' },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function (card)
        -- There should probably be extra localization text for this, normal text is too long
        card.joker_display_values.context = card.ability.extra.context and card.ability.extra.context:gsub("%_", " ") or "-"
    end
}
