+++
title = "Debugging sway and i3status-rs"
date = 2022-09-19

[taxonomies]
tags = ["wayland", "sway", "i3status", "linux"]
+++

The font-awesome setting was not working correctly with the previous config when using `i3status-rs`:
```i3
bar {
    font pango:Hack, FontAwesome 11
    ...
}
```

It resulted in some weird Kanji being displayed instead of the battery or WiFi icons.
In order to debug this we can use commands to query the font cache on the system.
I found this useful piece of info [here](https://github.com/greshake/i3status-rust#integrate-it-into-i3sway).
It seems that I have not read the manual...

We can validate the font file which `FontAwesome` matches by using:
```
$ fc-match FontAwesome
DejaVuSans.ttf: "DejaVu Sans" "Book
```

This is not the result I had expected, let's see what `pacman` has installed on my Arch Linux system:
```
$ pacman -Ql ttf-font-awesome | rg fa-
ttf-font-awesome /usr/share/fonts/TTF/fa-brands-400.ttf
ttf-font-awesome /usr/share/fonts/TTF/fa-regular-400.ttf
ttf-font-awesome /usr/share/fonts/TTF/fa-solid-900.ttf
ttf-font-awesome /usr/share/fonts/TTF/fa-v4compatibility.ttf
```

Then we can check what names of the fonts we can use by:
```bash
$ fc-match -a | rg '^fa-'
fa-brands-400.ttf: "Font Awesome 6 Brands" "Regular"
fa-regular-400.ttf: "Font Awesome 6 Free" "Regular"
fa-v4compatibility.ttf: "Font Awesome v4 Compatibility" "Regular"
fa-solid-900.ttf: "Font Awesome 6 Free" "Solid"
```

This means that we should get `sway` working by:
```i3
bar {
    font pango:Hack, "Font Awesome 6 Free" 11
    ...
}
```

After restarting everything works correctly.
