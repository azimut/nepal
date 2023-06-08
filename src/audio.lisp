(in-package #:nepal)

;; Base class
;; distance models
(defclass audio ()
  ((name     :initarg :name     :reader   audio-name)
   (buffers  :initarg :buffers  :reader   audio-buffers  :documentation "ALUT audio buffers")
   (paths    :initarg :paths    :reader   audio-paths)
   (source   :initarg :source   :reader   audio-source   :documentation "OpenAL source")
   (relative :initarg :relative :reader   audio-relative :documentation "OpenAL source parameter")
   (pos      :initarg :pos      :accessor pos            :documentation "OpenAL source parameter"))
  (:default-initargs
   :pos (v! 0 0 0)  ; position in local space
   :relative t      ; make basic audio in local space, not world space
   :paths (list)
   :buffers (list)
   :source nil
   :name (gensym))
  (:documentation "bare minimun data to play a file with OpenAL"))

;; TODO: support pattern?
(defmethod initialize-instance :after ((obj audio) &key name paths relative pos)
  (with-slots (buffers source) obj
    (setf buffers (mapcar (lambda (_) (load-abuffer (truename _))) paths))
    (setf source (init-source name))
    (al:source source :position pos)
    (al:source source :source-relative relative)))

(defmethod pos ((obj audio))
  (setf (slot-value obj 'pos) (al:get-source (audio-source obj) :position)))
(defmethod (setf pos) :after (val (obj audio))
  (al:source (audio-source obj) :position val))

(defun make-audio (name paths &key (pos (v! 0 0 0)))
  (make-instance 'audio :name name :paths paths :pos pos))

(defmethod play :around ((obj audio))
  (let ((state (al:get-source (audio-source obj) :source-state)))
    (when (not (eq :PLAYING state))
      (call-next-method))))

(defmethod play ((obj audio))
  (with-slots (buffers source) obj
    (let ((buffer (alexandria:random-elt buffers)))
      (al:source source :buffer buffer)
      (al:source-play source))))

(defmethod stop ((obj audio))
  (al:source-stop (audio-source obj)))
