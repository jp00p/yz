class_name Spell extends Node

signal cast_spell(spell:Spell)
signal scores_changed
signal preparation_changed

var caster:Entity
var scores:Array = [] : set = set_scores
var effects:Array = []
var hand:int
var has_cast:bool = false
var icon:String = "S_Buff07.png"
# spells have two components, the dice and the score
var components:Array = [] : set = set_components
var effect:int = Spells.EFFECTS.DAMAGE
var times_cast:int = 0
var spell_name:String = ""
var prepared = false : set = set_prepared
var description = ""
var score:int = 0

func _init(spellname:String=""):
    spell_name = Spells.ALL_SPELLS[spellname]["name"]
    hand = Spells.ALL_SPELLS[spellname]["hand"]
    effects = Spells.ALL_SPELLS[spellname]["effects"]
    description = Spells.ALL_SPELLS[spellname]["description"]

func set_scores(val):
    scores = val
    self.score = scores[0]
    scores_changed.emit()

func get_scores_label():
    if scores.size() > 1 and scores[0] != scores[-1]:
        return ("%d - %d" % [scores[0], scores[-1]])
    return("%d" % scores[0])

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
    components = val
    var new_scores = []
    for c in components:
        new_scores.append(c["score"])
    new_scores.sort()
    self.scores = new_scores

func cast(target:Entity) -> void:
    var outputs = []
    self.has_cast = true
    self.times_cast += 1
    Globals.set_score.emit(hand, score)
    # determine dice modifiers
    # determine spell effects and their totals
    for effect in effects:
        var effect_name = effect[0] # from the effects enum
        var effect_formula = effect[1] # the formula used to calculate the output
        var effect_check = null
        var effect_condition = true # if the effect has a condition this can be overriden

        if len(effect) > 2: # is there a condition for this effect?
            effect_check = effect[2]
            var condition_check = Expression.new()
            condition_check.parse(effect_check, ["x"])
            effect_condition = condition_check.execute([self], self)

        if effect_condition:
            var mod = Expression.new()
            var error = mod.parse(effect_formula, ["x"]) # eval the effect formula
            var output_total = mod.execute([self], self) # how much total damage/healing/etc
            outputs.append([effect_name, output_total])

    for output in outputs:
        # now we have all the outputs of our spell, actually do the stuff
        match output[0]:
            Spells.EFFECTS.DAMAGE:
                print("Target %s takes %s damage!" % [target.name, output[1]])
                await target.take_damage(output[1], 0)

            Spells.EFFECTS.HEAL:
                print("Caster gets healed!")
                await caster.heal(output[1])

            Spells.EFFECTS.POISON:
                print("Target gets poisoned!")
                await target.add_poison(output[1])

            Spells.EFFECTS.BLOCK:
                print("Caster gets some block!")
                await caster.add_block(output[1])
