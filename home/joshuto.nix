{ config, pkgs, ... }:

{
	programs.joshuto = 
	let
		preview_script = (pkgs.writeShellScript "preview_script" (builtins.readFile ./preview_script.sh));
	in
	{
		enable = true;
		settings = {
			display = {
				collapse_preview = false;
				column_ratio = [0 1 2];
			};
			preview = {
				preview_script = "${preview_script}";
			};
		};

		mimetype = {
			mimetype = {
				text = {
					app_list = [
						{ command = "vim"; fork = false; silent = false; }
					];
				};
			};
		};
	};


}