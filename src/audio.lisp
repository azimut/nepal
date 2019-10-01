(in-package #:incandescent)

;; Base class

(defclass audio ()
  ((buffers :initarg :buffers :accessor audio-buffers)
   (paths   :initarg :paths   :accessor audio-paths)
   (source  :initarg :source  :accessor audio-source)
   (name    :initarg :name    :accessor audio-name))
  (:default-initargs
   :paths (list)
   :buffers (list)
   :source (al:gen-source)
   :name (gensym))
  (:documentation "bare minimun data to play a file with OpenAL"))

;; TODO: support pattern?
(defmethod initialize-instance :after ((obj audio) &key)
  (with-slots (buffers paths) obj
    (let ((resolved (mapcar (op (load-abuffer (truename _))) paths)))
      (setf buffers resolved))))

(defun make-audio (name &rest paths)
  (check-type name keyword)
  (make-instance 'audio :name name :paths paths))

(defgeneric play-audio (obj))

(defmethod play-audio :around ((obj audio))
  "ignore order to play if source is busy"
  (with-slots (source) obj
    (when (eq :STOPPED (al:get-source source :source-state))
      (call-next-method))))

(defmethod play-audio ((obj audio))
  "Simplest play, plays the first buffer in buffers"
  (with-accessors ((buffers audio-buffers) (source audio-source))
      obj
    (let ((buffer (first buffers)))
      (al:source source :buffer buffer)
      (al:source-play source))))

(defmethod stop-audio ((obj audio))
  (with-slots (source) obj
    (al:source-stop source)))

#+nil
(progn (defclass foo ()
         ((field1 :initarg :field1))
         (:default-initargs
          :field1 1))
       (defclass bar (foo)
         ()
         (:default-initargs
          :field1 2))
       (defmethod ho ((obj foo))
         (print "foo"))
       (defmethod ho :around ((obj foo))
         (print "aroundfoo")
         (call-next-method))
       (defmethod ho :around ((obj bar))
         (print "aroundbar")
         (call-next-method))
       (defmethod ho ((obj bar))
         (print "bar"))
       (defmethod initialize-instance :after ((obj foo) &key)
         (with-slots (field1) obj
           (print field1))))
