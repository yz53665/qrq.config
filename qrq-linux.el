(setq qrq/org-basic-directory "~/myPrj/capture/")
;;=============================eaf======================================
;; most of the features in eaf is only available in win & linux
(add-to-list 'load-path "~/.emacs.d/site-lisp/emacs-application-framework/")
(require 'eaf)
(require 'eaf-browser)
(require 'eaf-demo)
(require 'eaf-pdf-viewer)
(require 'eaf-image-viewer)
(require 'eaf-mindmap)
(require 'eaf-rss-reader)
(require 'eaf-jupyter)
(require 'eaf-org-previewer)
(require 'eaf-system-monitor)
(require 'eaf-markdown-previewer)
(require 'eaf-file-manager)
(setq browse-url-browser-function 'eaf-open-browser)
(defalias 'browse-web #'eaf-open-browser)

;; proxy, be aware that aira2 proxy only support http proxy.
(setq hostip (car (split-string (shell-command-to-string "echo $hostip") "\n")))
(setq eaf-proxy-type "http")
(setq eaf-proxy-host (car (split-string (shell-command-to-string "echo $hostip") "\n")))
(setq eaf-proxy-port "7890")
(require 'eaf-evil)

;; use eaf-pdf to open pdf file in org-mode
(defun eaf-org-open-file (file &optional link)
  "An wrapper function on `eaf-open'."
  (eaf-open file))
;; use `emacs-application-framework' to open PDF file: link
(add-to-list 'org-file-apps '("\\.pdf\\'" . eaf-org-open-file))
;; continue the browser where you left using `eaf-browser-restore-buffers'
(setq eaf-browser-continue-where-left-off t)

;; enable eaf-evil, so that you can use evil kbd in normal mode, otherwise the
;; eaf kbd only available in insert mode.
(define-key key-translation-map (kbd "SPC")
    (lambda (prompt)
      (if (derived-mode-p 'eaf-mode)
          (pcase eaf--buffer-app-name
            ("browser" (if  (string= (eaf-call-sync "call_function" eaf--buffer-id "is_focus") "True")
                           (kbd "SPC")
                         (kbd eaf-evil-leader-key)))
            ("pdf-viewer" (kbd eaf-evil-leader-key))
            ("image-viewer" (kbd eaf-evil-leader-key))
            (_  (kbd "SPC")))
        (kbd "SPC"))))
;;=============================eaf end==================================

(with-eval-after-load 'elpy
  (setq-default elpy-rpc-python-command "python3")
  )

(provide 'qrq-linux)
