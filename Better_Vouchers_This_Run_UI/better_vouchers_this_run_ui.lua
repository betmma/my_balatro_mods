--- STEAMODDED HEADER
--- MOD_NAME: Better Vouchers This Run UI
--- MOD_ID: BetterVouchersThisRunUI
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: Rewrite the Run Info - Vouchers tab to enable it to display dozens of redeemed vouchers. 

----------------------------------------------
------------MOD CODE -------------------------


    -- This is a version that only changes the limit of vouchers in a row and is capable of displaying 64 vouchers, but it's not enough
    -- function G.UIDEF.used_vouchers()
    --     local silent = false
    --     local keys_used = {}
    --     local area_count = 0
    --     local voucher_areas = {}
    --     local voucher_tables = {}
    --     local voucher_table_rows = {}
    --     for k, v in ipairs(G.P_CENTER_POOLS["Voucher"]) do
    --     local key = 1 + math.floor((k-0.1)/2)
    --     keys_used[key] = keys_used[key] or {}
    --     if G.GAME.used_vouchers[v.key] then 
    --         keys_used[key][#keys_used[key]+1] = v
    --     end
    --     end
    --     for k, v in ipairs(keys_used) do 
    --     if next(v) then
    --         area_count = area_count + 1
    --     end
    --     end
    --     for k, v in ipairs(keys_used) do 
    --     if next(v) then
    --         if #voucher_areas and #voucher_areas % 8==0 then -- I've only changed this
    --         table.insert(voucher_table_rows, 
    --         {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes=voucher_tables}
    --         )
    --         voucher_tables = {}
    --         end
    --         voucher_areas[#voucher_areas + 1] = CardArea(
    --         G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
    --         (#v == 1 and 1 or 1.33)*G.CARD_W,
    --         (area_count >=10 and 0.75 or 1.07)*G.CARD_H, 
    --         {card_limit = 2, type = 'voucher', highlight_limit = 0})
    --         for kk, vv in ipairs(v) do 
    --         local center = G.P_CENTERS[vv.key]
    --         local card = Card(voucher_areas[#voucher_areas].T.x + voucher_areas[#voucher_areas].T.w/2, voucher_areas[#voucher_areas].T.y, G.CARD_W, G.CARD_H, nil, center, {bypass_discovery_center=true,bypass_discovery_ui=true,bypass_lock=true})
    --         card.ability.order = vv.order
    --         card:start_materialize(nil, silent)
    --         silent = true
    --         voucher_areas[#voucher_areas]:emplace(card)
    --         end
    --         table.insert(voucher_tables, 
    --         {n=G.UIT.C, config={align = "cm", padding = 0, no_fill = true}, nodes={
    --         {n=G.UIT.O, config={object = voucher_areas[#voucher_areas]}}
    --         }}
    --         )
    --     end
    --     end
    --     table.insert(voucher_table_rows,
    --             {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes=voucher_tables}
    --         )
    
        
    --     local t = silent and {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
    --     {n=G.UIT.R, config={align = "cm"}, nodes={
    --         {n=G.UIT.O, config={object = DynaText({string = {localize('ph_vouchers_redeemed')}, colours = {G.C.UI.TEXT_LIGHT}, bump = true, scale = 0.6})}}
    --     }},
    --     {n=G.UIT.R, config={align = "cm", minh = 0.5}, nodes={
    --     }},
    --     {n=G.UIT.R, config={align = "cm", colour = G.C.BLACK, r = 1, padding = 0.15, emboss = 0.05}, nodes={
    --         {n=G.UIT.R, config={align = "cm"}, nodes=voucher_table_rows},
    --     }}
    --     }} or 
    --     {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
    --     {n=G.UIT.O, config={object = DynaText({string = {localize('ph_no_vouchers')}, colours = {G.C.UI.TEXT_LIGHT}, bump = true, scale = 0.6})}}
    --     }}
    --     return t
    -- end
    local PAIRS_PER_ROW=4
    local ROWS_PER_PAGE=2
    function G.UIDEF.used_vouchers()
        -- warning: the meanings of variables below are different from the original functions
        local silent = false
        local keys_used = {}
        local vouchers_used = {}
        local area_count = 0
        local voucher_areas = {}
        local voucher_pairs = {}
        local voucher_rows = {}
        G.your_collection={}
        for k, v in ipairs(G.P_CENTER_POOLS["Voucher"]) do
        local key = 1 + math.floor((k-0.1)/2)
        keys_used[key] = keys_used[key] or {}
        if G.GAME.used_vouchers[v.key] then 
            keys_used[key][#keys_used[key]+1] = v
            table.insert(vouchers_used,v)
            silent=true
        end
        end
        local keys_used2={}
        for k, v in ipairs(keys_used) do 
        if next(v) then
            area_count = area_count + 1
            table.insert(keys_used2,v)
        end
        end
        keys_used=keys_used2

        for k, v in ipairs(keys_used) do 
            if k>PAIRS_PER_ROW*ROWS_PER_PAGE then break end
            if next(v) then
                if #voucher_areas and #voucher_areas % PAIRS_PER_ROW==0 then 
                table.insert(voucher_rows, 
                {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes=voucher_pairs}
                )
                voucher_pairs = {}
                end
                voucher_areas[#voucher_areas + 1] = CardArea(
                    G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                    (#v == 1 and 1 or 1.33)*G.CARD_W,
                    (area_count >=10 and 0.75 or 1.07)*G.CARD_H, 
                    {card_limit = 2, type = 'voucher', highlight_limit = 0})
                G.your_collection[#G.your_collection+1]=voucher_areas[#voucher_areas]
                for kk, vv in ipairs(v) do 
                    local center = G.P_CENTERS[vv.key]
                    local card = Card(voucher_areas[#voucher_areas].T.x + voucher_areas[#voucher_areas].T.w/2, voucher_areas[#voucher_areas].T.y, G.CARD_W, G.CARD_H, nil, center, {bypass_discovery_center=true,bypass_discovery_ui=true,bypass_lock=true})
                    card.ability.order = vv.order
                    card:start_materialize(nil, silent)
                    silent = true
                    voucher_areas[#voucher_areas]:emplace(card)
            end
            table.insert(voucher_pairs, 
            {n=G.UIT.C, config={align = "cm", padding = 0, no_fill = true}, nodes={
                {n=G.UIT.O, config={object = voucher_areas[#voucher_areas]}}
            }}
            )
            end
        end
        
        table.insert(voucher_rows, 
        {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes=voucher_pairs}
        )
        local deck_tables = {}

        
        local voucher_options = {}
        for i = 1, math.ceil(area_count/(PAIRS_PER_ROW*ROWS_PER_PAGE)) do
        table.insert(voucher_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(area_count/(PAIRS_PER_ROW*ROWS_PER_PAGE))))
        end
    
        if not silent then
            local t ={n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = {localize('ph_no_vouchers')}, colours = {G.C.UI.TEXT_LIGHT}, bump = true, scale = 0.6})}}
            }}
            return t
        end
        INIT_COLLECTION_CARD_ALERTS()
        -- create_UIBox_generic_options IS USELESS
        t={n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
            {n=G.UIT.R, config={align = "cm"}, nodes={
              {n=G.UIT.O, config={object = DynaText({string = {localize('ph_vouchers_redeemed')}, colours = {G.C.UI.TEXT_LIGHT}, bump = true, scale = 0.6})}}
            }},
            {n=G.UIT.R, config={align = "cm", minh = 0.5}, nodes={
            }},
            {n=G.UIT.R, config={align = "cm", colour = G.C.BLACK, r = 1, padding = 0.15, emboss = 0.05}, nodes={
              {n=G.UIT.R, config={align = "cm"}, nodes=voucher_rows},
            }},
            {n=G.UIT.R, config={align = "cm"}, nodes={
                create_option_cycle({options = voucher_options, w = 4.5, cycle_shoulders = true, opt_callback = 'used_voucher_page', focus_args = {snap_to = true, nav = 'wide'}, current_option = 1, colour = G.C.RED, no_pips = true})
            }}
          }}
        return t
    end

    
    G.FUNCS.used_voucher_page = function(args)
        -- warning: the meanings of variables below are different from the original functions
        if not args or not args.cycle_config then return end
        local keys_used = {}
        -- originally its structure is {first pair:{fp.first,fp.second}, second pair:{}, third pair:{tp.first}} means you have redeemed both of first pair and neither of second pair and the first one of the third pair
        local vouchers_used = {}
        local area_count = 0
        local voucher_areas = {}
        local voucher_pairs = {}
        local voucher_rows = {}
        for k, v in ipairs(G.P_CENTER_POOLS["Voucher"]) do
        local key = 1 + math.floor((k-0.1)/2)
        keys_used[key] = keys_used[key] or {}
        if G.GAME.used_vouchers[v.key] then 
            keys_used[key][#keys_used[key]+1] = v
            table.insert(vouchers_used,v)
            silent=true
        end
        end
        local keys_used2={}
        for k, v in ipairs(keys_used) do 
        if next(v) then
            area_count = area_count + 1
            table.insert(keys_used2,v)
        end
        end
        keys_used=keys_used2
        -- at this time it only includes pairs you've at least redeemed one of both
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards,1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end
        for i = 1, #G.your_collection do
            v=keys_used[PAIRS_PER_ROW*ROWS_PER_PAGE*(args.cycle_config.current_option - 1)+i]
            if not v then break end
            for j = 1, #v do
                local center = v[j]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                card:start_materialize(nil, i>1 or j>1)
                G.your_collection[i]:emplace(card)
            end
        end
        INIT_COLLECTION_CARD_ALERTS()
    end

----------------------------------------------
------------MOD CODE END----------------------