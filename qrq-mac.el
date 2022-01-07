(setq qrq/org-basic-directory "~/note/capture/")

(with-eval-after-load 'elpy
  ;;require "jupyter-client=6.1", higher version will cause async issue.
  ;;Please see: https://github.com/jupyter/jupyter_console/issues/241
  (setq python-shell-interpreter "jupyter"
        python-shell-interpreter-args "console --simple-prompt"
        python-shell-prompt-detect-failure-warning nil)
  (add-to-list 'python-shell-completion-native-disabled-interpreters
               "jupyter")
  )

(provide 'qrq-mac)