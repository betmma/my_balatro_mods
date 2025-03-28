return {
    descriptions = {
        Enhanced = {
            ellipsis={text={'{C:inactive}(#1# abilities omitted)'}},
            multiples={text={'{C:inactive}(X#1#)'}},
            real_random_chip={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for {C:chips}+#2#{} Chips"
                }
            },
            real_random_mult={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for {C:mult}+#2#{} Mult"
                }
            },
            real_random_x_mult={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for {X:red,C:white}X#2#{} Mult"
                }
            },
            real_random_dollars={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "to win {C:money}$#2#"
                }
            },
            real_random_joker_slot={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for {C:attention}+#2#{} Joker slot"
                },
            },
            real_random_consumable_slot={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for {C:attention}+#2#{} Consumable slot"
                },
            },
            real_random_random_voucher={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for a random {C:attention}Voucher{}"
                },
            },
            real_random_random_negative_joker={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for a random {C:dark_edition}negative{} {C:attention}Joker{}"
                },
            },
            real_random_new_ability={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for a new ability"
                },
            },
            real_random_double_probability={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "to double all probabilities"
                },
            },
            real_random_random_tag={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "for a random {C:attention}tag{}"
                },
            },
            real_random_retrigger_next={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "to retrigger the card",
                    "to its right {C:attention}#2#{} times"
                },
            },
            real_random_hand_size={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "to {C:attention}+#2#{} hand size"
                },
            },
            real_random_transfer_ability={
                text={
                    "{C:green}#1# in #3#{} chance",
                    "to transfer an ability",
                    "to the card to its right"
                },
            }
        },
        Other = {
            perishable_no_debuff = {
                name = "Perishable",
                text = {
                    "Debuffed after",
                    "{C:attention}#1#{} rounds"
                }
            }
        },
        Voucher = {
            v_betm_vouchers_oversupply = {
                name = "Oversupply",
                text = {
                    "Gain {C:attention}1{} {C:attention}Voucher Tag{}",
                    "after defeating {C:attention}Boss Blind{}",
                }
            },
            v_betm_vouchers_oversupply_plus = {
                name = "Oversupply Plus",
                text = {
                    "Gain {C:attention}1{} {C:attention}Voucher Tag{}",
                    "after defeating each {C:attention}Blind{}",
                }
            },
            v_betm_vouchers_gold_coin = {
                name = "Gold Coin",
                text = {
                    "Earn {C:money}$#1#{} immediately",
                    "{C:attention}Small Blind{} gives",
                    "no reward money",
                }
            },
            v_betm_vouchers_gold_bar = {
                name = "Gold Bar",
                text = {
                    "Earn {C:money}$#1#{} immediately",
                    "{C:attention}Big Blind{} gives",
                    "no reward money",
                }
            },
            v_betm_vouchers_abstract_art = {
                name = "Abstract Art",
                text = {
                    "{C:attention}+#1#{} Ante to win,",
                    "{C:blue}+#1#{} hand and",
                    "{C:red}+#1#{} discard per round",
                }
            },
            v_betm_vouchers_mondrian = {
                name = "Mondrian",
                text = {
                    "{C:attention}+#1#{} Ante to win,",
                    "{C:attention}+#1#{} Joker slot",
                }
            },
            v_betm_vouchers_round_up = {
                name = "Round Up",
                text = {
                    "{C:blue}Chips{} always round up",
                    "to nearest 10",
                }
            },
            v_betm_vouchers_round_up_plus = {
                name = "Round Up Plus",
                text = {
                    "{C:red}Mult{} always rounds up",
                    "to nearest 10",
                }
            },
            v_betm_vouchers_event_horizon = {
                name = "Event Horizon",
                text = {
                    "{C:green}#1# in #2#{} chance to",
                    "create a {C:spectral}Black Hole{} when",
                    "you open a {C:planet}Celestial Pack{}",
                    "Create {C:attention}2{} {C:dark_edition}Negative{}",
                    "{C:planet}Planet{} cards now",
                }
            },
            v_betm_vouchers_engulfer = {
                name = "Engulfer",
                text = {
                    "{C:green}#1# in #2#{} chance to",
                    "create a {C:spectral}Black Hole{}",
                    "when you use a {C:planet}Planet{} card",
                    "Create a {C:spectral}Black Hole{} now",
                    "{C:inactive}(Must have room)",
                }
            },
            v_betm_vouchers_target = {
                name = "Target",
                text = {
                    "If score is under",
                    "{C:attention}#1#%{} of required score",
                    "at end of round,",
                    "create a random {C:attention}Joker{}",
                    "{C:inactive}(Must have room)",
                }
            },
            v_betm_vouchers_bulls_eye = {
                name = "Bull's Eye",
                text = {
                    "If score is under",
                    "{C:attention}#1#%{} of required score",
                    "at end of round,",
                    "create a random",
                    "{C:dark_edition}Negative{} {C:attention}Joker{}",
                }
            },
            v_betm_vouchers_voucher_bundle = {
                name = "Voucher Bundle",
                text = {
                    "Redeem {C:attention}#1#{} random vouchers",
                }
            },
            v_betm_vouchers_voucher_bulk = {
                name = "Voucher Bulk",
                text = {
                    "Redeem {C:attention}#1#{} random vouchers",
                }
            },
            v_betm_vouchers_skip = {
                name = "Skip",
                text = {
                    "Earn {C:money}$#1#{} when you skip a {C:attention}Blind{}",
                }
            },
            v_betm_vouchers_skipper = {
                name = "Skipper",
                text = {
                    "Get a {C:attention}Double Tag{} when you skip a {C:attention}Blind{}",
                }
            },
            v_betm_vouchers_scrawl = {
                name = "Scrawl",
                text = {
                    "Gives {C:money}$#1#{} for each Joker you have,",
                    "then create {C:attention}Jokers{}",
                    "until Joker slots are full",
                }
            },
            v_betm_vouchers_scribble = {
                name = "Scribble",
                text = {
                    "Create {C:attention}#1#{} {C:dark_edition}Negative{}",
                    "{C:spectral}Spectral{} cards",
                }
            },
            v_betm_vouchers_reserve_area = {
                name = "Reserve Area",
                text = {
                    "You can reserve {C:tarot}Tarot{}",
                    "cards instead of using them",
                    "when opening an {C:tarot}Arcana Pack{}",
                }
            },
            v_betm_vouchers_reserve_area_plus = {
                name = "Reserve Area Plus",
                text = {
                    "You can reserve {C:spectral}Spectral{}",
                    "cards instead of using them",
                    "when opening a {C:spectral}Spectral Pack{}",
                    "Get an {C:attention}Ethereal Tag{} now",
                }
            },
            v_betm_vouchers_overkill = {
                name = "Overkill",
                text = {
                    "If score is above",
                    "{C:attention}#1#%{} of required score",
                    "at end of round, add",
                    "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{}, or",
                    "{C:dark_edition}Polychrome{} edition",
                    "to a random {C:attention}Joker",
                }
            },
            v_betm_vouchers_big_blast = {
                name = "Big Blast",
                text = {
                    "If score is above",
                    "{C:attention}#1#X{} required score",
                    "at end of round, add",
                    "{C:dark_edition}Negative{} edition to a",
                    "random {C:attention}Joker{}, and",
                    "increase this number by {C:attention}X#2#{}",
                    "{C:inactive}(Can override other editions){}",
                }
            },
            v_betm_vouchers_3d_boosters = {
                name = "3D Boosters",
                text = {
                    "{C:attention}+1{} Booster Pack",
                    "available in shop",
                }
            },
            v_betm_vouchers_4d_boosters = {
                name = "4D Boosters",
                text = {
                    "Rerolls apply to {C:attention}Booster Packs{}",
                    "Rerolled {C:attention}Booster Packs{}",
                    "cost {C:attention}$#1#{} more",
                }
            },
            v_betm_vouchers_b1g50 = {
                name = "B1G50%",
                text = {
                    "When you redeem a {C:attention}Voucher{},",
                    "{C:green}#1#%{} chance to redeem",
                    "a {C:attention}higher tier{} Voucher",
                    "and pay half its cost",
                    "{C:inactive}(This chance can't be doubled){}",
                    "{C:inactive}(B1G series can't give legendaries){}",
                }
            },
            v_betm_vouchers_b1g1 = {
                name = "B1G1",
                text = {
                    "When you redeem a",
                    "{C:attention}Voucher{}, always redeem",
                    "a {C:attention}higher tier{} Voucher",
                    "and pay its cost",
                }
            },
            v_betm_vouchers_collector = {
                name = "Collector",
                text = {
                    "Each {C:attention}Voucher{} redeemed reduces",
                    "Blind requirement by {C:attention}#1#%{}",
                    "{C:inactive}(multiplicative){}",
                }
            },
            v_betm_vouchers_connoisseur = {
                name = "Connoisseur",
                text = {
                    "If you have more than",
                    "{C:money}$#1#/(Vouchers redeemed + 1){}",
                    "{C:inactive}(Currently {C:money}$#2#{C:inactive}){}, redeeming",
                    "a voucher gives {C:dark_edition}Antimatter{}",
                    "and {C:attention}X#3#{} to requirement",
                }
            },
            v_betm_vouchers_flipped_card = {
                name = "Flipped Card",
                text = {
                    "You can {C:attention}flip{} up to #1# cards",
                    "once before playing each hand.",
                    "{C:attention}Flipped{} cards will return",
                    "to your hand after they are played",
                }
            },
            v_betm_vouchers_double_flipped_card = {
                name = "Double Flipped Card",
                text = {
                    "{C:attention}Flipped{} cards are",
                    "held in hand when scoring and",
                    "can trigger held-in-hand effects",
                }
            },
            v_betm_vouchers_prologue = {
                name = "Prologue",
                text = {
                    "When Blind begins, create",
                    "an {C:attention}Eternal{} {C:tarot}Tarot{} card",
                    "This card disappears when a",
                    "new Prologue card is created",
                    "{C:inactive}(Must have room)",
                }
            },
            v_betm_vouchers_epilogue = {
                name = "Epilogue",
                text = {
                    "{C:attention}+1{} consumable slot",
                    "When blind ends, create an",
                    "{C:attention}Eternal{} {C:spectral}Spectral{} card",
                    "This card disappears when a",
                    "new Epilogue card is created",
                    "{C:inactive}(Must have room)",
                }
            },
            v_betm_vouchers_bonus_plus = {
                name = "Bonus+",
                text = {
                    "Permanently increase",
                    "{C:blue}Bonus Card{} bonus",
                    "by {C:blue}+#1#{} extra chips",
                    "{C:inactive}(+30 -> +#2#){}",
                }
            },
            v_betm_vouchers_mult_plus = {
                name = "Mult+",
                text = {
                    "Permanently increase",
                    "{C:red}Mult Card{} bonus",
                    "by {C:red}+#1#{} Mult",
                    "{C:inactive}(+4 -> +#2#){}",
                }
            },
            v_betm_vouchers_omnicard = {
                name = "Omnicard",
                text = {
                    "{C:attention}Wild Cards{} can't be",
                    "debuffed. Retrigger",
                    "all {C:attention}Wild Cards{}",
                }
            },
            v_betm_vouchers_bulletproof = {
                name = "Bulletproof",
                text = {
                    "{C:attention}Glass Cards{} lose {X:mult,C:white}X#1#{}",
                    "instead of breaking",
                    "They break when",
                    "they reach {X:mult,C:white}X#2#{}",
                }
            },
            v_betm_vouchers_cash_clutch = {
                name = "Cash Clutch",
                text = {
                    "Earn an extra {C:money}$#1#{}",
                    "per remaining {C:blue}Hand",
                    "at end of round",
                }
            },
            v_betm_vouchers_inflation = {
                name = "Inflation",
                text = {
                    "Earn an extra {C:money}$#1#{}",
                    "per remaining {C:blue}Hand",
                    "at end of round",
                }
            },
            v_betm_vouchers_eternity = {
                name = "Eternity",
                text = {
                    "Shop can have {C:attention}Eternal{} Jokers",
                    "{C:attention}Eternal{} Jokers have a {C:green}#1#%{}",
                    "chance to be {C:dark_edition}Negative{}",
                    "{C:inactive}(This chance can't be doubled){}",
                }
            },
            v_betm_vouchers_half_life = {
                name = "Half-life",
                text = {
                    "Shop can have {C:attention}Perishable{} Jokers",
                    "{C:attention}Perishable{} Jokers only",
                    "take up {C:attention}#1#{} Joker slots",
                }
            },
            v_betm_vouchers_debt_burden = {
                name = "Debt Burden",
                text = {
                    "Shop can have {C:attention}Rental{} Jokers",
                    "{C:attention}Rental{} Jokers don't cost money",
                    "if you're in debt",
                    "Each {C:attention}Rental{} Joker increases",
                    "debt limit by {C:red}-$#1#{}",
                }
            },
            v_betm_vouchers_bobby_pin = {
                name = "Bobby Pin",
                text = {
                    "Shop can have {C:attention}Pinned{} Jokers",
                    "Each {C:attention}Pinned{} Joker copies",
                    "ability of {C:attention}Joker{} to the right",
                    "if itself {C:attention}isn't triggered{}",
                }
            },
            v_betm_vouchers_stow = {
                name = "Stow",
                text = {
                    "{C:dark_edition}+#1#{} Joker Slot",
                    "Leftmost Joker is debuffed",
                    "if Joker Slots are {C:attention}full",
                }
            },
            v_betm_vouchers_stash = {
                name = "Stash",
                text = {
                    "{C:dark_edition}+#1#{} Joker Slot",
                    "Rightmost Joker is debuffed if",
                    "there is {C:attention}1{} or {C:attention}no{} empty Joker Slot",
                }
            },
            v_betm_vouchers_undying = {
                name = "Undying",
                text = {
                    "When a non-{C:dark_edition}Phantom{} Joker is",
                    "destroyed, create a {C:dark_edition}Phantom{} copy",
                }
            },
            v_betm_vouchers_reincarnate = {
                name = "Reincarnate",
                text = {
                    "When a {C:dark_edition}Phantom{} Joker is sold,",
                    "create a Joker of the same {C:attention}rarity{}",
                }
            },
            v_betm_vouchers_bargain_aisle = {
                name = "Bargain Aisle",
                text = {
                    "First item in shop is {C:attention}free{}",
                }
            },
            v_betm_vouchers_clearance_aisle = {
                name = "Clearance Aisle",
                text = {
                    "First {C:attention}Booster Pack{} in shop is {C:attention}free{}",
                }
            },
            v_betm_vouchers_rich_boss = {
                name = "Rich Boss",
                text = {
                    "Boss Blinds give {C:money}$#1#{} more",
                }
            },
            v_betm_vouchers_richer_boss = {
                name = "Richer Boss",
                text = {
                    "Boss Blinds give {C:money}$#1#{} more per ante",
                }
            },
            v_betm_vouchers_gravity_assist = {
                name = "Gravity Assist",
                text = {
                    "When upgrading a poker hand,",
                    "also upgrade {C:attention}adjacent{} poker hands",
                }
            },
            v_betm_vouchers_gravitational_wave = {
                name = "Gravitational Wave",
                text = {
                    "When upgrading a poker hand, also upgrade",
                    "non-adjacent poker hands by {C:attention}#1#{} levels",
                }
            },
            v_betm_vouchers_garbage_bag = {
                name = "Garbage Bag",
                text = {
                    "You carry surplus {C:red}discards{} over rounds.",
                    "gain {C:red}#1#{} one-time discards",
                }
            },
            v_betm_vouchers_handbag = {
                name = "Handbag",
                text = {
                    "You carry surplus {C:blue}hands{} over rounds.",
                    "gain {C:blue}#1#{} one-time hands",
                }
            },
            v_betm_vouchers_echo_wall = {
                name = "Echo Wall",
                text = {
                    "{C:red}Discarding{} a card triggers",
                    "its {C:attention}end of round{} effect",
                }
            },
            v_betm_vouchers_echo_chamber = {
                name = "Echo Chamber",
                text = {
                    "{C:attention}Holding{} a card in each hand triggers",
                    "its {C:attention}end of round{} effect",
                }
            },
            v_betm_vouchers_laminator = {
                name = "Laminator",
                text = {
                    "When {C:attetntion}round ends{},",
                    "if {C:attention}leftmost{} joker has sticker,",
                    "{C:green}#1# in #2#{} chance to add random {C:attention}Edition",
                }
            },
            v_betm_vouchers_eliminator = {
                name = "Eliminator",
                text = {
                    "{C:attention}Remove{} all stickers",
                    "on {C:attention}Laminated{} Joker",
                }
            },
            v_betm_vouchers_gold_round_up = {
                name = "Gold Round Up",
                text = {
                    "Your {C:money}money{} always rounds up",
                    "to nearest even number",
                    "{C:inactive}(Round Up + Gold Coin){}",
                }
            },
            v_betm_vouchers_overshopping = {
                name = "Overshopping",
                text = {
                    "You can shop",
                    "after skipping a {C:attention}Blind{}",
                    "{C:inactive}(Overstock + Oversupply)",
                }
            },
            v_betm_vouchers_reroll_cut = {
                name = "Reroll Cut",
                text = {
                    "Rerolling {C:attention}Boss Blind{}",
                    "also rerolls tags, and",
                    "gives a random tag",
                    "{C:inactive}(Director's Cut + Reroll Surplus)",
                }
            },
            v_betm_vouchers_vanish_magic = {
                name = "Vanish Magic",
                text = {
                    "You can make playing cards",
                    "in the shop vanish and",
                    "earn {C:money}$#1#{} for each",
                    "{C:inactive}(Magic Trick + Blank)",
                }
            },
            v_betm_vouchers_darkness = {
                name = "Darkness",
                text = {
                    "{C:dark_edition}Negative{} cards",
                    "appear {C:attention}#1#X{} more often",
                    "{C:inactive}(Glow Up + Antimatter)",
                }
            },
            v_betm_vouchers_double_planet = {
                name = "Double Planet",
                text = {
                    "Create a random {C:planet}Planet{} card",
                    "when buying a {C:planet}Planet{} card",
                    "{C:inactive}(Must have room)",
                    "{C:inactive}(Planet Merchant + B1G50%)",
                }
            },
            v_betm_vouchers_trash_picker = {
                name = "Trash Picker",
                text = {
                    "{C:blue}+#1#{} hand and {C:red}+#1#{} discard per round",
                    "You can spend 1 hand to discard if",
                    "no discards left. {C:red}Discards{} {C:money}earn{}",
                    "as much as {C:blue}Hands{} at end of round",
                    "{C:inactive}(Grabber + Wasteful)",
                }
            },
            v_betm_vouchers_money_target = {
                name = "Money Target",
                text = {
                    "Earn double {C:money}interest{}",
                    "at end of round if your",
                    "money is a multiple of 5",
                    "{C:inactive}(Seed Money + Target){}",
                }
            },
            v_betm_vouchers_art_gallery = {
                name = "Art Gallery",
                text = {
                    "{C:attention}+#1#{} Ante to win",
                    "When {C:attention}Boss Blind{} is defeated,",
                    "randomly get {C:blue}+#1#{} hand,",
                    "{C:red}+#1#{} discard or {C:attention}-#1#{} Ante",
                    "{C:inactive}(Hieroglyph + Abstract Art){}",
                }
            },
            v_betm_vouchers_b1ginf = {
                name = "B1Ginf",
                text = {
                    "When you redeem a",
                    "{C:attention}Voucher{}, always redeem",
                    "all {C:attention}higher tier{} Vouchers",
                    "and pay their costs",
                    "{C:inactive}(Collector + B1G1){}",
                }
            },
            v_betm_vouchers_slate = {
                name = "Slate",
                text = {
                    "Permanently increase {C:attention}Stone Card{}",
                    "bonus by {C:blue}+#1#{} Chips",
                    "Select any number of {C:attention}Stone Cards{}",
                    "when playing a hand",
                    "{C:inactive}(Petroglyph + Bonus+){}",
                }
            },
            v_betm_vouchers_gilded_glider = {
                name = "Gilded Glider",
                text = {
                    "When a {C:attention}Gold Card{} gives money, if",
                    "the card to its right isn't enhanced,",
                    "transfer the {C:attention}Gold Card{} enhancement",
                    "from this card to that card",
                    "{C:inactive}(Gold Bar + Bonus+){}",
                }
            },
            v_betm_vouchers_mirror = {
                name = "Mirror",
                text = {
                    "When a {C:attention}Steel Card{} scores,",
                    "the card to its right",
                    "triggers one more time",
                    "{C:inactive}(Flipped Card + Omnicard){}",
                }
            },
            v_betm_vouchers_real_random = {
                name = "Real Random",
                text = {
                    "Randomize {C:attention}Lucky Card{} effects.",
                    "Create a {C:dark_edition}Negative{} {C:attention}Magician{}",
                    "when {C:attention}Blind{} begins",
                    "{C:inactive}(Crystal Ball + Omnicard){}",
                }
            },
            v_betm_vouchers_4d_vouchers = {
                name = "4D Vouchers",
                text = {
                    "Rerolls apply to {C:attention}Vouchers{},",
                    "but rerolled Vouchers",
                    "cost {C:attention}$#1#{} more",
                    "{C:inactive}(4D Boosters + Oversupply){}",
                }
            },
            v_betm_vouchers_recycle_area = {
                name = "Recycle Area",
                text = {
                    "You can {C:red}discard",
                    "your hand once when",
                    "opening a {C:tarot}Tarot Pack{}",
                    "or {C:spectral}Spectral Pack{}",
                    "{C:inactive}(Reserve Area + Wasteful){}",
                }
            },
            v_betm_vouchers_chaos = {
                name = "Chaos",
                text = {
                    "Same-type {C:attention}Enhancements{} can stack",
                    "{C:inactive}(Collector + Abstract Art){}",
                }
            },
            v_betm_vouchers_heat_death = {
                name = "Heat Death",
                text = {
                    "{C:attention}Eternal{} and {C:attention}Perishable{} can stack",
                    "Eternal Jokers give {C:dark_edition}+#1#{} Joker slot",
                    "when {C:attention}debuffed{} by Perishable",
                    "{C:inactive}(Eternity + Half-life){}",
                }
            },
            v_betm_vouchers_deep_roots = {
                name = "Deep Roots",
                text = {
                    "You earn {C:money}interest{} based on",
                    "the {C:attention}absolute value{} of your money",
                    "{C:inactive}(Seed Money + Debt Burden){}",
                }
            },
            v_betm_vouchers_solar_system = {
                name = "Solar System",
                text = {
                    "Retrigger {C:planet}Planet{} cards once",
                    "per {C:planet}Planet{} card held,",
                    "including the one being used",
                    "{C:inactive}(Planet Merchant + Event Horizon){}",
                }
            },
            v_betm_vouchers_forbidden_area = {
                name = "Forbidden Area",
                text = {
                    "When no consumable slots are left, buying or",
                    "reserving a {C:attention}consumable{} card moves it to",
                    "the {C:attention}Joker area{} and it acts like a Joker",
                    "{C:inactive}(Reserve Area + Undying){}",
                }
            },
            v_betm_vouchers_voucher_tycoon = {
                name = "Voucher Tycoon",
                text = {
                    "{C:attention}Vouchers{} appear in the shop",
                    "{C:inactive}(Oversupply + Planet Tycoon){}",
                }
            },
            v_betm_vouchers_cryptozoology = {
                name = "Cryptozoology",
                text = {
                    "Bought {C:attention}Jokers{} have a {C:dark_edition}#1#%{} chance",
                    "to have {C:dark_edition}Tentacle{} edition added",
                    "{C:inactive}(Crystal Ball + Undying){}",
                }
            },
            v_betm_vouchers_reroll_aisle = {
                name = "Reroll Aisle",
                text = {
                    "First {C:attention}item{} and {C:attention}Booster Pack{}",
                    "in shop are {C:attention}free{} after rerolls",
                    "{C:inactive}(Reroll Surplus + Clearance Aisle){}",
                }
            }
        }
    },
    misc = {
        challenge_names = {
            c_mod_testvoucher = 'TestVoucher'
        },
        dictionary = {
            k_fusion_voucher = 'Fusion Voucher',
            k_event_horizon_generate = "Event Horizon!",
            k_engulfer_generate = "Engulfer!",
            k_target_generate = "Target!",
            k_bulls_eye_generate = "Bull's Eye!",
            b_reserve = "RESERVE",
            k_transfer_ability = "Transfer!",
            k_overkill_edition = "Overkill!",
            k_big_blast_edition = "Big Blast!",
            b_flip_hand = "Flip",
            k_bulletproof = "Bulletproof!",
            b_vanish = "VANISH",
            k_heat_death = "Heat Death!",
            k_laminator = "Laminated!",
            k_undying = "Undying!",
            k_reincarnate = "Reincarnate!",
            k_solar_system = "Solar System!",
            over_retriggered = "Over-retriggered: ",
        }
    }
}
