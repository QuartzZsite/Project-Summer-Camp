enemy_health = 50;
dir = 1;
move_spd = 1;
fear_of_heights = 1;
xspd = 0;
yspd = 0;
grav = 0.2;
fall_height = 8;

my_tilemap = layer_tilemap_get_id("Ground")

StateFree = function()
{
	yspd += grav;
	xspd = move_spd * dir;	

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
		if (fear_of_heights && !position_meeting(x + (sprite_width / 2) * dir, y + (sprite_height / 2) + fall_height, my_tilemap))
		{
			dir *= -1
		}
		
		if (position_meeting(x + (sprite_width / 2) * dir - (sign(xspd) * 20), y, my_tilemap))
		{
			dir *= -1
		}
	}
	
	x += xspd;
	y += yspd;
	
	if (enemy_health <= 0)
	{
		state = StateDead;
	}
}

StateDead = function()
{
	xspd = 0;
	yspd = 0;
}

state = StateFree;

//ADD KNOCKBACK ON HIT BASED ON PLAYER'S SPRITE DIRECTION (SIGN)