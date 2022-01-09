(add-to-list 'melpa-include-packages 'org-download)
(add-to-list 'melpa-include-packages 'dap-mode)
(add-to-list 'load-path "~/capture/qrq.config")
(cond
 ((eq system-type 'gnu/linux)
  (require 'qrq-linux))
 ((eq system-type 'darwin)
  (require 'qrq-mac)))

;;   ;; Don't ask before reloading updated tags files
  (setq tags-revert-without-query t)
;;   ;; NO warning when loading large tag files
  (setq large-file-warning-threshold nil)
  (add-hook 'prog-mode-hook
    (lambda ()
      (add-hook 'after-save-hook
                'counsel-etags-virtual-update-tags 'append 'local)))
;;============================org-mode configuration========================
(setq-default org-directory qrq/org-basic-directory)
(setq-default org-agenda-files (list org-directory))

(with-eval-after-load 'org-mode
  )

(setq-default org-default-notes-file (concat qrq/org-basic-directory "refile.org"))
(setq-default org-log-done 'time)

;; org agenda configuration
(setq-default org-agenda-span 'day)
(setq-default org-agenda-custom-commands
      (quote (("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              (" " "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  ))
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil)))
              )
               nil))))

;; org refile设置
(setq-default org-refile-allow-creating-parent-nodes (quote confirm))
(setq-default org-refile-targets (quote ((nil :maxlevel . 5)
                                 (org-agenda-files :maxlevel . 5))))
(setq-default org-refile-use-outline-path t)
(setq-default org-refile-allow-creating-parent-nodes (quote confirm))


                                        ; Use the current window for indirect buffer display
;; org 归档设置
 (setq-default org-archive-mark-done nil)
  (setq-default org-archive-location "%s_archive::* Archived Tasks")
  (defun bh/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (save-restriction
    (widen)
    ;; Consider only tasks with done todo headings as archivable candidates
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (subtree-end (save-excursion (org-end-of-subtree t))))
      (if (member (org-get-todo-state) org-todo-keywords-1)
          (if (member (org-get-todo-state) org-done-keywords)
              (let* ((daynr (string-to-number (format-time-string "%d" (current-time))))
                     (a-month-ago (* 60 60 24 (+ daynr 1)))
                     (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                     (this-month (format-time-string "%Y-%m-" (current-time)))
                     (subtree-is-current (save-excursion
                                           (forward-line 1)
                                           (and (< (point) subtree-end)
                                                (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                (if subtree-is-current
                    subtree-end ; Has a date in this month or last month, skip it
                  nil))  ; available to archive
            (or subtree-end (point-max)))
        next-headline))))

(setq-default qrq/org-gong-path (concat qrq/org-basic-directory "gong.org"))
;; org cpature模板
(setq-default org-capture-templates
        '(("t" "Todo")
          ("tt" "Todo" entry
           (file org-default-notes-file)
           "* TODO %?\n\n")
          ("th" "Todo here" entry
           (file org-default-notes-file)
           "* TODO %?\n  %a\n")
          ("n" "note" entry
           (file org-default-notes-file)
           "* %U %^{标题} :NOTE:\n  %?\n")
          ("m" "meeting record" entry
           (file+olp qrq/org-gong-path "Meeting")
           "** %^U 和%^{谁}的会议 :MEETING:\n   %?" :empty-lines-after 1)
          ("r" "week report" entry
           (file+headline qrq/org-gong-path "Week Report")
           "** %^u %^{标题} :WEEKREPORT: \n   -第%^{次数}汇报\n   %?"
           :empty-lines-after 1)
          ;; ("r" "experiment record" entry
          ;;  (file+headline qrq/org-gong-path "自整定烤箱实验记录")
          ;;  "**** %^U
          ;;  %^{MachineNum}p %^{Mode}p %^{EnvTemp}p %^{InitTemp}p
          ;;  %^{TargetTemp}p %^{Kp}p %^{Ki}p %^{Kd}p
          ;;  %^{KiLimit}p %^{Overshoot}p %^{Fallack}p %^{RisingTime}p
          ;;  %^{StableTime}p\n\n" :jump-to-captured t :empty-lines-after 1)
          ))
;;=============================================org configuration end==========================================
;;=============================zotxt=====================================
(require-package 'zotxt)
;;=============================you-dao package===========================
(require-package 'youdao-dictionary)
;;============================youdao package end=========================

(defun org-dblock-write:block-update-time (params)
  (let ((fmt (or (plist-get params :format) "%d. %m. %Y")))
    (insert "Last block update at: "
            (format-time-string fmt (current-time)))))

;;=========================================org-download configuration==================
(require-package 'org-download)
(add-hook 'dired-mode-hook 'org-download-enable)
(add-hook 'org-mode-hook 'org-download-enable)
(setq-default org-download-method 'directory)
(setq-default org-download-screenshot-method "xclip") ;;未完成
(setq-default org-download-image-dir (concat qrq/org-basic-directory "pictures/"))
(setq-default org-download-heading-lvl nil)
;;=======================================org-download configuration end===============

;;==========================================lsp configuration============================
(require-package 'lsp-mode)
;;{{ lsp-mode configuration
(with-eval-after-load 'lsp-mode
  ;; enable log only for debug
  (setq-default lsp-log-io nil)
  ;; use `evil-matchit' instead
  (setq-default lsp-enable-folding nil)
  ;; no real time syntax check
  (setq-default lsp-diagnostic-package :none)
  ;; handle yasnippet by myself
  (setq-default lsp-enable-snippet nil)
  ;; use `company-ctags' only.
  ;; Please note `company-lsp' is automatically enabled if it's installed
  (setq-default lsp-enable-completion-at-point nil)
  ;; turn off for better performance
  (setq-default lsp-enable-symbol-highlighting nil)
  ;; use find-fine-in-project instead
  (setq-default lsp-enable-links nil)
  ;; auto restart lsp
  (setq-default lsp-restart 'auto-restart)
  ;; don't watch 3rd party javascript libraries
  (push "[/\\\\][^/\\\\]*\\.\\(json\\|html\\|jade\\)$" lsp-file-watch-ignored)
  ;; don't ping LSP language server too frequently
  (setq-default lsp-ui-sideline-enable nil)
  (setq-default lsp-ui-sideline-show-code-actions nil)
  (setq-default lsp-ui-sideline-show-hover nil)
  (setq-default lsp-modeline-code-actions-enable t)
  (setq-default lsp-eldoc-enable-hover nil)
  (setq-default lsp-signature-auto-activate nil)
  )

(with-eval-after-load 'go-mode

  (evil-define-key '(normal visual) go-mode-map (kbd "C-]") 'xref-find-definitions)
  (evil-define-key '(normal visual) go-mode-map (kbd "C-'") 'xref-find-references)
  )


(add-hook 'c-mode-hook 'lsp-deferred)

;;=======================================c-mode configuration==========================
(with-eval-after-load 'c-mode

  (evil-define-key '(normal visual) go-mode-map (kbd "C-]") 'xref-find-definitions)
  (evil-define-key '(normal visual) go-mode-map (kbd "C-'") 'xref-find-references)
  )

;;=======================================c-mode configuration end======================
;;=======================================lsp configuration end============================

(setq lazyflymake-flymake-mode-on t)
;; flycheck
;; (require-package 'flycheck)
;; (add-hook 'after-init-hook #'global-flycheck-mode)
;; ;; disable default lazyflymake to use flycheck
;; (setq-default my-disable-lazyflymake t)

;;===================================go-mode=============================================
(require-package 'go-mode)

(add-hook 'go-mode-hook #'lsp-deferred)

(with-eval-after-load 'go-mode
  (setq-default gofmt-command "goimports")
  (setq-default lsp-gopls-use-placeholders t)
  (evil-define-key '(normal visual) go-mode-map (kbd "C-]") 'godef-jump)
  (evil-define-key '(normal visual) go-mode-map (kbd "C-o") 'xref-pop-marker-stack)
  )


;; (add-to-list 'load-path "folder-in-which-go-dlv-files-are-in/") ;; if the files are not already in the load path
;; (require-package 'go-dlv)
;;=================================go-mode configuration end==============================

;;=================================dap-mode configuration================================
(require-package 'dap-mode)
(require 'dap-go)
(require 'dap-lldb)
(require 'dap-python)
(require 'dap-gdb-lldb)
(dap-go-setup)


(with-eval-after-load 'dap-mode
  ;; unable to use
  ;;(setq-default dap-lldb-debug-program '("/usr/local/Cellar/llvm/12.0.1/bin/lldb-vscode"))
  (setq-default dap-auto-configure-features '(sessions locals controls tooltip))
  (custom-set-faces
   '(dap-ui-pending-breakpoint-face ((t (:underline "dim gray"))))
   '(dap-ui-verified-breakpoint-face ((t (:underline "green")))))
  )
(dap-mode 1)
(dap-ui-mode 1)

;;=================================dap-mode end==========================================

;;================================csharp-mode configuration==============================
(require-package 'csharp-mode)
(require-package 'omnisharp)

(with-eval-after-load 'csharp-mode

  (evil-define-key '(normal visual) csharp-mode-map (kbd "C-]") 'xref-find-definitions)
  (evil-define-key '(normal visual) csharp-mode-map (kbd "C-'") 'xref-find-references)
  )

(defun my-csharp-mode-hook ()
  ;; enable the stuff you want for C# here
  (electric-pair-mode 1)       ;; Emacs 24
  (electric-pair-local-mode 1) ;; Emacs 25
  (setq imenu-create-index-function 'counsel-etags-imenu-default-create-index-function)
  )
(add-hook 'csharp-mode-hook 'lsp-deferred)
(add-hook 'csharp-mode-hook 'my-csharp-mode-hook)
;;===============================csharp-mode configuration end==========================

;;;; set gdb multi-windows when open
(setq-default gdb-many-windows t)

;;emacs theme configuration
(load-theme 'sanityinc-tomorrow-eighties t)
;;(load-theme 'solarized-dark t)

;;===============================verlog-mode configuration==============================
(require 'lsp-verilog)

(with-eval-after-load 'verilog-mode
  (custom-set-variables
   '(lsp-clients-svlangserver-launchConfiguration "/tools/verilator -sv --lint-only -Wall")
   '(lsp-clients-svlangserver-formatCommand "/tools/verible-verilog-format"))
  )

(add-hook 'verilog-mode-hook #'lsp-deferred)
;;==============================verlog-mode configuration end==========================

;;==============================elpy configuration=====================================
(set-fringe-style (quote (nil . nil)))
(custom-set-faces
 '(dap-ui-pending-breakpoint-face ((t (:underline "dim gray"))))
 '(dap-ui-verified-breakpoint-face ((t (:underline "green")))))
(set-fringe-style (quote (12 . 8)))
(setq left-fringe-width 12)

(with-eval-after-load 'elpy
  (setq-default elpy-rpc-virtualenv-path (concat (getenv "WORKON_HOME") "rpc-venv/"))
  (let ((venv-dir (concat (getenv "WORKON_HOME") "cv/")))
    (if (file-exists-p venv-dir) (pyvenv-activate venv-dir)))


  ;; (setq python-shell-interpreter "python"
  ;;       python-shell-interpreter-args "-i")
  )

;; 运行时让每个python的buffer都用单独的shell,避免共享变量,造成冲突
(add-hook 'elpy-mode-hook (lambda () (elpy-shell-toggle-dedicated-shell 1)))

;; 每个project一个shell
;;(add-hook 'elpy-mode-hook (lambda () (elpy-shell-set-local-shell (elpy-project-root))))
;; format-code

;;=============================elpy configuration end===================================

(defun qrq/newline-at-80 ()
  "在第80列新建一行并缩进, 如果80列在一个词的中间, 则将整个词都放到下一行."
  (move-to-column 80)
  (pyim-backward-word)
  (newline-and-indent)
  )

(defun qrq/auto-newline ()
  "在当前行每隔80列就调用`qrq/newline-at-80'新建一行并缩进."
  (interactive)
  (end-of-line)
  (while (> (current-column) 80)
    (qrq/newline-at-80)
    (end-of-line)
    )
  )

(defun qrq/add-prefix-at-beginning-of-line (prefix)
  "将 PREFIX 插入到该行开头."
  (beginning-of-line)
  (skip-chars-forward " \n\t")
  (insert prefix " ")
  )

(defun qrq/add-prefix-for-multiple-line ()
  "输入向下操作的行数（包括本行）, 为每一行调用`qrq/add-prefix-at-beginning-of-line'."
  (interactive)
  (setq-default numDownLines (read-number "please enter the number of line:"))
  (setq-default thePrefix (read-string "please enter the prefix:"))
  (dotimes (i (+ 1 numDownLines))
    (qrq/add-prefix-at-beginning-of-line thePrefix)
    (next-line))
  )

;;===========================================key configuration=========================================
(with-eval-after-load 'evil
  (my-space-leader-def
  ;;{{ my org mode setup
    "db" 'dap-hydra
    "oa" 'org-agenda
    "oc" 'org-capture
    "os" 'org-save-all-org-buffers
    ;;}}
    "yda" 'youdao-dictionary-search-at-point
    "ydi" 'youdao-dictionary-search-from-input
    ;;{{ my func
    "qnl" 'qrq/auto-newline
    "qap" 'qrq/add-prefix-for-multiple-line
    ;;}}
    )
  (my-semicolon-leader-def
    "l" 'avy-goto-line)
  (my-comma-leader-def
    "le" 'lsp-treemacs-errors-list
    "rn" 'lsp-rename)
)

(general-create-definer my-python-leader-def
  :prefix "SPC"
  :non-normal-prefix "S-SPC"
  :states '(normal motion insert emacs)
  :keymaps 'python-mode-map)

(my-python-leader-def
  "cc" 'elpy-shell-send-region-or-buffer-and-step
  "co" 'elpy-shell-send-group
  "ce" 'elpy-shell-send-statement)

(define-key isearch-mode-map (kbd "M-j") 'avy-isearch)
;;=========================================leader key configuration=========================================

;;=============================my hydra=========================================
(defhydra hydra-eaf ()
  "
")

;;========================================keyfreq configuration============================================
;; (require 'keyfreq)
;; (keyfreq-mode 0)
;; (keyfreq-autosave-mode 0)
;; (setq keyfreq-excluded-commands
;;       '(
;;         org-self-insert-command
;;         self-insert-command
;;         dap-tooltip-mouse-motion
;;         newline-and-indent
;;         ivy-next-line
;;         ivy-previous-line
;;         ivy-backward-delete-char
;;         ivy-done
;;         company-select-next-or-abort
;;         company-complete-selection
;;         mouse-set-region
;;         evil-mouse-drag-region
;;         undefined
;;         ignore
;;         evil-insert
;;         evil-next-line
;;         evil-previous-line
;;         evil-forward-char
;;         evil-backward-char))
;;========================================keyfreq configuration end========================================

(setq my-term-program "/bin/zsh")
(exec-path-from-shell-initialize)

(provide '.custom)
;;
