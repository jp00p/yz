extends Node

var YAHTZEE_SCORE = 50
var FULL_HOUSE_SCORE = 25
var SM_STRAIGHT_SCORE = 30
var LG_STRAIGHT_SCORE = 40

func wait(time=1.0):
    var timer = get_tree().create_timer(time, false)
    await timer.timeout

func sum(arr=[], die=false):
    var total = 0
    for i in arr:
        if not die:
            total += i
        else:
            total += i.value
    return total

func generate_combinations(data, start, length, current_combination, result):
    if current_combination.size() == length:
        result.append(current_combination.duplicate())
        return

    for i in range(start, data.size()):
        current_combination.append(data[i])
        generate_combinations(data, i + 1, length, current_combination, result)
        current_combination.pop_back()

func get_combinations(data, length):
    var result = []
    var current_combination = []
    generate_combinations(data, 0, length, current_combination, result)
    return result

func results(dice, score) -> Dictionary:
    return { "dice": dice, "score": score }

func generate_hands(dice_array) -> Dictionary:

    var basic_hands = [
        Spells.HANDS.ONES,
        Spells.HANDS.TWOS,
        Spells.HANDS.THREES,
        Spells.HANDS.FOURS,
        Spells.HANDS.FIVES,
        Spells.HANDS.SIXES,
    ]

    # conditions = {
    #   Spells.HANDS.ONES: [
    #       { "dice":[], "score":0 },
    #       { "dice":[], "score":0 }
    #       { "dice":[], "score":0 }
    #   ]
    # }

    var conditions = {} # the final results
    var dice_counts = {}  # dice values and their counts
    var included_dice = {}  # included dice for each condition

    # count the occurrences of each dice value
    for dice in dice_array:
        var value = dice.value
        if value not in dice_counts:
            dice_counts[value] = 0
        dice_counts[value] += 1
        if value not in included_dice:
            included_dice[value] = []
        included_dice[value].append(dice)

    # check for one or more of a single number
    # these are the basic yahtzee hands (top rows)
    # each hand here is worth the sum of the included dice
    for value in dice_counts.keys():
        var count = dice_counts[value]
        if count >= 1:

            var i = value - 1
            var number_label = basic_hands[i]
            var included_for_this_hand = []
            conditions[number_label] = [] # add to conditions dict

            for dice in included_dice[value]:
                included_for_this_hand.append(dice)
            var basic_hand_score = sum(included_for_this_hand, true)
            # add to the final conditions dict
            conditions[number_label].append(results(included_for_this_hand, basic_hand_score))

    # more advanced hand checks start here
    var pair_values = []
    var three_of_a_kind_values = []
    conditions[Spells.HANDS.PAIR] = []

    for value in dice_counts.keys():
        var count = dice_counts[value] # how many of these dice are there
        if count >= 2:
            if count == 2: # is it ONLY one pair?
                pair_values.append(value)
                var included = []
                for dice in included_dice[value]:
                    included.append(dice)
                var pair_score = included[0].value + included[1].value
                conditions[Spells.HANDS.PAIR].append(results(included, pair_score))
            else:
                # if there's more than one pair
                # things get more complicated
                var combinations = get_combinations(included_dice[value], 2)
                for combo in combinations:
                    if combo.size() > 1:
                        var pair_score = combo[0].value + combo[1].value
                        conditions[Spells.HANDS.PAIR].append(results(combo, pair_score))

        if count >= 3:
            # check for three of a kind
            three_of_a_kind_values.append(value)
            conditions[Spells.HANDS.THREE_OF_A_KIND] = []
            var combinations = get_combinations(included_dice[value], 3)
            for combo in combinations:
                var combo_score = sum(dice_array, true)
                conditions[Spells.HANDS.THREE_OF_A_KIND].append(results(combo, combo_score)) # 3oak is worth all the dice summed up

            if count >= 4:
                conditions[Spells.HANDS.FOUR_OF_A_KIND] = []
                var four_oak_score = sum(dice_array, true)
                conditions[Spells.HANDS.FOUR_OF_A_KIND].append(results(included_dice[value], four_oak_score)) # 4oak is worth all the dice summed up
                if count == 5:
                    # YAHTZEE!!!
                    conditions[Spells.HANDS.YAHTZEE] = []
                    conditions[Spells.HANDS.YAHTZEE].append(results(included_dice[value], YAHTZEE_SCORE))

    if pair_values.size() >= 2:
        pass
        #var combinations = get_combinations(pair_values, 2)
        #for combo in combinations:
        #    var included_pairs = []
        #    for value in combo:
        #        included_pairs += included_dice[value]
        #        conditions[Spells.HANDS.TWO_PAIR]["dice"].append(included_pairs)
        # not using TWO_PAIR right now

    if three_of_a_kind_values.size() >= 1 and pair_values.size() >= 1:
        conditions[Spells.HANDS.FULL_HOUSE] = []
        var combinations = get_combinations(three_of_a_kind_values, 1)
        var full_house_combinations = get_combinations(pair_values, 1)
        for three_of_a_kind_combo in combinations:
            for pair_combo in full_house_combinations:
                var included_three = []
                var included_two = []
                for value in three_of_a_kind_combo:
                    included_three += included_dice[value]
                for value in pair_combo:
                    included_two += included_dice[value]
                var all_included_dice = included_three + included_two
                conditions[Spells.HANDS.FULL_HOUSE].append(results(all_included_dice, FULL_HOUSE_SCORE))

    # check for all possible small straights
    var distinct_values = dice_counts.keys()
    distinct_values.sort()
    for i in range(len(distinct_values) - 3):
        var is_straight = true
        for j in range(i, i + 4):
            if len(distinct_values) > j + 1:
                if distinct_values[j] + 1 != distinct_values[j + 1]:
                    is_straight = false
                    break

        if is_straight:
            conditions[Spells.HANDS.SM_STRAIGHT] = []
            var included = []
            for j in range(i, i + 4):
                included += included_dice[distinct_values[j]]
            conditions[Spells.HANDS.SM_STRAIGHT].append(results(included, SM_STRAIGHT_SCORE))

    # check for all possible large straights
    if len(distinct_values) == 5 and distinct_values[4] - distinct_values[0] == 4:
        conditions[Spells.HANDS.LG_STRAIGHT] = []
        var included = []
        for value in distinct_values:
            included += included_dice[value]
        conditions[Spells.HANDS.LG_STRAIGHT].append(results(included, LG_STRAIGHT_SCORE))

    # add chance (all dice)
    var chance_score = sum(dice_array, true)
    conditions[Spells.HANDS.CHANCE] = []
    conditions[Spells.HANDS.CHANCE].append(results(dice_array, chance_score))

    if conditions[Spells.HANDS.PAIR].size() == 0:
        conditions.erase(Spells.HANDS.PAIR)

    return conditions

func debug_hands(hand):
    print("--- HANDS ------------------------------ ")
    for h in hand.keys():
        var handname = Spells.hand_name(h)
        for result in hand[h]:
            var dice_values = []
            var score = result["score"]
            for d in result["dice"]:
                dice_values.append(d.value)
            print("ID: %2d %12s Score: %2s Dice: %s" % [h, handname, score, dice_values])
    print("--------------------------------------- ")
