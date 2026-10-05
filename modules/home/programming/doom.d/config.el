;;; config.el -*- lexical-binding: t; -*-

(setq confirm-kill-emacs nil)

;; xclip.el prefers the xclip binary whenever it's installed, but the X
;; clipboard isn't synced to the Wayland one here.
(when (getenv "WAYLAND_DISPLAY")
  (setq xclip-method 'wl-copy))

(after! magit-section
  (setq magit-section-initial-visibility-alist
        (append '((untracked . show) (recent . show)
                  (unpushed . show) (unpulled . show))
                magit-section-initial-visibility-alist)))
