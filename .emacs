(setenv "PAGER" "/bin/cat")
(setenv "GIT_PAGER" "/bin/cat")
(setenv "GIT_EDITOR" "emacsclient")
(add-to-list 'exec-path "~/bin" t)

(add-to-list 'load-path "~/.emacs.d/myemacs")
(load "myemacs")

(setenv "PATH" (concat (getenv "PATH") ":" (getenv "HOME") "/bin"))

(setenv "TERM" "xterm-256color")
