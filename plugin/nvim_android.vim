let g:gradle_init_file = expand("<sfile>:h:h") . "/gradle/init.gradle"
lua require("android.gradle").load()
