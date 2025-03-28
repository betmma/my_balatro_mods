return{
    descriptions={
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
            v_betm_vouchers_oversupply={
                name = "供应过量",
                text = {
                    "击败{C:attention}Boss盲注{}后",
                    "获得{C:attention}1{}个{C:attention}奖券标签"
                }
            },
            v_betm_vouchers_oversupply_plus={
                name = "货源滚滚",
                text = {
                    "击败每个{C:attention}盲注{}后",
                    "获得{C:attention}1{}个{C:attention}奖券标签",
                }
            },
            v_betm_vouchers_gold_coin={
                name = "金币",
                text = {
                    "立即获得{C:money}$#1#",
                    "{C:attention}小盲注{}将失去奖励金"
                }
            },
            v_betm_vouchers_gold_bar={
                name = "金条",
                text = {
                    "立即获得{C:money}$#1#",
                    "{C:attention}大盲注{}将失去奖励金"
                }
            },
            v_betm_vouchers_abstract_art={
                name = "抽象艺术",
                text = {
                    "每回合出牌和弃牌次数各{C:blue}+#1#",
                    "赢下游戏需通关底注数{C:attention}+#1#",
                }
            },
            v_betm_vouchers_mondrian={
                name = "蒙德里安",
                text = {
                    "{C:attention}+#1#{}小丑牌槽位",
                    "赢下游戏需通关底注数{C:attention}+#1#",
                }
            },
            v_betm_vouchers_round_up={
                name = "凑个整儿",
                text = {
                    "出牌计分时",
                    "每次计入的{C:blue}筹码",
                    "均向上取整至十位数",
                }
            },
            v_betm_vouchers_round_up_plus={
                name = "凑个整儿 Plus版",
                text = {
                    "出牌计分时",
                    "每次计入的{C:red}倍率",
                    "均向上取整至十位数",
                }
            },
            v_betm_vouchers_event_horizon={
                name = "事件视界",
                text = {
                    "购买本奖券后即刻生成",
                    "{C:attention}2{}张随机的{C:dark_edition}负片{C:planet}星球牌",
                    "开启天体包时有{C:green}#1#/#2#{}的几率",
                    "生成一张{C:spectral}黑洞",
                }
            },
            v_betm_vouchers_engulfer={
                name = "万物终焉",
                text = {
                    "购买本奖券后",
                    "即刻生成一张{C:spectral}黑洞",
                    "使用{C:planet}星球牌{}时有{C:green}#1#/#2#{}的几率",
                    "生成一张{C:spectral}黑洞",
                    "{C:inactive}（必须有空位）",
                }
            },
            v_betm_vouchers_target={
                name = "射箭标靶",
                text = {
                    "若回合结束时的得分",
                    "为最低要求的{C:attention}#1#%{}或更低",
                    "随机生成一张{C:attention}小丑牌",
                    "{C:inactive}（必须有空位）",
                }
            },
            v_betm_vouchers_bulls_eye={
                name = "正中十环",
                text = {
                    "若回合结束时的得分",
                    "为最低要求的{C:attention}#1#%{}或更低",
                    "随机生成一张{C:dark_edition}负片{C:attention}小丑牌",
                    "{C:inactive}（必须有空位）",
                }
            },
            v_betm_vouchers_voucher_bundle={
                name = "奖券同捆包",
                text = {
                    "随机给予{C:attention}#1#{}张奖券",
                }
            },
            v_betm_vouchers_voucher_bulk={
                name = "奖券大捆包",
                text = {
                    "随机给予{C:attention}#1#{}张奖券",
                }
            },
            v_betm_vouchers_skip={
                name = "大步流星",
                text = {
                    "跳过{C:attention}盲注{}时",
                    "获得{C:money}$#1#",
                }
            },
            v_betm_vouchers_skipper={
                name = "乘风破浪",
                text = {
                    "跳过{C:attention}盲注{}时",
                    "获得一个{C:attention}双倍标签",
                }
            },
            v_betm_vouchers_scrawl={
                name = "狗爬字",
                text = {
                    "每有一张小丑牌给予{C:money}$#1#",
                    "并随机生成{C:attention}小丑牌",
                    "直至填满槽位",
                }
            },
            v_betm_vouchers_scribble={
                name = "胡写乱画",
                text = {
                    "生成{C:attention}#1#{}张",
                    "{C:dark_edition}负片{C:spectral}幻灵牌",
                }
            },
            v_betm_vouchers_reserve_area={
                name = "打包带走",
                text = {
                    "在{C:tarot}秘术包{}中选取的{C:tarot}塔罗牌",
                    "可存入消耗牌槽位",
                }
            },
            v_betm_vouchers_reserve_area_plus={
                name = "连吃带拿",
                text = {
                    "在{C:spectral}幻灵包{}中选取的{C:spectral}幻灵牌",
                    "可存入消耗牌槽位",
                    "且开启{C:spectral}幻灵包{}时",
                    "额外获得一个{C:attention}空灵标签",
                }
            },
            v_betm_vouchers_overkill={
                name = "用力过猛",
                text = {
                    "若回合结束时的得分",
                    "为最低要求的{C:attention}#1#%{}或更高",
                    "为随机一张{C:attention}小丑牌添加{C:dark_edition}闪箔{}、",
                    "{C:dark_edition}镭射{}或{C:dark_edition}多彩{}的其中一种",
                }
            },
            v_betm_vouchers_big_blast={
                name = "瞬间爆炸",
                text = {
                    "若回合结束时的得分",
                    "为最低要求的{C:attention}#1#倍{}或更高",
                    "为随机一张{C:attention}小丑牌添加{C:dark_edition}负片",
                    "并使上述倍数要求{C:attention}翻倍",
                    "{C:inactive,s:0.8}本奖券提供的负片",
                    "{C:inactive,s:0.8}可覆盖小丑牌的原有版本",
                }
            },
            v_betm_vouchers_3d_boosters={
                name = "三维堆叠",
                text = {
                    "商店中可供选购的",
                    "补充包数量{C:attention}+1",
                }
            },
            v_betm_vouchers_4d_boosters={
                name = "四维堆叠",
                text = {
                    "重掷会对{C:attention}补充包{}生效",
                    "但会使新的{C:attention}补充包{}价格上涨{C:attention}$#1#",
                }
            },
            v_betm_vouchers_b1g50={
                name = "第二张半价",
                text = {
                    "兑换{C:attention}奖券{}时有{C:green}#1#%{}的几率",
                    "直接获得它的{C:attention}高级{}版本",
                    "并支付其价格的一半",
                    "{C:inactive}（上述几率无法倍增）",
                    "{C:inactive}（本系列奖券无法给予传奇级奖券）",
                }
            },
            v_betm_vouchers_b1g1={
                name = "买一“赠”一",
                text = {
                    "兑换{C:attention}奖券{}时",
                    "直接获得它的{C:attention}高级{}版本",
                    "并支付全款",
                }
            },
            v_betm_vouchers_collector={
                name = "收集者",
                text = {
                    "每兑换一张{C:attention}奖券",
                    "使盲注的最低得分要求削减{C:attention}#1#%",
                    "{C:inactive}（叠乘）",
                }
            },
            v_betm_vouchers_connoisseur={
                name = "鉴赏家",
                text = {
                    "若拥有资金多于{C:money}$#1#/(兑换奖券数 + 1)",
                    "{C:inactive}（现为{C:money}$#2#{C:inactive}）",
                    "兑换奖券时将赠送{C:dark_edition}反物质",
                    "并使上述资金需求{C:attention}X#3#",
                }
            },
            v_betm_vouchers_flipped_card={
                name = "暗斗明争",
                text = {
                    "每次出牌前有一次机会",
                    "将至多#1#张牌{C:attention}翻面",
                    "{C:attention}背面朝上{}的卡牌",
                    "会在计分完毕后回到手中",
                }
            },
            v_betm_vouchers_double_flipped_card={
                name = "潜行伏击",
                text = {
                    "{C:attention}背面朝上{}的卡牌",
                    "将在手牌中参与计分",
                    "且可触发手牌中效果",
                    "{C:inactive}（如钢铁牌）",
                }
            },
            v_betm_vouchers_prologue={
                name = "前言",
                text = {
                    "盲注开局时",
                    "生成一张{C:attention}永恒{C:tarot}塔罗牌",
                    "{C:inactive}（必须有空位）",
                    "该牌会在本奖券",
                    "生成新牌时消失",
                }
            },
            v_betm_vouchers_epilogue={
                name = "后记",
                text = {
                    "消耗牌槽位{C:attention}+1",
                    "盲注结束时",
                    "生成一张{C:attention}永恒{C:spectral}幻灵牌",
                    "{C:inactive}（必须有空位）",
                    "该牌会在本奖券",
                    "生成新牌时消失",
                }
            },
            v_betm_vouchers_bonus_plus={
                name = "奖励+",
                text = {
                    "{C:blue}奖励牌{}的筹码加成",
                    "永久{C:blue}+#1#",
                    "{C:inactive}（+30 -> +#2#）",
                }
            },
            v_betm_vouchers_mult_plus={
                name = "倍率+",
                text = {
                    "{C:red}倍率牌{}的倍率加成",
                    "永久{C:red}+#1#",
                    "{C:inactive}（+4 -> +#2#）",
                }
            },
            v_betm_vouchers_omnicard={
                name = "全能卡",
                text = {
                    "{C:attention}百搭牌{}永不失效",
                    "且可重新触发",
                }
            },
            v_betm_vouchers_bulletproof={
                name = "防爆玻璃",
                text = {
                    "{C:attention}玻璃牌{}触发破碎时",
                    "只会损失{X:mult,C:white}X#1#{}倍率而非摧毁",
                    "仅在倍率低至{X:mult,C:white}X#2#{}时摧毁",
                }
            },
            v_betm_vouchers_cash_clutch={
                name = "稳攥不赔",
                text = {
                    "回合结束时",
                    "每个剩余的{C:blue}出牌次数",
                    "多折现{C:money}$#1#",
                }
            },
            v_betm_vouchers_inflation={
                name = "通货膨胀",
                text = {
                    "回合结束时",
                    "每个剩余的{C:blue}出牌次数",
                    "再多折现{C:money}$#1#",
                }
            },
            v_betm_vouchers_eternity={
                name = "亘古永恒",
                text = {
                    "商店中可能出现{C:attention}永恒{}小丑",
                    "{C:attention}永恒{}小丑有{C:green}#1#%{}的几率",
                    "同时拥有{C:dark_edition}负片",
                    "{C:inactive}（上述几率无法倍增）",
                }
            },
            v_betm_vouchers_half_life={
                name = "半衰期",
                text = {
                    "商店中会出现{C:attention}易腐{}小丑",
                    "{C:attention}易腐{}小丑牌仅占{C:attention}#1#{}个槽位",
                }
            },
            v_betm_vouchers_debt_burden={
                name = "债多压身",
                text = {
                    "商店中可能出现{C:attention}出租{}小丑牌",
                    "负债时，{C:attention}出租{}小丑牌不会扣减资金",
                    "每张{C:attention}出租{}小丑牌",
                    "可使负债上限提升{C:red}$#1#",
                }
            },
            v_betm_vouchers_bobby_pin={
                name = "铁丝发夹",
                text = {
                    "商店中可能出现{C:attention}左极固定{}小丑牌",
                    "每张{C:attention}左极固定{}小丑牌{C:attention}自身未触发{}时",
                    "复制其{C:attention}右侧{}小丑牌的能力",
                }
            },
            v_betm_vouchers_stow={
                name = "层叠堆放",
                text = {
                    "小丑牌槽位{C:dark_edition}+#1#",
                    "小丑牌槽位{C:attention}已满{}时",
                    "最左侧的小丑牌失效",
                }
            },
            v_betm_vouchers_stash={
                name = "箱中玄机",
                text = {
                    "小丑牌槽位{C:dark_edition}+#1#",
                    "小丑牌槽位{C:attention}已满{}或仅剩{C:attention}1{}个空位时",
                    "最右侧的小丑牌失效",
                }
            },
            v_betm_vouchers_undying={
                name = "不灭",
                text = {
                    "摧毁非{C:dark_edition}幽形{}小丑牌后",
                    "生成一张{C:dark_edition}幽形{}复制",
                }
            },
            v_betm_vouchers_reincarnate={
                name = "转世还魂",
                text = {
                    "售出{C:dark_edition}幽形{}小丑牌后",
                    "生成一张{C:attention}稀有度{}与之相同的小丑牌",
                }
            },
            v_betm_vouchers_bargain_aisle={
                name = "降价促销",
                text = {
                    "每个商店内的第一件商品",
                    "均为{C:attention}免费",
                }
            },
            v_betm_vouchers_clearance_aisle={
                name = "清仓处理",
                text = {
                    "每个商店内的第一个补充包",
                    "均为{C:attention}免费",
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
            v_betm_vouchers_gold_round_up={
                name = "凑个整儿 黄金版",
                text = {
                    "你的{C:money}资金{}永远",
                    "向上取至最近的偶数值",
                    "{C:inactive}（凑个整儿 + 金币）",
                }
            },
            v_betm_vouchers_overshopping={
                name = "究极购物狂",
                text = {
                    "跳过盲注后仍会进入商店",
                    "{C:inactive}（库存过剩 + 供应过量）",
                }
            },
            v_betm_vouchers_reroll_cut={
                name = "重掷剪辑版",
                text = {
                    "重掷Boss盲注时",
                    "跳关奖励标签也会刷新",
                    "并随机赠送一个标签",
                    "{C:inactive}（导演剪辑版 + 大量重掷）",
                }
            },
            v_betm_vouchers_vanish_magic={
                name = "消失术",
                text = {
                    "你可以消除商店中的扑克牌",
                    "每消除一张，获得{C:money}$#1#",
                    "{C:inactive}（戏法 + 空白）",
                }
            },
            v_betm_vouchers_darkness={
                name = "暗物质",
                text = {
                    "{C:dark_edition}负片{}牌出现频率{C:attention}X#1#",
                    "{C:inactive}（焕彩 + 反物质）",
                }
            },
            v_betm_vouchers_double_planet={
                name = "双行星系统",
                text = {
                    "购买{C:planet}星球牌{}时",
                    "随机生成一张{C:planet}星球牌",
                    "{C:inactive}（必须有空位）",
                    "{C:inactive}（星球牌商人 + 第二张半价）",
                }
            },
            v_betm_vouchers_trash_picker={
                name = "垃圾夹",
                text = {
                    "每回合{C:blue}出牌{}和{C:red}弃牌{}次数各{C:attention}+#1#",
                    "弃牌次数耗尽时",
                    "仍可消耗出牌次数继续弃牌",
                    "回合结束时，剩余{C:red}弃牌{}次数",
                    "的{C:money}折现价{}与{C:blue}出牌{}次数相等",
                    "{C:inactive}（抓手 + 常弃常新）",
                }
            },
            v_betm_vouchers_money_target={
                name = "百發百中",
                text = {
                    "若资金为5的倍数",
                    "则回合结束时{C:money}奖励{}翻倍",
                    "{C:inactive}（种子基金 + 射箭标靶）",
                }
            },
            v_betm_vouchers_art_gallery={
                name = "艺作画廊",
                text = {
                    "赢下游戏需通关底注数{C:attention}+#1#",
                    "击败{C:attention}Boss盲注{}时，随机获得：",
                    "出牌次数{C:blue}+#1#{}、弃牌次数{C:red}+#1#{}或底注{C:attention}-#1#",
                    "{C:inactive}（象形文字 + 抽象艺术）",
                }
            },
            v_betm_vouchers_b1ginf={
                name = "无限量批发",
                text = {
                    "兑换{C:attention}奖券{}时",
                    "直接获得它所有的{C:attention}高级{}版本",
                    "并支付全款",
                    "{C:inactive}（收集者 + 买一“赠”一）",
                }
            },
            v_betm_vouchers_slate={
                name = "神秘石板",
                text = {
                    "{C:attention}石头牌{}不计入出牌张数上限",
                    "且筹码加成永久{C:blue}+#1#",
                    "{C:inactive}（远古岩画 + 奖励+）",
                }
            },
            v_betm_vouchers_gilded_glider={
                name = "镶金滑翔机",
                text = {
                    "{C:attention}黄金牌{}给予资金时",
                    "若其右侧的卡牌没有增强",
                    "则将{C:attention}黄金{}增强转移至该卡牌",
                    "{C:inactive}（金条 + 倍率+）",
                }
            },
            v_betm_vouchers_mirror={
                name = "镜面反射",
                text = {
                    "{C:attention}钢铁牌{}计分时",
                    "重新触发其右侧的卡牌",
                    "{C:inactive}（暗斗明争 + 全能卡）",
                }
            },
            v_betm_vouchers_real_random={
                name = "真随机",
                text = {
                    "使{C:attention}幸运牌{}的效果随机化",
                    "盲注开局时生成一张{C:dark_edition}负片{C:attention}魔术师",
                    "{C:inactive}（水晶球 + 全能卡）",
                }
            },
            v_betm_vouchers_4d_vouchers={
                name = "四维奖券",
                text = {
                    "重掷会对{C:attention}奖券{}生效",
                    "但会使新的奖券价格上涨{C:attention}$#1#",
                    "{C:inactive}（四维堆叠 + 供应过量）",
                }
            },
            v_betm_vouchers_recycle_area={
                name = "喜新厌旧",
                text = {
                    "打开{C:tarot}秘术包{}或{C:spectral}幻灵包{}时",
                    "你可以{C:red}弃掉{}并重抽一手扑克牌",
                    "{C:inactive}（打包带走 + 常弃常新）",
                }
            },
            v_betm_vouchers_chaos={
                name = "杂七杂八",
                text = {
                    "同种{C:attention}增强{}可堆叠",
                    "{C:inactive}（收集者 + 抽象艺术）",
                }
            },
            v_betm_vouchers_heat_death={
                name = "热寂",
                text = {
                    "{C:attention}永恒{}和{C:attention}易腐{}可共存",
                    "同时拥有两者的小丑牌",
                    "因易腐而{C:attention}失效{}时",
                    "将提供{C:dark_edition}#1#{}个小丑牌槽位",
                    "{C:inactive}（亘古永恒 + 半衰期）",
                }
            },
            v_betm_vouchers_deep_roots={
                name = "财富根植",
                text = {
                    "{C:money}利息{}结算基于{C:money}资金{}的{C:attention}绝对值",
                    "{C:inactive}（种子基金 + 债多压身）",
                }
            },
            v_betm_vouchers_solar_system={
                name = "太阳系",
                text = {
                    "每拥有一张{C:planet}星球牌",
                    "（包含正在结算的）",
                    "使用的{C:planet}星球牌{}可重新触发一次",
                    "{C:inactive}（星球牌商人 + 事件视界）",
                }
            },
            v_betm_vouchers_forbidden_area={
                name = "禁区走私",
                text = {
                    "购买或保留{C:attention}消耗牌{}时，若槽位已满",
                    "则将其作为小丑牌放入{C:attention}小丑牌槽位",
                    "{C:inactive}（打包带走 + 不灭）",
                }
            },
            v_betm_vouchers_voucher_tycoon={
                name = "奖券大亨",
                text = {
                    "{C:attention}奖券{}会出现在商店的卡牌槽位中",
                    "{C:inactive}（供应过量 + 星球大亨）",
                }
            },
            v_betm_vouchers_cryptozoology={
                name = "玄奇异兽",
                text = {
                    "购得的{C:attention}小丑牌{}有{C:dark_edition}#1#%{}的几率",
                    "带有{C:dark_edition}触角{}版本",
                    "{C:inactive}（水晶球 + 不灭）",
                }
            },
            v_betm_vouchers_reroll_aisle={
                name = "连轴抛售",
                text = {
                    "在每个商店内重掷后",
                    "第一件{C:attention}商品{}和{C:attention}补充包",
                    "均为{C:attention}免费",
                    "{C:inactive}（大量重掷 + 清仓处理）",
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