(in-package #:nepal)

;; Base class
(defclass audio ()
  ((buffers  :initarg :buffers  :reader audio-buffers)
   (paths    :initarg :paths    :reader audio-paths)
   (source   :initarg :source   :reader audio-source)
   (relative :initarg :relative :reader audio-relative)
   (name     :initarg :name     :reader audio-name))
  (:default-initargs
   :relative t
   :paths (list)
   :buffers (list)
   :source nil
   :name (gensym))
  (:documentation "bare minimun data to play a file with OpenAL"))

(defgeneric play (obj))
(defgeneric stop (obj))

;; TODO: support pattern?
(defmethod initialize-instance :after ((obj audio) &key name paths relative)
  (with-slots (buffers source) obj
    (let ((resolved (mapcar (op (load-abuffer (truename _))) paths)))
      (setf buffers resolved)
      (setf source  (init-source name))
      ;; https://www.gamedev.net/forums/topic/338053-openal-ambient-music---what-position/
      ;; make basic audio non-positional
      (al:source source :source-relative relative))))

(defun make-audio (name paths)
  (make-instance 'audio :name name :paths paths))

(defmethod play :around ((obj audio))
  "ignore order to play if source is busy"
  (let ((state (al:get-source (audio-source obj) :source-state)))
    (when (or (eq :STOPPED state)
              (eq :INITIAL state))
      (call-next-method))))

(defmethod play ((obj audio))
  "Simplest play, plays the first buffer in buffers"
  (with-accessors ((buffers audio-buffers)
                   (source  audio-source))
      obj
    (let ((buffer (first buffers)))
      (al:source source :buffer buffer)
      (al:source-play source))))

(defmethod stop ((obj audio))
  (al:source-stop (audio-source obj)))
