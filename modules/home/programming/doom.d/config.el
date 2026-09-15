;;; config.el -*- lexical-binding: t; -*-

(setq confirm-kill-emacs nil)

(after! magit-section
  (setq magit-section-initial-visibility-alist
        (append '((untracked . show) (recent . show)
                  (unpushed . show) (unpulled . show))
                magit-section-initial-visibility-alist)))
