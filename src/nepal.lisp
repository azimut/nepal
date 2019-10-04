;;;; nepal.lisp

(in-package #:nepal)

(defvar *audio-init* nil)
(defvar *audio-buffers* (make-hash-table :test #'equal))
(defvar *audio-sources* (make-hash-table))

(defun list-asources ()
  (alexandria:maphash-keys #'print *audio-sources*)
  (values))
(defun list-abuffers ()
  (alexandria:maphash-keys #'print *audio-buffers*)
  (values))

(defun init-source (name)
  (check-type name keyword)
  (or (gethash name *audio-sources*)
      (setf (gethash name *audio-sources*) (al:gen-source))))

(defun load-abuffer (path)
  (or (gethash path *audio-buffers*)
      (let ((buffer (alut:create-buffer-from-file path)))
        (when (zerop buffer)
          (error "Could not load file! Use wav."))
        (setf (gethash path *audio-buffers*) buffer))))

(defun init-audio ()
  (unless *audio-init*
    (alut:init)
    (setf *audio-init* t)))
