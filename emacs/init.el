;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file replaces itself with the actual configuration at first run.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; We can't tangle without org!
(require 'org)

(defvar user/init-org-file (concat user-emacs-directory "Emacs.org"))
(defvar user/init-el-file  (concat user-emacs-directory "init.el"))

(find-file user/init-org-file)
(org-babel-tangle)
(load-file user/init-el-file)
(byte-compile-file user/init-el-file)
