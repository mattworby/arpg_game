[gd_scene load_steps=5 format=3 uid="uid://c8q5y6fhj4m2g"]

[node name="HealthManaUI" type="CanvasLayer"]
script = ExtResource("1_g3bvh")

[node name="HealthOrb" type="TextureRect" parent="."]
offset_left = 40.0
offset_top = 460.0
offset_right = 140.0
offset_bottom = 560.0
expand_mode = 1
stretch_mode = 5

[node name="HealthFill" type="TextureRect" parent="HealthOrb"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
pivot_offset = Vector2(50, 0)
expand_mode = 1
stretch_mode = 5

[node name="ManaOrb" type="TextureRect" parent="."]
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -140.0
offset_top = -140.0
offset_right = -40.0
offset_bottom = -40.0
grow_horizontal = 0
grow_vertical = 0
expand_mode = 1
stretch_mode = 5

[node name="ManaFill" type="TextureRect" parent="ManaOrb"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
pivot_offset = Vector2(50, 0)
expand_mode = 1
stretch_mode = 5