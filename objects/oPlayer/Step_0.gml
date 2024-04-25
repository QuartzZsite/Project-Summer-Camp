//Get inputs
right_key = keyboard_check(ord("D")) || keyboard_check(vk_right);
left_key = keyboard_check(ord("A")) || keyboard_check(vk_left);
up_key = keyboard_check(ord("W")) || keyboard_check(vk_up);
down_key = keyboard_check(ord("S")) || keyboard_check(vk_down);
jump_key_pressed = keyboard_check_pressed(vk_space);
jump_key_hold = keyboard_check(vk_space);
dash_key = keyboard_check_pressed(vk_shift);
attack_key = keyboard_check(ord("F")) || mouse_check_button(mb_left);


state();