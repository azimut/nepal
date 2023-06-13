(in-package #:nepal)

(defvar *audio-init* nil)
(defvar *audio-buffers* (make-hash-table :test #'equal))
(defvar *audio-sources* (make-hash-table))

(defun list-abuffers () (alexandria:hash-table-plist *audio-buffers*))
(defun list-asources () (alexandria:hash-table-plist *audio-sources*))
(defun list-asources-playing ()
  (loop :for (_ source) :on (nepal::list-asources) :by #'cddr
        :when (eq :playing (al:get-source source :source-state))
          :collect source))

(defun init-source (name)
  (check-type name keyword)
  (or (gethash name *audio-sources*)
      (setf (gethash name *audio-sources*) (al:gen-source))))

(defmethod delete-source ((name symbol))
  (alexandria:when-let ((source (gethash name *audio-sources*)))
    (al:delete-source source)
    (remhash name *audio-sources*)))
(defmethod delete-source ((name number))
  (error "TODO: unimplemented!"))

(defun playing-source-p (id)
  (eq :playing (al:get-source id :source-state)))

(defun load-abuffer (path)
  (or (gethash path *audio-buffers*)
      (let ((buffer (alut:create-buffer-from-file path)))
        (when (zerop buffer)
          (error "Could not load file! Try using .wav"))
        (setf (gethash path *audio-buffers*) buffer))))

(defun init-audio ()
  (unless *audio-init*
    (alut:init)
    (setf *audio-init* t)))
