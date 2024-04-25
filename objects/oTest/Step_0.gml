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
	if(instance_nearest(x, y, oEnemy).x > oTest.x)
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

xspd = lerp(xspd, 0, 0.05)


x += xspd;
y += yspd;