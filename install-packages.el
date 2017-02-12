(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(package-install 'column-marker)
(package-install 'yasnippet)
(package-install 'markdown-mode)
(package-install 'dockerfile-mode)
