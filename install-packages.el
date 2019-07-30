(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(package-install 'yasnippet)
(package-install 'markdown-mode)
(package-install 'dockerfile-mode)
(package-install 'xclip)
(package-install 'haskell-mode)
(package-install 'haskell-snippets)
(package-install 'groovy-mode)
(package-install 'gradle-mode)
(package-install 'nodejs-repl)
(package-install 'typescript-mode)
;; (package-install 'purescript-mode)
(package-install 'json-mode)
(package-install 'jsonnet-mode)
(package-install 'php-mode)
(package-install 'yaml-mode)
(package-install 'scala-mode)
(package-install 'sbt-mode)
(package-install 'string-inflection)
