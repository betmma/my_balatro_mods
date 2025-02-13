-- cryptid cross-mod content functionality that executes after cryptid is loaded. This file is to fix eternity voucher broken due to cryptid overriding create_card.
--[[ 
The order of loading is as follows:
Betmma Mods load, add the hook
If you have Cryptid:
Cryptid lib loads, removing the hook
Cryptid cross-mod (this file) loads, adding the hook back
]]

-- eternity
local create_card_ref=create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    local card=create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if used_voucher('eternity') and _type == 'Joker' and ((area == G.shop_jokers) or (area == G.pack_cards)) and card.ability.eternal then
        if pseudorandom('eternity')<1/get_voucher('eternity').config.extra then
            card:set_edition{negative=true}
        end
    end
    return card
end

-- bobby pin and heat death do inject into create_card, but the injection is to mimic cryptid enable_pinned_in_shop and eternal_perishable_compat without cryptid mod. So no need to add these 2 hooks here.

-- empty return
return {
    init=function()end,
    items={}
}