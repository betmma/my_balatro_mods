return {
    descriptions = {
        Ability = {
            c_betmma_spell_switch = {
                name = 'Switch',
                text = {
                    "Flip current element",
                    "of selected spell",
                    'Cooldown: {C:mult}#1#/#2# #3#{}'
                }
            }
        },
        Spell = {
            c_betm_spells_dark = {
                name = "Dark",
                text = {
                    "{C:chips}+#1#{} chips",
                },
                before_desc = "2 different Dark suits"
            },
            c_betm_spells_light = {
                name = "Light",
                text = {
                    "{C:mult}+#1#{} Mult",
                },
                before_desc = "2 different Light suits"
            },
            c_betm_spells_earth = {
                name = "Earth",
                text = {
                    "{C:money}+$#1#{}",
                },
                before_desc = "2 same ranks"
            },
            c_betm_spells_air = {
                name = "Air",
                text = {
                    "{C:green}#1# in #2#{} chance to",
                    "copy second card",
                },
                before_desc = "2 different ranks with gap > 4"
            },
            c_betm_spells_water = {
                name = "Water",
                text = {
                    "{C:attention}Decrease{} rank of",
                    "second card by 1",
                },
                before_desc = "2 decreasing ranks x and x-1"
            },
            c_betm_spells_fire = {
                name = "Fire",
                text = {
                    "{C:attention}Destroy{} the second card",
                },
                before_desc = "2 increasing ranks x and x+1"
            },
            c_betm_spells_shadow = {
                name = "Shadow",
                text = {
                    "{X:mult,C:white}X#1#{} Mult",
                },
                before_desc = "1 Dark suit and 1 Light suit"
            },
            c_betm_spells_inferno = {
                name = "Inferno",
                text = {
                    "{C:attention}Destroy{} the third card",
                    "and {C:chips}+#1#{} chips",
                },
                before_desc = "2 ranks x, x+1, and a Dark suit"
            },
            c_betm_spells_abyss = {
                name = "Abyss",
                text = {
                    "{C:chips}+#1#*a{} chips where a",
                    "equals rank of third card",
                },
                before_desc = "2 ranks x, x-1, and a Dark suit"
            },
            c_betm_spells_cavern = {
                name = "Cavern",
                text = {
                    "{C:money}+$#1#{}",
                },
                before_desc = "2 same Dark suits"
            },
            c_betm_spells_smoke = {
                name = "Smoke",
                text = {
                    "{C:attention}Convert{} the second",
                    "card to {C:attention}#1#{}",
                },
                before_desc = "1 Dark suit and 1 not Dark suit"
            },
            c_betm_spells_radiance = {
                name = "Radiance",
                text = {
                    "{C:attention}Third card{} gains {C:mult}-#1#{} Mult,",
                    "{C:attention}other cards played{} gain {C:mult}+#2#{} Mult,",
                    "cards {C:attention}held in hand{} gain {C:mult}+#3#{} Mult",
                },
                before_desc = "2 ranks x, x+1, and a Light suit"
            },
            c_betm_spells_reflection = {
                name = "Reflection",
                text = {
                    "Change rank of {C:attention}third card{}",
                    "into {C:attention}first card",
                },
                before_desc = "3 Light suits X, Y and X"
            },
            c_betm_spells_crystal = {
                name = "Crystal",
                text = {
                    "Enhances {C:attention}second card{}",
                    "to {C:attention}Glass Card{}.",
                    "If already {C:attention}Glass Card{}, {C:money}+$#1#{}",
                },
                before_desc = "2 same Light suits"
            },
            c_betm_spells_halo = {
                name = "Halo",
                text = {
                    "{C:attention}Second card{} gains {C:mult}+#1#{} Mult",
                },
                before_desc = "1 Light suit and 1 not Light suit"
            },
            c_betm_spells_steam = {
                name = "Steam",
                text = {
                    "{X:mult,C:white}X#1#{} Mult, but cards in this hand",
                    "will be debuffed after {C:attention}#2#{} rounds",
                },
                before_desc = "3 ranks x, x+1, and x-1"
            },
            c_betm_spells_magma = {
                name = "Magma",
                text = {
                    "Change #1# unenhanced Cards",
                    "in deck into {C:attention}Gold Card{}",
                },
                before_desc = "4 ranks x, x, x+1, and x+1"
            },
            c_betm_spells_ember = {
                name = "Ember",
                text = {
                    "{C:attention}Destroy{} all played cards, and add",
                    "{C:attention}#1#{} copies of fourth card into deck",
                },
                before_desc = "2 odd ranks and 2 even ranks, alternatively"
            },
            c_betm_spells_mud = {
                name = "Mud",
                text = {
                    "Cards {C:attention}held in hand{}",
                    "gain {C:money}+$#1#{} when scored",
                },
                before_desc = "4 ranks x, x, x-1, and x-1"
            },
            c_betm_spells_dust = {
                name = "Dust",
                text = {
                    "Copy {C:attention}fourth card{} and gain {C:money}+$#1#{}",
                    "for each card copied by this spell",
                    "{C:inactive}(Currently {C:money}$#2#{C:inactive}){}",
                },
                before_desc = "4 ranks x, x, y and y, gap > 4"
            },
            c_betm_spells_cloud = {
                name = "Cloud",
                text = {
                    "Transfer permanent {C:attention}Bonuses{}",
                    "{C:inactive,s:0.8}(+chips, +Mult, +$)",
                    "from played cards to {C:attention}third card{}",
                },
                before_desc = "3 ranks x, x-2, and x-4"
            },
            c_betm_spells_ripple = {
                name = "Ripple",
                text = {
                    "{X:mult,C:white}X#1#{} Mult",
                },
                before_desc = "3 ranks x, x-1 and x"
            },
            c_betm_spells_lava = {
                name = "Lava",
                text = {
                    "Change first unenhanced Card",
                    "in hand into {C:attention}Gold Card{}.",
                    "{X:mult,C:white}X#1#{} Mult for each {C:attention}Gold Card{} in hand",
                },
                before_desc = "4 ranks x, x, Numbered and Numbered"
            }
        },
        Voucher = {
            v_betm_spells_magic_scroll = {
                name = 'Magic Scroll',
                text = {
                    "{C:attention}+#1#{} Spell Slot",
                }
            },
            v_betm_spells_magic_wheel = {
                name = 'Magic Wheel',
                text = {
                    "{C:attention}+#1#{} Spell Slot",
                    "You can spend {C:money}$#2#{} to reroll",
                    "the sequence of a Spell",
                }
            }
        }
    },
    misc = {
        dictionary = {
            b_spell_cards = "Spell Cards",
            k_spell = "Spell",
        }
    }
}
