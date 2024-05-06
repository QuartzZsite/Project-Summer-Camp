enemy_health = 50;
dir = -1;
move_spd = 1;
fear_of_heights = 1;
xspd = 0;
yspd = 0;
grav = 0.2;
fall_height = 8;
change_sprite_direction = 1; // cuz of image x scale

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
		if (fear_of_heights && !position_meeting(x + (change_sprite_direction * sprite_width / 2) * dir - (sign(xspd) * 30), y + (sprite_height / 2) + fall_height, my_tilemap))
		{
			dir *= -1
			image_xscale *= -1;
			change_sprite_direction *= -1;
			
		}
		
		if (position_meeting(x + (change_sprite_direction * sprite_width / 2) * dir - (sign(xspd) * 40), y, my_tilemap))
		{
			dir *= -1
			image_xscale *= -1;
			change_sprite_direction *= -1;
			
		}
	}
	
	x += floor(xspd);
	y += floor(yspd);
	
	if (enemy_health <= 0)
	{
		state = StateDead;
	}
	

}

StateDead = function()
{
	xspd = 0;
	yspd = 0;
	
	sprite_index = sEnemyGhostDead;
	
	if(image_index > image_number -1)
    {
		instance_destroy();
    }
}

state = StateFree;