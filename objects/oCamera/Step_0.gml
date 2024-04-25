if (follow != noone)
{
	xTo = follow.x
	yTo = follow.y
}

x += (xTo - x) / 25;
y += (yTo - y) / 25;

x = clamp(x, camWidth/2, room_width - camWidth/2)
y = clamp(y, camHeight/2, room_height - camHeight/2)
camera_set_view_pos(view_camera[0], x - (camWidth * 0.5), y - (camHeight * 0.5));
