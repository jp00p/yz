extends Node

signal shake_panel(which)
signal reset_panels
signal create_floating_text(text:FloatingText)
signal enemy_died
signal enemy_attack(target)

signal player_ready_to_cast
signal roll_dice(who) # make someone roll
signal toggle_roll_button_state(state) # enable/disable roll button
signal add_dice_tray(whose) # combat starts, adds a dice tray to the UI
signal show_spell_options
signal swap_dice(who) # swap whose dice in the dice tray
signal set_score(hand, amt)
