instance_destroy(obj_custom_object_ext)
instance_destroy(obj_custom_object)
with(instance_create(0,0,obj_custom_object)){
	switch (os_type)
	{
		case os_windows: 
			game_directory = "C:/Users/" + environment_get_variable("USERNAME") + "/Documents/pizza tower android/"
		break
		case os_android:
			game_directory = "/storage/emulated/0/Documents/pizza tower android/"
		break
	}
	mods_path = game_directory + "mods/"
	if (!directory_exists(mods_path))
	{
	    directory_create(mods_path)
	}
    //image_alpha=0
    depth=-9999
    selected=0
    move=0
    moveLR=0
	lerp_var=0
	setting=0
	debugging=false
	reloadtext = "/{s} Mod's reloaded!/"
    mods = array_create(0)
    frame=0
    tab=0
    tabs=["MODS","SETTINGS","CREDITS"]
    global.loading_mods=0
    instance_deactivate_all(1)
	instance_activate_object(obj_inputAssigner)
	instance_activate_object(obj_virtual_controller)
	instance_activate_object(obj_virtual_controller_manager)
	instance_activate_object(obj_elite_controller)
	instance_activate_object(obj_screensizer)
	instance_activate_object(obj_savesystem)
    drawgui_event=@'
	    function scr_load_file(filename)
		{
			var t = ""
			if file_exists(filename)
			{
				var _file = buffer_load(filename)
				if buffer_get_size(_file) > 0
					t = buffer_read(_file, buffer_string)
				buffer_delete(_file); 
			}
			return t
		}
		function Mod(mod_path, mod_name, mod_desc = "", is_enabled = false, mod_icon = spr_null, is_reload = false, mod_settings = []) constructor
	    {
		    file_path = mod_path;
			name = mod_name;
			desc = mod_desc;
			enabled = is_enabled;
			icon = mod_icon;
			reload = is_reload;
			settings = mod_settings;
		}
	    draw_set_color(c_black)
		draw_set_alpha(0.5)
	    draw_rectangle(0,0,960,540,false)
		if tab == 0 {
			if array_length(mods) == 0
			{
				ini_open(mods_path + "fabric.ini")
				for (var mod_folder = file_find_first(mods_path + "*",0);mod_folder != "";mod_folder = file_find_next())
				{
					var _path = mods_path + mod_folder
					if directory_exists(_path) {
						if file_exists(_path + "/mod.json")						
							jsonstruct = json_parse(scr_load_file(_path + "/mod.json"))
						else
							jsonstruct = {}
						
						var mod_name = variable_struct_exists(jsonstruct, "name") ? jsonstruct.name : mod_folder
						var mod_desc = variable_struct_exists(jsonstruct, "desc") ? jsonstruct.desc : ""
						
						if file_exists(_path + "/icon.gif")
							icon = sprite_add_gif(_path + "/icon.gif", 0, 0, 0, 0, 0)
						else
							if file_exists(_path + "/icon.png")
								icon = sprite_add(_path + "/icon.png", 0, 0, 0, 0, 0)
							else
								icon = spr_null
						
						var settings = variable_struct_exists(jsonstruct, "settings") ? jsonstruct.settings : []
						if array_length(settings) > 0
						{
							for (i=0;i<array_length(settings);i++)
							{
								settings[i].value = ini_key_exists(mod_name, settings[i].id) ? ini_read_real("Settings", settings[i].id, 0) : settings[i].value
								ini_write_real(mod_name, settings[i].id, settings[i].value)
							}
						}
						
			            array_push(mods, new Mod(mod_folder, mod_name, mod_desc, ini_read_real(mod_name, "enabled", 0), icon, false, settings))
					}
				}
		        file_find_close()
				array_push(mods, new Mod("", "reload mods", "", false, 0, spr_null, true, []))
				ini_close()
			}
	        draw_set_alpha(1)
	        draw_set_valign(fa_bottom)
	        draw_set_color(c_white)
	        draw_set_font(global.creditsfont)
			draw_set_halign(fa_center)
			draw_text_ext_transformed(display_get_gui_width()/2, 520, string_upper(mods[selected].desc), 32, 900, 0.6, 0.6, 0)
			draw_sprite_stretched(mods[selected].icon, frame % sprite_get_number(mods[selected].icon),  display_get_gui_width() - 120, 70, 100, 100)
	        for(var i = 0;i < array_length(mods);i++)
	        {
		        var m = mods[i]
				draw_set_valign(fa_top)
				draw_set_halign(fa_left)
				draw_set_font(global.creditsfont)
	            draw_set_color(i == selected ? c_white : c_gray)
	
	            if !m.reload
					var text = string_upper(m.name) + " : " + (debugging ? m.enabled : (m.enabled ? "ON" : "OFF"))
				else
					var text = string_upper(m.name)
					
				var width = string_width(text)
				var xscale = min(width, display_get_gui_width() - 20) / width
				draw_text_transformed(15, display_get_gui_height() / 2 + ((i-(lerp_var+0.5)) * 50), text, xscale, 1, 0)
	        }
        }
        if (tab == 1 && array_length(mods[selected].settings) > 0) {
        	draw_set_alpha(1)
        	for(var i = 0;i < array_length(mods[selected].settings);i++)
	        {
		        var s = mods[selected].settings[i]
				draw_set_valign(fa_top)
				draw_set_halign(fa_left)
				draw_set_font(global.creditsfont)
	            draw_set_alpha(i == setting ? 1 : 0.5)
				var text = "TYPE NOT FOUND, GML WILL NOT WORK"
	            if s.type == "number"
		            text = s.name + ": " + string(s.value)
				else
					if s.type == "string"
			            text = s.name + ": " + s.texts[s.value]
					else
						if s.type == "toggle"
				            text = s.name + ": " + (s.value ? "ON" : "OFF")
						else
							draw_set_font(global.smallfont)
				var width = string_width(text)
				var xscale = min(width, display_get_gui_width() - 20) / width
				draw_text_transformed(15, display_get_gui_height() / 2 + ((i-(lerp_var+0.5)) * 50), text, xscale, 1, 0)
	        }
		}
        draw_set_color(c_black)
		draw_set_alpha(0.5)
	    draw_rectangle(0,0,960,50,false)
		draw_set_alpha(1)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
        draw_set_font(global.creditsfont)
		draw_set_halign(fa_left)
		var x = 0
		for(var i = 0;i < array_length(tabs);i++) {
			draw_set_color(i == tab ? c_white : c_gray)
			draw_text(30+x, 5, tabs[i])
			x += string_width(tabs[i])+30
		}
    '
    step_event=@'
	    ini_open(mods_path + "fabric.ini")
		function scr_load_file(filename)
		{
			var t = ""
			if file_exists(filename)
			{
				var _file = buffer_load(filename)
				if buffer_get_size(_file) > 0
					t = buffer_read(_file, buffer_string)
				buffer_delete(_file); 
			}
			return t
		}
	    function clamp(v,min,max)
			return (v > max) ? min : (v < min) ? max : v
	    if !global.loading_mods {
	        scr_getinput()
	        move = key_down2-key_up2
	        moveLR = key_right2+key_left2
	        if key_taunt2 {
		        tab = (tab + 1) % array_length(tabs)
				scr_soundeffect(sfx_enemyprojectile)
			}
			if (tab == 1 && array_length(mods[selected].settings) > 0) {
				lerp_var = lerp(lerp_var,setting,0.1)
		        setting = clamp(setting+move,0,array_length(mods[selected].settings)-1)
				var s = mods[selected].settings[setting]
				if s.type == "number"
					mods[selected].settings[setting].value = clamp(s.value+(moveLR*(variable_struct_exists(s,"step") ? s.step : 1)),s.min,s.max)
				if s.type == "string"
					mods[selected].settings[setting].value = clamp(s.value+moveLR,0,array_length(s.texts)-1)
				if s.type == "toggle"
					mods[selected].settings[setting].value = (s.value + key_jump) % 2
				ini_write_real(mods[selected].name, s.id, s.value)
			}
			if tab == 0 {
				frame+=1
		        if move != 0 
			        frame = 0
				lerp_var = lerp(lerp_var,selected,0.1)
		        selected = clamp(selected+move,0,array_length(mods)-1)
		        if(key_jump)
		        {
			        if selected != array_length(mods)-1
					{
				        mods[selected].enabled = !mods[selected].enabled
						ini_write_real(mods[selected].name, "enabled", mods[selected].enabled)
					}
					else
					{
						mods = []
						if !instance_exists(obj_transfotip)
						{
							with instance_create(0, 0, obj_transfotip)
							{
								text = other.reloadtext
								depth = -10000
							}
						}
					}
					scr_soundeffect(sfx_enemyprojectile)
				}
			}
			if key_slap2
				global.loading_mods = 1
		}else{
			instance_activate_all()
			for (var i = 0;i < array_length(mods);i++)
			{
				var _mod = mods[i]
				var mod_folder = mods_path + _mod.file_path
				global.mod_path = mod_folder
				if variable_struct_exists(_mod, "settings")
				{
					if array_length(_mod.settings) > 0
					{
						for(var i = 0;i < array_length(_mod.settings);i++)
						{
							var s = _mod.settings[i]
							if s.type == "string" {
								variable_global_set(s.id, s.texts[s.value])
								variable_global_set(s.id + "_num", s.value)
							}
							else
							{
								variable_global_set(s.id, s.value)
							}
						}
					}
				}
				if _mod.enabled
				{
					var _path = mod_folder + "/init.gml"
					if file_exists(_path)
					{
						var snippet = live_snippet_create(scr_load_file(_path))
						if live_snippet_call(snippet){} else {
							get_string_async("Your mod fucked up!", "Runtime error in: \"" + _path + "\"\n\n" + global.live_result)
						}
					}
					var scripts_path = mod_folder + "/scripts"
					if directory_exists(scripts_path) {
						for (var script = file_find_first(scripts_path + "/*.gml",0);script != "";script = file_find_next())
						{
							var _path = scripts_path + "/" + script
							if file_exists(_path)
							{
								var snippet = live_snippet_create(scr_load_file(_path))
								if live_snippet_call(snippet){} else {
									get_string_async("Your mod fucked up!", "Runtime error in: \"" + _path + "\"\n\n" + global.live_result)
								}
							}
						}
					}
				}
			}
			instance_destroy()
			scr_soundeffect(sfx_enemyprojectile)
		}
		ini_close()
    '
    docommand("reload_gml",1,1)
}
