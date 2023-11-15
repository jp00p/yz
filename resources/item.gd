class_name Item extends Resource

## The name of the item
@export_placeholder("Super amazing relic") var item_name:String = "Super amazing relic"
## The description of the item
@export_multiline var item_description:String

@export_group("Item effect")
## What does this item do?
@export var effect : Effect

## Who gets affected by the effect?
@export var effect_target = Effects.TARGETS

## When does this effect trigger?
@export var effect_trigger:Effects.TRIGGERS

## How long does the effect last?
@export var effect_duration:Effects.DURATION
