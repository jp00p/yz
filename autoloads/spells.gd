extends Node

enum HANDS {
    ONES,
    TWOS,
    THREES,
    FOURS,
    FIVES,
    SIXES,
    PAIR,
    TWO_PAIR,
    THREE_OF_A_KIND,
    FOUR_OF_A_KIND,
    FULL_HOUSE,
    SM_STRAIGHT,
    LG_STRAIGHT,
    YAHTZEE,
    CHANCE
}

func hand_name(hand:int):
    return HANDS.keys()[hand].capitalize()

enum EFFECTS {
    DAMAGE,
    HEAL,
    BLOCK,
    POISON,
}

var ONES = {
    "Strike": {
        "name": "Strike",
        "description": "Deals a little damage",
        "hand":HANDS.ONES,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
    "Block": {
        "name": "Block",
        "description": "Adds a little defense",
        "hand":HANDS.ONES,
        "effects": [
            [EFFECTS.BLOCK, "x.score"]
        ]
    },
    "Poison": {
        "name": "Poison",
        "description": "Adds 1 stack of poison",
        "hand":HANDS.ONES,
        "effects": [
            [EFFECTS.POISON, "1"]
        ]
    },
    "Heal": {
        "name": "Heal",
        "description": "Heals a little",
        "hand":HANDS.ONES,
        "effects": [
            [EFFECTS.HEAL, "x.score"]
        ]
    }
}

var TWOS = {
    "Dual Strike": {
        "name": "Toxic gas", # name of spell
        "description": "Deals damage and has a chance to poison", # description of spell
        "hand":HANDS.TWOS, # what yahtzee hand it corresponds to
        "effects": [
            [EFFECTS.DAMAGE, "x.score"], # does damage equal to the yahtzee score (total of all 2s)
            [EFFECTS.POISON, "1", "chance(0.5)"], # 50% chance to add poison
        ]
    },
    "Helping hand": {
        "name": "Healing ward",
        "description": "Heals you, has a chance to add block",
        "hand":HANDS.TWOS,
        "effects": [
            [EFFECTS.HEAL, "half(x.score)"], # heals you for half the yahtzee score
            [EFFECTS.BLOCK, "half(x.score)", "chance(0.5)"], # 50% chance to add block
        ]
    },
    "Gemini beam": {
        "name": "Gemini beam",
        "description": "Two beams that get stronger over time",
        "hand":HANDS.TWOS,
        "effects": [
            [EFFECTS.DAMAGE, "x.score + (x.times_cast % 2)"], # deals 1 more damage every 2 times you cast this spell
        ]
    }
}

var THREES = {
    "Three Strike": {
        "name": "Three Strike",
        "description": "Deals a little damage",
        "hand":HANDS.THREES,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var FOURS = {
    "Four Strike": {
        "name": "Four Strike",
        "description": "Deals a little damage",
        "hand":HANDS.FOURS,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var FIVES = {
    "Five Strike": {
        "name": "Five Strike",
        "description": "Deals a little damage",
        "hand":HANDS.FIVES,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var SIXES = {
    "Six Strike": {
        "name": "Six Strike",
        "description": "Deals a little damage",
        "hand":HANDS.SIXES,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var PAIR = {
    "Pair Strike": {
        "name": "Pair Strike",
        "description": "Deals a little damage",
        "hand":HANDS.PAIR,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var TWO_PAIR = {
    "Two Pair Strike": {
        "name": "Two Pair Strike",
        "description": "Deals a little damage",
        "hand":HANDS.TWO_PAIR,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var THREE_OF_A_KIND = {
    "Three Oak": {
        "name": "Three Oak",
        "description": "Deals a little damage",
        "hand":HANDS.THREE_OF_A_KIND,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var FULL_HOUSE = {
    "Full Strike": {
        "name": "Full Strike",
        "description": "Deals a little damage",
        "hand":HANDS.FULL_HOUSE,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var SM_STRAIGHT = {
    "Small Straight": {
        "name": "Small Straight",
        "description": "Deals a little damage",
        "hand":HANDS.SM_STRAIGHT,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var LG_STRAIGHT = {
    "Large Straight": {
        "name": "Large Straight",
        "description": "Deals a little damage",
        "hand":HANDS.SM_STRAIGHT,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"]
        ]
    },
}

var YAHTZEE = {
    "Hand of Yahtzara": {
        "name": "Hand of Yahtzara",
        "description": "A huge magic hand comes down to assist you",
        "hand":HANDS.YAHTZEE,
        "effects": [
            [EFFECTS.DAMAGE, "x.score"],
            [EFFECTS.BLOCK, "10"],
            [EFFECTS.HEAL, "10"]
        ]
    }
}

var CHANCE = {
    "Wild Magic": {
        "name": "Wild Magic",
        "description": "Unpredictable magic",
        "hand":HANDS.CHANCE,
        "effects": [
            [EFFECTS.DAMAGE, "x.score", "chance(0.33)"],
            [EFFECTS.BLOCK, "x.score", "chance(0.33)"],
            [EFFECTS.HEAL, "x.score", "chance(0.33)"],
            [EFFECTS.POISON, "5", "chance(0.33)"]
        ]
    }
}

var ALL_SPELLS = {}

func _ready():
    ALL_SPELLS.merge(ONES)
    ALL_SPELLS.merge(TWOS)
    ALL_SPELLS.merge(THREES)
    ALL_SPELLS.merge(FOURS)
    ALL_SPELLS.merge(FIVES)
    ALL_SPELLS.merge(SIXES)
    ALL_SPELLS.merge(PAIR)
    ALL_SPELLS.merge(TWO_PAIR)
    ALL_SPELLS.merge(THREE_OF_A_KIND)
    ALL_SPELLS.merge(FULL_HOUSE)
    ALL_SPELLS.merge(SM_STRAIGHT)
    ALL_SPELLS.merge(LG_STRAIGHT)
    ALL_SPELLS.merge(YAHTZEE)
    ALL_SPELLS.merge(CHANCE)

