+++
title = "Debugging sway and i3status-rs"
date = 2022-09-19

[taxonomies]
tags = ["wayland", "sway", "i3status", "linux"]
+++

Recently I have been toying around with the `sway` compositor on Wayland in
order to have a more lightweight setup with better support for keyboard-only
interaction. However, because I have not used Arch Linux on my desktop for some
time, I am re-learning a few things as I go as well.

<!-- more -->

I have followed the documentation on setting up `i3status-rs` on my machine and
I pasted the initial config for `sway` from the website:
```
bar {
    font pango:Hack, FontAwesome 11
    ...
}
```

I realized later, was not working correctly and was showing 漢字 instead of
font awesome icons. The reason why it took me so long to realize something was
not working correctly was because I was also setting up correct `locale` setting
in order to be able to render Japanese fonts correctly.

It seems that [the
author](https://github.com/greshake/i3status-rust#integrate-it-into-i3sway) has
also specified that it would be good to ensure that `FontAwesome` is pointing
to the right font on one's system, so let's do that:
```bash
$ fc-match FontAwesome
DejaVuSans.ttf: "DejaVu Sans" "Book
```

That's unexpected, let's see what `pacman` has installed on my system:
```bash
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
```
bar {
    font pango:Hack, "Font Awesome 6 Free" 11
    ...
}
```

After restarting everything works correctly.
