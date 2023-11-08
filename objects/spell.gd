class_name Spell extends Node

signal cast_spell(spell:Spell)
signal score_changed
signal score_has_range(range_text)
signal preparation_changed

var caster:Entity
var score:int = 0 : set = set_score
var score_range:Array = []
var effects:Array = []
var label:String = ""
var hand:int
var has_cast:bool = false
var icon:String = "S_Buff07.png"
# spells have two components, the dice and the score
var components:Dictionary = {} : set = set_components
var effect:int = Globals.SPELL_EFFECTS.DAMAGE_ENEMY
var times_cast:int = 0
var spell_name:String = ""
var prepared = false : set = set_prepared
var description = ""

func _init(spellname:String=""):
    spell_name = Spells.ALL_SPELLS[spellname]["name"]
    hand = Spells.ALL_SPELLS[spellname]["hand"]
    effects = Spells.ALL_SPELLS[spellname]["effects"]
    description = Spells.ALL_SPELLS[spellname]["description"]

func set_score(val):
    score = val
    score_changed.emit()
    var score_copy = components["score"].duplicate()
    # score could be a range, so show [x-y] on the label
    score_copy.sort()
    if score_copy.size() > 1 and score_copy[0] != score_copy[-1]:
        var range_text = str(score_copy[0]) + "-" + str(score_copy[-1])
        score_has_range.emit(range_text)

func set_prepared(val):
    prepared = val
    preparation_changed.emit()

func half(val) -> int:
    return floori(val * 0.5)

func double(val) -> int:
    return floori(val * 2)

func chance(prob:float):
    return randf() > prob

func set_components(val) -> void:
    # since a hand could be comprised of several sets of dice
    # the spell needs to handle showing a range of possible scores
    # when the spell is cast, there will only be one set of components left
    # since the player has chosen their selected dice
    # so score[0] is the final score
    components = val
    if components.size() > 0:
        self.score = components["score"][0]

func cast(target:Entity) -> void:
    var outputs = []
    self.times_cast += 1
    # determine dice modifiers
    # determine spell effects and their totals
    print("Casting spell")
    for effect in effects:
        var effect_name = effect[0] # from the effects enum
        var effect_formula = effect[1] # the formula used to calculate the output
        var effect_check = null
        var effect_condition = true # if the effect has a condition this can be overriden
        print("EFFECT SIZE: %s" % len(effect))
        print("SPELL EFFECT NAME: %s  FORMULA: %s" % [effect_name, effect_formula])

        if len(effect) > 2: # is there a condition for this effect?
            effect_check = effect[2]
            var condition_check = Expression.new()
            condition_check.parse(effect_check, ["x"])
            print("CONDITION: %s" % effect[2])
            effect_condition = condition_check.execute([self], self)

        print("EFFECT CONDITION: %s" % effect_condition)

        if effect_condition:
            var mod = Expression.new()
            var error = mod.parse(effect_formula, ["x"]) # eval the effect formula
            var output_total = mod.execute([self], self) # how much total damage/healing/etc
            print("SPELL OUTPUT: %s" % output_total)
            outputs.append([effect_name, output_total])

    print(outputs)

    for output in outputs:
        # now we have all the outputs of our spell, actually do the stuff
        match output[0]:
            Spells.EFFECTS.DAMAGE:
                target.take_damage(output[1], 0)
                print("Target %s takes %s damage!" % [target.name, output[1]])
            Spells.EFFECTS.HEAL:
                caster.heal(output[1])
                print("Caster gets healed!")
            Spells.EFFECTS.POISON:
                target.add_poison(output[1])
                print("Target gets poisoned!")
            Spells.EFFECTS.BLOCK:
                caster.add_block(output[1])
                print("Caster gets some block!")
