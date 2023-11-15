extends Node

enum EFFECTS {
    DAMAGE,
    HEAL,
    BLOCK,
    POISON,
}

enum TARGETS {
    PLAYER,
    ENEMY,
}

enum TRIGGERS {
    PASSIVE,
    START_OF_COMBAT,
    START_OF_TURN,
    END_OF_TURN,
    END_OF_COMBAT,
    ON_SPELL_CAST,
    ON_ROLL
}

enum DURATION {
    ONCE,
    FOREVER,
}
