window_set_size(1280,720)
player_health = 100;

xspd = 0;
yspd = 0;

move_spd = 2;

grav = 0.2

//Jump stuff
jump_spd = -2.5;
jump_max = 2;
jump_count = 0;
jump_hold_frames = 15;
jump_timer = 0;

//Dash Stuff
can_dash = false;
dash_distance = 96;
dash_time = 12;

//Attack stuff
hitByAttack = ds_list_create();

//Tile map info
my_tilemap = layer_tilemap_get_id("Ground")

StateFree = function()
{
	
	//getting xspd and yspd
	xspd = (right_key - left_key) * move_spd;
	//apply gravity
	yspd += grav;

	//Jump Stuff
	//Reset counter
	if (place_meeting(x, y + 2, [my_tilemap]))
	{
		jump_count = 0;
		can_dash = true;
	}
	else
	{
		if (jump_count == 0)
		{
			jump_count = 1
		}
	}

	//Initiate jump
	if (jump_key_pressed && jump_count < jump_max)
	{
		jump_count++;
	
		jump_timer = jump_hold_frames;
	}

	//End jump earlier
	if (!jump_key_hold)
	{
		jump_timer = 0;
	}

	//Jump based on timer
	if (jump_timer > 0)
	{
		yspd = jump_spd;
	
		jump_timer--;
	}
	
	//Dash Input
	if (can_dash && dash_key)
	{
		can_dash = false;
		if (right_key-left_key != 0 || down_key-up_key !=0)
		{
			dash_direction = point_direction(0, 0, right_key-left_key, down_key-up_key);
		}
		else
		{
			dash_direction = point_direction(0, 0, image_xscale, 0);
		}
		dash_speed = dash_distance/dash_time;
		dash_energy = dash_distance;
		state = StateDash;
	}

	#region Collisions
	
		//x collision
		if (place_meeting(x + xspd, y, my_tilemap))
		{
			//move player closer to wall
			var _pixel_check = sign(xspd);
			while !place_meeting(x + _pixel_check, y, my_tilemap)
			{
				x += _pixel_check;
			}
		
			//set speed to 0
			xspd = 0;
		}
	
		//y collision
		if place_meeting(x + xspd, y + yspd, my_tilemap)
		{
			var _pixel_check = sign(yspd);
			while !place_meeting(x + xspd, y + _pixel_check, my_tilemap)
			{
				y += _pixel_check;
			}
		
			yspd = 0;
		}
	
	#endregion
	
	
	if (place_meeting(x, y, oEnemy))
	{
		player_health -=25;
		state = StateGettingDamaged;
	}

	//move player
	#region
	
		x += floor(xspd);
		y += (yspd);
	
	#endregion
	
	#region Animation Stuff
	
	//invert sprite
	if (xspd != 0)
	{
		image_xscale = sign(xspd);
	}


	//Idle animation
	if (xspd == 0 && place_meeting(x, y + 1, [my_tilemap]))
	{
		sprite_index = sSusieIdle;
	}

	//Running animation
	else if (xspd != 0 && place_meeting(x, y + 1, [my_tilemap]))
	{
		sprite_index = sSusieRun;
	}

	//Jump Up
	else if (sign(yspd) == -1)
	{
		sprite_index = sSusieJump;
	}

	//Falling
	else if (sign(yspd) == 1)
	{
		sprite_index = sSusieFalling;
	}

	//Attack
	if (attack_key && yspd == 0)
	{
		state = StateAttack;
	}
	
	#endregion
	
}

StateDash = function()
{
	//Move via Dash
	xspd = lengthdir_x(dash_speed, dash_direction);
	yspd = lengthdir_y(dash_speed, dash_direction);
	
	//Dash Trail
	with (instance_create_depth(x, y, depth+1, oTrail))
	{
		image_speed = 0
		image_xscale = oPlayer.image_xscale;
		sprite_index = other.sprite_index;
		image_blend = #f69df4;
		image_alpha = 0.7;
		
	}
	
	#region //Collision Stuff
	
		//x collision
		if (place_meeting(x + xspd, y, my_tilemap))
		{
			//move player closer to wall
			var _pixel_check = sign(xspd);
			while !place_meeting(x + _pixel_check, y, my_tilemap)
			{
				x += _pixel_check;
			}
		
			//set speed to 0
			xspd = 0;
		}
	
		//y collision
		if place_meeting(x + xspd, y + yspd, my_tilemap)
		{
			var _pixel_check = sign(yspd);
			while !place_meeting(x + xspd, y + _pixel_check, my_tilemap)
			{
				y += _pixel_check;
			}
		
			yspd = 0;
		}
	
	#endregion
	
	//move
	x += xspd;
	y += yspd;
	
	//Ending the dash
	dash_energy -= dash_speed;
	if (dash_energy <= 0)
	{
		xspd = 0;
		yspd = 0;
		state = StateFree;
	}
	
	//Jump code so it can buffer while dashing
	#region
	
	//Initiate jump
	if (jump_key_pressed && jump_count < jump_max)
	{
		jump_count++;
	
		jump_timer = jump_hold_frames;
	}

	//End jump earlier
	if (!jump_key_hold)
	{
		jump_timer = 0;
	}

	//Jump based on timer
	if (jump_timer > 0)
	{
		yspd = jump_spd;
	
		jump_timer--;
	}
	#endregion
}

StateAttack = function()
{
	xspd = 0;
	yspd = 0;
	
	//Start of the attack
	if (sprite_index != sSusieAttack)
	{
		sprite_index = sSusieAttack;
		image_index = 0;
		ds_list_clear(hitByAttack);
	}
	
	//Use hitbox and check for hits
	mask_index = sSusieAttackHB
	var hitByAttackNow = ds_list_create();
	var hits = instance_place_list(x, y, oEnemy, hitByAttackNow, false);
	if (hits > 0)
	{
		for (var i = 0; i < hits; i++)
		{
			//If this instance has not yet been hit by this attack
			var hitID = hitByAttackNow[| i];
			if (ds_list_find_index(hitByAttack, hitID) == -1)
			{
				ds_list_add(hitByAttack, hitID);
				with (hitID)
				{
					
					//ENEMY HIT AND STUFF
					hitByAttackNow[| i].state = StateDead;
				}
			}
		}
	}
	ds_list_destroy(hitByAttackNow);

	if(image_index > image_number -1)
    {
            mask_index = sSusieIdle
			state = StateFree;
    }
	
}

StateKnockback = function()
{
	yspd += grav;
	//x collision
	if (place_meeting(x + xspd, y, my_tilemap))
	{
		//move player closer to wall
		var _pixel_check = sign(xspd);
		while !place_meeting(x + _pixel_check, y, my_tilemap)
		{
			x += _pixel_check;
		}
	
		//set speed to 0
		xspd = 0;
	}
	
	//y collision
	if place_meeting(x + xspd, y + yspd, my_tilemap)
	{
		var _pixel_check = sign(yspd);
		while !place_meeting(x + xspd, y + _pixel_check, my_tilemap)
		{
			y += _pixel_check;
		}
	
		yspd = 0;
	}
	
	xspd = lerp(xspd, 0, 0.05);
	
	x += xspd;
	y += yspd;
	
	if (sprite_index != sSusieDamage)
	{
		sprite_index = sSusieDamage;
		image_index = 0;
	}
	
	if(image_index > image_number -1)
    {
            mask_index = sSusieIdle
			state = StateFree;
	}
}

StateGettingDamaged = function()
{
	if (player_health > 0)
	{
		yspd += grav;
		//x collision
		if (place_meeting(x + xspd, y, my_tilemap))
		{
			//move player closer to wall
			var _pixel_check = sign(xspd);
			while !place_meeting(x + _pixel_check, y, my_tilemap)
			{
				x += _pixel_check;
			}
		
			//set speed to 0
			xspd = 0;
		}
		
		//y collision
		if place_meeting(x + xspd, y + yspd, my_tilemap)
		{
			var _pixel_check = sign(yspd);
			while !place_meeting(x + xspd, y + _pixel_check, my_tilemap)
			{
				y += _pixel_check;
			}
		
			yspd = 0;
		}
		
		if (place_meeting(x, y, oEnemy))
		{
			if(instance_nearest(x, y, oEnemy).x > oPlayer.x)
			{
				xspd = -5;
				yspd = -2;
			}
			else
			{
				xspd = 5;
				yspd = -2;
			}
		
		}
		
		state = StateKnockback;
	}
	else
	{
		state = StateDead;
	}
}

StateDead = function()
{
	room_restart();
}

state = StateFree;