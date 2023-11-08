extends Node

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

func check_dice_conditions(dice_array):

    var basic_hands = [
        Spells.HANDS.ONES,
        Spells.HANDS.TWOS,
        Spells.HANDS.THREES,
        Spells.HANDS.FOURS,
        Spells.HANDS.FIVES,
        Spells.HANDS.SIXES,
    ]

    var conditions = { # Dictionary to store all valid hands
        Spells.HANDS.PAIR: { "dice": [], "score": [] },
        #"Two pair": { "dice": [], "score": [] },
        Spells.HANDS.THREE_OF_A_KIND:{ "dice": [], "score": [] },
        Spells.HANDS.FOUR_OF_A_KIND:{ "dice": [], "score": [] },
        Spells.HANDS.FULL_HOUSE:{ "dice": [], "score": [] },
        Spells.HANDS.SM_STRAIGHT:{ "dice": [], "score": [] },
        Spells.HANDS.LG_STRAIGHT:{ "dice": [], "score": [] },
        Spells.HANDS.YAHTZEE:{ "dice": [], "score": [] },
        Spells.HANDS.CHANCE:{ "dice": [], "score": [] }
    }
    var dice_counts = {}  # Dictionary to store dice values and their counts
    var included_dice = {}  # Dictionary to store included dice for each condition

    # Count the occurrences of each dice value
    for dice in dice_array:
        var value = dice.value
        if value not in dice_counts:
            dice_counts[value] = 0
        dice_counts[value] += 1
        if value not in included_dice:
            included_dice[value] = []
        included_dice[value].append(dice)

    # Check for one or more of a single number
    # These are worth the sum of the dice with that number
    for value in dice_counts.keys():
        #print(dice_counts[value])
        var count = dice_counts[value]
        if count >= 1:
            var idx = value - 1
            var number_label = basic_hands[idx]
            conditions[number_label] = { "dice": [], "score": [] }
            var included = []
            for dice in included_dice[value]:
                included.append(dice)
            conditions[number_label]["dice"].append(included)
            conditions[number_label]["score"].append(sum(included, true))

    # Check for one pair, two pairs, three of a kind, four of a kind, full house, and Yahtzee
    var pair_values = []
    var three_of_a_kind_values = []

    for value in dice_counts.keys():
        var count = dice_counts[value]
        if count >= 2:
            if count == 2: # is it ONLY one pair?
                pair_values.append(value)
                var included = []
                for dice in included_dice[value]:
                    included.append(dice)
                conditions[Spells.HANDS.PAIR]["dice"].append(included)
                conditions[Spells.HANDS.PAIR]["score"].append(included[0].value + included[1].value) # one pair is worth the sum of the pair of dice
            else:
                # otherwise we gotta get all the combination of dice pairs
                var combinations = get_combinations(included_dice[value], 2)
                for combo in combinations:
                    if combo.size() > 1:
                        conditions[Spells.HANDS.PAIR]["dice"].append(combo)
                        conditions[Spells.HANDS.PAIR]["score"].append(combo[0].value + combo[1].value)

        if count >= 3:
            three_of_a_kind_values.append(value)
            var combinations = get_combinations(included_dice[value], 3)
            for combo in combinations:
                conditions[Spells.HANDS.THREE_OF_A_KIND]["dice"].append(combo)
                conditions[Spells.HANDS.THREE_OF_A_KIND]["score"].append(sum(dice_array, true)) # 3oak is worth all the dice summed up

            if count >= 4:
                conditions[Spells.HANDS.FOUR_OF_A_KIND]["dice"].append(included_dice[value])
                conditions[Spells.HANDS.FOUR_OF_A_KIND]["score"].append(sum(dice_array, true)) # 4oak is worth all the dice summed up
                if count == 5:
                    conditions[Spells.HANDS.YAHTZEE]["dice"].append(included_dice[value])
                    conditions[Spells.HANDS.YAHTZEE]["score"].append(50) # yahtzee is worth 50 score

    if pair_values.size() >= 2:
        var combinations = get_combinations(pair_values, 2)
        for combo in combinations:

            var included_pairs = []
            for value in combo:
                included_pairs += included_dice[value]
            #conditions[Spells.HANDS.TWO_PAIR]["dice"].append(included_pairs) # not using this right now

    if three_of_a_kind_values.size() >= 1 and pair_values.size() >= 1:
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
                conditions[Spells.HANDS.FULL_HOUSE]["dice"].append(all_included_dice)
                conditions[Spells.HANDS.FULL_HOUSE]["score"].append(25)

    # Check for all possible small straights
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
            var included = []
            for j in range(i, i + 4):
                included += included_dice[distinct_values[j]]
            conditions[Spells.HANDS.SM_STRAIGHT]["dice"].append(included)
            conditions[Spells.HANDS.SM_STRAIGHT]["score"].append(30) # small straight is 30 score

    # Check for all possible large straights
    if len(distinct_values) == 5 and distinct_values[4] - distinct_values[0] == 4:
        var included = []
        for value in distinct_values:
            included += included_dice[value]
        conditions[Spells.HANDS.LG_STRAIGHT]["dice"].append(included)
        conditions[Spells.HANDS.LG_STRAIGHT]["score"].append(40) # large straight is 40 score

    conditions[Spells.HANDS.CHANCE]["dice"].append(dice_array)
    conditions[Spells.HANDS.CHANCE]["score"].append(sum(dice_array, true))

    for hand in conditions:
        if conditions[hand].get("dice").size() == 0 and conditions[hand].get("score").size() == 0:
            conditions.erase(hand)
    return conditions
