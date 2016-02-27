;;
;; encodage des fichiers
(set-language-environment "UTF-8")

;; desactive curseur clignotant
(if (>= emacs-major-version 21)
  (blink-cursor-mode -1))

;; tout les fichiers de save temp dans /tmp
(setq backup-directory-alist
  `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
  `((".*" ,temporary-file-directory t)))


;;--------------------------------------------------------------------
;; Pour que la couleur marche en mode shell.
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(defun to-bottom () (interactive) "Recenter screen so that current
line is on the bottom of the screen"
  (recenter -1)
  )
(defun set-key-to-bottom () (interactive)
  (local-set-key "\C-l" 'to-bottom)
  )
(add-hook 'shell-mode-hook 'set-key-to-bottom)

;;--------------------------------------------------------------------
;; Des espaces pour indenter.
(setq indent-tabs-mode nil)
